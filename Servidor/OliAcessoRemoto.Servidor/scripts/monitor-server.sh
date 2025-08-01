#!/bin/bash

# Script de monitoramento e manutenção do OliAcesso Remoto Server
# Verifica status, logs e performance do servidor

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
SERVICE_NAME="oliacesso-server"
SERVER_DIR="/opt/oliacesso-server"
LOG_DIR="/var/log/oliacesso"

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

# Verificar status do serviço
check_service_status() {
    echo "=================================================="
    log_info "STATUS DO SERVIÇO"
    echo "=================================================="
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        log_success "Serviço está ATIVO"
    else
        log_error "Serviço está INATIVO"
    fi
    
    if systemctl is-enabled --quiet $SERVICE_NAME; then
        log_success "Serviço está HABILITADO para inicialização automática"
    else
        log_warning "Serviço NÃO está habilitado para inicialização automática"
    fi
    
    echo ""
    sudo systemctl status $SERVICE_NAME --no-pager
    echo ""
}

# Verificar conectividade
check_connectivity() {
    echo "=================================================="
    log_info "TESTE DE CONECTIVIDADE"
    echo "=================================================="
    
    # Testar porta local
    if curl -f http://localhost:7070/health &> /dev/null; then
        log_success "Aplicação respondendo na porta 7070"
    else
        log_error "Aplicação NÃO está respondendo na porta 7070"
    fi
    
    # Verificar portas abertas
    log_info "Portas em uso pelo processo:"
    sudo netstat -tlnp | grep dotnet || log_warning "Nenhum processo dotnet encontrado"
    
    echo ""
}

# Verificar uso de recursos
check_resources() {
    echo "=================================================="
    log_info "USO DE RECURSOS"
    echo "=================================================="
    
    # CPU e Memória
    log_info "Uso de CPU e Memória:"
    ps aux | grep -E "(dotnet|nginx)" | grep -v grep
    
    echo ""
    
    # Espaço em disco
    log_info "Espaço em disco:"
    df -h /opt/oliacesso-server
    
    echo ""
    
    # Memória do sistema
    log_info "Memória do sistema:"
    free -h
    
    echo ""
}

# Verificar logs
check_logs() {
    echo "=================================================="
    log_info "LOGS RECENTES"
    echo "=================================================="
    
    log_info "Últimas 20 linhas do log do serviço:"
    sudo journalctl -u $SERVICE_NAME -n 20 --no-pager
    
    echo ""
    
    # Verificar logs de erro
    log_info "Erros recentes (últimas 24 horas):"
    sudo journalctl -u $SERVICE_NAME --since "24 hours ago" --grep "ERROR\|FATAL\|Exception" --no-pager || log_info "Nenhum erro encontrado"
    
    echo ""
}

# Verificar certificados SSL
check_ssl_certificates() {
    echo "=================================================="
    log_info "CERTIFICADOS SSL"
    echo "=================================================="
    
    if command -v certbot &> /dev/null; then
        sudo certbot certificates || log_warning "Nenhum certificado encontrado"
    else
        log_warning "Certbot não está instalado"
    fi
    
    echo ""
}

# Verificar configuração Nginx
check_nginx() {
    echo "=================================================="
    log_info "STATUS DO NGINX"
    echo "=================================================="
    
    if systemctl is-active --quiet nginx; then
        log_success "Nginx está ATIVO"
        
        # Testar configuração
        if sudo nginx -t &> /dev/null; then
            log_success "Configuração Nginx está VÁLIDA"
        else
            log_error "Configuração Nginx tem ERROS"
            sudo nginx -t
        fi
    else
        log_error "Nginx está INATIVO"
    fi
    
    echo ""
}

# Verificar atualizações
check_updates() {
    echo "=================================================="
    log_info "VERIFICAÇÃO DE ATUALIZAÇÕES"
    echo "=================================================="
    
    # Verificar atualizações do sistema
    log_info "Verificando atualizações do sistema..."
    apt list --upgradable 2>/dev/null | head -10
    
    echo ""
    
    # Verificar versão do .NET
    if command -v dotnet &> /dev/null; then
        log_info "Versão atual do .NET: $(dotnet --version)"
    fi
    
    echo ""
}

