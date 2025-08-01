#!/bin/bash

# Script principal de gerenciamento do OliAcesso Remoto Server
# Fornece um menu unificado para todas as operações

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Diretório dos scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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

# Verificar se os scripts existem
check_scripts() {
    local missing_scripts=()
    
    if [ ! -f "$PROJECT_ROOT/install-ubuntu.sh" ]; then
        missing_scripts+=("install-ubuntu.sh")
    fi
    
    local scripts=("deploy-server.sh" "setup-ssl.sh" "monitor-server.sh" "update-server.sh" "uninstall-server.sh")
    
    for script in "${scripts[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            missing_scripts+=("$script")
        fi
    done
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        log_error "Scripts não encontrados:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $script"
        done
        exit 1
    fi
}

# Verificar status do sistema
check_system_status() {
    local status_ok=true
    
    # Verificar se o serviço existe
    if systemctl list-unit-files | grep -q "oliacesso-server"; then
        if systemctl is-active --quiet oliacesso-server; then
            echo -e "${GREEN}✓${NC} Serviço OliAcesso está rodando"
        else
            echo -e "${RED}✗${NC} Serviço OliAcesso está parado"
            status_ok=false
        fi
    else
        echo -e "${YELLOW}!${NC} Serviço OliAcesso não está instalado"
        status_ok=false
    fi
    
    # Verificar Nginx
    if command -v nginx &> /dev/null; then
        if systemctl is-active --quiet nginx; then
            echo -e "${GREEN}✓${NC} Nginx está rodando"
        else
            echo -e "${RED}✗${NC} Nginx está parado"
            status_ok=false
        fi
    else
        echo -e "${YELLOW}!${NC} Nginx não está instalado"
    fi
    
    # Verificar .NET
    if command -v dotnet &> /dev/null; then
        echo -e "${GREEN}✓${NC} .NET $(dotnet --version) está instalado"
    else
        echo -e "${RED}✗${NC} .NET não está instalado"
        status_ok=false
    fi
    
    # Verificar conectividade
    if curl -f http://localhost:7070/health &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Aplicação está respondendo"
    else
        echo -e "${RED}✗${NC} Aplicação não está respondendo"
        status_ok=false
    fi
    
    return $status_ok
}

# Mostrar cabeçalho
show_header() {
    clear
    echo -e "${CYAN}"
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Gerenciamento"
    echo "=================================================="
    echo -e "${NC}"
    echo ""
    
    echo -e "${BLUE}Status do Sistema:${NC}"
    check_system_status
    echo ""
}

# Menu principal
show_main_menu() {
    echo -e "${PURPLE}INSTALAÇÃO E CONFIGURAÇÃO:${NC}"
    echo "1) Instalação inicial completa (Ubuntu)"
    echo "2) Deploy/Atualizar aplicação"
    echo "3) Configurar SSL/HTTPS"
    echo ""
    
    echo -e "${PURPLE}MONITORAMENTO E MANUTENÇÃO:${NC}"
    echo "4) Monitor do servidor (diagnóstico)"
    echo "5) Atualizar sistema e dependências"
    echo "6) Verificar logs em tempo real"
    echo ""
    
    echo -e "${PURPLE}OPERAÇÕES AVANÇADAS:${NC}"
    echo "7) Backup manual das configurações"
    echo "8) Restaurar backup"
    echo "9) Reiniciar serviços"
    echo ""
    
    echo -e "${PURPLE}DESINSTALAÇÃO:${NC}"
    echo "10) Desinstalar completamente"
    echo ""
    
    echo -e "${PURPLE}INFORMAÇÕES:${NC}"
    echo "11) Ver documentação"
    echo "12) Comandos úteis"
    echo ""
    
    echo "0) Sair"
    echo ""
}

# Executar instalação inicial
run_installation() {
    log_info "Iniciando instalação inicial..."
    cd "$PROJECT_ROOT"
    chmod +x install-ubuntu.sh
    ./install-ubuntu.sh
}

# Executar deploy
run_deploy() {
    log_info "Iniciando deploy da aplicação..."
    cd "$PROJECT_ROOT"
    chmod +x scripts/deploy-server.sh
    ./scripts/deploy-server.sh
}

# Configurar SSL
run_ssl_setup() {
    log_info "Configurando SSL/HTTPS..."
    cd "$PROJECT_ROOT"
    chmod +x scripts/setup-ssl.sh
    ./scripts/setup-ssl.sh
}

