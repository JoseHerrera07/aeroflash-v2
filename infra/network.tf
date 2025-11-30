# infra/network.tf

# 1. La VPC principal
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aeroflash-vpc"
  }
}

# 2. Internet Gateway (Para que la VPC tenga salida a internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aeroflash-igw"
  }
}

# 3. Subred PÚBLICA (Donde estará nuestra EC2 por ahora)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" 
  map_public_ip_on_launch = true         # Asigna IP pública automática

  tags = {
    Name = "aeroflash-public-subnet"
  }
}

# 4. Subred PRIVADA (Donde estarán las bases de datos RDS - Seguridad)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "aeroflash-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b" # RDS necesita 2 zonas distintas para alta disponibilidad

  tags = {
    Name = "aeroflash-private-subnet-2"
  }
}

# 5. Tabla de Enrutamiento Pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Todo el tráfico sale a internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "aeroflash-public-rt"
  }
}

# 6. Asociar la tabla a la subred pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
