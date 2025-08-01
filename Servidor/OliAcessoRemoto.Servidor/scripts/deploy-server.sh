#!/bin/bash

# Script de deploy do OliAcesso Remoto Server
# Este script faz o build e deploy da aplicação no servidor Ubuntu

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
SERVER_DIR="/opt/oliacesso-server"
PROJECT_NAME="OliAcessoRemoto.Servidor"
SERVICE_NAME="oliacesso-server"

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

# Verificar se .NET está instalado
check_dotnet() {
    if ! command -v dotnet &> /dev/null; then
        log_error ".NET não está instalado! Execute primeiro o script install-ubuntu.sh"
        exit 1
    fi
    
    log_info "Versão do .NET: $(dotnet --version)"
}

# Parar o serviço se estiver rodando
stop_service() {
    log_info "Parando serviço $SERVICE_NAME..."
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        sudo systemctl stop $SERVICE_NAME
        log_success "Serviço parado"
    else
        log_info "Serviço não estava rodando"
    fi
}

# Fazer backup da versão anterior
backup_previous() {
    if [ -d "$SERVER_DIR" ] && [ "$(ls -A $SERVER_DIR)" ]; then
        BACKUP_DIR="/opt/oliacesso-server-backup-$(date +%Y%m%d_%H%M%S)"
        log_info "Fazendo backup para $BACKUP_DIR..."
        sudo cp -r $SERVER_DIR $BACKUP_DIR
        log_success "Backup criado"
    fi
}

# Limpar diretório de destino
clean_target() {
    log_info "Limpando diretório de destino..."
    sudo rm -rf $SERVER_DIR/*
    log_success "Diretório limpo"
}

# Fazer build da aplicação
build_application() {
    log_info "Fazendo build da aplicação..."
    
    # Limpar build anterior
    dotnet clean
    
    # Restaurar dependências
    dotnet restore
    
    # Build em modo Release
    dotnet build --configuration Release --no-restore
    
    # Publicar aplicação
    dotnet publish --configuration Release --output ./publish --no-build
    
    log_success "Build concluído"
}

# Copiar arquivos para o servidor
deploy_files() {
    log_info "Copiando arquivos para $SERVER_DIR..."
    
    # Criar diretório se não existir
    sudo mkdir -p $SERVER_DIR
    
    # Copiar arquivos publicados
    sudo cp -r ./publish/* $SERVER_DIR/
    
    # Copiar arquivos de configuração
    if [ -f "appsettings.Production.json" ]; then
        sudo cp appsettings.Production.json $SERVER_DIR/
    fi
    
    # Definir permissões
    sudo chown -R $USER:$USER $SERVER_DIR
    sudo chmod +x $SERVER_DIR/$PROJECT_NAME.dll
    
    log_success "Arquivos copiados"
}

# Atualizar configurações
update_config() {
    log_info "Atualizando configurações..."
    
    # Criar appsettings.Production.json se não existir
    if [ ! -f "$SERVER_DIR/appsettings.Production.json" ]; then
        sudo tee $SERVER_DIR/appsettings.Production.json > /dev/null <<EOF
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
    "DefaultConnection": "Data Source=$SERVER_DIR/data/oliacesso.db"
  }
}
EOF
        sudo chown $USER:$USER $SERVER_DIR/appsettings.Production.json
    fi
    
    log_success "Configurações atualizadas"
}

# Iniciar o serviço
start_service() {
    log_info "Iniciando serviço $SERVICE_NAME..."
    
    # Recarregar daemon
    sudo systemctl daemon-reload
    
    # Iniciar serviço
    sudo systemctl start $SERVICE_NAME
    
    # Verificar status
    sleep 3
    if systemctl is-active --quiet $SERVICE_NAME; then
        log_success "Serviço iniciado com sucesso"
    else
        log_error "Falha ao iniciar o serviço"
        sudo systemctl status $SERVICE_NAME
        exit 1
    fi
}

# Verificar saúde da aplicação
health_check() {
    log_info "Verificando saúde da aplicação..."
    
    sleep 5
    
    if curl -f http://localhost:7070/health &> /dev/null; then
        log_success "Aplicação está respondendo"
    else
        log_warning "Aplicação pode não estar respondendo na porta 7070"
        log_info "Verifique os logs: sudo journalctl -u $SERVICE_NAME -f"
    fi
}

# Mostrar status final
show_status() {
    echo ""
    echo "=================================================="
    log_success "Deploy concluído!"
    echo "=================================================="
    echo ""
    log_info "Status do serviço:"
    sudo systemctl status $SERVICE_NAME --no-pager
    echo ""
    log_info "Para ver os logs:"
    echo "sudo journalctl -u $SERVICE_NAME -f"
    echo ""
    log_info "Para parar o serviço:"
    echo "sudo systemctl stop $SERVICE_NAME"
    echo ""
    log_info "Para reiniciar o serviço:"
    echo "sudo systemctl restart $SERVICE_NAME"
}

# Função principal
main() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Deploy"
    echo "=================================================="
    echo ""
    
    check_dotnet
    stop_service
    backup_previous
    clean_target
    build_application
    deploy_files
    update_config
    start_service
    health_check
    show_status
}

# Executar função principal
main "$@"