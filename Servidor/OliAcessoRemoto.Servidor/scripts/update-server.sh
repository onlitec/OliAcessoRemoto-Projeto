#!/bin/bash

# Script de atualização do OliAcesso Remoto Server
# Atualiza o sistema, .NET e a aplicação

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

# Verificar se está rodando como usuário normal
check_user() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script não deve ser executado como root!"
        exit 1
    fi
}

# Fazer backup antes da atualização
create_backup() {
    log_info "Criando backup antes da atualização..."
    
    BACKUP_DIR="/opt/oliacesso-backup-update-$(date +%Y%m%d_%H%M%S)"
    sudo mkdir -p $BACKUP_DIR
    
    # Backup da aplicação
    if [ -d "$SERVER_DIR" ]; then
        sudo cp -r $SERVER_DIR $BACKUP_DIR/app
    fi
    
    # Backup das configurações do sistema
    sudo cp /etc/systemd/system/$SERVICE_NAME.service $BACKUP_DIR/ 2>/dev/null || true
    sudo cp /etc/nginx/sites-available/oliacesso-server $BACKUP_DIR/ 2>/dev/null || true
    
    sudo chown -R $USER:$USER $BACKUP_DIR
    
    log_success "Backup criado em $BACKUP_DIR"
    echo "BACKUP_DIR=$BACKUP_DIR" > /tmp/oliacesso-backup-path
}

# Atualizar sistema operacional
update_system() {
    log_info "Atualizando sistema operacional..."
    
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    
    log_success "Sistema atualizado"
}

# Atualizar .NET
update_dotnet() {
    log_info "Verificando atualizações do .NET..."
    
    # Verificar versão atual
    CURRENT_VERSION=$(dotnet --version)
    log_info "Versão atual do .NET: $CURRENT_VERSION"
    
    # Atualizar .NET
    sudo apt update
    sudo apt install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
    
    # Verificar nova versão
    NEW_VERSION=$(dotnet --version)
    log_info "Nova versão do .NET: $NEW_VERSION"
    
    if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
        log_success ".NET atualizado de $CURRENT_VERSION para $NEW_VERSION"
    else
        log_info ".NET já estava na versão mais recente"
    fi
}

# Atualizar Docker (se instalado)
update_docker() {
    if command -v docker &> /dev/null; then
        log_info "Atualizando Docker..."
        
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        log_success "Docker atualizado"
    else
        log_info "Docker não está instalado, pulando..."
    fi
}

# Atualizar certificados SSL
update_ssl_certificates() {
    if command -v certbot &> /dev/null; then
        log_info "Renovando certificados SSL..."
        
        sudo certbot renew --quiet
        
        if [ $? -eq 0 ]; then
            log_success "Certificados SSL renovados"
        else
            log_warning "Nenhum certificado precisava ser renovado"
        fi
    else
        log_info "Certbot não está instalado, pulando..."
    fi
}

# Verificar se há nova versão da aplicação
check_app_updates() {
    log_info "Verificando atualizações da aplicação..."
    
    # Aqui você pode implementar lógica para verificar se há uma nova versão
    # Por exemplo, verificar um repositório Git ou um servidor de atualizações
    
    if [ -f "update-available.flag" ]; then
        log_info "Nova versão da aplicação disponível"
        return 0
    else
        log_info "Aplicação está na versão mais recente"
        return 1
    fi
}

# Atualizar aplicação
update_application() {
    log_info "Atualizando aplicação..."
    
    # Parar serviço
    sudo systemctl stop $SERVICE_NAME
    
    # Aqui você implementaria a lógica de atualização da aplicação
    # Por exemplo, fazer git pull, build, etc.
    
    # Por enquanto, apenas reiniciar o serviço
    sudo systemctl start $SERVICE_NAME
    
    # Verificar se o serviço iniciou corretamente
    sleep 5
    if systemctl is-active --quiet $SERVICE_NAME; then
        log_success "Aplicação atualizada e reiniciada"
    else
        log_error "Falha ao reiniciar a aplicação após atualização"
        
        # Tentar restaurar backup
        restore_backup
        exit 1
    fi
}

# Restaurar backup em caso de falha
restore_backup() {
    log_warning "Tentando restaurar backup..."
    
    if [ -f "/tmp/oliacesso-backup-path" ]; then
        BACKUP_DIR=$(cat /tmp/oliacesso-backup-path | cut -d'=' -f2)
        
        if [ -d "$BACKUP_DIR/app" ]; then
            sudo systemctl stop $SERVICE_NAME
            sudo rm -rf $SERVER_DIR
            sudo cp -r $BACKUP_DIR/app $SERVER_DIR
            sudo systemctl start $SERVICE_NAME
            
            log_success "Backup restaurado"
        else
            log_error "Backup não encontrado!"
        fi
    else
        log_error "Caminho do backup não encontrado!"
    fi
}

