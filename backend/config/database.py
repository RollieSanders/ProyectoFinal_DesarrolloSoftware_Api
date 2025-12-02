import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

db_config = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_DATABASE")
}

def get_db_connection():
    # ... (código de conexión) ...
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"Error de conexión a MySQL: {err}")
        return None

def execute_query(query, params=None, fetch=True):
    # ... (código de ejecución de consultas) ...
    conn = get_db_connection()
    if conn is None:
        raise Exception("No se pudo establecer la conexión a la base de datos.")
    
    cursor = conn.cursor(dictionary=True)
    result = None
    
    try:
        cursor.execute(query, params or ())
        
        if query.strip().upper().startswith(("INSERT", "UPDATE", "DELETE")):
            conn.commit()
            if query.strip().upper().startswith("INSERT"):
                result = cursor.lastrowid
            else:
                result = cursor.rowcount 
        elif fetch:
            result = cursor.fetchall()
            
    except mysql.connector.Error as err:
        conn.rollback()
        raise Exception(f"Error al ejecutar la consulta: {err}")
    finally:
        cursor.close()
        conn.close()
        
    return result

def initialize_database():
    """
    Crea la tabla 'products' e inserta los datos iniciales 
    solo si la tabla está vacía.
    """
    
    # 1. Definición de la estructura de la tabla y los datos iniciales
    CREATE_TABLE_QUERY = """
    CREATE TABLE IF NOT EXISTS products (
        id INT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        image_url VARCHAR(500)
    );
    """
    # IMPORTANTE: Usamos el ID de tus datos estáticos (1, 2, 3, etc.)
    # Por lo tanto, el campo 'id' NO es AUTO_INCREMENT.
    INITIAL_PRODUCTS = [
        (1, "Gourmet Burger", 15.00, "https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
        (2, "Fresh Salad", 12.50, "https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
        (3, "Ceviche", 22.00, "https://cdn3.photostockeditor.com/c/2301/restaurant-cooked-food-on-blue-ceramic-plate-tuna fish-tuna fish-image.jpg"),
        (4, "Pizza Pepperoni", 18.00, "https://images.pexels.com/photos/2147491/pexels-photo-2147491.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
        (5, "Tacos al Pastor", 10.00, "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
    ]
    INSERT_QUERY = """
    INSERT INTO products (id, name, price, image_url) 
    VALUES (%s, %s, %s, %s)
    """

    try:
        # 2. Intentar crear la tabla (CREATE TABLE IF NOT EXISTS)
        execute_query(CREATE_TABLE_QUERY, fetch=False)
        print("✅ Tabla 'products' verificada/creada.")
        
        # 3. Verificar si la tabla ya tiene datos
        count_query = "SELECT COUNT(*) FROM products"
        count_result = execute_query(count_query, fetch=True)
        product_count = count_result[0]['COUNT(*)'] if count_result else 0

        if product_count == 0:
            # 4. Insertar datos iniciales si está vacía
            conn = get_db_connection()
            if conn is None:
                 raise Exception("No se pudo establecer la conexión para inserción inicial.")
            
            cursor = conn.cursor()
            cursor.executemany(INSERT_QUERY, INITIAL_PRODUCTS)
            conn.commit()
            cursor.close()
            conn.close()
            print(f"Se insertaron {len(INITIAL_PRODUCTS)} productos iniciales.")
        else:
            print(f"La tabla 'products' ya contiene {product_count} registros. Omite la inserción inicial.")

    except Exception as e:
        print(f"❌ Error al inicializar la base de datos: {e}")