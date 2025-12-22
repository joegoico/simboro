from abc import ABC,abstractmethod
from datetime import date

class CriterioDeuda(ABC):
    @abstractmethod
    def esDeudor(self,ultima_fecha_pago: date, fecha_actual: date)-> bool:
        pass

class DeudaFechaFija(CriterioDeuda):
    def __init__(self, fecha_limite: int) -> None:
        self.fecha_limite = fecha_limite

    def esDeudor(self, ultima_fecha_pago: date, fecha_actual: date) -> bool:
        return fecha_actual.day > self.fecha_limite
    
class DeudaPorVencimiento(CriterioDeuda):
    def esDeudor(self, ultima_fecha_pago: date, fecha_actual: date) -> bool:
        return (fecha_actual - ultima_fecha_pago).days >= 30
