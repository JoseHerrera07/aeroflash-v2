# --- 1. Generar Par de Claves SSH (Key Pair) ---
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "aeroflash-key-v2"       # Nombre de la llave en AWS
  public_key = tls_private_key.pk.public_key_openssh
}

# Guardar la llave privada en tu carpeta local para poder usarla luego
resource "local_file" "ssh_key" {
  filename = "${path.module}/aeroflash-key.pem"
  content  = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

# --- 2. Buscar la imagen (AMI) de Ubuntu 22.04 más reciente ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID oficial de Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- 3. Crear la Instancia EC2 ---
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.kp.key_name

  # --- CAMBIO IMPORTANTE: AUMENTAR DISCO DURO ---
  root_block_device {
    volume_size = 25           # 25 GB de espacio (suficiente para Jenkins + Docker)
    volume_type = "gp3"        # SSD de uso general moderno
    delete_on_termination = true
  }
  # ----------------------------------------------

  tags = {
    Name = "aeroflash-server-v2"
  }
  
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  
  user_data = <<-EOF
              #!/bin/bash
              # Log de todo lo que pasa para depurar si falla
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              echo "--- Iniciando Instalación Automática ---"
              
              # 1. Actualizar el sistema
              apt-get update -y
              apt-get install -y ca-certificates curl gnupg git jq postgresql-client awscli

              # 2. Instalar Docker (Instrucciones oficiales)
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              chmod a+r /etc/apt/keyrings/docker.gpg

              echo \
                "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              # 3. Dar permisos al usuario ubuntu para usar docker sin sudo
              usermod -aG docker ubuntu

              echo "--- Instalación Completada ---"
              EOF
}

# --- 4. Output: Mostrar la IP al terminar ---
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
