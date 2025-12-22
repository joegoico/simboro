from fastapi import HTTPException
from repositories.disciplina_repository import DisciplinaRepository
from models.disciplina_model import DisciplinaCreate, DisciplinaUpdate
from supabase import Client

class DisciplinaService:
    def get_disciplinas_by_institucion(self, institucion_id: int, supabase_client: Client):
        try:
            disciplina_repo = DisciplinaRepository(supabase_client)
            disciplinas = disciplina_repo.get_by_institucion(institucion_id)
            if not disciplinas:
                raise HTTPException(status_code=404, detail="No se encontraron disciplinas")
            return disciplinas
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    def get_disciplina_by_id(self, disciplina_id: int, supabase_client: Client):
        try:
            disciplina_repo = DisciplinaRepository(supabase_client)
            disciplina = disciplina_repo.get_by_id(disciplina_id)
            if not disciplina:
                raise HTTPException(status_code=404, detail="Disciplina no encontrada")
            return disciplina[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def create_disciplina(self, disciplina: DisciplinaCreate, supabase_client: Client):
        try:
            disciplina_repo = DisciplinaRepository(supabase_client)
            return disciplina_repo.create(disciplina)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update_disciplina(self, disciplina_id: int, disciplina: DisciplinaUpdate, supabase_client: Client):
        try:
            disciplina_repo = DisciplinaRepository(supabase_client)
            disciplina_updated = disciplina_repo.update(disciplina_id, disciplina)
            if not disciplina_updated:
                raise HTTPException(status_code=404, detail="Disciplina no encontrada")
            return disciplina_updated[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def delete_disciplina(self, disciplina_id: int, supabase_client: Client):
        try:
            disciplina_repo = DisciplinaRepository(supabase_client)
            disciplina_deleted = disciplina_repo.delete(disciplina_id)
            if not disciplina_deleted:
                raise HTTPException(status_code=404, detail="Disciplina no encontrada")
            return {"detail": "Disciplina eliminada"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
