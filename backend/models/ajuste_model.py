from typing import Literal, TypedDict, Optional
from pydantic import BaseModel
from interfaces.ajuste import Ajuste, AjustePorcentaje, AjusteFijo, CalculoDescuento, CalculoAumento

class AjusteDB(TypedDict):
    tipo_ajuste: Literal["descuento", "aumento"]
    estrategia: Literal["porcentaje", "fijo"]
    valor: float

def construir_ajuste(data: AjusteDB) -> Ajuste:
    if data["estrategia"] == "porcentaje":
        estrategia = AjustePorcentaje(data["valor"])
    else:
        estrategia = AjusteFijo(data["valor"])

    if data["tipo_ajuste"] == "descuento":
        return CalculoDescuento(estrategia)
    else:
        return CalculoAumento(estrategia)

class AjusteCreate(BaseModel):
    tipo_ajuste: Literal["descuento", "aumento"]
    estrategia: Literal["porcentaje", "fijo"]
    valor: float
    institucion_id_institucion: int

class AjusteUpdate(BaseModel):
    tipo_ajuste: Optional[Literal["descuento", "aumento"]] = None
    estrategia: Optional[Literal["porcentaje", "fijo"]] = None
    valor: Optional[float] = None

class AjusteRead(BaseModel):
    id_ajuste: int
    tipo_ajuste: Literal["descuento", "aumento"]
    estrategia: Literal["porcentaje", "fijo"]
    valor: float

    class Config:
        from_attributes = True
 