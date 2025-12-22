from pydantic import BaseModel
from typing import Optional


# Modelo base para Institucion (datos compartidos entre creación, lectura, actualización)
class InstitucionBase(BaseModel):
    nombre: str 

# Modelo para la creación de una Institucion
class InstitucionCreate(InstitucionBase):
    pass

# Modelo para actualizar Institucion (todos son opcionales)
class InstitucionUpdate(BaseModel):
    nombre: Optional[str] = None


# Modelo para leer y retornar una Institucion, incluyendo el id
class InstitucionRead(InstitucionBase):
    id_institucion: int

    class Config:
        orm_mode = True