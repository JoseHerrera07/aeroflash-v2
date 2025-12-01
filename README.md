# AeroFlash v2.0 - Sistema de Reserva de Vuelos

## Descripción del Proyecto
AeroFlash es una plataforma web de gestión y reserva de vuelos diseñada bajo una arquitectura moderna de microservicios. Este proyecto representa la evolución tecnológica de un sistema legado, migrando hacia una infraestructura en la nube automatizada, escalable y observable.

El objetivo principal no es solo permitir la reserva de boletos, sino demostrar cómo una ingeniería DevOps robusta puede resolver problemas críticos de rendimiento y despliegue en aplicaciones empresariales.

## Problemática y Solución Tecnológica

### El Problema (Antes)
Los sistemas tradicionales de reserva a menudo enfrentan desafíos críticos que degradan la experiencia del usuario y la operatividad del negocio:
* **Cuellos de Botella y Latencia:** En momentos de alta demanda, las peticiones se bloquean debido a servidores web ineficientes o bases de datos saturadas, causando tiempos de carga lentos.
* **Ceguera Operativa:** Cuando ocurre un error (ej. fallos 500), los administradores no tienen visibilidad inmediata de la causa raíz, dependiendo de logs dispersos y difíciles de analizar.
* **Despliegues Manuales Arriesgados:** Las actualizaciones del sistema requieren intervención humana directa en los servidores, lo que provoca tiempos de inactividad (downtime) y errores de configuración humana.

### La Solución (AeroFlash v2.0)
Esta infraestructura ha sido diseñada específicamente para mitigar estos riesgos mediante:

1.  **Alto Rendimiento y Concurrencia:**
    * Utilizamos **FastAPI** (Python) como backend, que gracias a su naturaleza asíncrona maneja miles de conexiones simultáneas de manera más eficiente que frameworks tradicionales, reduciendo los bloqueos de I/O.
    * Implementamos **Nginx** como Proxy Inverso para gestionar eficientemente las conexiones entrantes y servir contenido estático, liberando carga del servidor de aplicaciones.

2.  **Observabilidad Completa (Detección de Cuellos de Botella):**
    * El stack de monitoreo (**Prometheus y Grafana**) permite visualizar en tiempo real métricas críticas como latencia por endpoint y consumo de memoria. Esto permite identificar proactivamente qué partes del código son lentas antes de que el sistema colapse.
    * **Loki** centraliza los logs, permitiendo correlacionar picos de errores con despliegues recientes o aumentos de tráfico.

3.  **Infraestructura Inmutable y Automatización:**
    * Gracias a **Docker**, garantizamos que el entorno de desarrollo sea idéntico al de producción, eliminando el problema de "funciona en mi máquina".
    * **Terraform** y **Jenkins** permiten reconstruir o actualizar toda la infraestructura en minutos sin intervención manual, asegurando consistencia y reduciendo el tiempo de recuperación ante desastres (RTO).

## Arquitectura del Sistema

El proyecto está construido sobre una arquitectura de microservicios orquestados con Docker Compose, desplegados sobre una instancia AWS EC2 provisionada mediante Código (IaC).

### Componentes Principales:
* **Frontend (Nginx):** Interfaz de usuario responsiva y Proxy Inverso.
* **Backend (FastAPI):** API REST asíncrona conectada a PostgreSQL.
* **Base de Datos (AWS RDS):** Persistencia de datos gestionada y segura en la nube.
* **CI/CD (Jenkins):** Pipeline de integración y despliegue continuo.

## Estructura del Proyecto

A continuación se detalla la organización de los archivos y directorios del repositorio:

.
├── app/                            # Código fuente de la aplicación y servicios
│   ├── backend/                    # Microservicio de API (Python/FastAPI)
│   │   ├── main.py                 # Lógica de negocio y endpoints
│   │   ├── Dockerfile              # Definición de imagen del backend
│   │   └── requirements.txt        # Dependencias de Python
│   ├── frontend/                   # Microservicio de Interfaz de Usuario
│   │   ├── index.html              # Código HTML/JS de la aplicación cliente
│   │   ├── nginx.conf              # Configuración del Proxy Inverso
│   │   └── Dockerfile              # Definición de imagen del frontend
│   ├── monitoring/                 # Configuración del stack de observabilidad
│   │   ├── prometheus.yml          # Reglas de recolección de métricas
│   │   ├── loki-config.yaml        # Configuración del sistema de logs
│   │   └── promtail-config.yml     # Agente de envío de logs
│   ├── jenkins/                    # Entorno personalizado de CI/CD
│   │   └── Dockerfile              # Imagen de Jenkins con Docker integrado
│   └── docker-compose.yml          # Orquestación de todos los servicios
├── infra/                          # Infraestructura como Código (Terraform)
│   ├── provider.tf                 # Configuración del proveedor AWS
│   ├── network.tf                  # VPC, Subnets, Internet Gateway y Rutas
│   ├── security.tf                 # Grupos de Seguridad (Firewall)
│   ├── compute.tf                  # Definición de instancia EC2
│   ├── rds.tf                      # Base de datos relacional (PostgreSQL)
│   ├── secrets.tf                  # Gestión de credenciales (AWS Secrets Manager)
│   └── iam.tf                      # Roles y Permisos de acceso
├── Jenkinsfile                     # Definición del Pipeline de automatización
└── README.md                       # Documentación del proyecto

## Requisitos Previos

* Docker y Docker Compose
* Terraform (v1.0+)
* Cuenta de AWS y AWS CLI configurado
* Git

## Guía de Despliegue Rápido

### 1. Infraestructura
Desde el directorio `infra/`:
terraform init
terraform apply

### 2. Despliegue de Aplicación
Conéctese al servidor mediante SSH y ejecute desde el directorio `app/`:
docker-compose up -d --build

### 3. Acceso
* Web: http://<IP-PUBLICA>
* Grafana: http://<IP-PUBLICA>:3000
* Jenkins: http://<IP-PUBLICA>:8080

## Licencia
Este proyecto es de código abierto para fines educativos.
