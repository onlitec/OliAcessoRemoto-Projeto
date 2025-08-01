# 🔧 Correção da Configuração de Porta do Servidor

## 📋 Problema Identificado

O servidor OliAcessoRemoto foi instalado no IP **172.20.120.40** mas estava configurado para rodar na **porta 7070** em vez da porta 5000 esperada pelo cliente.

## 🔍 Diagnóstico Realizado

### Status das Portas no Servidor:
```bash
# Verificação via SSH
ssh alfreire@172.20.120.40 "ss -tlnp | grep -E ':(5000|7070)'"

# Resultado:
LISTEN 0      512        127.0.0.1:5000       0.0.0.0:*             
LISTEN 0      512          0.0.0.0:7070       0.0.0.0:*    users:(("dotnet",pid=293,fd=294))   
LISTEN 0      512            [::1]:5000          [::]:*             
```

### Configuração do Servidor:
- **Porta 5000**: Apenas localhost (não acessível externamente)
- **Porta 7070**: Acessível externamente (configuração de produção)

### Arquivo de Configuração de Produção:
```json
{
  "Networking": {
    "BindAddress": "0.0.0.0",
    "Port": 7070,
    "EnableIPv6": false
  }
}
```

## ✅ Correções Implementadas

### 1. Arquivo `settings.json` (Distribuição)
```json
{
  "ServerAddress": "http://172.20.120.40:7070",
  "ServerPort": "7070"
}
```

### 2. Código `MainWindow.xaml.cs`
- Atualizado método `ConnectButton_Click`
- Atualizado método `StartServerButton_Click`  
- Atualizado método `RestoreDefaultSettings`
- Atualizado método `LoadSettings`

**Antes:**
```csharp
serverUrl = "http://localhost:5000";
```

**Depois:**
```csharp
serverUrl = "http://172.20.120.40:7070";
```

## 🧪 Testes de Conectividade

### Health Check do Servidor:
```bash
ssh alfreire@172.20.120.40 "curl -s http://localhost:7070/health"
# Resultado: {"status":"Healthy","timestamp":"2025-07-31T23:34:14.4241603Z","version":"1.0.0","environment":"Production"}
```

### Status: ✅ Servidor funcionando corretamente na porta 7070

## 📦 Arquivos Atualizados

1. `OliAcessoRemoto\Distribuicao\settings.json`
2. `OliAcessoRemoto\MainWindow.xaml.cs`
3. `OliAcessoRemoto\publish\settings.json`

## 🚀 Próximos Passos

1. ✅ Cliente compilado com novas configurações
2. ✅ Arquivo settings.json atualizado
3. ✅ Conectividade com servidor verificada
4. 🔄 Testar conexão cliente-servidor

## 📝 Informações de Acesso

- **Servidor IP**: 172.20.120.40
- **Porta**: 7070
- **URL Completa**: http://172.20.120.40:7070
- **SignalR Hub**: http://172.20.120.40:7070/remoteAccessHub
- **Health Check**: http://172.20.120.40:7070/health

## 🔐 Credenciais SSH

- **Usuário**: alfreire@172.20.120.40
- **Senha**: ae3a89f745

---
*Correção realizada em: 31/07/2025*