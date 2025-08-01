# 🚀 OliAcesso Remoto Server - Guia de Instalação Ubuntu

Scripts automatizados para instalação e gerenciamento do servidor OliAcesso Remoto no Ubuntu.

## 📋 Pré-requisitos

- Ubuntu 20.04, 22.04 ou 24.04
- Usuário com privilégios sudo
- Conexão com internet
- Pelo menos 2GB de RAM livre
- 5GB de espaço em disco

## ⚡ Início Rápido

### 1. Download e Permissões
```bash
# Dar permissão de execução
chmod +x *.sh
chmod +x scripts/*.sh
```

### 2. Verificar Estado Atual
```bash
# Script inteligente que detecta o estado atual
./quick-start.sh
```

### 3. Instalação Completa (Primeira vez)
```bash
# Instalação automática completa
./install-ubuntu.sh
```

### 4. Deploy da Aplicação
```bash
# Fazer build e deploy
./scripts/deploy-server.sh
```

### 5. Configurar HTTPS (Opcional)
```bash
# Configurar SSL com Let's Encrypt
./scripts/setup-ssl.sh
```

## 🛠️ Scripts Disponíveis

| Script | Descrição | Uso |
|--------|-----------|-----|
| `quick-start.sh` | 🎯 Detecta estado e sugere próximos passos | `./quick-start.sh` |
| `install-ubuntu.sh` | 📦 Instalação inicial completa | `./install-ubuntu.sh` |
| `scripts/manage-server.sh` | 🎛️ Menu de gerenciamento completo | `./scripts/manage-server.sh` |
| `scripts/deploy-server.sh` | 🚀 Deploy/atualização da aplicação | `./scripts/deploy-server.sh` |
| `scripts/setup-ssl.sh` | 🔒 Configuração SSL/HTTPS | `./scripts/setup-ssl.sh` |
| `scripts/monitor-server.sh` | 📊 Monitoramento e diagnóstico | `./scripts/monitor-server.sh` |
| `scripts/update-server.sh` | 🔄 Atualização do sistema | `./scripts/update-server.sh` |
| `scripts/uninstall-server.sh` | 🗑️ Desinstalação completa | `./scripts/uninstall-server.sh` |

## 📖 Fluxo de Instalação Recomendado

### Para Iniciantes
```bash
# 1. Verificar estado atual
./quick-start.sh

# 2. Seguir as sugestões do script
# O script irá guiá-lo através do processo
```

### Para Usuários Avançados
```bash
# 1. Instalação inicial
./install-ubuntu.sh

# 2. Deploy da aplicação
./scripts/deploy-server.sh

# 3. Configurar SSL (se necessário)
./scripts/setup-ssl.sh

# 4. Monitorar
./scripts/monitor-server.sh
```

## 🎛️ Gerenciamento Diário

### Menu Interativo Completo
```bash
./scripts/manage-server.sh
```

### Comandos Rápidos
```bash
# Status dos serviços
sudo systemctl status oliacesso-server
sudo systemctl status nginx

# Ver logs em tempo real
sudo journalctl -u oliacesso-server -f

# Testar conectividade
curl -I http://localhost:7070/health

# Reiniciar serviços
sudo systemctl restart oliacesso-server
```

## 🔧 Solução de Problemas

### Serviço não inicia
```bash
# 1. Verificar logs
sudo journalctl -u oliacesso-server -n 50

# 2. Verificar configuração
./scripts/monitor-server.sh

# 3. Refazer deploy
./scripts/deploy-server.sh
```

### Problemas de conectividade
```bash
# 1. Verificar firewall
sudo ufw status

# 2. Verificar portas
sudo netstat -tlnp | grep dotnet

# 3. Verificar Nginx
sudo nginx -t
```

### Problemas de SSL
```bash
# 1. Verificar certificados
sudo certbot certificates

# 2. Renovar certificados
sudo certbot renew

# 3. Reconfigurar SSL
./scripts/setup-ssl.sh
```

## 📁 Estrutura de Arquivos

```
/opt/oliacesso-server/          # Aplicação
├── OliAcessoRemoto.Servidor.dll
├── appsettings.json
├── appsettings.Production.json
├── data/                       # Banco de dados
├── logs/                       # Logs da aplicação
└── ssl/                        # Certificados

/etc/systemd/system/            # Serviços
└── oliacesso-server.service

/etc/nginx/sites-available/     # Nginx
└── oliacesso-server
```

## 🔄 Backup e Restauração

### Backup Automático
```bash
# Backup manual
./scripts/manage-server.sh
# Escolher opção 7

# Backup durante deploy
# Feito automaticamente pelo deploy-server.sh
```

### Restaurar Backup
```bash
# Menu de restauração
./scripts/manage-server.sh
# Escolher opção 8
```

## 🌐 Acesso à Aplicação

### HTTP (Desenvolvimento)
```
http://seu-servidor:7070
```

### HTTPS (Produção)
```
https://seu-dominio.com
```

### Health Check
```
http://seu-servidor:7070/health
```

## 📊 Monitoramento

### Logs em Tempo Real
```bash
# Logs do serviço
sudo journalctl -u oliacesso-server -f

# Logs do Nginx
sudo tail -f /var/log/nginx/oliacesso-*.log
```

### Status do Sistema
```bash
# Usar o monitor integrado
./scripts/monitor-server.sh

# Ou verificar manualmente
sudo systemctl status oliacesso-server nginx
```

## 🔄 Atualizações

### Atualização Completa
```bash
./scripts/update-server.sh --full
```

### Atualização Específica
```bash
# Apenas sistema
./scripts/update-server.sh --system

# Apenas .NET
./scripts/update-server.sh --dotnet

# Apenas SSL
./scripts/update-server.sh --ssl
```

## 🆘 Suporte

### Diagnóstico Automático
```bash
# Verificação completa do sistema
./scripts/monitor-server.sh

# Estado atual e sugestões
./quick-start.sh
```

### Informações do Sistema
```bash
# Versões instaladas
dotnet --version
nginx -v
lsb_release -a

# Uso de recursos
df -h /opt/oliacesso-server
free -h
```

### Logs Importantes
```bash
# Logs do serviço (últimas 50 linhas)
sudo journalctl -u oliacesso-server -n 50

# Logs de erro do sistema
sudo journalctl --since "1 hour ago" --grep "ERROR\|FATAL"
```

## ⚠️ Notas Importantes

1. **Não execute como root**: Todos os scripts devem ser executados como usuário normal
2. **Backup automático**: Os scripts fazem backup antes de mudanças importantes
3. **Firewall**: As portas necessárias são configuradas automaticamente
4. **SSL**: Certificados são renovados automaticamente
5. **Logs**: Logs antigos são limpos automaticamente

## 🎯 Próximos Passos

Após a instalação bem-sucedida:

1. ✅ Testar a aplicação: `curl -I http://localhost:7070/health`
2. ✅ Configurar SSL se necessário: `./scripts/setup-ssl.sh`
3. ✅ Configurar monitoramento: `./scripts/monitor-server.sh`
4. ✅ Agendar atualizações regulares
5. ✅ Documentar configurações específicas do seu ambiente

---

**💡 Dica**: Use sempre `./quick-start.sh` quando não souber qual script executar. Ele detecta automaticamente o estado atual e sugere os próximos passos!