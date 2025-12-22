from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional

class AlumnoBase(BaseModel):
    nombre: str
    apellido: str
    correo_electronico: EmailStr = Field(..., alias="correo_electronico")
    descripcion: Optional[str] = None
    pagos_realizados: List[str] = []  # IDs of pagos
    cant_dias:int #cuantos dias asiste
    DISCIPLINA_id_disciplina: int
    INSTITUCION_id_institucion: int

    class Config:
        validate_by_name = True
        allow_population_by_alias = True

class AlumnoCreate(AlumnoBase):
    pass

class AlumnoUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    correo_electronico: Optional[str] = None
    descripcion: Optional[str] = None
    cant_dias: Optional[int] = None

    class Config:
        validate_by_name = True
        allow_population_by_alias = True



class AlumnoRead(AlumnoBase):
    id_alumno: int

    class Config:
        from_attributes = True
        validate_by_name = True
        allow_population_by_alias = True