from pydantic import BaseModel
from typing import Optional

class DeudorBase(BaseModel):
    cant_dias_adeudados: int
    monto_total: float

    class Config:
        validate_by_name = True

class DeudorCreate(DeudorBase):
    id_deudor: int
    institucion_id_institucion: int     

class DeudorUpdate(BaseModel):
    cant_dias_adeudados: Optional[int] = None
    monto_total: Optional[int] = None

class DeudorRead(DeudorBase):
    pass

