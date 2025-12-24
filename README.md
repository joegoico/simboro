# Simboro 🏆

**Simboro** es una solución integral diseñada para la gestión eficiente de instituciones deportivas. Esta plataforma permite centralizar la administración de alumnos, el control de pagos y el seguimiento detallado de las finanzas institucionales (ingresos y egresos) en un solo lugar.

---

## 🚀 Características Principales

- **Gestión de Alumnos:** Registro, seguimiento y administración de perfiles de deportistas.
- **Control de Pagos:** Monitoreo de cuotas sociales, vencimientos y estados de cuenta de los socios/alumnos.
- **Gestión Financiera:** Módulo de contabilidad simple para registrar ingresos y egresos de la institución.
- **Multiplataforma:** Gracias a Flutter, la aplicación está diseñada para funcionar en múltiples entornos.
- **Arquitectura Escalable:** Separación clara entre el frontend (móvil/web) y el backend (lógica de negocio).

---

## 🛠️ Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en microservicios o componentes separados:

- **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Interfaz de usuario fluida y reactiva.
- **Backend:** [Python](https://www.python.org/) - Procesamiento de datos y lógica de servidor.
- **Infraestructura:** [Docker](https://www.docker.com/) & Docker Compose - Para un despliegue consistente y fácil configuración del entorno.

---

## 📂 Estructura del Proyecto

```text
simboro/
├── backend/            # Lógica del servidor y API (Python)
├── lib/                # Código fuente de la aplicación Flutter
├── android/ ios/ web/  # Configuraciones específicas por plataforma
├── docker-compose.yml  # Configuración de contenedores
├── pubspec.yaml        # Dependencias de Flutter
└── package.json        # Gestión de scripts adicionales

## ⚙️ Instalación y Configuración

Podés correr el proyecto usando **Docker**.

### 📋 Requisitos Previos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Canal stable)
* [Python 3.10+](https://www.python.org/downloads/)
* [Docker & Docker Compose](https://docs.docker.com/get-docker/)

---

### 🐳 Usando Docker
Esta opción levanta tanto el backend como los servicios necesarios automáticamente.

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/joegoico/simboro.git](https://github.com/joegoico/simboro.git)
   cd simboro

2. **Levantar los contenedores:**
  ```bash
  docker-compose up --build
