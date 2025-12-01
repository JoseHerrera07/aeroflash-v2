resource "aws_security_group" "app_sg" {
  name        = "aeroflash-app-sg"
  description = "Security Group para AeroFlash App + Monitoring + Jenkins"
  vpc_id      = aws_vpc.main.id

  # 1. SSH (Puerto 22) 
  ingress {
    description = "SSH desde cualquier lugar"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Esto lo dejo por ahora asi para poder hacer mi presentacion xd
  }

  # 2. HTTP (Puerto 80) 
  ingress {
    description = "Acceso Web Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 3. Backend API (Puerto 5000) 
  ingress {
    description = "Acceso API Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 4. Grafana (Puerto 3000) 
  ingress {
    description = "Acceso Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 5. Prometheus (Puerto 9090) 
  ingress {
    description = "Acceso Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 6. Jenkins (Puerto 8080) 
  ingress {
    description = "Acceso Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # 7. SonarQube 
  ingress {
    description = "Acceso SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aeroflash-security-group"
  }
}
