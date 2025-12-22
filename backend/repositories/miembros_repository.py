from supabase import Client
from models.miembros_model import (
    MiembroCreate, MiembroRead, MiembroUpdate)
from typing import List, Optional, Dict
from datetime import datetime

class MiembrosRepository:
    def __init__(self, supabase_client: Client):
        self.table_name = 'miembros'
        self.client = supabase_client

    # En tu MiembrosRepository

    def get_miembro_by_id(self, id: str) -> Optional[dict]: # Acepta el cliente autenticado
        """Obtener un miembro por su ID usando un cliente autenticado."""
        response = self.client.table(self.table_name).select('*').eq('user_id', id).execute()
        
        # Esta es la lógica CRÍTICA Y CORRECTA
        if not response.data:
            return None  # Devuelve None si la lista está vacía
        
        return response.data[0] # Solo accede a [0] si hay datos
        
    def get_miembros_by_inst(self, id_institucion: int) -> List[dict]:
        """Obtener miembros usando función RPC"""
        response = self.client.rpc(
            'get_miembros_institucion', 
            {'p_institucion_id': id_institucion}
        ).execute()
        return response.data

    def get_miembro_status(self, token: str) -> Optional[dict]:
        """Obtener el status del usuario"""
        user_response = self.client.auth.get_user(token)
        user_id = user_response.user.id
        response = self.client.table(self.table_name).select("user_id,id_institucion,rol").eq('user_id', user_id).execute()
        return response.data


    def create_miembro(self, data: MiembroCreate) -> Optional[dict]:
        """Crear un nuevo miembro"""
        payload = data.model_dump(by_alias=True)
        response = self.client.table(self.table_name).insert(payload).execute()
        return response.data[0] if response.data else None

    def update_miembro(self, id: str, data: MiembroUpdate) -> Optional[dict]:
        """Actualizar un miembro existente"""
        payload = data.model_dump(by_alias=True,exclude_unset=True)
        response = self.client.table(self.table_name).update(payload).eq('user_id', id).execute()
        return response.data[0] if response.data else None

    def delete_miembro(self, id: str) -> bool:
        """Eliminar un miembro"""
        response = self.client.table(self.table_name).delete().eq('user_id', id).execute()
        return len(response.data) > 0 if response.data else False

    def check_user_is_member(self, user_id: str, institucion_id: int) -> bool:
        """Verificar si un usuario es miembro de una institución"""
        response = self.client.table(self.table_name).select('id').eq('user_id', user_id).eq('id_institucion', institucion_id).execute()
        return len(response.data) > 0

