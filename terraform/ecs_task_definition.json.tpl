{
  "family": "${family}",
  "networkMode": "awsvpc",
  "cpu": "512",
  "memory": "1024",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "executionRoleArn": "${ecs_execution_role_arn}",
  "taskRoleArn": "${ecs_task_role_arn}",
  "containerDefinitions": [
    {
      "name": "frontend-container",
      "image": "${frontend_image_uri}",
      "cpu": 0,
      "memoryReservation": 128,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/proyectofinal",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "frontend"
        }
      }
    },
    {
      "name": "backend-container",
      "image": "${backend_image_uri}",
      "cpu": 0,
      "memoryReservation": 512,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/proyectofinal",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "backend"
        }
      },
      "environment": [
        {
          "name": "DB_HOST",
          "value": "${db_endpoint}" 
        }
      ]
    }
  ]
}