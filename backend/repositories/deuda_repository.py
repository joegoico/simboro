from models.deuda_model import DeudaCreate, DeudaUpdate
from supabase import Client

class DeudaRepository:
    def __init__(self, client: Client):
        self.supabase = client
        self.table = "deuda"

    def get_by_deudor(self, deudor_id: int):
        return self.supabase.table(self.table).select("*").eq("deudor_id", deudor_id).execute().data
    
    def get_by_id(self, id: int):
        return self.supabase.table(self.table).select("*").eq("id_deuda", id).execute().data
    
    def create(self, deuda: DeudaCreate):
        payload = deuda.model_dump(by_alias=True)
        payload['fecha_reg_deuda'] = payload['fecha_reg_deuda'].isoformat()
        return self.supabase.table(self.table).insert(payload).execute().data[0]
    
    def update(self, id: int, deuda: DeudaUpdate):
        payload = deuda.model_dump(by_alias=True, exclude_unset=True)
        if 'fecha_reg_deuda' in payload:
            payload['fecha_reg_deuda'] = payload['fecha_reg_deuda'].isoformat()
        return self.supabase.table(self.table).update(payload).eq("id_deuda", id).execute().data
    
    def delete(self, id: int):
        return self.supabase.table(self.table).delete().eq("id_deuda", id).execute().data
    
        
