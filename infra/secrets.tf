resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_creds" {
  name = "aeroflash/db/credentials_v2" 
  
  recovery_window_in_days = 0 
}


resource "aws_secretsmanager_secret_version" "db_creds_val" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = "flightadmin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.default.address 
    port     = 5432
    dbname   = "flightbookingdb"
  })
}
