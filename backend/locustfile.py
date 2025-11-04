from locust import HttpUser, task, between
import random

class APIUser(HttpUser):
    wait_time = between(1, 5) # Simula un tiempo de espera entre 1 y 5 segundos entre peticiones

    @task(3) # La tarea de obtener todos los productos se ejecutará 3 veces más que las otras
    def get_all_products(self):
        self.client.get("/products")

    @task(1)
    def get_one_product(self):
        # Selecciona un ID de producto aleatorio para simular peticiones variadas
        product_id = random.randint(1, 5)
        self.client.get(f"/products/{product_id}")

    @task(1)
    def create_a_product(self):
        # Crea un nuevo producto con un ID aleatorio y único (dentro de lo razonable para la prueba)
        new_id = random.randint(100, 1000)
        new_product = {
            "id": new_id,
            "name": f"Test Product {new_id}",
            "price": 9.99
        }
        self.client.post("/products", json=new_product)

    @task(1)
    def update_a_product(self):
        # Actualiza un producto existente (e.g., el de ID 1)
        updated_product = {
            "id": 1,
            "name": "Updated Gourmet Burger",
            "price": 16.50
        }
        self.client.put("/products/1", json=updated_product)
    
    @task(1)
    def delete_a_product(self):
        # Borra un producto existente (e.g., el de ID 2)
        self.client.delete("/products/2")