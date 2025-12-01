resource "aws_db_subnet_group" "default" {
  name       = "aeroflash-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "AeroFlash DB Subnets"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "aeroflash-rds-sg"
  description = "Permitir trafico solo desde la EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres desde App Server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    
    security_groups = [aws_security_group.app_sg.id] 
  }

  tags = {
    Name = "aeroflash-rds-sg"
  }
}


resource "aws_db_instance" "default" {
  identifier           = "aeroflash-db-v2"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "16.3" 
  instance_class       = "db.t3.micro" 
  db_name              = "flightbookingdb"
  username             = "flightadmin"
  password             = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  skip_final_snapshot    = true 
  publicly_accessible    = false 
}
