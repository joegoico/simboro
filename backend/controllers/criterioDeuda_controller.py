from fastapi import APIRouter, Depends
from supabase import Client
from database.supabase_client import get_supabase_client
from models.criterioDeuda_model import CriterioDeudaCreate, CriterioDeudaRead, CriterioDeudaUpdate
from services.criterioDeuda_service import CriterioDeudaService

router = APIRouter(prefix="/criterio_deuda", tags=["criterio deuda"])
service = CriterioDeudaService()

@router.post("/", response_model=CriterioDeudaRead, status_code=201)
def create(criterio: CriterioDeudaCreate, supabase_client: Client = Depends(get_supabase_client)):
    return service.create(criterio, supabase_client)

@router.get("/institucion/{institucion_id}", response_model=list[CriterioDeudaRead])
def get_by_institucion(institucion_id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_by_institucion(institucion_id, supabase_client)

@router.get("/{id}", response_model=CriterioDeudaRead)
def get_criterio(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_by_id(id, supabase_client)

@router.put("/{id}", response_model=CriterioDeudaRead)
def update(id: int, criterio: CriterioDeudaUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update(id, criterio, supabase_client)

@router.delete("/{id}")
def delete(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete(id, supabase_client)
