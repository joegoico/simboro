from fastapi import APIRouter, Depends
from typing import List
from models.pagos_model import PagoRead, PagoCreate, PagoUpdate
from services.pagos_service import PagoService
from fastapi.encoders import jsonable_encoder
from supabase import Client
from database.supabase_client import get_supabase_client

router = APIRouter(
    prefix="/pago",
    tags=["pago"]
)

service = PagoService()

@router.get("/{id_pago}", response_model=PagoRead)
async def get_pago(id_pago: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_by_id_pago(id_pago, supabase_client)

@router.get("/alumno/{id_alumno}", response_model=List[PagoRead])
async def get_pagos(id_alumno: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_pagos_by_alumno(id_alumno, supabase_client)

@router.post("/", response_model=PagoRead)
async def create_pago(pago: PagoCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_pago(pago, supabase_client)

@router.put("/{id}")
async def update_pago(id: int, pago: PagoUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_pago(id, pago, supabase_client)

@router.delete("/{id}")
async def delete_pago(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_pago(id, supabase_client)


