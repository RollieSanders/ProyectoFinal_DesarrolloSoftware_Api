# ----------------------------------------------------
# 4B. MAIN.TF - Infraestructura AWS
# ----------------------------------------------------

# 1. Proveedor de AWS
provider "aws" {
  region = var.aws_region
}

# 2. Red (VPC, Subredes, Internet Gateway)
# Usaremos un módulo simple para crear una VPC con subredes públicas y privadas
# Se recomienda usar el módulo VPC de la comunidad para producción, pero este esqueleto es funcional.

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route table para subredes públicas (necesaria para acceso a Internet desde subnets públicas)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Asociaciones de route table a las subredes públicas
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Subredes Públicas (donde irá el ALB)
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index] # Asignación de AZ

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

# Data source para obtener AZs disponibles en la región
data "aws_availability_zones" "available" {
  state = "available"
}


# 3. AWS ECR (Container Registry)

# Repositorio para el Frontend
resource "aws_ecr_repository" "frontend" {
  name = var.frontend_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Repositorio para el Backend
resource "aws_ecr_repository" "backend" {
  name = var.backend_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 4. Roles IAM para ECS/Fargate (Ejecución y Tarea)

# Rol para que Fargate pueda extraer imágenes y manejar logs
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Política de acceso de ejecución (Logs, ECR)
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Rol de la Tarea (para permisos dentro del contenedor, ej: acceso a RDS/S3, etc.)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}


# 5. ECS Cluster (El entorno de orquestación)

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}


# 6. ECS Task Definition (La plantilla de nuestros contenedores)

# Nota: Usamos la plantilla JSON creada previamente (ecs_task_definition.json.tpl)
# Las URIs de las imágenes se pasarán desde GitHub Actions durante el despliegue.

data "template_file" "ecs_task_definition" {
  template = file("${path.module}/ecs_task_definition.json.tpl")

  vars = {
    family                 = "${var.project_name}-task-definition"
    aws_region             = var.aws_region
    ecs_execution_role_arn = aws_iam_role.ecs_execution_role.arn
    ecs_task_role_arn      = aws_iam_role.ecs_task_role.arn
    
    # Valores de imagen por defecto, reemplazados por el pipeline de GitHub Actions
    frontend_image_uri     = "nginx:latest" 
    backend_image_uri      = "python:latest"
    
    # El endpoint de la base de datos se debe proporcionar mediante la variable
    # `db_endpoint`. En despliegues automatizados, pásalo desde Terraform vars
    # o desde el pipeline CI/CD (GitHub Actions).
    db_endpoint            = var.db_endpoint
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task-definition"
  # The template file contains the full task-definition JSON; extract the
  # "containerDefinitions" array and re-encode it so Terraform receives the
  # expected JSON array for container_definitions.
  container_definitions    = jsonencode(jsondecode(data.template_file.ecs_task_definition.rendered).containerDefinitions)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}


# 7. Application Load Balancer (ALB) y Listener (Punto de entrada)
# [Faltan recursos clave como: Security Groups, Target Groups, Listener y el ECS Service]
# Solo incluimos el esqueleto del ALB y el Service para mantener la presentación.

resource "aws_lb" "main" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

# Target Group para el Frontend (Fargate usa target_type = "ip")
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-tg-frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener HTTP que apunta al target group frontend
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Grupo de logs para los contenedores ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 14
}

# --- Grupo de Seguridad para el ALB (permite tráfico web)
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite tráfico desde cualquier lugar
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todo el tráfico
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg" }
}

# 8. ECS Service (Mantiene las tareas en ejecución)

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1 # Puedes escalar esto
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate.id]
    subnets          = aws_subnet.public[*].id # Idealmente subredes privadas
    assign_public_ip = true
  }
  
  # Este bloque vincula el servicio al ALB (Requiere Target Group creado previamente)
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn # DEBE EXISTIR
    container_name   = "frontend-container"
    container_port   = 80
  }
}

# --- Grupo de Seguridad para Fargate (permite tráfico desde el ALB)
resource "aws_security_group" "fargate" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id] # Solo permite tráfico desde el ALB
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    # Permitir tráfico desde el ALB (o ajustar según arquitectura interna)
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-fargate-sg" }
}