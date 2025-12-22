from fastapi import HTTPException
from models.deudor_model import DeudorCreate, DeudorUpdate
from repositories.deudor_repository import DeudorRepository
from supabase import Client

class DeudorService:
    def get_deudores(self, institucion_id: int, supabase_client: Client):
        try:
            deudores_repo = DeudorRepository(supabase_client)
            deudores = deudores_repo.get_deudores(institucion_id)
            if not deudores:
                raise HTTPException(status_code=404, detail="No se encontraron deudores")
            return deudores
        except HTTPException:
            raise

    def get_by_id(self, id_: int, supabase_client: Client):
        try:
            deudor_repo = DeudorRepository(supabase_client)
            deudor = deudor_repo.get_by_id(id_)
            if not deudor:
                raise HTTPException(status_code=404, detail="Deudor no encontrado")
            return deudor
        except HTTPException:
            raise 
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    

    def create(self, deudor: DeudorCreate, supabase_client: Client):
        try:
            deudor_repo = DeudorRepository(supabase_client)
            created = deudor_repo.create(deudor)
            if not created:
                raise HTTPException(status_code=400, detail="Error al crear el deudor")
            return created
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update(self, id_: int, deudor: DeudorUpdate, supabase_client: Client):
        try:
            deudor_repo = DeudorRepository(supabase_client)
            updated = deudor_repo.update(id_, deudor)
            if not updated:
                raise HTTPException(status_code=404, detail="Deudor no encontrado")
            return updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def delete(self, id_: int, supabase_client: Client):
        try:
            deudor_repo = DeudorRepository(supabase_client)
            deleted = deudor_repo.delete(id_)
            if not deleted:
                raise HTTPException(status_code=404, detail="Deudor no encontrado")
            return deleted[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