# Executar monitor
run_monitor() {
    log_info "Abrindo monitor do servidor..."
    cd "$PROJECT_ROOT"
    chmod +x scripts/monitor-server.sh
    ./scripts/monitor-server.sh
}

# Executar atualização
run_update() {
    log_info "Iniciando atualização do sistema..."
    cd "$PROJECT_ROOT"
    chmod +x scripts/update-server.sh
    ./scripts/update-server.sh
}

# Ver logs em tempo real
view_logs() {
    echo ""
    echo "Escolha o log para visualizar:"
    echo "1) Log do serviço OliAcesso"
    echo "2) Log de acesso do Nginx"
    echo "3) Log de erro do Nginx"
    echo "4) Todos os logs (múltiplas janelas)"
    echo ""
    read -p "Opção: " log_choice
    
    case $log_choice in
        1)
            log_info "Visualizando logs do serviço (Ctrl+C para sair)..."
            sudo journalctl -u oliacesso-server -f
            ;;
        2)
            log_info "Visualizando logs de acesso do Nginx (Ctrl+C para sair)..."
            sudo tail -f /var/log/nginx/oliacesso-access.log 2>/dev/null || sudo tail -f /var/log/nginx/access.log
            ;;
        3)
            log_info "Visualizando logs de erro do Nginx (Ctrl+C para sair)..."
            sudo tail -f /var/log/nginx/oliacesso-error.log 2>/dev/null || sudo tail -f /var/log/nginx/error.log
            ;;
        4)
            log_info "Abrindo múltiplas janelas de log..."
            log_info "Execute os comandos abaixo em terminais separados:"
            echo "sudo journalctl -u oliacesso-server -f"
            echo "sudo tail -f /var/log/nginx/oliacesso-access.log"
            echo "sudo tail -f /var/log/nginx/oliacesso-error.log"
            ;;
        *)
            log_error "Opção inválida!"
            ;;
    esac
}

# Backup manual
manual_backup() {
    log_info "Criando backup manual..."
    
    BACKUP_DIR="$HOME/oliacesso-backup-manual-$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup da aplicação
    if [ -d "/opt/oliacesso-server" ]; then
        sudo cp -r /opt/oliacesso-server $BACKUP_DIR/app
    fi
    
    # Backup das configurações
    sudo cp /etc/systemd/system/oliacesso-server.service $BACKUP_DIR/ 2>/dev/null || true
    sudo cp /etc/nginx/sites-available/oliacesso-server $BACKUP_DIR/ 2>/dev/null || true
    
    sudo chown -R $USER:$USER $BACKUP_DIR
    
    log_success "Backup criado em: $BACKUP_DIR"
}

# Restaurar backup
restore_backup() {
    echo ""
    log_info "Backups disponíveis:"
    
    local backups=($(find $HOME -maxdepth 1 -name "oliacesso-backup-*" -type d 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_warning "Nenhum backup encontrado em $HOME"
        return
    fi
    
    for i in "${!backups[@]}"; do
        echo "$((i+1))) $(basename ${backups[$i]})"
    done
    
    echo ""
    read -p "Escolha o backup para restaurar (0 para cancelar): " backup_choice
    
    if [ "$backup_choice" -eq 0 ] 2>/dev/null; then
        log_info "Operação cancelada"
        return
    fi
    
    if [ "$backup_choice" -gt 0 ] 2>/dev/null && [ "$backup_choice" -le "${#backups[@]}" ]; then
        local selected_backup="${backups[$((backup_choice-1))]}"
        
        log_warning "ATENÇÃO: Esta operação irá sobrescrever a instalação atual!"
        read -p "Continuar? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Restaurando backup: $(basename $selected_backup)"
            
            # Parar serviço
            sudo systemctl stop oliacesso-server 2>/dev/null || true
            
            # Restaurar aplicação
            if [ -d "$selected_backup/app" ]; then
                sudo rm -rf /opt/oliacesso-server
                sudo cp -r $selected_backup/app /opt/oliacesso-server
            fi
            
            # Restaurar configurações
            if [ -f "$selected_backup/oliacesso-server.service" ]; then
                sudo cp $selected_backup/oliacesso-server.service /etc/systemd/system/
                sudo systemctl daemon-reload
            fi
            
            if [ -f "$selected_backup/oliacesso-server" ]; then
                sudo cp $selected_backup/oliacesso-server /etc/nginx/sites-available/
            fi
            
            # Reiniciar serviços
            sudo systemctl start oliacesso-server
            sudo systemctl reload nginx 2>/dev/null || true
            
            log_success "Backup restaurado com sucesso!"
        fi
    else
        log_error "Opção inválida!"
    fi
}

# Reiniciar serviços
restart_services() {
    echo ""
    echo "Escolha os serviços para reiniciar:"
    echo "1) Apenas OliAcesso"
    echo "2) Apenas Nginx"
    echo "3) Ambos"
    echo ""
    read -p "Opção: " restart_choice
    
    case $restart_choice in
        1)
            log_info "Reiniciando serviço OliAcesso..."
            sudo systemctl restart oliacesso-server
            log_success "Serviço OliAcesso reiniciado"
            ;;
        2)
            log_info "Reiniciando Nginx..."
            sudo systemctl restart nginx
            log_success "Nginx reiniciado"
            ;;
        3)
            log_info "Reiniciando ambos os serviços..."
            sudo systemctl restart oliacesso-server
            sudo systemctl restart nginx
            log_success "Ambos os serviços reiniciados"
            ;;
        *)
            log_error "Opção inválida!"
            ;;
    esac
}

