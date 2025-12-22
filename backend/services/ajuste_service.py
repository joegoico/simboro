from fastapi import HTTPException
from repositories.ajuste_repository import AjusteRepository
from models.ajuste_model import AjusteCreate, AjusteUpdate, AjusteRead
from supabase import Client

class AjusteService:

    def get_ajuste_by_id(self, ajuste_id: int, client: Client):
        try:
            repo = AjusteRepository(client)
            ajuste = repo.get_by_id(ajuste_id)
            if not ajuste:
                raise HTTPException(status_code=404, detail="Ajuste no encontrado")
            return ajuste
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_ajustes_by_institucion(self, institucion_id: int, client: Client):
        try:
            repo = AjusteRepository(client)
            ajustes = repo.get_ajustes(institucion_id)
            if not ajustes:
                raise HTTPException(status_code=404, detail="No se encontraron ajustes")
            return ajustes
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def create_ajuste(self, ajuste: AjusteCreate, client: Client):
        try:
            repo = AjusteRepository(client)
            created = repo.create(ajuste)
            if not created:
                raise HTTPException(status_code=400, detail="Error al crear el ajuste")
            return created
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update_ajuste(self, ajuste_id: int, ajuste: AjusteUpdate, client: Client):
        try:
            repo = AjusteRepository(client)
            updated = repo.update(ajuste_id, ajuste)
            if not updated:
                raise HTTPException(status_code=404, detail="Ajuste no encontrado")
            return updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def delete_ajuste(self, ajuste_id: int, client: Client):
        try:
            repo = AjusteRepository(client)
            deleted = repo.delete(ajuste_id)
            if not deleted:
                raise HTTPException(status_code=404, detail="Ajuste no encontrado")
            return {"detail": "Ajuste eliminado correctamente"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
