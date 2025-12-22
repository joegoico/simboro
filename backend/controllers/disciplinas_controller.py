from fastapi import APIRouter, Depends
from typing import List
from services.disciplina_service import DisciplinaService
from models.disciplina_model import DisciplinaRead, DisciplinaCreate, DisciplinaUpdate
from supabase import Client
from database.supabase_client import get_supabase_client

router = APIRouter(prefix="/disciplina", tags=["disciplina"])
service = DisciplinaService()

@router.get("/institucion/{institucion_id}", response_model=List[DisciplinaRead])
def get_disciplinas_by_institucion(institucion_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_disciplinas_by_institucion(institucion_id, supabase_client)

@router.get("/{disciplina_id}", response_model=DisciplinaRead)
def get_disciplina_by_id(disciplina_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_disciplina_by_id(disciplina_id, supabase_client)

@router.post("/", response_model=DisciplinaRead)
def create_disciplina(disciplina: DisciplinaCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create_disciplina(disciplina, supabase_client)

@router.put("/{disciplina_id}", response_model=DisciplinaRead)
def update_disciplina(disciplina_id: int, disciplina: DisciplinaUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update_disciplina(disciplina_id, disciplina, supabase_client)

@router.delete("/{disciplina_id}")
def delete_disciplina(disciplina_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete_disciplina(disciplina_id, supabase_client)