# Executar desinstalação
run_uninstall() {
    log_warning "Iniciando processo de desinstalação..."
    cd "$PROJECT_ROOT"
    chmod +x scripts/uninstall-server.sh
    ./scripts/uninstall-server.sh
}

# Mostrar documentação
show_documentation() {
    if [ -f "$SCRIPT_DIR/README.md" ]; then
        less "$SCRIPT_DIR/README.md"
    else
        log_error "Documentação não encontrada!"
    fi
}

# Mostrar comandos úteis
show_useful_commands() {
    echo ""
    echo "=================================================="
    echo "    COMANDOS ÚTEIS"
    echo "=================================================="
    echo ""
    
    echo -e "${BLUE}STATUS DOS SERVIÇOS:${NC}"
    echo "sudo systemctl status oliacesso-server"
    echo "sudo systemctl status nginx"
    echo ""
    
    echo -e "${BLUE}CONTROLE DOS SERVIÇOS:${NC}"
    echo "sudo systemctl start|stop|restart oliacesso-server"
    echo "sudo systemctl start|stop|restart nginx"
    echo ""
    
    echo -e "${BLUE}LOGS:${NC}"
    echo "sudo journalctl -u oliacesso-server -f"
    echo "sudo tail -f /var/log/nginx/oliacesso-*.log"
    echo ""
    
    echo -e "${BLUE}CONECTIVIDADE:${NC}"
    echo "curl -I http://localhost:7070/health"
    echo "sudo netstat -tlnp | grep dotnet"
    echo ""
    
    echo -e "${BLUE}SSL/CERTIFICADOS:${NC}"
    echo "sudo certbot certificates"
    echo "sudo certbot renew --dry-run"
    echo ""
    
    echo -e "${BLUE}FIREWALL:${NC}"
    echo "sudo ufw status"
    echo "sudo ufw allow 7070/tcp"
    echo ""
    
    echo -e "${BLUE}SISTEMA:${NC}"
    echo "df -h /opt/oliacesso-server"
    echo "free -h"
    echo "ps aux | grep dotnet"
    echo ""
    
    read -p "Pressione Enter para continuar..."
}

# Função principal
main() {
    check_scripts
    
    while true; do
        show_header
        show_main_menu
        
        read -p "Escolha uma opção: " choice
        
        case $choice in
            1)
                run_installation
                ;;
            2)
                run_deploy
                ;;
            3)
                run_ssl_setup
                ;;
            4)
                run_monitor
                ;;
            5)
                run_update
                ;;
            6)
                view_logs
                ;;
            7)
                manual_backup
                ;;
            8)
                restore_backup
                ;;
            9)
                restart_services
                ;;
            10)
                run_uninstall
                ;;
            11)
                show_documentation
                ;;
            12)
                show_useful_commands
                ;;
            0)
                log_info "Saindo..."
                exit 0
                ;;
            *)
                log_error "Opção inválida!"
                ;;
        esac
        
        echo ""
        read -p "Pressione Enter para continuar..."
    done
}

# Executar função principal
main "$@"