# backend/services/frecuencia_service.py
from fastapi import HTTPException
from repositories.evaluador_repository import FrecuenciaRepository
from models.evaluador_model import PeriodicidadCreate, PeriodicidadUpdate
from supabase import Client

class FrecuenciaService:

    def get_by_institucion(self, id_institucion: int, supabase_client: Client):
        try:
            frecuencia_repo = FrecuenciaRepository(supabase_client)
            frecuencia = frecuencia_repo.get_by_institucion(id_institucion)
            if not frecuencia:
                raise HTTPException(status_code=404, detail="Frecuencia no encontrada")
            return frecuencia[0]
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error al obtener la frecuencia: {str(e)}")

    def create(self, frecuencia: PeriodicidadCreate, supabase_client: Client):
        try:
            frecuencia_repo = FrecuenciaRepository(supabase_client)
            created_frecuencia = frecuencia_repo.create(frecuencia)
            if not created_frecuencia:
                raise HTTPException(status_code=400, detail="Error al crear la frecuencia") 
            return created_frecuencia
        except HTTPException as e:  
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error al crear la frecuencia: {str(e)}")

    def update(self, id_institucion: int, frecuencia: PeriodicidadUpdate, supabase_client: Client):
        try:
            frecuencia_repo = FrecuenciaRepository(supabase_client)
            updated = frecuencia_repo.update(id_institucion, frecuencia)
            if not updated:
                raise HTTPException(status_code=404, detail="Frecuencia no encontrada")
            return updated
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error al actualizar la frecuencia: {str(e)}")
    
    def delete(self, id_institucion: int, supabase_client: Client):
        try:
            frecuencia_repo = FrecuenciaRepository(supabase_client)
            deleted = frecuencia_repo.delete(id_institucion)
            if not deleted:
                raise HTTPException(status_code=404, detail="Frecuencia no encontrada")
            return {"detail": "Frecuencia eliminada exitosamente"}
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error al eliminar la frecuencia: {str(e)}")
