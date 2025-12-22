from supabase import Client
from models.alumno_model import AlumnoCreate, AlumnoUpdate

class AlumnoRepository:
    def __init__(self, client: Client):
        self.client = client
        self.table = 'alumno'

    def get_all(self):
        res = self.client.table(self.table).select("*").execute()
        return res.data
    
    def get_by_id(self, alumno_id: int):
        return self.client.table(self.table).select("*").eq("id_alumno", alumno_id).execute().data

    def get_by_institucion(self, institucion_id: int):
        return self.client.table(self.table).select("*").eq("INSTITUCION_id_institucion", institucion_id).execute().data

    def create(self, alumno: AlumnoCreate):
        payload = alumno.model_dump(by_alias=True)
        return self.client.table(self.table).insert(payload).execute().data[0]

    def update(self, alumno_id: int, alumno: AlumnoUpdate):
        payload = alumno.model_dump(by_alias=True, exclude_unset=True)
        return self.client.table(self.table).update(payload).eq("id_alumno", alumno_id).execute().data

    def delete(self, alumno_id: int):
        return self.client.table(self.table).delete().eq("id_alumno", alumno_id).execute().data