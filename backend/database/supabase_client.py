import os
from fastapi import Header, HTTPException
from supabase import create_client, Client

# Docker Compose ya ha cargado estas variables en el entorno.
SUPABASE_URL = os.getenv("SUPABASE_URL")
ANON_KEY = os.getenv("ANON_KEY")

if not SUPABASE_URL or not ANON_KEY:
    raise ValueError("Faltan SUPABASE_URL o ANON_KEY en las variables de entorno.")

# --- CLIENTES ---

# 1. Cliente Anónimo (CORRECTO: Usar def)
def get_supabase_anon_client() -> Client:
    """
    Devuelve una instancia anónima (sin usuario) para login/registro.
    """
    return create_client(SUPABASE_URL, ANON_KEY)

# 2. Cliente Autenticado (MEJORA: Cambiado de async def -> def)
def get_supabase_client(
    authorization: str = Header(..., alias="Authorization")
) -> Client:
    """
    Valida el header y devuelve un cliente con la sesión del usuario inyectada.
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Formato de token inválido")
    
    user_jwt = authorization.split(" ")[1]

    # Creamos el cliente base
    supabase_client = create_client(SUPABASE_URL, ANON_KEY)
    
    try:
        # Inyectamos el token. Al ser librería síncrona, esto es bloqueante (muy rápido, pero bloqueante).
        # Al usar 'def', FastAPI maneja esto en un hilo seguro.
        supabase_client.auth.set_session(user_jwt, "dummy_refresh")
        
        # Opcional: Si solo necesitas que las peticiones a la DB vayan firmadas
        # y no necesitas usar métodos de auth del usuario, también podrías usar:
        # supabase_client.postgrest.auth(user_jwt)
        
    except Exception as e:
        # Capturamos errores si el formato del token rompe la librería
        raise HTTPException(status_code=401, detail=f"Error configurando sesión: {str(e)}")

    return supabase_client