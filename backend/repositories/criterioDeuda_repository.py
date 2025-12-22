from models.criterioDeuda_model import CriterioDeudaCreate, CriterioDeudaUpdate
from supabase import Client

class CriterioDeudaRepository:
    def __init__(self, client: Client):
        self.table = "criterio_deuda"
        self.supabase = client

    def create(self, criterio: CriterioDeudaCreate):
        payload = criterio.model_dump(exclude_none=True)
        return self.supabase.table(self.table).insert(payload).execute().data[0]

    def get_by_institucion(self, institucion_id: int):
        return self.supabase.table(self.table).select("*").eq("institucion_id_institucion", institucion_id).execute().data[0]

    def get_by_id(self, criterio_id: int):
        return self.supabase.table(self.table).select("*").eq("id_criterio", criterio_id).execute().data[0]

    def update(self, criterio_id: int, criterio: CriterioDeudaUpdate):
        payload = criterio.model_dump(exclude_none=True)
        return self.supabase.table(self.table).update(payload).eq("id_criterio", criterio_id).execute().data

    def delete(self, criterio_id: int):
        return self.supabase.table(self.table).delete().eq("id_criterio", criterio_id).execute().data
