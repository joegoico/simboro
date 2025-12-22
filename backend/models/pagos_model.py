from pydantic import BaseModel
from datetime import date
from typing import Optional

class PagoModel(BaseModel):
    alumno_id_alumno: int
    fecha_de_pago: date
    descuento: bool
    cargo_adicional: bool
    PRECIO_id_precio: int



    class Config:
        validate_by_name = True
        allow_population_by_alias = True
        # Este encoder se utilizará para la serialización a JSON


# Puedes definir también modelos para actualizar o leer, heredando de PagoCreate o adaptando el campo:
class PagoCreate(PagoModel):
    pass
class PagoUpdate(BaseModel):
    fecha_de_pago: Optional[date] = None
    descuento: Optional[bool] = None
    cargo_adicional: Optional[bool] = None
    PRECIO_id_precio: Optional[int] = None



    class Config:
        validate_by_name = True
        allow_population_by_alias = True

class PagoRead(PagoModel):
    id_pago: int

    class Config:
        from_attributes = True
        validate_by_name = True
        allow_population_by_alias = True
