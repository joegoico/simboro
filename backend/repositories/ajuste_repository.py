from models.ajuste_model import AjusteCreate,AjusteUpdate
from supabase import Client

class AjusteRepository:
    def __init__(self, client: Client):
        self.supabase = client
        self.table = 'ajuste'

    def get_by_id(self, ajuste_id: int):
        return self.supabase.table(self.table).select("*").eq("id_ajuste", ajuste_id).execute().data[0]
    
    def get_ajustes(self, institucion_id: int):
        # Ejecuta la subconsulta y extrae la lista de alumnos con deuda
        return self.supabase.table(self.table).select("*").eq("institucion_id_institucion", institucion_id).execute().data

    def create(self, ajuste: AjusteCreate):
        payload = ajuste.model_dump()
        return self.supabase.table(self.table).insert(payload).execute().data[0]

    def update(self, id_: int, ajuste: AjusteUpdate):
        payload = ajuste .model_dump(exclude_none=True)
        return self.supabase.table(self.table).update(payload).eq("id_ajuste", id_).execute().data

    def delete(self, id_: int):
        return self.supabase.table(self.table).delete().eq("id_ajuste", id_).execute().data 