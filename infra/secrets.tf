# Generar una contraseña aleatoria fuerte
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Crear el secreto en AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_creds" {
  name = "aeroflash/db/credentials_v2" # Nombre único
  
  # Esto fuerza a que se borre inmediatamente si destruyes terraform
  recovery_window_in_days = 0 
}

# Guardar las credenciales en formato JSON dentro del secreto
resource "aws_secretsmanager_secret_version" "db_creds_val" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = "flightadmin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.default.address # Referencia circular, Terraform la resuelve
    port     = 5432
    dbname   = "flightbookingdb"
  })
}
