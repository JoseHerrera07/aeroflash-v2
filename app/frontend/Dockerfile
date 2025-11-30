FROM nginx:alpine

# Eliminamos la configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copiamos nuestra configuración
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos los archivos estáticos (en el futuro aquí irá el 'dist' de Angular)
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
