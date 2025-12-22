from fastapi import HTTPException
from repositories.alumno_repository import AlumnoRepository
from models.alumno_model import AlumnoCreate, AlumnoUpdate
from supabase import Client

class AlumnoService:
    def get_alumnos(self, client: Client):
        try:
            repo = AlumnoRepository(client)
            return repo.get_all()
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    def get_alumno(self, alumno_id: int, client: Client):
        try:
            repo = AlumnoRepository(client)
            alumno = repo.get_by_id(alumno_id)
            if not alumno:
                raise HTTPException(status_code=404, detail="Alumno no encontrado")
            return alumno[0]
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_alumnos_by_institucion(self, institucion_id: int, client: Client):
        try:
            repo = AlumnoRepository(client)
            alumnos = repo.get_by_institucion(institucion_id)
            if not alumnos:
                raise HTTPException(status_code=404, detail="No se encontraron alumnos")
            return alumnos
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def create_alumno(self, alumno: AlumnoCreate    , client: Client):
        try:
            repo = AlumnoRepository(client)
            alumno_created = repo.create(alumno)
            if not alumno_created:
                raise HTTPException(status_code=404, detail="Alumno no creado")
            return {"detail": "Alumno creado correctamente"}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update_alumno(self, alumno_id: int, alumno_update: AlumnoUpdate, client: Client):
        try:
            repo = AlumnoRepository(client)
            updated = repo.update(alumno_id, alumno_update)
            if not updated:
                raise HTTPException(status_code=404, detail="Alumno no encontrado o sin cambios")
            return {"detail": "Alumno actualizado correctamente"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))


    def delete_alumno(self, alumno_id: int, client: Client):
        try:
            repo = AlumnoRepository(client)
            deleted = repo.delete(alumno_id)
            if not deleted:
                raise HTTPException(status_code=404, detail="Alumno no encontrado")
            return {"detail": "Alumno eliminado correctamente"}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))