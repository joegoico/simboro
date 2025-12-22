from fastapi import Header, HTTPException

def get_token_from_header(authorization: str = Header(..., alias="Authorization")) -> str:
    """
    Extrae el token JWT puro del header Authorization.
    Ejemplo header: "Bearer eyJhbGci..." -> Retorna: "eyJhbGci..."
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401, 
            detail="Token inválido. Debe empezar con 'Bearer '"
        )
    
    try:
        # Divide el string por el espacio y toma la segunda parte (el token)
        token = authorization.split(" ")[1]
        return token
    except IndexError:
        raise HTTPException(
            status_code=401, 
            detail="Token no encontrado después de Bearer"
        )