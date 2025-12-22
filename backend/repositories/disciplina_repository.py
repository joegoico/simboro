from supabase import Client
from models.disciplina_model import DisciplinaCreate, DisciplinaUpdate

class DisciplinaRepository:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.table = 'disciplina'

    def get_by_id(self, disciplina_id: int):
          return  self.supabase.table(self.table).select("*").eq("id_disciplina", disciplina_id).execute().data
        

    def get_by_institucion(self, institucion_id: int):
        return self.supabase.table(self.table).select("*").eq("INSTITUCION_id_institucion", institucion_id).execute().data

    def create(self, disciplina: DisciplinaCreate):
        payload = disciplina.model_dump(by_alias=True)
        return self.supabase.table(self.table).insert(payload).execute().data[0]

    def update(self, disciplina_id: int, disciplina: DisciplinaUpdate):
        payload = disciplina.model_dump(by_alias=True, exclude_unset=True)
        return self.supabase.table(self.table).update(payload).eq("id_disciplina", disciplina_id).execute().data

    def delete(self, disciplina_id: int):
        return self.supabase.table(self.table).delete().eq("id_disciplina", disciplina_id).execute().data
