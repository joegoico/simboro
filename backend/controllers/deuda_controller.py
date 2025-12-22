from fastapi import APIRouter, Depends
from services.deuda_service import DeudaService
from models.deuda_model import DeudaCreate, DeudaUpdate, DeudaRead
from typing import List
from supabase import Client
from database.supabase_client import get_supabase_client

router = APIRouter(prefix="/deuda", tags=["deuda"])

service = DeudaService()

@router.get("/deudor/{deudor_id}", response_model=List[DeudaRead])
async def get_deudas_by_deudor(deudor_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_deudas_by_deudor(deudor_id, supabase_client)

@router.get("/{id}", response_model=DeudaRead)
async def get_deuda_by_id(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_deuda_by_id(id, supabase_client)

@router.post("/", status_code=201)
async def create_deuda(deuda: DeudaCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_deuda(deuda, supabase_client)

@router.put("/{id}", status_code=200)
async def update_deuda(id: int, deuda: DeudaUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_deuda(id, deuda, supabase_client)

@router.delete("/{id}", status_code=200)
async def delete_deuda(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_deuda(id, supabase_client)


