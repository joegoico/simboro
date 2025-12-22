from pydantic import BaseModel
from typing import Optional
class PrecioBase(BaseModel):
    cant_dias: int
    monto: float
    DISCIPLINA_id_disciplina: int

    class Config:
        validate_by_name = True
        allow_population_by_alias = True

class PrecioCreate(PrecioBase):
    pass

class PrecioUpdate(BaseModel):
    cant_dias: Optional[int] = None
    monto: Optional[float] = None

class PrecioRead(PrecioBase):
    id_precio: int

    class Config:
        from_attributes = True
        validate_by_name = True
        allow_population_by_alias = True
