from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from controllers import (
    alumnos_controller, disciplinas_controller, pagos_controller,
    precios_controller, deudor_controller, deuda_controller, institucion_controller,
    ajuste_controller,criterioDeuda_controller,miembros_controller
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(alumnos_controller.router)
app.include_router(disciplinas_controller.router)
app.include_router(pagos_controller.router)
app.include_router(precios_controller.router)
app.include_router(deudor_controller.router)
app.include_router(deuda_controller.router)
app.include_router(institucion_controller.router)
app.include_router(ajuste_controller.router)
app.include_router(criterioDeuda_controller.router)
app.include_router(miembros_controller.router)

# --- AGREGA ESTO ---
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    # Imprime el error exacto en la consola
    print(f"\n❌ ERROR DE VALIDACIÓN 422:")
    print(f"--> Cuerpo recibido: {exc.body}")
    print(f"--> Errores detallados: {exc.errors()}\n")
    
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": exc.body},
    )
# -------------------