from repositories.deuda_repository import DeudaRepository
from fastapi import HTTPException
from models.deuda_model import DeudaCreate, DeudaUpdate
from supabase import Client

class DeudaService:
    def get_deudas_by_deudor(self, deudor_id: int, client: Client):
        try:
            repo = DeudaRepository(client)
            deudas = repo.get_by_deudor(deudor_id)
            if not deudas:
                raise HTTPException(status_code=404, detail="No se encontraron deudas")
            return deudas
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def get_deuda_by_id(self, id: int, client: Client):
        try:
            repo = DeudaRepository(client)
            deuda = repo.get_by_id(id)
            if not deuda:
                raise HTTPException(status_code=404, detail="Deuda no encontrada")
            return deuda
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def create_deuda(self, deuda: DeudaCreate, client: Client):
        try:
            repo = DeudaRepository(client)
            created_deuda = repo.create(deuda)
            if not created_deuda:
                raise HTTPException(status_code=400, detail="Error al crear la deuda")
            return created_deuda
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def update_deuda(self, id: int, deuda: DeudaUpdate, client: Client):
        try:
            repo = DeudaRepository(client)
            updated_deuda = repo.update(id, deuda)
            if not updated_deuda:
                raise HTTPException(status_code=400, detail="Error al actualizar la deuda")
            return updated_deuda
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def delete_deuda(self, id: int, client: Client):
        try:
            repo = DeudaRepository(client)
            deleted_deuda = repo.delete(id)
            if not deleted_deuda:
                raise HTTPException(status_code=400, detail="Error al eliminar la deuda")
            return deleted_deuda
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
        
        
