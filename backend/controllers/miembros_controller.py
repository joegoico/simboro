# backend/controllers/miembro_controller.py
from fastapi import APIRouter, Depends, status, HTTPException
from supabase import Client
from database.dependencies import get_token_from_header
from database.supabase_client import get_supabase_client
from typing import List
from services.miembros_service import MiembrosService
from models.miembros_model import (
    MiembroCreate, 
    MiembroRead, 
    MiembroUpdate,
    UserStatusResponse
)

router = APIRouter(prefix="/miembros", tags=["miembros"])

# Instanciamos el servicio (Como es "stateless" y no tiene __init__, esto está bien)
service = MiembrosService()

@router.get("/{user_id}", response_model=MiembroRead)
async def get_miembro(
    user_id: str,
    supabase_client: Client = Depends(get_supabase_client)
):
    """Obtener un miembro por su ID"""
    # CORRECCIÓN 1: Llamamos solo UNA vez y guardamos el resultado
    miembro = service.get_miembro_by_id(user_id, supabase_client)
    
    # print(f"Debug: {miembro}") # Descomentar solo para debug local
    
    return miembro

@router.get("/status", response_model=UserStatusResponse)
async def get_miembro_status(
    supabase_client: Client = Depends(get_supabase_client),
    token: str = Depends(get_token_from_header)
):
    """Obtener el status del usuario"""
    return service.get_miembro_status(supabase_client, token)

@router.get("/institucion/{institucion_id}", response_model=List[MiembroRead])
async def get_miembros_from_institucion(
    institucion_id: int, # Simplifiqué el nombre del parámetro
    supabase_client: Client = Depends(get_supabase_client)
):
    """Obtener miembros de una institución"""
    # La verificación de seguridad la hace Supabase con RLS usando el token del client
    return service.get_miembros_by_inst(institucion_id, supabase_client)

@router.post("/", response_model=MiembroRead, status_code=status.HTTP_201_CREATED)
async def create_miembro(
    miembro: MiembroCreate, 
    supabase_client: Client = Depends(get_supabase_client)
):
    """Crear un nuevo miembro"""
    return service.create_miembro(miembro, supabase_client)

# CORRECCIÓN 2: El response_model debe ser MiembroRead (lo que devuelves), no Update (lo que recibes)
@router.put("/{user_id}", response_model=MiembroRead)
async def update_miembro(
    user_id: str, 
    miembro_update: MiembroUpdate, 
    supabase_client: Client = Depends(get_supabase_client)
):
    """Actualizar un miembro""" 
    return service.update_miembro(user_id, miembro_update, supabase_client)
    
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_miembro(
    user_id: str, 
    supabase_client: Client = Depends(get_supabase_client)
):
    """Eliminar un miembro"""
    service.delete_miembro(user_id, supabase_client)
    # No es necesario retornar nada explícito en un 204
    return