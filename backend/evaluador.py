from datetime import date
from models.criterioDeuda_model import construir_criterio,CriterioDeuda
from repositories.alumno_repository import AlumnoRepository
from repositories.deudor_repository import DeudorRepository
from repositories.deuda_repository import DeudaRepository
from repositories.pagos_repository import PagoRepository
from repositories.criterioDeuda_repository import CriterioDeudaRepository
from repositories.disciplina_repository import DisciplinaRepository
from repositories.precios_repository import PrecioRepository
from models.deudor_model import DeudorCreate
from models.deuda_model import DeudaCreate, DeudaUpdate

class EvaluadorDeudores:
    def __init__(self, id_institucion: int):
        self.institucion = id_institucion
        self.repo_alumno = AlumnoRepository()
        self.repo_pago = PagoRepository()
        self.repo_deudor = DeudorRepository()
        self.repo_criterio = CriterioDeudaRepository()
        self.repo_deuda = DeudaRepository()
        self.repo_disciplinas = DisciplinaRepository()
        self.repo_precios = PrecioRepository()

    def mes_deuda_registrado(self, fecha_actual: date, id_deudor: int):
        # Verifica si ya tiene deuda registrada en el mes actual
        deudas = self.repo_deuda.get_by_deudor(id_deudor)
        if not deudas:
            return False
        else:
            for deuda in deudas:
                fecha_registro = deuda["fecha_reg_deuda"]
                if fecha_registro.month == fecha_actual.month and fecha_registro.year == fecha_actual.year:
                    return True
            return False
        
    def get_disciplina(self, id_disciplina):
        return self.repo_disciplinas.get_by_id(id_disciplina)
    
    def get_precio(self, id_precio):
        return self.repo_precios.get_by_id(id_precio)
    
    def get_deudor(self, id_deudor):
        return self.repo_deudor.get_by_id(id_deudor)
    
    
    def hallar_deudores(self, alumnos,hoy,criterio):
        for alumno in alumnos:
            pagos = self.repo_pago.get_by_alumno(alumno["id_alumno"])
            if not pagos:
                continue
            ultima_fecha = max(p["fecha_de_pago"] for p in pagos)

            if criterio.esDeudor(ultima_fecha, hoy):
                deudor = self.get_deudor(alumno["id_alumno"])
                disciplina = self.get_disciplina(alumno["DISCIPLINA_id_disciplina"])
                dias = alumno["cant_dias"]
                monto = self.calcular_monto(dias, alumno["DISCIPLINA_id_disciplina"])
                deuda =DeudaCreate(
                            fecha_reg_deuda=hoy,
                            monto=monto,
                            disciplina_id_disciplina=alumno["DISCIPLINA_id_disciplina"],
                            deudor_id_deudor=alumno["id_alumno"])

                if deudor:
                    if not self.mes_deuda_registrado(hoy, alumno["id_alumno"]):
                        self.repo_deuda.create(deuda)
                else:
                    self.repo_deudor.create(
                        DeudorCreate(
                            id_deudor=alumno["id_alumno"],
                            cant_dias_adeudados=dias,
                            monto_total=monto,
                            institucion_id_institucion=self.institucion
                        )
                    )
                    self.repo_deuda.create(deuda)

    def ejecutar(self, criterio: CriterioDeuda):
        try:
            hoy = date.today()
            alumnos = self.repo_alumno.get_by_institucion(self.institucion)
            self.hallar_deudores(alumnos, hoy,criterio)
        except Exception as e:
            print(f"Error al ejecutar el evaluador de deudores: {e}")
            raise e
        

    def calcular_monto(self, cantidad_dias: int, id_disciplina: int) -> float:
        precios = self.repo_precios.get_by_disciplina(id_disciplina)
        for precio in precios:
            if precio["cantidad_dias"] == cantidad_dias:
                return precio["monto"]
        return 0.0  # placeholder
