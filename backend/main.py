from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from fastapi.middleware.cors import CORSMiddleware
from config.database import execute_query, initialize_database # <--- ¡CAMBIO AQUÍ!
import mysql.connector

app = FastAPI()

origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "https://cart-proy-idat.netlify.app/",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins = ["*"],
    allow_credentials = True,
    allow_methods = ["*"],
    allow_headers = ["*"]
)

class Product(BaseModel):
    id:int
    name:str
    price:float
    image_url:Optional[str] = None

products = [
    Product(id = 1, name="Gourmet Burger", price=15.00, image_url="https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
    Product(id = 2, name="Fresh Salad", price=12.50, image_url="https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
    Product(id = 3, name="Ceviche", price=22.00, image_url="https://cdn3.photostockeditor.com/c/2301/restaurant-cooked-food-on-blue-ceramic-plate-tuna fish-tuna fish-image.jpg"),
    Product(id = 4, name="Pizza Pepperoni", price=18.00, image_url="https://images.pexels.com/photos/2147491/pexels-photo-2147491.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
    Product(id = 5, name="Tacos al Pastor", price=10.00, image_url="https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&dpr=1"),
]

# --- Función de Inicialización al Inicio de la App ---
@app.on_event("startup")
async def startup_event():
    """Ejecuta la inicialización de la base de datos al iniciar la API."""
    initialize_database()

@app.get("/products", response_model = List[Product])
# response_model = List[Product] : Indica que la respuesta sera una lista de objetos de tipo Product
async def get_products():
    """Obtiene todos los productos de la base de datos."""
    try:
        query = "SELECT id, name, price, image_url FROM products"
        # La función execute_query se llama igual, solo cambió la importación.
        db_products = execute_query(query) 
        return db_products
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error DB al obtener productos: {e}")

@app.get("/products/{product_id}", response_model= Product)
async def get_product(product_id:int):
    product = next( (p for p in products if p.id == product_id), None )
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@app.post("/products", response_model=Product)
async def create_product(product:Product):
    if any(p.id == product.id for p in products):
        raise HTTPException(status_code=400, detail="Product ID already exists")
    products.append(product)
    return product

@app.put("/products/{product_id}", response_model=Product)
async def update_product(product_id:int, product:Product):
    index = next( ( i for i, p in enumerate(products) if p.id == product_id ), None)
    if index is None:
        raise HTTPException(status_code=400, detail="Product not found")    
    
    
    if products[index].id != product.id:
        raise HTTPException(status_code=400, detail="ID Product not coincide")
    
    products[index] = product
    return product

@app.delete("/products/{product_id}", response_model=Product)
async def delete_product(product_id:int):
    index = next( ( i for i, p in enumerate(products) if p.id == product_id ), None)
    if index is None:
        raise HTTPException(status_code=400, detail="Product not found")    
    delete_product = products.pop(index)
    return delete_product