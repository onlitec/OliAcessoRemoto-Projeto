#!/bin/bash

# Script de início rápido para OliAcesso Remoto Server
# Detecta o estado atual e sugere próximos passos

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

# Verificar sistema operacional
check_os() {
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log_error "Este script é apenas para Ubuntu!"
        echo "Sistema detectado: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
        exit 1
    fi
    
    VERSION=$(lsb_release -rs 2>/dev/null || echo "Desconhecida")
    log_info "Sistema: Ubuntu $VERSION"
}

# Verificar se está rodando como usuário normal
check_user() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script não deve ser executado como root!"
        log_info "Execute como usuário normal: ./quick-start.sh"
        exit 1
    fi
    
    log_info "Usuário: $USER"
}

# Detectar estado da instalação
detect_installation_state() {
    local state="not_installed"
    
    # Verificar se .NET está instalado
    if command -v dotnet &> /dev/null; then
        state="dotnet_installed"
        
        # Verificar se o serviço existe
        if systemctl list-unit-files | grep -q "oliacesso-server"; then
            state="service_installed"
            
            # Verificar se está rodando
            if systemctl is-active --quiet oliacesso-server; then
                state="running"
                
                # Verificar se está respondendo
                if curl -f http://localhost:7070/health &> /dev/null 2>&1; then
                    state="fully_operational"
                fi
            fi
        fi
    fi
    
    echo $state
}

# Mostrar status atual
show_current_status() {
    echo -e "${CYAN}"
    echo "=================================================="
    echo "    OliAcesso Remoto Server - Início Rápido"
    echo "=================================================="
    echo -e "${NC}"
    echo ""
    
    local state=$(detect_installation_state)
    
    case $state in
        "not_installed")
            echo -e "${RED}❌ Sistema não instalado${NC}"
            echo ""
            echo "Componentes necessários:"
            echo "  - .NET 9 Runtime"
            echo "  - Nginx"
            echo "  - Docker (opcional)"
            echo "  - Configurações de firewall"
            ;;
        "dotnet_installed")
            echo -e "${YELLOW}⚠️  .NET instalado, mas servidor não configurado${NC}"
            echo ""
            echo "Próximos passos necessários:"
            echo "  - Configurar serviço systemd"
            echo "  - Fazer deploy da aplicação"
            echo "  - Configurar Nginx"
            ;;
        "service_installed")
            echo -e "${YELLOW}⚠️  Serviço configurado, mas não está rodando${NC}"
            echo ""
            echo "Status dos componentes:"
            echo "  ✅ .NET: $(dotnet --version)"
            echo "  ❌ Serviço: Parado"
            ;;
        "running")
            echo -e "${YELLOW}⚠️  Serviço rodando, mas aplicação não responde${NC}"
            echo ""
            echo "Status dos componentes:"
            echo "  ✅ .NET: $(dotnet --version)"
            echo "  ✅ Serviço: Rodando"
            echo "  ❌ Aplicação: Não responde"
            ;;
        "fully_operational")
            echo -e "${GREEN}✅ Sistema totalmente operacional${NC}"
            echo ""
            echo "Status dos componentes:"
            echo "  ✅ .NET: $(dotnet --version)"
            echo "  ✅ Serviço: Rodando"
            echo "  ✅ Aplicação: Respondendo"
            
            if systemctl is-active --quiet nginx; then
                echo "  ✅ Nginx: Rodando"
            else
                echo "  ⚠️  Nginx: Parado"
            fi
            
            if command -v certbot &> /dev/null && sudo certbot certificates 2>/dev/null | grep -q "Certificate Name"; then
                echo "  ✅ SSL: Configurado"
            else
                echo "  ⚠️  SSL: Não configurado"
            fi
            ;;
    esac
    
    echo ""
}

# Sugerir próximos passos
suggest_next_steps() {
    local state=$(detect_installation_state)
    
    echo -e "${PURPLE}PRÓXIMOS PASSOS RECOMENDADOS:${NC}"
    echo ""
    
    case $state in
        "not_installed")
            echo "1. Execute a instalação inicial:"
            echo "   ${CYAN}./install-ubuntu.sh${NC}"
            echo ""
            echo "2. Após a instalação, faça o deploy:"
            echo "   ${CYAN}./scripts/deploy-server.sh${NC}"
            echo ""
            echo "3. Configure SSL (opcional):"
            echo "   ${CYAN}./scripts/setup-ssl.sh${NC}"
            ;;
        "dotnet_installed")
            echo "1. Configure o serviço e faça deploy:"
            echo "   ${CYAN}./scripts/deploy-server.sh${NC}"
            echo ""
            echo "2. Configure SSL (opcional):"
            echo "   ${CYAN}./scripts/setup-ssl.sh${NC}"
            ;;
        "service_installed")
            echo "1. Faça o deploy da aplicação:"
            echo "   ${CYAN}./scripts/deploy-server.sh${NC}"
            echo ""
            echo "2. Ou inicie o serviço manualmente:"
            echo "   ${CYAN}sudo systemctl start oliacesso-server${NC}"
            ;;
        "running")
            echo "1. Verifique os logs para diagnosticar:"
            echo "   ${CYAN}sudo journalctl -u oliacesso-server -f${NC}"
            echo ""
            echo "2. Ou refaça o deploy:"
            echo "   ${CYAN}./scripts/deploy-server.sh${NC}"
            ;;
        "fully_operational")
            echo "✅ Sistema funcionando perfeitamente!"
            echo ""
            echo "Opções de manutenção:"
            echo "1. Monitorar sistema:"
            echo "   ${CYAN}./scripts/monitor-server.sh${NC}"
            echo ""
            echo "2. Atualizar sistema:"
            echo "   ${CYAN}./scripts/update-server.sh${NC}"
            echo ""
            echo "3. Configurar SSL (se ainda não configurado):"
            echo "   ${CYAN}./scripts/setup-ssl.sh${NC}"
            echo ""
            echo "4. Acessar aplicação:"
            echo "   ${CYAN}http://localhost:7070${NC}"
            ;;
    esac
}

