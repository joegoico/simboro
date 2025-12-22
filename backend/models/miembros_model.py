# backend/models/miembro_model.py
from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID

class MiembroBase(BaseModel):
    """Modelo base con los campos comunes"""
    institucion_id_institucion: int 
    rol: str

    class Config:
        populate_by_name = True

class MiembroCreate(MiembroBase):
    """Modelo para crear un nuevo miembro"""
    user_id: str
class MiembroUpdate(BaseModel):
    """Modelo para actualizar un miembro - todos los campos son opcionales"""
    rol: Optional[str] = None
    

class MiembroRead(MiembroBase):
    """Modelo para leer un miembro - incluye todos los campos"""
    user_id: UUID
    
    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class UserStatusResponse(BaseModel):
    has_institution: bool
    institution_id: Optional[int] = None
    role: Optional[str] = None