from abc import ABC, abstractmethod

class Ajuste(ABC):
    @abstractmethod
    def ajustar(self, base: float) -> float:
        pass

class AjustePorcentaje(Ajuste):
    def __init__(self, porcentaje: float):
        self.porcentaje = porcentaje

    def ajustar(self, base: float) -> float:
        return base * (self.porcentaje / 100)
    
class AjusteFijo(Ajuste):
    def __init__(self, valor_fijo: float):
        self.valor_fijo = valor_fijo

    def ajustar(self, base: float) -> float:
        return self.valor_fijo
    

class CalculoDescuento(Ajuste):
    def __init__(self, estrategia: Ajuste):
        self.estrategia = estrategia

    def ajustar(self, base: float) -> float:
        return base - self.estrategia.ajustar(base)
    
class CalculoAumento(Ajuste):
    def __init__(self, estrategia: Ajuste):
        self.estrategia = estrategia

    def ajustar(self, base: float) -> float:
        return base + self.estrategia.ajustar(base)
    
    
    
