#!/bin/bash

# Script de desinstalação do OliAcesso Remoto Server
# Remove completamente o servidor e suas configurações

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

# Confirmar desinstalação
confirm_uninstall() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Desinstalação"
    echo "=================================================="
    echo ""
    log_warning "ATENÇÃO: Este script irá remover completamente o OliAcesso Remoto Server!"
    echo ""
    echo "Será removido:"
    echo "- Serviço systemd"
    echo "- Arquivos da aplicação"
    echo "- Configurações do Nginx"
    echo "- Dados da aplicação"
    echo ""
    log_warning "Esta ação NÃO PODE ser desfeita!"
    echo ""
    
    read -p "Tem certeza que deseja continuar? Digite 'CONFIRMAR' para prosseguir: " confirmation
    
    if [ "$confirmation" != "CONFIRMAR" ]; then
        log_info "Desinstalação cancelada pelo usuário"
        exit 0
    fi
    
    echo ""
    read -p "Deseja fazer backup antes da desinstalação? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        create_backup
    fi
}

# Criar backup antes da desinstalação
create_backup() {
    log_info "Criando backup antes da desinstalação..."
    
    BACKUP_DIR="$HOME/oliacesso-backup-uninstall-$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup da aplicação
    if [ -d "$SERVER_DIR" ]; then
        sudo cp -r $SERVER_DIR $BACKUP_DIR/app
    fi
    
    # Backup das configurações
    if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
        sudo cp /etc/systemd/system/$SERVICE_NAME.service $BACKUP_DIR/
    fi
    
    if [ -f "/etc/nginx/sites-available/oliacesso-server" ]; then
        sudo cp /etc/nginx/sites-available/oliacesso-server $BACKUP_DIR/
    fi
    
    # Backup dos logs
    if [ -d "/var/log/nginx" ]; then
        sudo cp /var/log/nginx/oliacesso-*.log $BACKUP_DIR/ 2>/dev/null || true
    fi
    
    sudo chown -R $USER:$USER $BACKUP_DIR
    
    log_success "Backup criado em $BACKUP_DIR"
    echo ""
}

# Parar e desabilitar serviço
stop_service() {
    log_info "Parando e desabilitando serviço..."
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        sudo systemctl stop $SERVICE_NAME
        log_success "Serviço parado"
    fi
    
    if systemctl is-enabled --quiet $SERVICE_NAME; then
        sudo systemctl disable $SERVICE_NAME
        log_success "Serviço desabilitado"
    fi
}

# Remover serviço systemd
remove_systemd_service() {
    log_info "Removendo serviço systemd..."
    
    if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
        sudo rm /etc/systemd/system/$SERVICE_NAME.service
        sudo systemctl daemon-reload
        log_success "Serviço systemd removido"
    else
        log_info "Serviço systemd não encontrado"
    fi
}

# Remover arquivos da aplicação
remove_application_files() {
    log_info "Removendo arquivos da aplicação..."
    
    if [ -d "$SERVER_DIR" ]; then
        sudo rm -rf $SERVER_DIR
        log_success "Arquivos da aplicação removidos"
    else
        log_info "Diretório da aplicação não encontrado"
    fi
}

# Remover configurações do Nginx
remove_nginx_config() {
    log_info "Removendo configurações do Nginx..."
    
    # Remover site habilitado
    if [ -L "/etc/nginx/sites-enabled/oliacesso-server" ]; then
        sudo rm /etc/nginx/sites-enabled/oliacesso-server
        log_success "Site Nginx desabilitado"
    fi
    
    # Remover configuração
    if [ -f "/etc/nginx/sites-available/oliacesso-server" ]; then
        sudo rm /etc/nginx/sites-available/oliacesso-server
        log_success "Configuração Nginx removida"
    fi
    
    # Testar configuração Nginx
    if sudo nginx -t &> /dev/null; then
        sudo systemctl reload nginx
        log_success "Nginx recarregado"
    else
        log_warning "Erro na configuração Nginx após remoção"
    fi
}

# Remover certificados SSL (opcional)
remove_ssl_certificates() {
    echo ""
    read -p "Deseja remover os certificados SSL? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removendo certificados SSL..."
        
        if command -v certbot &> /dev/null; then
            # Listar certificados
            DOMAINS=$(sudo certbot certificates 2>/dev/null | grep "Certificate Name:" | cut -d':' -f2 | tr -d ' ')
            
            for domain in $DOMAINS; do
                read -p "Remover certificado para $domain? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sudo certbot delete --cert-name $domain
                    log_success "Certificado para $domain removido"
                fi
            done
        else
            log_info "Certbot não está instalado"
        fi
    fi
}

