FROM jenkins/jenkins:lts

# Cambiamos a root para instalar dependencias
USER root

# 1. Instalar Docker CLI (para poder enviar comandos al Docker del servidor)
RUN apt-get update && \
    apt-get install -y docker.io

# 2. Instalar Docker Compose (versión moderna)
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Volvemos al usuario jenkins por seguridad
# (Aunque para acceder al socket de docker a veces se requiere root o añadir al grupo, 
# para simplificar este lab usaremos root en el runtime del compose si falla permisos, 
# pero dejamos preparado el usuario jenkins)
USER jenkins
