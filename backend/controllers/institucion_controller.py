from fastapi import APIRouter, Depends
from supabase import Client
from database.supabase_client import get_supabase_client
from services.institucion_service import InstitucionService
from models.institucion_model import InstitucionCreate, InstitucionRead, InstitucionUpdate


router = APIRouter(prefix="/institucion", tags=["institucion"])
service = InstitucionService()


@router.get("/{id}", response_model=InstitucionRead)
async def get_institucion(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.get_institucion_by(id, supabase_client)

@router.post("/")
async def create_institucion(
    institucion: InstitucionCreate,
    # Pídele a FastAPI que ejecute la dependencia y te dé el resultado
    supabase_client: Client = Depends(get_supabase_client)
):
    # Pasa el cliente YA AUTENTICADO al servicio
    return service.create(institucion, supabase_client)

@router.put("/{id}")
async def update_institucion(id: int, institucion: InstitucionUpdate, supabase_client: Client = Depends(get_supabase_client)):
    return service.update(id, institucion, supabase_client)

@router.delete("/{id}")
async def delete_institucion(id: int, supabase_client: Client = Depends(get_supabase_client)):
    return service.delete(id, supabase_client)

