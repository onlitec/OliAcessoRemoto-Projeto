# 🚀 Guia de Instalação do Servidor OliAcesso Remoto
## Ubuntu 22.04 - IP: 172.20.120.40

## 📋 Status do Deploy

✅ **Status**: Deploy concluído com sucesso!
- Servidor instalado e configurado no Ubuntu 22.04 (IP: 172.20.120.40)
- Serviço systemd configurado e ativo
- Health check funcionando: http://172.20.120.40:7070/health
- Configuração CORS corrigida para produção
- Serviço habilitado para inicialização automática

### 📋 Informações do Servidor
- **IP**: 172.20.120.40
- **SO**: Ubuntu 22.04
- **Usuário**: alfreire
- **Porta do Serviço**: 7070
- **URL de Acesso**: http://172.20.120.40:7070

---

## 🛠️ Opções de Instalação

### Opção 1: Deploy Automático (Recomendado)

#### No Windows (PowerShell):
```powershell
# Compilar e fazer deploy completo
.\deploy-server.ps1 -All

# Ou separadamente:
.\deploy-server.ps1 -Build    # Apenas compilar
.\deploy-server.ps1 -Deploy   # Apenas fazer deploy
```

#### No Linux/WSL (Bash):
```bash
# Dar permissão de execução
chmod +x deploy-server.sh

# Executar deploy
./deploy-server.sh
```

### Opção 2: Instalação Manual

#### 1. Preparar o Servidor
```bash
# Conectar ao servidor
ssh alfreire@172.20.120.40

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar .NET 9
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y aspnetcore-runtime-9.0

# Criar diretórios
sudo mkdir -p /opt/oliacesso-server/logs
sudo chown -R alfreire:alfreire /opt/oliacesso-server
```

#### 2. Compilar o Servidor (no Windows)
```powershell
dotnet publish Servidor/OliAcessoRemoto.Servidor.csproj -c Release -o publish-server --self-contained false
```

#### 3. Transferir Arquivos
```bash
# Usando SCP
scp -r publish-server/* alfreire@172.20.120.40:/opt/oliacesso-server/

# Ou usando rsync
rsync -avz publish-server/ alfreire@172.20.120.40:/opt/oliacesso-server/
```

#### 4. Configurar Serviço Systemd
```bash
# No servidor
sudo tee /etc/systemd/system/oliacesso-server.service > /dev/null <<EOF
[Unit]
Description=OliAcesso Remoto Server
After=network.target

[Service]
Type=notify
User=alfreire
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

# Habilitar e iniciar serviço
sudo systemctl daemon-reload
sudo systemctl enable oliacesso-server
sudo systemctl start oliacesso-server
```

#### 5. Configurar Firewall
```bash
sudo ufw allow 7070/tcp
sudo ufw allow 7071/tcp
sudo ufw --force enable
```

---

## 🔧 Comandos de Gerenciamento

### Status do Serviço
```bash
# Verificar status
sudo systemctl status oliacesso-server

# Ver logs em tempo real
sudo journalctl -u oliacesso-server -f

# Ver logs das últimas 100 linhas
sudo journalctl -u oliacesso-server -n 100
```

### Controle do Serviço
```bash
# Iniciar
sudo systemctl start oliacesso-server

# Parar
sudo systemctl stop oliacesso-server

# Reiniciar
sudo systemctl restart oliacesso-server

# Recarregar configuração
sudo systemctl reload oliacesso-server
```

### Monitoramento
```bash
# Verificar se está respondendo
curl http://172.20.120.40:7070/health

# Verificar portas abertas
sudo netstat -tlnp | grep 7070

# Verificar uso de recursos
htop
```

---

## 🌐 URLs e Endpoints

### URLs Principais
- **Servidor**: http://172.20.120.40:7070
- **Health Check**: http://172.20.120.40:7070/health
- **SignalR Hub**: http://172.20.120.40:7070/remotehub

### Endpoints da API
- `GET /health` - Status do servidor
- `POST /api/auth/login` - Autenticação
- `GET /api/connections` - Lista de conexões
- `POST /api/connections/register` - Registrar cliente

