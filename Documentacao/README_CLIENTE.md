# OliAcesso Remoto - Cliente Windows

Um cliente de acesso remoto moderno e seguro para Windows, desenvolvido em WPF com .NET 9.

## 📋 Características

- **Interface Moderna**: Interface WPF intuitiva e fácil de usar
- **Executável Independente**: Não requer instalação do .NET Framework
- **Conexão Segura**: Comunicação via SignalR com autenticação JWT
- **ID Simples**: Sistema de IDs numéricos de 9 dígitos para fácil compartilhamento
- **Configurações Personalizáveis**: Opções de qualidade, segurança e comportamento
- **Histórico de Conexões**: Mantém registro das conexões recentes

## 🚀 Instalação

### Opção 1: Instalação Automática (Recomendada)

1. **Baixe os arquivos** do cliente para uma pasta temporária
2. **Execute o PowerShell como Administrador**:
   - Clique com o botão direito no menu Iniciar
   - Selecione "Windows PowerShell (Admin)" ou "Terminal (Admin)"
3. **Navegue até a pasta** onde estão os arquivos:
   ```powershell
   cd "C:\caminho\para\os\arquivos"
   ```
4. **Execute o instalador**:
   ```powershell
   .\install.ps1
   ```
5. **Siga as instruções** na tela

### Opção 2: Execução Portátil

1. **Baixe os arquivos** para qualquer pasta
2. **Execute diretamente** o arquivo `OliAcessoRemoto.exe`
3. O aplicativo funcionará sem instalação

## 📁 Arquivos Necessários

Para funcionamento correto, certifique-se de que os seguintes arquivos estão na mesma pasta:

- `OliAcessoRemoto.exe` (arquivo principal)
- `D3DCompiler_47_cor3.dll`
- `PenImc_cor3.dll`
- `PresentationNative_cor3.dll`
- `vcruntime140_cor3.dll`
- `wpfgfx_cor3.dll`

## 🎯 Como Usar

### Para Receber Conexões:

1. **Inicie o aplicativo**
2. **Configure o servidor** (se necessário):
   - Vá para a aba "Configurações"
   - Defina o endereço do servidor (padrão: http://localhost:5000)
3. **Clique em "Iniciar Servidor"**
4. **Compartilhe seu ID** (exibido na tela) com quem deseja conectar
5. **Aceite as conexões** quando solicitado

### Para Conectar a Outro Computador:

1. **Obtenha o ID** do computador de destino
2. **Digite o ID** no campo "ID do Computador Remoto"
3. **Clique em "Conectar"**
4. **Aguarde a aprovação** do usuário remoto

## ⚙️ Configurações

### Aba Segurança:
- **Exigir Senha**: Requer senha para conexões
- **Aceitar Automaticamente**: Aceita conexões sem confirmação
- **Senha de Acesso**: Define senha personalizada

### Aba Geral:
- **Iniciar com Windows**: Inicia automaticamente com o sistema
- **Minimizar para Bandeja**: Minimiza para a área de notificação
- **Mostrar Notificações**: Exibe notificações de eventos

### Aba Conexão:
- **Endereço do Servidor**: URL do servidor de conexão
- **Porta do Servidor**: Porta de comunicação
- **Qualidade**: Define qualidade da transmissão (Baixa/Média/Alta)
- **Qualidade Adaptativa**: Ajusta automaticamente conforme a conexão

## 🔧 Desinstalação

### Se Instalado via Script:

1. **Execute o PowerShell como Administrador**
2. **Execute o comando**:
   ```powershell
   & "$env:ProgramFiles\OliAcesso\install.ps1" -Uninstall
   ```

### Se Executado Portátil:

1. **Feche o aplicativo**
2. **Delete a pasta** com os arquivos
3. **Remova atalhos** (se criados manualmente)

## 🛠️ Solução de Problemas

### Erro "Não foi possível conectar ao servidor":
- Verifique se o servidor está rodando
- Confirme o endereço e porta do servidor
- Verifique sua conexão com a internet
- Desative temporariamente firewall/antivírus para teste

### Aplicativo não inicia:
- Verifique se todos os arquivos DLL estão presentes
- Execute como administrador
- Verifique se o Windows está atualizado

### Erro de permissão na instalação:
- Execute o PowerShell como Administrador
- Verifique se a política de execução permite scripts:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## 📞 Suporte

Para suporte técnico ou relatar problemas:
- Verifique os logs do aplicativo
- Anote mensagens de erro específicas
- Inclua informações sobre sua versão do Windows

## 📄 Licença

© 2024 OliAcesso - Todos os direitos reservados.

---

**Versão**: 1.0.0  
**Compatibilidade**: Windows 10/11 (x64)  
**Requisitos**: Nenhum (executável independente)