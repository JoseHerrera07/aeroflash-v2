# Grupo de subredes para la DB (le dice a AWS dónde poner la DB)
resource "aws_db_subnet_group" "default" {
  name       = "aeroflash-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "AeroFlash DB Subnets"
  }
}

# Reglas de seguridad para la DB
resource "aws_security_group" "rds_sg" {
  name        = "aeroflash-rds-sg"
  description = "Permitir trafico solo desde la EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres desde App Server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    # MAGIA: Solo permitimos tráfico que venga del Security Group de la EC2
    security_groups = [aws_security_group.app_sg.id] 
  }

  tags = {
    Name = "aeroflash-rds-sg"
  }
}

# La Base de Datos en sí
resource "aws_db_instance" "default" {
  identifier           = "aeroflash-db-v2"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "16.3" # O la versión que prefieras compatible con free tier
  instance_class       = "db.t3.micro" # Capa gratuita elegible
  db_name              = "flightbookingdb"
  username             = "flightadmin"
  password             = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  skip_final_snapshot    = true # Para laboratorios, evita backups al borrar
  publicly_accessible    = false # Súper importante por seguridad
}
