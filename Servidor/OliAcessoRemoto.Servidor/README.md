# 🖥️ OliAcesso Remoto - Servidor

Servidor moderno de acesso remoto construído com .NET 9, ASP.NET Core e SignalR para comunicação em tempo real.

## 🚀 Características

### **Tecnologias Modernas**
- **.NET 9** - Framework mais recente
- **ASP.NET Core** - Web API moderna
- **SignalR** - Comunicação em tempo real
- **Entity Framework Core** - ORM moderno
- **JWT Authentication** - Autenticação segura
- **Serilog** - Logging estruturado
- **Docker** - Containerização
- **BCrypt** - Hash seguro de senhas

### **Funcionalidades**
- ✅ **Autenticação JWT** - Tokens seguros
- ✅ **Comunicação em tempo real** - SignalR WebSockets
- ✅ **Controle remoto** - Mouse e teclado
- ✅ **Compartilhamento de tela** - Transmissão em tempo real
- ✅ **Qualidade adaptativa** - Ajuste automático de qualidade
- ✅ **Compressão de dados** - Otimização de banda
- ✅ **Múltiplas sessões** - Várias conexões simultâneas
- ✅ **Logs estruturados** - Monitoramento completo
- ✅ **Health checks** - Monitoramento de saúde
- ✅ **API REST** - Interface programática
- ✅ **Swagger/OpenAPI** - Documentação automática

### **Segurança**
- 🔐 **Autenticação JWT** com expiração
- 🔐 **Hash BCrypt** para senhas
- 🔐 **CORS configurável**
- 🔐 **HTTPS obrigatório** em produção
- 🔐 **Validação de entrada** rigorosa
- 🔐 **Rate limiting** (configurável)

## 📋 Requisitos

### **Sistema Operacional**
- Ubuntu 20.04, 22.04 ou 24.04 LTS
- Debian 11 ou 12
- CentOS/RHEL 8+ (com adaptações)

### **Software**
- .NET 9 SDK/Runtime
- Docker (opcional, mas recomendado)
- Nginx (para proxy reverso)
- 2GB RAM mínimo
- 10GB espaço em disco

## 🛠️ Instalação

### **Instalação Automática (Ubuntu)**

```bash
# Baixar e executar script de instalação
curl -fsSL https://raw.githubusercontent.com/seu-repo/install-ubuntu.sh | bash

# Ou baixar e revisar primeiro
wget https://raw.githubusercontent.com/seu-repo/install-ubuntu.sh
chmod +x install-ubuntu.sh
./install-ubuntu.sh
```

### **Instalação Manual**

#### **1. Instalar .NET 9**
```bash
# Ubuntu
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
```

#### **2. Clonar e Compilar**
```bash
git clone https://github.com/seu-repo/oliacesso-servidor.git
cd oliacesso-servidor
dotnet restore
dotnet build -c Release
dotnet publish -c Release -o /opt/oliacesso-server
```

#### **3. Configurar Serviço**
```bash
sudo cp oliacesso-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable oliacesso-server
sudo systemctl start oliacesso-server
```

### **Instalação com Docker**

#### **Docker Compose (Recomendado)**
```bash
# Clonar repositório
git clone https://github.com/seu-repo/oliacesso-servidor.git
cd oliacesso-servidor

# Configurar variáveis de ambiente
cp .env.example .env
nano .env

# Iniciar serviços
docker-compose up -d

# Verificar logs
docker-compose logs -f oliacesso-server
```

#### **Docker Manual**
```bash
# Build da imagem
docker build -t oliacesso-server .

# Executar container
docker run -d \
  --name oliacesso-server \
  -p 7070:80 \
  -v $(pwd)/logs:/app/logs \
  -e ASPNETCORE_ENVIRONMENT=Production \
  oliacesso-server
```

## ⚙️ Configuração

### **Arquivo de Configuração**
Edite `appsettings.json` ou use variáveis de ambiente:

```json
{
  "Jwt": {
    "Key": "sua-chave-secreta-super-segura-aqui",
    "Issuer": "OliAcessoRemoto.Servidor",
    "Audience": "OliAcessoRemoto.Cliente"
  },
  "Server": {
    "MaxConnections": 100,
    "MaxConnectionDuration": "24:00:00"
  }
}
```

### **Variáveis de Ambiente**
```bash
export ASPNETCORE_ENVIRONMENT=Production
export Jwt__Key="sua-chave-secreta"
export Server__MaxConnections=100
```

### **SSL/HTTPS**
```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com

# Renovação automática
sudo crontab -e
# Adicionar: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔌 API Endpoints

### **Autenticação**
```http
POST /api/auth/login
POST /api/auth/validate
POST /api/auth/revoke
GET  /api/auth/server-info
```

### **Conexões**
```http
GET  /api/connections/active
GET  /api/connections/{id}
GET  /api/connections/clients/online
GET  /api/connections/statistics
POST /api/connections/{id}/disconnect
```

### **SignalR Hub**
```
/remotehub - WebSocket endpoint para comunicação em tempo real
```

### **Monitoramento**
```http
GET /health - Health check
GET /info - Informações do servidor
```

## 📊 Monitoramento

### **Logs**
```bash
# Logs do serviço
sudo journalctl -u oliacesso-server -f

# Logs da aplicação
tail -f /opt/oliacesso-server/logs/server-*.txt

# Logs do Docker
docker logs -f oliacesso-server
```

### **Métricas**
- **Prometheus** - Coleta de métricas
- **Grafana** - Dashboards visuais
- **Health checks** - Monitoramento de saúde

### **Performance**
```bash
# Status do serviço
sudo systemctl status oliacesso-server

# Uso de recursos
htop
docker stats

# Conexões ativas
curl http://localhost:7070/api/connections/statistics
```

## 🔧 Desenvolvimento

### **Executar Localmente**
```bash
dotnet run --environment Development
```

### **Testes**
```bash
dotnet test
```

### **Build**
```bash
dotnet build -c Release
```

## 🐛 Troubleshooting

### **Problemas Comuns**

#### **Porta em uso**
```bash
sudo lsof -i :7070
sudo kill -9 <PID>
```

#### **Permissões**
```bash
sudo chown -R $USER:$USER /opt/oliacesso-server
chmod 755 /opt/oliacesso-server
```

#### **Firewall**
```bash
sudo ufw allow 7070/tcp
sudo ufw status
```

#### **SSL/Certificados**
```bash
sudo certbot certificates
sudo certbot renew --dry-run
```

### **Logs de Debug**
```bash
# Habilitar logs detalhados
export ASPNETCORE_ENVIRONMENT=Development
export Logging__LogLevel__Default=Debug
```

## 📚 Documentação

- **API Documentation**: `http://seu-servidor:7070/swagger`
- **Health Check**: `http://seu-servidor:7070/health`
- **Server Info**: `http://seu-servidor:7070/info`

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- **Issues**: [GitHub Issues](https://github.com/seu-repo/issues)
- **Documentação**: [Wiki](https://github.com/seu-repo/wiki)
- **Email**: suporte@oliacesso.com

---

**OliAcesso Remoto Server v1.0.0** - Desenvolvido com ❤️ usando .NET 9