# Verificar saúde após atualização
health_check() {
    log_info "Verificando saúde do sistema após atualização..."
    
    # Verificar serviços
    services=("$SERVICE_NAME" "nginx")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            log_success "$service está funcionando"
        else
            log_error "$service não está funcionando"
        fi
    done
    
    # Verificar conectividade
    sleep 5
    if curl -f http://localhost:7070/health &> /dev/null; then
        log_success "Aplicação está respondendo"
    else
        log_error "Aplicação não está respondendo"
    fi
    
    # Verificar logs por erros
    if sudo journalctl -u $SERVICE_NAME --since "5 minutes ago" --grep "ERROR\|FATAL" --quiet; then
        log_warning "Erros encontrados nos logs recentes"
        sudo journalctl -u $SERVICE_NAME --since "5 minutes ago" --grep "ERROR\|FATAL" --no-pager
    else
        log_success "Nenhum erro encontrado nos logs"
    fi
}

# Limpeza pós-atualização
cleanup() {
    log_info "Executando limpeza pós-atualização..."
    
    # Limpar cache do apt
    sudo apt autoremove -y
    sudo apt autoclean
    
    # Limpar logs antigos
    sudo journalctl --vacuum-time=7d
    
    # Remover arquivos temporários
    rm -f /tmp/oliacesso-backup-path
    
    log_success "Limpeza concluída"
}

# Mostrar relatório final
show_report() {
    echo ""
    echo "=================================================="
    log_success "ATUALIZAÇÃO CONCLUÍDA"
    echo "=================================================="
    echo ""
    
    log_info "Versões atuais:"
    echo "- Sistema: $(lsb_release -d | cut -f2)"
    echo "- .NET: $(dotnet --version)"
    
    if command -v docker &> /dev/null; then
        echo "- Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
    fi
    
    if command -v nginx &> /dev/null; then
        echo "- Nginx: $(nginx -v 2>&1 | cut -d' ' -f3 | cut -d'/' -f2)"
    fi
    
    echo ""
    log_info "Status dos serviços:"
    sudo systemctl status $SERVICE_NAME --no-pager -l
    
    echo ""
    log_info "Para verificar logs:"
    echo "sudo journalctl -u $SERVICE_NAME -f"
}

# Menu de opções
show_menu() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Atualização"
    echo "=================================================="
    echo ""
    echo "1) Atualização completa (recomendado)"
    echo "2) Atualizar apenas sistema operacional"
    echo "3) Atualizar apenas .NET"
    echo "4) Atualizar apenas Docker"
    echo "5) Renovar certificados SSL"
    echo "6) Verificar saúde do sistema"
    echo "0) Sair"
    echo ""
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1)
            full_update
            ;;
        2)
            create_backup
            update_system
            health_check
            cleanup
            ;;
        3)
            create_backup
            update_dotnet
            health_check
            ;;
        4)
            update_docker
            ;;
        5)
            update_ssl_certificates
            ;;
        6)
            health_check
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

# Atualização completa
full_update() {
    create_backup
    update_system
    update_dotnet
    update_docker
    update_ssl_certificates
    
    if check_app_updates; then
        update_application
    fi
    
    health_check
    cleanup
    show_report
}

# Função principal
main() {
    check_user
    
    if [ $# -eq 0 ]; then
        # Modo interativo
        show_menu
    else
        case $1 in
            --full)
                full_update
                ;;
            --system)
                create_backup
                update_system
                health_check
                cleanup
                ;;
            --dotnet)
                create_backup
                update_dotnet
                health_check
                ;;
            --ssl)
                update_ssl_certificates
                ;;
            --check)
                health_check
                ;;
            *)
                echo "Uso: $0 [--full|--system|--dotnet|--ssl|--check]"
                echo ""
                echo "Opções:"
                echo "  --full     Atualização completa"
                echo "  --system   Atualizar apenas sistema operacional"
                echo "  --dotnet   Atualizar apenas .NET"
                echo "  --ssl      Renovar certificados SSL"
                echo "  --check    Verificar saúde do sistema"
                echo ""
                echo "Sem parâmetros: modo interativo"
                ;;
        esac
    fi
}

# Executar função principal
main "$@"