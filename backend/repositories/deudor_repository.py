from supabase import Client
from models.deudor_model import DeudorCreate, DeudorUpdate

class DeudorRepository:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.table = 'deudor'

    def get_deudores(self, institucion_id: int):
        # Ejecuta la subconsulta y extrae la lista de alumnos con deuda
        return self.supabase.table(self.table).select("*").eq("institucion_id_institucion", institucion_id).execute().data

    def get_by_id(self, id: int):
        return self.supabase.table(self.table).select("*").eq("id_deudor", id).execute().data

    def create(self, deudor: DeudorCreate):
        payload = deudor.model_dump()
        return self.supabase.table(self.table).insert(payload).execute().data[0]

    def update(self, id_: int, deudor: DeudorUpdate):
        payload = deudor.model_dump(exclude_none=True)
        return self.supabase.table(self.table).update(payload).eq("id_deudor", id_).execute().data

    def delete(self, id_: int):
        return self.supabase.table(self.table).delete().eq("id_deudor", id_).execute().data