# Limpeza de logs antigos
cleanup_logs() {
    echo "=================================================="
    log_info "LIMPEZA DE LOGS"
    echo "=================================================="
    
    # Limpar logs do systemd (manter últimos 7 dias)
    log_info "Limpando logs do systemd..."
    sudo journalctl --vacuum-time=7d
    
    # Limpar logs do Nginx (manter últimos 30 dias)
    if [ -d "/var/log/nginx" ]; then
        log_info "Limpando logs antigos do Nginx..."
        sudo find /var/log/nginx -name "*.log.*" -mtime +30 -delete
    fi
    
    log_success "Limpeza concluída"
    echo ""
}

# Backup de configurações
backup_configs() {
    echo "=================================================="
    log_info "BACKUP DE CONFIGURAÇÕES"
    echo "=================================================="
    
    BACKUP_DIR="/opt/oliacesso-backup-$(date +%Y%m%d_%H%M%S)"
    
    log_info "Criando backup em $BACKUP_DIR..."
    sudo mkdir -p $BACKUP_DIR
    
    # Backup das configurações
    if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
        sudo cp /etc/systemd/system/$SERVICE_NAME.service $BACKUP_DIR/
    fi
    
    if [ -f "/etc/nginx/sites-available/oliacesso-server" ]; then
        sudo cp /etc/nginx/sites-available/oliacesso-server $BACKUP_DIR/
    fi
    
    if [ -d "$SERVER_DIR" ]; then
        sudo cp -r $SERVER_DIR/appsettings*.json $BACKUP_DIR/ 2>/dev/null || true
    fi
    
    sudo chown -R $USER:$USER $BACKUP_DIR
    
    log_success "Backup criado em $BACKUP_DIR"
    echo ""
}

# Reiniciar serviços
restart_services() {
    echo "=================================================="
    log_info "REINICIAR SERVIÇOS"
    echo "=================================================="
    
    read -p "Deseja reiniciar o serviço OliAcesso? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Reiniciando serviço $SERVICE_NAME..."
        sudo systemctl restart $SERVICE_NAME
        sleep 3
        
        if systemctl is-active --quiet $SERVICE_NAME; then
            log_success "Serviço reiniciado com sucesso"
        else
            log_error "Falha ao reiniciar o serviço"
        fi
    fi
    
    echo ""
    
    read -p "Deseja reiniciar o Nginx? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Reiniciando Nginx..."
        sudo systemctl restart nginx
        
        if systemctl is-active --quiet nginx; then
            log_success "Nginx reiniciado com sucesso"
        else
            log_error "Falha ao reiniciar o Nginx"
        fi
    fi
    
    echo ""
}

# Menu interativo
show_menu() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Monitoramento"
    echo "=================================================="
    echo ""
    echo "1) Status completo"
    echo "2) Verificar logs"
    echo "3) Verificar recursos"
    echo "4) Verificar SSL"
    echo "5) Limpeza de logs"
    echo "6) Backup de configurações"
    echo "7) Reiniciar serviços"
    echo "8) Monitoramento em tempo real"
    echo "0) Sair"
    echo ""
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1)
            check_service_status
            check_connectivity
            check_resources
            check_nginx
            check_ssl_certificates
            ;;
        2)
            check_logs
            ;;
        3)
            check_resources
            ;;
        4)
            check_ssl_certificates
            ;;
        5)
            cleanup_logs
            ;;
        6)
            backup_configs
            ;;
        7)
            restart_services
            ;;
        8)
            log_info "Monitoramento em tempo real (Ctrl+C para sair):"
            sudo journalctl -u $SERVICE_NAME -f
            ;;
        0)
            log_info "Saindo..."
            exit 0
            ;;
        *)
            log_error "Opção inválida!"
            ;;
    esac
}

# Função principal
main() {
    if [ $# -eq 0 ]; then
        # Modo interativo
        while true; do
            show_menu
            echo ""
            read -p "Pressione Enter para continuar..."
            clear
        done
    else
        # Modo não interativo - executar todas as verificações
        check_service_status
        check_connectivity
        check_resources
        check_nginx
        check_ssl_certificates
        check_logs
        check_updates
    fi
}

# Executar função principal
main "$@"