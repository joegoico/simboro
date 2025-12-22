from fastapi import APIRouter, Depends
from typing import List
from services.alumno_service import AlumnoService
from models.alumno_model import AlumnoRead, AlumnoCreate, AlumnoUpdate
from supabase import Client
from database.supabase_client import get_supabase_client

router = APIRouter(prefix="/alumno", tags=["alumno"])
service = AlumnoService()

@router.get("/", response_model=List[AlumnoRead])
def list_alumnos(supabase_client: Client = Depends(get_supabase_client)):
    return service.get_alumnos(supabase_client)

@router.get("/{alumno_id}", response_model=AlumnoRead)
def get_alumno(alumno_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_alumno(alumno_id, supabase_client)


@router.get("/institucion/{institucion_id}", response_model=List[AlumnoRead])
def list_by_institucion(institucion_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_alumnos_by_institucion(institucion_id, supabase_client)

@router.post("/", status_code=201)
def create_alumno(alumno: AlumnoCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_alumno(alumno, supabase_client)

@router.put("/{alumno_id}", status_code=200)
def update_alumno(alumno_id: int, alumno: AlumnoUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_alumno(alumno_id, alumno, supabase_client)

@router.delete("/{alumno_id}")
def delete_alumno(alumno_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_alumno(alumno_id, supabase_client)
