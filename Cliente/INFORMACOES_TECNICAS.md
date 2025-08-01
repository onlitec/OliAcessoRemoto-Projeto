# INFORMAÇÕES TÉCNICAS - OnliDesk V2.0

## 📋 Especificações Técnicas

### **Versão do Software**
- **Nome**: OnliDesk V2.0
- **Versão**: 2.0.0
- **Data de Build**: Janeiro 2025
- **Framework**: .NET 9.0

### **Requisitos do Sistema**
- **Sistema Operacional**: Windows 10/11 (x64)
- **Framework**: .NET 9.0 Runtime
- **Memória RAM**: Mínimo 512 MB
- **Espaço em Disco**: 50 MB
- **Conexão**: Internet (para conectar ao servidor)

### **Configurações de Rede**
- **Servidor Padrão**: http://172.20.120.40:7070
- **Protocolo**: HTTP/HTTPS
- **Comunicação**: SignalR WebSockets
- **Porta do Servidor**: 7070 (configurável)

## 🔧 Funcionalidades Implementadas

### **V2.0 - Novidades**
✅ **Conexão Automática ao Servidor**
- Conecta automaticamente ao iniciar
- Não requer intervenção manual
- Conexão em background

✅ **Interface Melhorada**
- Feedback visual aprimorado
- Status de conexão em tempo real
- Mensagens de erro mais claras

✅ **Configuração Flexível**
- Endereço do servidor configurável
- Configurações salvas em JSON
- Restauração de padrões

### **Funcionalidades Existentes**
✅ Geração automática de ID único
✅ Conexão cliente-servidor
✅ Recebimento de solicitações de acesso
✅ Sistema de configurações
✅ Histórico de conexões recentes
✅ Cópia de ID para área de transferência

## 📁 Estrutura de Arquivos

### **Arquivos Principais**
- `OliAcessoRemoto.exe` - Executável principal
- `settings.json` - Configurações do usuário
- `Executar-OnliDesk.bat` - Script de execução

### **Bibliotecas (.dll)**
- SignalR Client Libraries
- Microsoft Extensions
- Identity Model
- Newtonsoft.Json
- System.Net.ServerSentEvents

### **Arquivos de Configuração**
- `OliAcessoRemoto.runtimeconfig.json` - Configuração do runtime
- `OliAcessoRemoto.deps.json` - Dependências

## 🔄 Processo de Inicialização

1. **Carregamento da Aplicação**
   - Inicialização do WPF
   - Carregamento das configurações
   - Geração/carregamento do ID local

2. **Conexão Automática** (NOVO na V2.0)
   - Leitura do endereço do servidor
   - Tentativa de conexão em background
   - Registro do cliente no servidor
   - Atualização do status da interface

3. **Estado Operacional**
   - Interface pronta para uso
   - Aguardando solicitações de conexão
   - Monitoramento contínuo da conexão

## 🛠️ Resolução de Problemas

### **Problemas Comuns**

**1. Cliente não conecta automaticamente**
- Verificar se o servidor está ativo
- Confirmar endereço do servidor em Configurações
- Verificar conectividade de rede

**2. Erro de .NET Runtime**
- Instalar .NET 9.0 Runtime
- Reiniciar o sistema após instalação

**3. Firewall/Antivírus**
- Adicionar exceção para OliAcessoRemoto.exe
- Liberar comunicação na porta configurada

### **Logs e Diagnóstico**
- Erros são exibidos na interface
- Verificar configurações em settings.json
- Testar conectividade manual se necessário

## 📞 Suporte Técnico

Para suporte técnico:
- Verificar este arquivo primeiro
- Consultar README.md
- Contatar equipe de desenvolvimento

---
**OnliDesk V2.0 - Desenvolvido com .NET 9.0 e SignalR**