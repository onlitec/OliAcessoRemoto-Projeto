@echo off
echo ========================================
echo    OnliDesk V2.0 - Cliente de Acesso Remoto
echo ========================================
echo.
echo Iniciando cliente com conexao automatica...
echo.

REM Verifica se o .NET está instalado
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: .NET Runtime nao encontrado!
    echo.
    echo Por favor, instale o .NET 9.0 Runtime:
    echo https://dotnet.microsoft.com/download/dotnet/9.0
    echo.
    pause
    exit /b 1
)

REM Executa o cliente
echo Conectando automaticamente ao servidor...
start "" "OliAcessoRemoto.exe"

echo.
echo Cliente iniciado com sucesso!
echo O cliente se conectara automaticamente ao servidor.
echo.
echo Pressione qualquer tecla para fechar esta janela...
pause >nul