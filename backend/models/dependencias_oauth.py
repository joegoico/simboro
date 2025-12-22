from services.login_service import LoginService
from fastapi import Header, HTTPException, status
from typing import Annotated, Optional

# Dependencia para obtener el servicio
def get_login_service() -> LoginService:
    return LoginService()

# Dependencia para extraer el token del header
def get_token_from_header(
    authorization: Annotated[Optional[str], Header(description="Bearer token")] = None
) -> str:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )
    
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise ValueError("Invalid authentication scheme")
        return token
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format. Use: Bearer <token>"
        )