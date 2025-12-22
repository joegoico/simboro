from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date

class PeriodicidadBase(BaseModel):
    tipo: Literal["diaria", "cada_n_dias", "semanal"]
    valor: Optional[int] = None  # solo para "cada_n_dias" o día de la semana si "semanal"
    dia_semana: Optional[Literal["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]] = None  # solo para "semanal"
    fecha_ultima_ejecucion:date  # Formato ISO 8601, por ejemplo "2023-10-01T00:00:00Z"

class PeriodicidadCreate(PeriodicidadBase):
    pass
class PeriodicidadUpdate(PeriodicidadBase):
    tipo: Optional[Literal["diaria", "cada_n_dias", "semanal"]] = None
    valor: Optional[int] = None  # solo para "cada_n_dias" o día de la semana si "semanal"
    dia_semana: Optional[Literal["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]] = None  # solo para "semanal"

class PeriodicidadRead(PeriodicidadBase):
    id: int
