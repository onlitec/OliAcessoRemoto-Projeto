#!/bin/bash

# Script de instalação do OliAcesso Remoto Server no Ubuntu
# Versão: 1.0.0
# Compatível com: Ubuntu 20.04, 22.04, 24.04

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se está rodando como root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script não deve ser executado como root!"
        exit 1
    fi
}

# Verificar versão do Ubuntu
check_ubuntu_version() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        log_error "Este script é apenas para Ubuntu!"
        exit 1
    fi
    
    VERSION=$(lsb_release -rs)
    log_info "Detectado Ubuntu $VERSION"
    
    if [[ ! "$VERSION" =~ ^(20\.04|22\.04|24\.04) ]]; then
        log_warning "Versão do Ubuntu não testada. Continuando mesmo assim..."
    fi
}

# Atualizar sistema
update_system() {
    log_info "Atualizando sistema..."
    sudo apt update && sudo apt upgrade -y
    log_success "Sistema atualizado"
}

# Instalar dependências
install_dependencies() {
    log_info "Instalando dependências..."
    
    # Dependências básicas
    sudo apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    
    log_success "Dependências básicas instaladas"
}

# Instalar .NET 9
install_dotnet() {
    log_info "Instalando .NET 9..."
    
    # Adicionar repositório Microsoft
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Atualizar e instalar .NET
    sudo apt update
    sudo apt install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
    
    # Verificar instalação
    dotnet --version
    log_success ".NET 9 instalado com sucesso"
}

# Instalar Docker
install_docker() {
    log_info "Instalando Docker..."
    
    # Remover versões antigas
    sudo apt remove -y docker docker-engine docker.io containerd runc || true
    
    # Adicionar repositório Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalar Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Adicionar usuário ao grupo docker
    sudo usermod -aG docker $USER
    
    # Habilitar Docker no boot
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Docker instalado com sucesso"
}

# Instalar Nginx
install_nginx() {
    log_info "Instalando Nginx..."
    
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    log_success "Nginx instalado com sucesso"
}

# Configurar firewall
configure_firewall() {
    log_info "Configurando firewall..."
    
    # Habilitar UFW
    sudo ufw --force enable
    
    # Regras básicas
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Permitir SSH
    sudo ufw allow ssh
    
    # Permitir HTTP/HTTPS
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # Permitir porta do OliAcesso
    sudo ufw allow 7070/tcp
    sudo ufw allow 7071/tcp
    
    # Mostrar status
    sudo ufw status
    
    log_success "Firewall configurado"
}

# Criar diretórios do projeto
create_directories() {
    log_info "Criando diretórios do projeto..."
    
    sudo mkdir -p /opt/oliacesso-server
    sudo mkdir -p /opt/oliacesso-server/logs
    sudo mkdir -p /opt/oliacesso-server/data
    sudo mkdir -p /opt/oliacesso-server/ssl
    
    # Definir permissões
    sudo chown -R $USER:$USER /opt/oliacesso-server
    chmod 755 /opt/oliacesso-server
    
    log_success "Diretórios criados"
}

# Criar serviço systemd
create_systemd_service() {
    log_info "Criando serviço systemd..."
    
    sudo tee /etc/systemd/system/oliacesso-server.service > /dev/null <<EOF
[Unit]
Description=OliAcesso Remoto Server
After=network.target

[Service]
Type=notify
User=$USER
WorkingDirectory=/opt/oliacesso-server
ExecStart=/usr/bin/dotnet /opt/oliacesso-server/OliAcessoRemoto.Servidor.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=oliacesso-server
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://+:7070

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable oliacesso-server
    
    log_success "Serviço systemd criado"
}

# Criar configuração básica da aplicação
create_app_config() {
    log_info "Criando configuração básica da aplicação..."
    
    sudo tee /opt/oliacesso-server/appsettings.Production.json > /dev/null <<EOF
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Urls": "http://+:7070",
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=/opt/oliacesso-server/data/oliacesso.db"
  }
}
EOF
    
    sudo chown $USER:$USER /opt/oliacesso-server/appsettings.Production.json
    
    log_success "Configuração da aplicação criada"
}

# Criar endpoint de health check
create_health_endpoint() {
    log_info "Criando endpoint de health check..."
    
    sudo tee /opt/oliacesso-server/health.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>OliAcesso Server Health</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>OliAcesso Remoto Server</h1>
    <p>Status: <span style="color: green;">Online</span></p>
    <p>Timestamp: $(date)</p>
</body>
</html>
EOF
    
    sudo chown $USER:$USER /opt/oliacesso-server/health.html
    
    log_success "Endpoint de health check criado"
}

# Configurar SSL/TLS
configure_ssl() {
    log_info "Configurando SSL/TLS..."
    
    # Instalar Certbot
    sudo apt install -y certbot python3-certbot-nginx
    
    log_info "Para configurar SSL, execute:"
    log_info "sudo certbot --nginx -d seu-dominio.com"
    
    log_success "Certbot instalado"
}

# Função principal
main() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Instalação Ubuntu"
    echo "=================================================="
    echo ""
    
    check_root
    check_ubuntu_version
    
    log_info "Iniciando instalação..."
    
    update_system
    install_dependencies
    install_dotnet
    install_docker
    install_nginx
    configure_firewall
    create_directories
    create_systemd_service
    create_app_config
    create_health_endpoint
    configure_ssl
    
    echo ""
    echo "=================================================="
    log_success "Instalação concluída com sucesso!"
    echo "=================================================="
    echo ""
    log_info "Próximos passos:"
    echo "1. Copie os arquivos do servidor para /opt/oliacesso-server/"
    echo "2. Configure o SSL: sudo certbot --nginx -d seu-dominio.com"
    echo "3. Inicie o serviço: sudo systemctl start oliacesso-server"
    echo "4. Verifique o status: sudo systemctl status oliacesso-server"
    echo "5. Acesse: http://seu-servidor:7070/health"
    echo ""
    log_warning "IMPORTANTE: Faça logout e login novamente para usar o Docker sem sudo"
}

# Executar função principal
main "$@"
