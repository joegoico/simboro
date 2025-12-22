from models.precio_model import PrecioBase, PrecioCreate, PrecioUpdate, PrecioRead
from supabase import Client


class PrecioRepository:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.table = 'precio'

    def get_by_id(self, precio_id: int):
        return (self.supabase.table(self.table).select("*").eq("id_precio", precio_id).execute().data)

    def get_by_disciplina(self, disciplina_id: int):
        return self.supabase.table(self.table).select("*").eq("DISCIPLINA_id_disciplina", disciplina_id).execute().data
    
    def create(self, precio: PrecioCreate):
        payload = precio.model_dump(by_alias=True)
        return (self.supabase.table(self.table).insert(payload).execute().data)
    
    def update(self, precio_id: int, precio: PrecioUpdate):
        payload = precio.model_dump(by_alias=True)
        return (self.supabase.table(self.table).update(payload).eq("id_precio", precio_id).execute().data)
    
    def delete(self, precio_id: int):
        return (self.supabase.table(self.table).delete().eq("id_precio", precio_id).execute().data)
        
