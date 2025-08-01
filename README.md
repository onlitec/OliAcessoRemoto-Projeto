# OliAcesso Remoto - Projeto Completo

Sistema completo de acesso remoto com interface web de monitoramento, desenvolvido em .NET e WPF.

## 📁 Estrutura do Projeto

```
OliAcessoRemoto-Projeto/
├── Servidor/           # Aplicação servidor ASP.NET Core
├── Cliente/            # Aplicação cliente WPF
├── Documentacao/       # Documentação técnica
└── README.md          # Este arquivo
```

## 🖥️ Servidor

**Localização:** `./Servidor/`

O servidor é uma aplicação ASP.NET Core 9.0 que fornece:

- **API RESTful** para gerenciamento de conexões
- **Interface Web** de monitoramento em tempo real
- **SignalR Hubs** para comunicação em tempo real
- **Banco de dados** SQLite com Entity Framework Core
- **Sistema de relatórios** e estatísticas
- **Monitoramento de sistema** (CPU, memória, rede)

### Principais Funcionalidades:
- Dashboard em tempo real
- Monitoramento de conexões ativas
- Histórico de conexões
- Relatórios em CSV
- Métricas de sistema
- Interface web responsiva

### Tecnologias:
- ASP.NET Core 9.0
- Entity Framework Core
- SignalR
- SQLite
- Bootstrap 5
- Chart.js

## 💻 Cliente

**Localização:** `./Cliente/`

O cliente é uma aplicação WPF que permite:

- Conexão remota com outros computadores
- Interface gráfica intuitiva
- Configurações de conexão
- Histórico de conexões

### Tecnologias:
- WPF (.NET)
- SignalR Client
- Interface moderna

## 📚 Documentação

**Localização:** `./Documentacao/`

Contém toda a documentação técnica do projeto:

- Guias de instalação
- Documentação de deploy
- Informações técnicas
- Correções e atualizações

## 🚀 Como Executar

### Servidor:
```bash
cd Servidor/OliAcessoRemoto.Servidor
dotnet run
```
Acesse: http://localhost:5165

### Cliente:
```bash
cd Cliente
./OliAcessoRemoto.exe
```

## 🔧 Configuração

### Servidor:
- Configure a string de conexão no `appsettings.json`
- Ajuste as portas conforme necessário
- Configure logs no Serilog

### Cliente:
- Configure o endereço do servidor no `settings.json`
- Ajuste configurações de conexão

## 📊 Interface Web

O servidor inclui uma interface web completa com:

- **Dashboard:** Estatísticas em tempo real
- **Conexões:** Monitoramento de conexões ativas e históricas
- **Relatórios:** Geração de relatórios em CSV
- **Sistema:** Informações de sistema e métricas

## 🛠️ Desenvolvimento

### Pré-requisitos:
- .NET 9.0 SDK
- Visual Studio 2022 ou VS Code
- Git

### Build:
```bash
# Servidor
cd Servidor/OliAcessoRemoto.Servidor
dotnet build

# Cliente (se necessário recompilar)
cd Cliente
# Usar Visual Studio para build do WPF
```

## 📝 Licença

Este projeto é proprietário e desenvolvido para uso específico.

## 👥 Contribuição

Para contribuir com o projeto:

1. Faça fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📞 Suporte

Para suporte técnico, consulte a documentação na pasta `Documentacao/` ou entre em contato com a equipe de desenvolvimento.

---

**Versão:** 2.0  
**Última atualização:** Janeiro 2025