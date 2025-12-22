from fastapi import APIRouter, Depends
from typing import List
from services.ajuste_service import AjusteService
from models.ajuste_model import AjusteRead, AjusteCreate, AjusteUpdate
from supabase import Client
from database.supabase_client import get_supabase_client

router = APIRouter(prefix="/ajuste", tags=["ajuste"])
service = AjusteService()

@router.get("/{ajuste_id}", response_model=AjusteRead)
async def get_ajuste(ajuste_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_ajuste_by_id(ajuste_id, supabase_client)

@router.get("/institucion/{institucion_id}", response_model=List[AjusteRead])
async def get_ajustes_by_institucion(institucion_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_ajustes_by_institucion(institucion_id, supabase_client)

@router.post("/", response_model=AjusteRead)
async def create_ajuste(ajuste: AjusteCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_ajuste(ajuste, supabase_client)

@router.put("/{ajuste_id}", response_model=AjusteRead)
async def update_ajuste(ajuste_id: int, ajuste: AjusteUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_ajuste(ajuste_id, ajuste, supabase_client)

@router.delete("/{ajuste_id}")
async def delete_ajuste(ajuste_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_ajuste(ajuste_id, supabase_client) 