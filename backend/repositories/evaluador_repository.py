# backend/repositories/frecuencia_repository.py
from supabase import Client
from models.evaluador_model import PeriodicidadCreate,PeriodicidadUpdate

class FrecuenciaRepository:
    def __init__(self, supabase_client: Client):
        self.client = supabase_client
        self.table = "frecuencia_mejorada"

    def get_by_institucion(self, id_institucion: int):
        return self.client.table(self.table).select("*").eq("institucion_id", id_institucion).execute().data

    def create(self, frecuencia: PeriodicidadCreate):
        payload = frecuencia.model_dump()
        payload["fecha_ultima_ejecucion"] = frecuencia.fecha_ultima_ejecucion.isoformat()  # Convert date to ISO format
        return self.client.table(self.table).insert(payload).execute().data[0]

    def update(self, id_institucion: int, frecuencia: PeriodicidadUpdate):
        payload = frecuencia.model_dump(exclude_none=True)
        payload["fecha_ultima_ejecucion"] = frecuencia.fecha_ultima_ejecucion.isoformat()  # Convert date to ISO format
        return self.client.table(self.table).update(payload).eq("institucion_id", id_institucion).execute().data
    
    def delete(self, id_institucion: int):
        return self.client.table(self.table).delete().eq("institucion_id", id_institucion).execute().data
