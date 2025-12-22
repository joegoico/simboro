from pydantic import BaseModel
from typing import Optional, List
class DisciplinaBase(BaseModel):
    nombre: str
    descripcion: Optional[str] = None
    INSTITUCION_id_institucion: int

class DisciplinaCreate(DisciplinaBase):
    pass

class DisciplinaUpdate(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None

    class Config:
        validate_by_name = True
        allow_population_by_alias = True

class DisciplinaRead(DisciplinaBase):
    id_disciplina: int
    descripcion: Optional[str] = None
    precios: List[str] = []  # IDs of precios

    class Config:
        from_attributes = True
        validate_by_name = True
        allow_population_by_alias = True

