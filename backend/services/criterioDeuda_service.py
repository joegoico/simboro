from fastapi import HTTPException
from repositories.criterioDeuda_repository import CriterioDeudaRepository
from models.criterioDeuda_model import CriterioDeudaCreate, CriterioDeudaUpdate
from supabase import Client

class CriterioDeudaService:
    def create(self, criterio: CriterioDeudaCreate, client: Client):
        try:
            repo = CriterioDeudaRepository(client)
            criterio_created = repo.create(criterio)
            if not criterio_created:
                raise HTTPException(status_code=400, detail="Error al crear el criterio de deuda")
            return criterio_created
        except HTTPException:  
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_by_institucion(self, institucion_id: int, client: Client):
        try:
            repo = CriterioDeudaRepository(client)
            criterios = repo.get_by_institucion(institucion_id)
            if not criterios:
                raise HTTPException(status_code=404, detail="No se encontraron criterios para esta institución")
            return criterios
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_by_id(self, criterio_id: int, client: Client):
        try:
            repo = CriterioDeudaRepository(client)
            criterio = repo.get_by_id(criterio_id)
            if not criterio:
                raise HTTPException(status_code=404, detail="Criterio no encontrado")
            return criterio
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update(self, criterio_id: int, criterio: CriterioDeudaUpdate, client: Client):
        try:
            repo = CriterioDeudaRepository(client)
            updated = repo.update(criterio_id, criterio)
            if not updated:
                raise HTTPException(status_code=404, detail="Criterio no encontrado")
            return updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    def delete(self, criterio_id: int, client: Client):
        try:
            repo = CriterioDeudaRepository(client)
            eliminado = repo.delete(criterio_id)
            if not eliminado:
                raise HTTPException(status_code=404, detail="Criterio no encontrado")
            return {"detail": "Criterio eliminado"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
