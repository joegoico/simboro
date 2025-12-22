from models.pagos_model import PagoCreate, PagoUpdate, PagoRead
from supabase import Client

class PagoRepository:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.table = 'pago'

    def get_by_id(self, pago_id: int):
        return self.supabase.table(self.table).select("*").eq("id_pago", pago_id).execute().data

    def get_by_alumno(self, alumno_id: int):
        return self.supabase.table(self.table).select("*").eq("alumno_id_alumno", alumno_id).execute().data

    def create(self, pago: PagoCreate):
        payload = pago.model_dump(by_alias=True)
        payload['fecha_de_pago'] = payload['fecha_de_pago'].isoformat()
        res = self.supabase.table(self.table).insert(payload).execute().data
        return res

    def update(self, pago_id: int, pago: PagoUpdate):
        payload = pago.model_dump(by_alias=True, exclude_none=True)
        if 'fecha_de_pago' in payload:
            payload['fecha_de_pago'] = payload['fecha_de_pago'].isoformat()
        return self.supabase.table(self.table).update(payload).eq("id_pago", pago_id).execute().data

    def delete(self, pago_id: int):
        return self.supabase.table(self.table).delete().eq("id_pago", pago_id).execute().data

