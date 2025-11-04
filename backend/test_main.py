from fastapi.testclient import TestClient
from main import app  # Importa tu instancia de FastAPI

client = TestClient(app)

def test_read_products():
    #Prueba para verificar la obtención de todos los productos.
    response = client.get("/products")
    assert response.status_code == 200
    assert response.json() == [
        {"id": 1, "name": "Gourmet Burger", "price": 15.00, "image_url": "https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"},
        {"id": 2, "name": "Fresh Salad", "price": 12.50, "image_url": "https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"},
        {"id": 3, "name": "Ceviche", "price": 22.00, "image_url": "https://cdn3.photostockeditor.com/c/2301/restaurant-cooked-food-on-blue-ceramic-plate-tuna fish-tuna fish-image.jpg"},
        {"id": 4, "name": "Pizza Pepperoni", "price": 18.00, "image_url": "https://images.pexels.com/photos/2147491/pexels-photo-2147491.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"},
        {"id": 5, "name": "Tacos al Pastor", "price": 10.00, "image_url": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"},
    ]

def test_read_product_id():
    #Prueba para verificar la obtención de un producto específico por ID.
    response = client.get("/products/1")
    assert response.status_code == 200
    assert response.json() == {"id": 1, "name": "Gourmet Burger", "price": 15.00, "image_url": "https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"}

def test_read_product_not_found():
    #Prueba para verificar el manejo de un producto no encontrado.
    response = client.get("/products/999")
    assert response.status_code == 404
    assert response.json() == {"detail": "Product not found"}

def test_create_product():
    #Prueba para verificar la creación de un nuevo producto.
    new_product = {"id": 6, "name": "Sushi Roll", "price": 16.50, "image_url": None}
    response = client.post("/products", json=new_product)
    assert response.status_code == 200
    assert response.json() == new_product

def test_create_product_duplicate_id():
    #Prueba para verificar el manejo de un ID de producto duplicado al crear.
    duplicate_product = {"id": 1, "name": "Another Burger", "price": 20.00}
    response = client.post("/products", json=duplicate_product)
    assert response.status_code == 400
    assert response.json() == {"detail": "Product ID already exists"}

def test_update_product():
    #Prueba para verificar la actualización de un producto existente.
    updated_product_data = {"id": 1, "name": "Gourmet Burger Updated", "price": 17.00, "image_url": None}
    response = client.put("/products/1", json=updated_product_data)
    assert response.status_code == 200
    assert response.json() == updated_product_data

def test_update_product_not_found():
    #Prueba para verificar el manejo de un producto no encontrado al actualizar.
    non_existent_product_data = {"id": 999, "name": "Fake Product", "price": 1.00}
    response = client.put("/products/999", json=non_existent_product_data)
    assert response.status_code == 400
    assert response.json() == {"detail": "Product not found"}

def test_update_product_id_mismatch():
    #Prueba para verificar el manejo de discrepancia de IDs al actualizar.
    mismatched_product_data = {"id": 2, "name": "Wrong ID Product", "price": 10.00}
    response = client.put("/products/1", json=mismatched_product_data)
    assert response.status_code == 400
    assert response.json() == {"detail": "ID Product not coincide"}

def test_delete_product():
    #Prueba para verificar la eliminación de un producto.
    response = client.delete("/products/2")
    assert response.status_code == 200
    assert response.json() == {"id": 2, "name": "Fresh Salad", "price": 12.50, "image_url": "https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"}

def test_delete_product_not_found():
    #Prueba para verificar el manejo de un producto no encontrado al eliminar.
    response = client.delete("/products/999")
    assert response.status_code == 400
    assert response.json() == {"detail": "Product not found"}