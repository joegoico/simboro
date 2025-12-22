from fastapi import APIRouter, Depends
from models.deudor_model import DeudorCreate, DeudorUpdate
from services.deudor_service import DeudorService
from supabase import Client
from database.supabase_client import get_supabase_client

service = DeudorService()

router = APIRouter(prefix="/deudor", tags=["deudor"])


@router.get("/institucion/{institucion_id}")
def get_deudores(institucion_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_deudores(institucion_id, supabase_client)

@router.get("/{id}")
def get_by_id(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_by_id(id, supabase_client)

@router.post("/")
def create(deudor: DeudorCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create(deudor, supabase_client)

@router.put("/{id}")
def update(id: int, deudor: DeudorUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update(id, deudor, supabase_client)

@router.delete("/{id}")
def delete(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete(id, supabase_client)
