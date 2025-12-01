pipeline {
    agent any

    stages {
        stage('Validar Código') {
            steps {
                echo ' Verificando estructura...'
                sh 'ls -la'
            }
        }

        stage('Desplegar en Servidor') {
            steps {
                script {
                    echo ' Iniciando Despliegue Continuo...'
                    
                    // 1. Copiar los archivos desde el espacio de trabajo de Jenkins a la carpeta real
                    sh 'cp -r app/backend /home/ubuntu/app/'
                    sh 'cp -r app/frontend /home/ubuntu/app/'
                    sh 'cp -r app/monitoring /home/ubuntu/app/'
                    sh 'cp app/docker-compose.yml /home/ubuntu/app/'
                    
                    // 2. Ir a la carpeta y reiniciar Docker
                    dir('/home/ubuntu/app') {
                        sh 'docker-compose up -d --build backend frontend prometheus grafana loki promtail sonarqube'
                    }
                }
            }
        }
    }
    post {
        success {
            echo ' ¡Despliegue Exitoso! La aplicación se ha actualizado.'
        }
        failure {
            echo ' Algo falló. Revisa los logs.'
        }
    }
}
