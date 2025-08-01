#!/bin/bash

# Script de configuração SSL/HTTPS para OliAcesso Remoto Server
# Configura certificados SSL usando Let's Encrypt e Nginx

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

# Verificar se Nginx está instalado
check_nginx() {
    if ! command -v nginx &> /dev/null; then
        log_error "Nginx não está instalado! Execute primeiro o script install-ubuntu.sh"
        exit 1
    fi
}

# Verificar se certbot está instalado
check_certbot() {
    if ! command -v certbot &> /dev/null; then
        log_info "Instalando Certbot..."
        sudo apt update
        sudo apt install -y certbot python3-certbot-nginx
        log_success "Certbot instalado"
    fi
}

# Solicitar informações do domínio
get_domain_info() {
    echo ""
    log_info "Configuração de SSL/HTTPS"
    echo ""
    
    read -p "Digite o domínio (ex: servidor.exemplo.com): " DOMAIN
    read -p "Digite o email para o certificado: " EMAIL
    
    if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
        log_error "Domínio e email são obrigatórios!"
        exit 1
    fi
    
    log_info "Domínio: $DOMAIN"
    log_info "Email: $EMAIL"
}

# Criar configuração Nginx
create_nginx_config() {
    log_info "Criando configuração Nginx..."
    
    sudo tee /etc/nginx/sites-available/oliacesso-server > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # Redirecionar para HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    # Logs
    access_log /var/log/nginx/oliacesso-access.log;
    error_log /var/log/nginx/oliacesso-error.log;
    
    # SSL será configurado pelo Certbot
    
    # Proxy para aplicação .NET
    location / {
        proxy_pass http://localhost:7070;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # WebSocket support
    location /ws {
        proxy_pass http://localhost:7070;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
EOF
    
    # Habilitar site
    sudo ln -sf /etc/nginx/sites-available/oliacesso-server /etc/nginx/sites-enabled/
    
    # Remover configuração padrão se existir
    sudo rm -f /etc/nginx/sites-enabled/default
    
    log_success "Configuração Nginx criada"
}

# Testar configuração Nginx
test_nginx_config() {
    log_info "Testando configuração Nginx..."
    
    if sudo nginx -t; then
        log_success "Configuração Nginx válida"
    else
        log_error "Erro na configuração Nginx!"
        exit 1
    fi
}

# Recarregar Nginx
reload_nginx() {
    log_info "Recarregando Nginx..."
    sudo systemctl reload nginx
    log_success "Nginx recarregado"
}

# Configurar certificado SSL
setup_ssl_certificate() {
    log_info "Configurando certificado SSL..."
    
    # Obter certificado
    sudo certbot --nginx \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        --domains "$DOMAIN" \
        --redirect
    
    if [ $? -eq 0 ]; then
        log_success "Certificado SSL configurado com sucesso!"
    else
        log_error "Falha ao configurar certificado SSL"
        exit 1
    fi
}

# Configurar renovação automática
setup_auto_renewal() {
    log_info "Configurando renovação automática..."
    
    # Testar renovação
    sudo certbot renew --dry-run
    
    if [ $? -eq 0 ]; then
        log_success "Renovação automática configurada"
        log_info "O certificado será renovado automaticamente pelo cron"
    else
        log_warning "Problema na configuração de renovação automática"
    fi
}

# Configurar firewall para HTTPS
configure_firewall_https() {
    log_info "Configurando firewall para HTTPS..."
    
    # Permitir HTTPS
    sudo ufw allow 443/tcp
    
    # Mostrar status
    sudo ufw status
    
    log_success "Firewall configurado para HTTPS"
}

# Testar conectividade
test_connectivity() {
    log_info "Testando conectividade..."
    
    echo ""
    log_info "Testando HTTP (deve redirecionar para HTTPS):"
    curl -I "http://$DOMAIN" || log_warning "Falha no teste HTTP"
    
    echo ""
    log_info "Testando HTTPS:"
    curl -I "https://$DOMAIN" || log_warning "Falha no teste HTTPS"
    
    echo ""
}

# Mostrar informações finais
show_final_info() {
    echo ""
    echo "=================================================="
    log_success "SSL/HTTPS configurado com sucesso!"
    echo "=================================================="
    echo ""
    log_info "Seu servidor está disponível em:"
    echo "https://$DOMAIN"
    echo ""
    log_info "Comandos úteis:"
    echo "- Ver status do certificado: sudo certbot certificates"
    echo "- Renovar certificado: sudo certbot renew"
    echo "- Testar renovação: sudo certbot renew --dry-run"
    echo "- Ver logs Nginx: sudo tail -f /var/log/nginx/oliacesso-*.log"
    echo ""
    log_info "O certificado será renovado automaticamente a cada 60 dias"
}

# Função principal
main() {
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Configuração SSL"
    echo "=================================================="
    echo ""
    
    check_root
    check_nginx
    check_certbot
    get_domain_info
    create_nginx_config
    test_nginx_config
    reload_nginx
    setup_ssl_certificate
    setup_auto_renewal
    configure_firewall_https
    test_connectivity
    show_final_info
}

# Executar função principal
main "$@"