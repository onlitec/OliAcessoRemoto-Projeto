# Scripts de Instalação e Manutenção - OliAcesso Remoto Server

Este diretório contém scripts para instalação, configuração e manutenção do servidor OliAcesso Remoto no Ubuntu.

## Scripts Disponíveis

### 1. `install-ubuntu.sh` (Raiz do projeto)
**Instalação inicial completa do servidor**
- Instala .NET 9, Docker, Nginx
- Configura firewall e serviços
- Cria estrutura de diretórios
- Configura serviço systemd

```bash
chmod +x install-ubuntu.sh
./install-ubuntu.sh
```

### 2. `deploy-server.sh`
**Deploy e atualização da aplicação**
- Faz build da aplicação
- Para o serviço atual
- Faz backup da versão anterior
- Implanta nova versão
- Reinicia o serviço

```bash
chmod +x scripts/deploy-server.sh
./scripts/deploy-server.sh
```

### 3. `setup-ssl.sh`
**Configuração SSL/HTTPS**
- Configura certificados Let's Encrypt
- Configura Nginx para HTTPS
- Configura renovação automática
- Testa conectividade SSL

```bash
chmod +x scripts/setup-ssl.sh
./scripts/setup-ssl.sh
```

### 4. `monitor-server.sh`
**Monitoramento e diagnóstico**
- Verifica status dos serviços
- Monitora recursos do sistema
- Analisa logs
- Verifica certificados SSL
- Menu interativo para manutenção

```bash
chmod +x scripts/monitor-server.sh
./scripts/monitor-server.sh
```

### 5. `update-server.sh`
**Atualização do sistema e aplicação**
- Atualiza sistema operacional
- Atualiza .NET e dependências
- Renova certificados SSL
- Verifica saúde após atualizações

```bash
chmod +x scripts/update-server.sh
./scripts/update-server.sh --full
```

### 6. `uninstall-server.sh`
**Desinstalação completa**
- Remove aplicação e configurações
- Faz backup antes da remoção
- Remove serviços e certificados
- Limpeza completa do sistema

```bash
chmod +x scripts/uninstall-server.sh
./scripts/uninstall-server.sh
```

## Ordem de Execução Recomendada

### Primeira Instalação
1. `install-ubuntu.sh` - Instalação inicial
2. `deploy-server.sh` - Deploy da aplicação
3. `setup-ssl.sh` - Configurar HTTPS (opcional)

### Manutenção Regular
- `monitor-server.sh` - Verificação diária
- `update-server.sh` - Atualizações mensais
- `deploy-server.sh` - Deploy de novas versões

### Resolução de Problemas
1. `monitor-server.sh` - Diagnóstico
2. `deploy-server.sh` - Redeployment se necessário
3. `update-server.sh --check` - Verificação de saúde

## Permissões dos Scripts

Todos os scripts devem ser executados com permissões de usuário normal (não root). Eles usam `sudo` quando necessário.

```bash
# Dar permissão de execução para todos os scripts
chmod +x install-ubuntu.sh
chmod +x scripts/*.sh
```

## Logs e Monitoramento

### Logs do Sistema
```bash
# Logs do serviço
sudo journalctl -u oliacesso-server -f

# Logs do Nginx
sudo tail -f /var/log/nginx/oliacesso-*.log

# Status dos serviços
sudo systemctl status oliacesso-server
sudo systemctl status nginx
```

### Comandos Úteis
```bash
# Reiniciar serviço
sudo systemctl restart oliacesso-server

# Verificar portas
sudo netstat -tlnp | grep dotnet

# Verificar certificados SSL
sudo certbot certificates

# Testar conectividade
curl -I http://localhost:7070/health
```

## Estrutura de Diretórios

```
/opt/oliacesso-server/          # Aplicação principal
├── OliAcessoRemoto.Servidor.dll
├── appsettings.json
├── appsettings.Production.json
├── data/                       # Dados da aplicação
├── logs/                       # Logs da aplicação
└── ssl/                        # Certificados SSL

/etc/systemd/system/            # Serviços
└── oliacesso-server.service

/etc/nginx/sites-available/     # Configuração Nginx
└── oliacesso-server

/var/log/nginx/                 # Logs Nginx
├── oliacesso-access.log
└── oliacesso-error.log
```

## Backup e Recuperação

Os scripts criam backups automáticos em:
- `/opt/oliacesso-backup-YYYYMMDD_HHMMSS/` - Backups do sistema
- `$HOME/oliacesso-backup-*` - Backups do usuário

### Restaurar Backup
```bash
# Parar serviço
sudo systemctl stop oliacesso-server

# Restaurar arquivos
sudo cp -r /opt/oliacesso-backup-*/app/* /opt/oliacesso-server/

# Reiniciar serviço
sudo systemctl start oliacesso-server
```

## Solução de Problemas Comuns

### Serviço não inicia
```bash
# Verificar logs
sudo journalctl -u oliacesso-server -n 50

# Verificar configuração
sudo systemctl status oliacesso-server

# Redeployar
./scripts/deploy-server.sh
```

### Problemas de SSL
```bash
# Renovar certificados
sudo certbot renew

# Reconfigurar SSL
./scripts/setup-ssl.sh
```

### Problemas de conectividade
```bash
# Verificar firewall
sudo ufw status

# Verificar portas
sudo netstat -tlnp

# Verificar Nginx
sudo nginx -t
sudo systemctl status nginx
```

## Suporte

Para problemas ou dúvidas:
1. Execute `./scripts/monitor-server.sh` para diagnóstico
2. Verifique os logs do sistema
3. Consulte a documentação do projeto