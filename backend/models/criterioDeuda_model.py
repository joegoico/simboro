from typing import Literal, Optional
from pydantic import BaseModel
from interfaces.criterio_deuda import (
    CriterioDeuda,
    DeudaFechaFija,
    DeudaPorVencimiento,
)

# Modelo que representa un registro de la base de datos
class CriterioDeudaDB(BaseModel):
    tipo_criterio: Literal["porFecha", "porMes"]
    dia_vencimiento: Optional[int] = None
    institucion_id_institucion: int

class CriterioDeudaCreate(BaseModel):
    tipo_criterio: Literal["porFecha", "porMes"]
    dia_vencimiento: Optional[int] = None
    institucion_id_institucion: int

class CriterioDeudaUpdate(BaseModel):
    tipo_criterio: Optional[Literal["porFecha", "porMes"]] = None
    dia_vencimiento: Optional[int] = None

class CriterioDeudaRead(BaseModel):
    id_criterio: int
    tipo_criterio: Literal["porFecha", "porMes"]
    dia_vencimiento: Optional[int] = None

    class Config:
        from_attributes = True


def construir_criterio(data: CriterioDeudaDB) -> CriterioDeuda:
    if data.tipo_criterio == "porFecha":
        if data.dia_vencimiento is None:
            raise ValueError("El criterio 'porFecha' requiere un día")
        return DeudaFechaFija(data.dia_vencimiento)
    elif data.tipo_criterio == "porMes":
        return DeudaPorVencimiento()
    else:
        raise ValueError(f"Criterio desconocido: {data.tipo_criterio}")
