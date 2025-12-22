from repositories.miembros_repository import MiembrosRepository
from supabase import Client
from models.miembros_model import MiembroCreate, MiembroUpdate, UserStatusResponse
from typing import List, Optional, Dict, Any
from fastapi import HTTPException

class MiembrosService:
    # Eliminamos el __init__ porque no podemos crear el repo sin el cliente todavía
    
    def get_miembro_by_id(self, id: str, client: Client) -> Optional[Dict[str, Any]]:
        try:
            # 1. Instanciamos el repositorio AQUÍ, inyectando el cliente autenticado
            repo = MiembrosRepository(client)
            
            # 2. Llamamos al método del repo (que ya no pide el cliente, usa self.client)
            miembro = repo.get_miembro_by_id(id)
            
            # print(f"Response: {miembro}") # Debug (quitar en producción)
            
            if not miembro:
                # 404 es correcto aquí si es una búsqueda por ID específico
                raise HTTPException(status_code=404, detail="Miembro no encontrado")
            
            return miembro
            
        except HTTPException as e:
            raise e # Re-lanzamos las excepciones HTTP controladas
        except Exception as e:
            # Capturamos errores inesperados (ej. fallo de conexión a Supabase)
            print(f"Error interno: {e}") # Loguear el error real en consola
            raise HTTPException(status_code=500, detail="Error interno del servidor al obtener miembro")

    def get_miembros_by_inst(self, id_institucion: int, client: Client) -> List[Dict[str, Any]]:
        try:
            repo = MiembrosRepository(client) # Inyección de dependencia
            miembros = repo.get_miembros_by_inst(id_institucion)
            
            # OJO: Devolver 404 en una lista vacía es debatible. 
            # A veces es mejor devolver [] (lista vacía con status 200) 
            # porque "no hay resultados" es una respuesta válida, no un error.
            # Pero si tu regla de negocio exige error, déjalo así.
            if not miembros:
                 raise HTTPException(status_code=404, detail="No se encontraron miembros")
                 
            return miembros
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def get_miembro_status(self, client: Client, token: str) -> Optional[Dict[str, Any]]:
        try:
            repo = MiembrosRepository(client)
            data = repo.get_miembro_status(token)
            
            if data and len(data) > 0:
                # Encontró un registro, significa que ya es miembro de una institución
                registro = data[0]
                # Verificamos que institucion_id no sea nulo (por si acaso)
                has_inst = registro.get('id_institucion') is not None
                
                return UserStatusResponse(
                    has_institution=has_inst,
                    institution_id=registro.get('id_institucion'),
                    role=registro.get('rol')
                )
            else:
                # No encontró ningún registro, significa que no es miembro de ninguna institución
                return UserStatusResponse(
                    has_institution=False,
                    institution_id=None,
                    role=None
                )
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e)) 

    def create_miembro(self, data: MiembroCreate, client: Client) -> Optional[Dict[str, Any]]:
        try:
            repo = MiembrosRepository(client)
            miembro = repo.create_miembro(data)
            
            if not miembro:
                raise HTTPException(status_code=400, detail="No se pudo crear el miembro")
                
            return miembro
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def update_miembro(self, id: str, data: MiembroUpdate, client: Client) -> Optional[Dict[str, Any]]:
        try:
            repo = MiembrosRepository(client)
            miembro = repo.update_miembro(id, data)
            
            if not miembro:
                raise HTTPException(status_code=404, detail="Miembro no encontrado para actualizar")
                
            return miembro
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    def delete_miembro(self, id: str, client: Client) -> bool:
        try:
            repo = MiembrosRepository(client)
            success = repo.delete_miembro(id)
            
            if not success:
                raise HTTPException(status_code=404, detail="Miembro no encontrado o error al eliminar")
                
            return success
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))