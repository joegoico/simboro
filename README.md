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
```
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
```
---
## 🏗️ Arquitectura de Base de Datos

El sistema utiliza **PostgreSQL** (gestionado a través de **Supabase**) con un diseño orientado a la consistencia de datos, la escalabilidad y el soporte multi-inquilino (*multi-tenancy*).

### 1. Normalización y Diseño Relacional

El esquema ha sido normalizado siguiendo los principios de la **Forma Normal de Boyce-Codd (FNBC)** para garantizar la integridad referencial y eliminar anomalías de actualización.

* **Eliminación de Redundancias:** A diferencia de modelos tradicionales, la entidad `alumno` no almacena directamente la disciplina ni la frecuencia semanal. Esta información se deriva a través de la relación con la tabla `precio`, centralizando las reglas de negocio y evitando discrepancias de datos.
* **Jerarquía de Especialización:** Se implementó un modelo de herencia (relación 1:1) entre `alumno` y `deudor`. Un `deudor` no es una entidad aislada, sino una extensión semántica de un alumno con saldos pendientes.
* **Integridad de Dominio:** El uso extensivo de `CHECK constraints` asegura que los datos sean válidos antes de persistir (ej. montos positivos, días de la semana entre 1-7, y estados de frecuencia específicos).

### 2. Modelo Multi-tenant (Aislamiento Lógico)

El sistema está diseñado para gestionar múltiples instituciones de forma simultánea.

* **Tenant Key:** La entidad `institucion` actúa como el eje central. Casi todas las entidades operativas (`alumno`, `disciplina`, `gasto`, `ajuste`) poseen una clave foránea hacia `id_institucion`.
* **Seguridad:** Esta estructura facilita la implementación de **Row Level Security (RLS)** en Supabase, garantizando que cada miembro solo acceda a los datos de su respectiva institución.

### 3. Motor de Automatización de Deudas

Una de las características más robustas del esquema es su capacidad para parametrizar la lógica de cobro:

* **Estrategias Dinámicas:** La tabla `ajuste` permite definir recargos o bonificaciones mediante "estrategias" configurables por la institución.
* **Orquestación de Tareas:** Las tablas `frecuencia_ejecucion`, `evaluador` y `criterio_deuda` funcionan como metadatos para un trabajador de fondo (*background worker*). Esto permite que el sistema sepa cuándo y bajo qué reglas debe evaluar la morosidad de un alumno de forma automática.

### 4. Diccionario de Entidades Clave

| Entidad | Propósito |
| --- | --- |
| **Miembros** | Gestión de usuarios internos (Profesores/Principales) y RBAC. |
| **Precio** | Centraliza la relación entre disciplina, frecuencia y costo. |
| **Pago / Gasto** | Registro de flujo de caja y trazabilidad financiera. |
| **Deuda** | Histórico detallado de saldos pendientes por alumno y concepto. |

---


