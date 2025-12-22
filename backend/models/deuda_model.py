from pydantic import BaseModel
from typing import Optional
from datetime import date

class DeudaBase(BaseModel):
    fecha_reg_deuda: date
    monto: float
    disciplina_id_disciplina: int

class DeudaCreate(DeudaBase):
    deudor_id_deudor: int

class DeudaUpdate(DeudaBase):
    fecha_reg_deuda: Optional[date] = None
    monto: Optional[float] = None
    disciplina_id_disciplina: Optional[int] = None


class DeudaRead(DeudaBase):
    pass