# Mostrar comandos úteis
show_useful_commands() {
    echo ""
    echo -e "${PURPLE}COMANDOS ÚTEIS:${NC}"
    echo ""
    
    echo -e "${BLUE}Gerenciamento completo:${NC}"
    echo "  ./scripts/manage-server.sh"
    echo ""
    
    echo -e "${BLUE}Status rápido:${NC}"
    echo "  sudo systemctl status oliacesso-server"
    echo "  curl -I http://localhost:7070/health"
    echo ""
    
    echo -e "${BLUE}Logs:${NC}"
    echo "  sudo journalctl -u oliacesso-server -f"
    echo "  sudo tail -f /var/log/nginx/oliacesso-*.log"
    echo ""
    
    echo -e "${BLUE}Controle de serviços:${NC}"
    echo "  sudo systemctl start|stop|restart oliacesso-server"
    echo "  sudo systemctl start|stop|restart nginx"
    echo ""
}

# Executar ação rápida
quick_action() {
    local state=$(detect_installation_state)
    
    echo ""
    echo -e "${PURPLE}AÇÕES RÁPIDAS:${NC}"
    
    case $state in
        "not_installed")
            echo "1) Instalar tudo automaticamente"
            echo "2) Ver documentação"
            ;;
        "dotnet_installed"|"service_installed")
            echo "1) Fazer deploy da aplicação"
            echo "2) Ver logs"
            echo "3) Abrir gerenciador completo"
            ;;
        "running")
            echo "1) Ver logs em tempo real"
            echo "2) Refazer deploy"
            echo "3) Reiniciar serviço"
            echo "4) Abrir gerenciador completo"
            ;;
        "fully_operational")
            echo "1) Abrir no navegador"
            echo "2) Ver logs"
            echo "3) Monitorar sistema"
            echo "4) Abrir gerenciador completo"
            ;;
    esac
    
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma ação: " action
    
    case $action in
        1)
            case $state in
                "not_installed")
                    log_info "Iniciando instalação automática..."
                    chmod +x install-ubuntu.sh
                    ./install-ubuntu.sh
                    ;;
                "dotnet_installed"|"service_installed")
                    log_info "Fazendo deploy..."
                    chmod +x scripts/deploy-server.sh
                    ./scripts/deploy-server.sh
                    ;;
                "running")
                    log_info "Visualizando logs (Ctrl+C para sair)..."
                    sudo journalctl -u oliacesso-server -f
                    ;;
                "fully_operational")
                    log_info "Abrindo aplicação..."
                    if command -v xdg-open &> /dev/null; then
                        xdg-open http://localhost:7070
                    else
                        echo "Acesse: http://localhost:7070"
                    fi
                    ;;
            esac
            ;;
        2)
            case $state in
                "not_installed")
                    if [ -f "scripts/README.md" ]; then
                        less scripts/README.md
                    else
                        log_error "Documentação não encontrada!"
                    fi
                    ;;
                "dotnet_installed"|"service_installed"|"running"|"fully_operational")
                    log_info "Visualizando logs (Ctrl+C para sair)..."
                    sudo journalctl -u oliacesso-server -f
                    ;;
            esac
            ;;
        3)
            case $state in
                "dotnet_installed"|"service_installed"|"running")
                    chmod +x scripts/manage-server.sh
                    ./scripts/manage-server.sh
                    ;;
                "fully_operational")
                    chmod +x scripts/monitor-server.sh
                    ./scripts/monitor-server.sh
                    ;;
            esac
            ;;
        4)
            if [ "$state" = "running" ] || [ "$state" = "fully_operational" ]; then
                chmod +x scripts/manage-server.sh
                ./scripts/manage-server.sh
            fi
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
    check_os
    check_user
    show_current_status
    suggest_next_steps
    show_useful_commands
    quick_action
}

# Executar função principal
main "$@"