# Remover regras do firewall
remove_firewall_rules() {
    log_info "Removendo regras do firewall..."
    
    # Remover regras específicas do OliAcesso
    sudo ufw delete allow 7070/tcp 2>/dev/null || true
    sudo ufw delete allow 7071/tcp 2>/dev/null || true
    
    log_success "Regras do firewall removidas"
}

# Remover logs
remove_logs() {
    log_info "Removendo logs..."
    
    # Remover logs do systemd
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s
    
    # Remover logs específicos do Nginx
    sudo rm -f /var/log/nginx/oliacesso-*.log*
    
    log_success "Logs removidos"
}

# Remover usuário e grupo (se criados especificamente)
remove_user_group() {
    echo ""
    read -p "Foi criado um usuário específico para o OliAcesso? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Digite o nome do usuário: " username
        
        if id "$username" &>/dev/null; then
            read -p "Remover usuário $username? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo userdel -r $username 2>/dev/null || true
                log_success "Usuário $username removido"
            fi
        fi
    fi
}

# Limpeza final
final_cleanup() {
    log_info "Executando limpeza final..."
    
    # Limpar cache do apt
    sudo apt autoremove -y
    sudo apt autoclean
    
    # Remover arquivos temporários
    sudo rm -rf /tmp/oliacesso-*
    
    log_success "Limpeza final concluída"
}

# Verificar o que ainda está instalado
check_remaining() {
    echo ""
    echo "=================================================="
    log_info "VERIFICAÇÃO PÓS-DESINSTALAÇÃO"
    echo "=================================================="
    
    # Verificar se o serviço ainda existe
    if systemctl list-unit-files | grep -q $SERVICE_NAME; then
        log_warning "Serviço $SERVICE_NAME ainda está listado"
    else
        log_success "Serviço removido completamente"
    fi
    
    # Verificar diretórios
    if [ -d "$SERVER_DIR" ]; then
        log_warning "Diretório $SERVER_DIR ainda existe"
    else
        log_success "Diretório da aplicação removido"
    fi
    
    # Verificar configurações Nginx
    if [ -f "/etc/nginx/sites-available/oliacesso-server" ]; then
        log_warning "Configuração Nginx ainda existe"
    else
        log_success "Configuração Nginx removida"
    fi
    
    # Verificar processos
    if pgrep -f "OliAcessoRemoto.Servidor" > /dev/null; then
        log_warning "Processos da aplicação ainda estão rodando"
    else
        log_success "Nenhum processo da aplicação encontrado"
    fi
}

# Mostrar relatório final
show_final_report() {
    echo ""
    echo "=================================================="
    log_success "DESINSTALAÇÃO CONCLUÍDA"
    echo "=================================================="
    echo ""
    
    if [ -n "$BACKUP_DIR" ]; then
        log_info "Backup salvo em: $BACKUP_DIR"
        echo ""
    fi
    
    log_info "Componentes que permanecem instalados:"
    echo "- .NET Runtime (pode ser usado por outras aplicações)"
    echo "- Nginx (pode estar sendo usado por outros sites)"
    echo "- Docker (pode estar sendo usado por outros containers)"
    echo "- Firewall UFW (configuração básica mantida)"
    echo ""
    
    log_info "Para remover completamente estes componentes:"
    echo "- .NET: sudo apt remove --purge dotnet-*"
    echo "- Nginx: sudo apt remove --purge nginx nginx-common"
    echo "- Docker: sudo apt remove --purge docker-ce docker-ce-cli containerd.io"
    echo ""
    
    log_warning "IMPORTANTE: Só remova estes componentes se tiver certeza"
    log_warning "de que não são usados por outras aplicações!"
}

# Função principal
main() {
    check_user
    confirm_uninstall
    
    log_info "Iniciando desinstalação..."
    echo ""
    
    stop_service
    remove_systemd_service
    remove_application_files
    remove_nginx_config
    remove_ssl_certificates
    remove_firewall_rules
    remove_logs
    remove_user_group
    final_cleanup
    check_remaining
    show_final_report
}

# Executar função principal
main "$@"