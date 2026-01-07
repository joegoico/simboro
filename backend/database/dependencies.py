from fastapi import Header, HTTPException
from logging import getLogger

def get_token_from_header(authorization: str = Header(..., alias="Authorization")) -> str:

    # --- DEBUG PRINT ---

    print(f"DEBUG HEADER RECIBIDO: '{authorization}'")

    # -------------------
    if not authorization.startswith("Bearer "):

        print("DEBUG: El header no empieza con Bearer")

        raise HTTPException(status_code=401, detail="Token inválido format")


    try:

        token = authorization.split(" ")[1]

        # Imprime los primeros 10 caracteres para ver si tiene sentido

        print(f"DEBUG TOKEN EXTRAÍDO: {token[:10]}...")

        return token

    except IndexError:

        print("DEBUG: Falló el split")

        raise HTTPException(status_code=401, detail="Token missing")
