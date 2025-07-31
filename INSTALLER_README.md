# Bot Timer - Instalador Windows

Este projeto inclui um script do Inno Setup para criar um instalador profissional para Windows.

## Pré-requisitos

1. **Inno Setup** instalado no seu PC (você já tem)
2. **Flutter SDK** configurado
3. Projeto buildado para Windows

## Como gerar o instalador

### Método 1: Script automático
Execute o arquivo `build_installer.bat` que irá:
1. Buildar o projeto Flutter para Windows
2. Compilar o instalador usando Inno Setup

### Método 2: Manual
1. Buildar o projeto:
   ```bash
   flutter build windows --release
   ```

2. Abrir o Inno Setup Compiler e carregar o arquivo `installer.iss`

3. Compilar o script (Build > Compile)

## Arquivos do instalador

- `installer.iss` - Script principal do Inno Setup
- `build_installer.bat` - Script para automizar o processo
- `installer_output/` - Pasta onde será gerado o instalador final

## Configurações do instalador

O instalador irá:
- Instalar o Bot Timer em `Program Files`
- Criar atalhos no menu iniciar e área de trabalho (opcional)
- Criar pasta `audios_bot` em Documentos para áudios personalizados
- Incluir todas as DLLs necessárias do Flutter
- Suportar instalação em português brasileiro e inglês

## Personalização

Para personalizar o instalador, edite o arquivo `installer.iss`:

- **Ícone**: Adicione um arquivo .ico e defina em `SetupIconFile`
- **Licença**: Adicione um arquivo de licença e defina em `LicenseFile`
- **Versão**: Altere `AppVersion` para a versão atual
- **Informações**: Modifique as URLs e informações do desenvolvedor

## Distribuição

Após a compilação, o arquivo `BotTimerSetup.exe` estará na pasta `installer_output/` e pode ser distribuído para instalação em outros PCs Windows.
