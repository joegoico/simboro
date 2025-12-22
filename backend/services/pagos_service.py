from fastapi import HTTPException
from repositories.pagos_repository import PagoRepository
from models.pagos_model import PagoCreate, PagoUpdate, PagoRead
from datetime import datetime
from supabase import Client

class PagoService:

    def get_by_id_pago(self, pago_id: int, supabase_client: Client):
        try:
            pago_repo = PagoRepository(supabase_client)
            pago = pago_repo.get_by_id(pago_id)
            if not pago:
                raise HTTPException(status_code=404, detail="Pago no encontrado")
            return pago[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_pagos_by_alumno(self, alumno_id: int, supabase_client: Client):
        try:
            pago_repo = PagoRepository(supabase_client)
            pagos = pago_repo.get_by_alumno(alumno_id)
            if not pagos:
                raise HTTPException(status_code=404, detail="No se encontraron pagos")
            return pagos
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def create_pago(self, pago: PagoCreate, supabase_client: Client):
        try:
            pago_repo = PagoRepository(supabase_client)
            created = pago_repo.create(pago)
            if not created:
                raise HTTPException(status_code=400, detail="Error al crear el pago")

            return created[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update_pago(self, pago_id: int, pago: PagoUpdate, supabase_client: Client):
        try:
            pago_repo = PagoRepository(supabase_client)
            updated = pago_repo.update(pago_id, pago)
            if not updated:
                raise HTTPException(status_code=404, detail="Pago no encontrado")
            return updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def delete_pago(self, pago_id: int, supabase_client: Client):
        try:
            pago_repo = PagoRepository(supabase_client)
            deleted = pago_repo.delete(pago_id)
            if not deleted:
                raise HTTPException(status_code=404, detail="Pago no encontrado")
            return {"detail": "Pago eliminado correctamente"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
