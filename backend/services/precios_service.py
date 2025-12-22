from repositories.precios_repository import PrecioRepository
from fastapi import HTTPException
from models.precio_model import PrecioCreate, PrecioUpdate
from supabase import Client 
class PrecioService:

    def get_precio_by_id(self, precio_id: int, supabase_client: Client):
        try:
            precio_repo = PrecioRepository(supabase_client)
            precio = precio_repo.get_by_id(precio_id)
            if not precio:
                raise HTTPException(status_code=404, detail="Precio no encontrado")
            return precio[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def get_precios_by_disciplina(self, disciplina_id: int, supabase_client: Client):
        try:
            precio_repo = PrecioRepository(supabase_client)
            precios = precio_repo.get_by_disciplina(disciplina_id)
            if not precios:
                raise HTTPException(status_code=404, detail="No se encontraron precios")
            return precios
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def create_precio(self, precio: PrecioCreate, supabase_client: Client):
        try:
            precio_repo = PrecioRepository(supabase_client)
            precio_created = precio_repo.create(precio)
            if not precio_created:
                raise HTTPException(status_code=404, detail="Precio no creado")
            return precio_created[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def update_precio(self, precio_id: int, precio: PrecioUpdate, supabase_client: Client):
        try:
            precio_repo = PrecioRepository(supabase_client)
            updated = precio_repo.update(precio_id, precio)
            if not updated:
                raise HTTPException(status_code=404, detail="Precio no encontrado")
            return updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def delete_precio(self, precio_id: int, supabase_client: Client):
        try:
            precio_repo = PrecioRepository(supabase_client)
            deleted = precio_repo.delete(precio_id)
            if not deleted:
                raise HTTPException(status_code=404, detail="Precio no encontrado")
            return {"detail": "Precio eliminado correctamente"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
