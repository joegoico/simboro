from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from models.precio_model import PrecioRead, PrecioCreate, PrecioUpdate    
from services.precios_service import PrecioService
from supabase import Client
from database.supabase_client import get_supabase_client
# Assuming Disciplina is defined in api_disciplinas.py

router = APIRouter(
    prefix="/precio",
    tags=["precio"]
)

service = PrecioService()

@router.get("/{id}", response_model=PrecioRead)
async def get_precio(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_precio_by_id(id, supabase_client)

@router.get("/disciplina/{disciplina_id}", response_model=List[PrecioRead])
async def get_precios(disciplina_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_precios_by_disciplina(disciplina_id, supabase_client)


@router.post("/", response_model=PrecioRead)
async def create_precio(precio: PrecioCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_precio(precio, supabase_client)

@router.put("/{id}", response_model=PrecioRead)
async def update_precio(id: int, precio: PrecioUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_precio(id, precio, supabase_client)

@router.delete("/{id}")
async def delete_precio(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_precio(id, supabase_client)