---

## 📁 Estrutura de Arquivos

```
/opt/oliacesso-server/
├── OliAcessoRemoto.Servidor.dll      # Executável principal
├── appsettings.json                   # Configuração padrão
├── appsettings.Production.json        # Configuração de produção
├── *.dll                             # Bibliotecas necessárias
├── logs/                             # Logs do servidor
│   └── server-YYYY-MM-DD.txt
└── data/                             # Dados do servidor
    └── connections.db
```

---

## 🔒 Configuração de Segurança

### Firewall (UFW)
```bash
# Verificar status
sudo ufw status

# Regras aplicadas:
# - SSH (22/tcp) - ALLOW
# - HTTP (80/tcp) - ALLOW  
# - HTTPS (443/tcp) - ALLOW
# - OliAcesso (7070/tcp) - ALLOW
# - OliAcesso SSL (7071/tcp) - ALLOW
```

### SSL/TLS (Opcional)
```bash
# Instalar Certbot
sudo apt install -y certbot

# Gerar certificado (se tiver domínio)
sudo certbot certonly --standalone -d seu-dominio.com

# Configurar no appsettings.Production.json
# "RequireHttps": true
# "Urls": "https://0.0.0.0:7071"
```

---

## 🐛 Solução de Problemas

### Servidor não inicia
```bash
# Verificar logs de erro
sudo journalctl -u oliacesso-server -n 50

# Verificar se a porta está em uso
sudo netstat -tlnp | grep 7070

# Verificar permissões
ls -la /opt/oliacesso-server/
```

### Problemas de Conexão
```bash
# Testar conectividade local
curl localhost:7070/health

# Testar conectividade externa
curl 172.20.120.40:7070/health

# Verificar firewall
sudo ufw status verbose
```

### Performance
```bash
# Monitorar recursos
htop
iotop
nethogs

# Verificar logs de performance
tail -f /opt/oliacesso-server/logs/server-$(date +%Y-%m-%d).txt
```

---

## 📊 Monitoramento e Logs

### Localização dos Logs
- **Sistema**: `/var/log/syslog`
- **Serviço**: `journalctl -u oliacesso-server`
- **Aplicação**: `/opt/oliacesso-server/logs/`

### Comandos Úteis
```bash
# Logs em tempo real
sudo journalctl -u oliacesso-server -f

# Logs com filtro de erro
sudo journalctl -u oliacesso-server -p err

# Logs de hoje
sudo journalctl -u oliacesso-server --since today

# Estatísticas do serviço
systemctl show oliacesso-server
```

---

## 🔄 Atualizações

### Deploy de Nova Versão
```bash
# Parar serviço
sudo systemctl stop oliacesso-server

# Fazer backup
cp -r /opt/oliacesso-server /opt/oliacesso-server-backup-$(date +%Y%m%d)

# Transferir novos arquivos
# (usar deploy-server.sh ou manual)

# Iniciar serviço
sudo systemctl start oliacesso-server
```

### Rollback
```bash
# Parar serviço
sudo systemctl stop oliacesso-server

# Restaurar backup
rm -rf /opt/oliacesso-server/*
cp -r /opt/oliacesso-server-backup-YYYYMMDD/* /opt/oliacesso-server/

# Iniciar serviço
sudo systemctl start oliacesso-server
```

---

## 📞 Suporte

### Informações do Sistema
```bash
# Versão do Ubuntu
lsb_release -a

# Versão do .NET
dotnet --version

# Status geral do sistema
systemctl status
```

### Coleta de Logs para Suporte
```bash
# Criar arquivo de diagnóstico
sudo journalctl -u oliacesso-server -n 1000 > oliacesso-diagnostico.log
sudo systemctl status oliacesso-server >> oliacesso-diagnostico.log
curl -v http://localhost:7070/health >> oliacesso-diagnostico.log 2>&1
```

---

**✅ Servidor configurado e pronto para uso!**

**URL de acesso**: http://172.20.120.40:7070