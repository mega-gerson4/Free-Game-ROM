# Arquivos — versão 2.2

O RAR recebido contém **27 arquivos**, totalizando **2.558.522 bytes descompactados**. O arquivo original tem **1.974.878 bytes**. O ZIP da release reproduz esses 27 arquivos, sem atalhos de um computador específico já gerados.

| Arquivo ou grupo | Função |
| --- | --- |
| `Installer Windows.bat` / `Repair Windows.bat` | Instalação e reparação no Windows. |
| `windows/InstallerCore.ps1` | Valida 40 registros e componentes, prepara a cópia instalada, gera o atalho na pasta do projeto e oculta auxiliares. |
| `windows/TrunGameFreeMega.ps1` | Interface Windows Forms, busca, filtros, cópia, abertura, histórico e idiomas. |
| `windows/Launcher.vbs` | Inicia a cópia instalada sem manter o console visível. |
| `windows/BuildStatus.ps1` | Janelas de resultado e detalhes em Read More. |
| `Installer Linux.sh` / `Repair Linux.sh` | Instalação e reparação Linux. |
| `linux/Start Linux.sh` | Inicia a interface com `wish`. |
| `linux/TrunGameFreeMega.tcl` | Interface Tcl/Tk, busca, categorias e histórico. |
| `linux/BuildStatus.tcl` | Janela de resultado e segunda janela de detalhes. |
| `Installer macOS.command` / `Repair macOS.command` | Compila o aplicativo SwiftUI e repete a instalação. |
| `macos/TrunGameFreeMega.swift` | Interface SwiftUI/AppKit e DataSense no macOS. |
| `catalog.tsv` / `catalog-original.txt` | Catálogo estruturado dos 40 links e referência original. |
| `credits.txt` | Os 16 créditos originais. |
| `assets/MEGA-Logo.png` / `.ico` | Nova logo principal e ícone. |
| `assets/MEGA-Logo-2.png` / `.ico` | Variante de logo fornecida. |
| `PREVIEW-LINUX.png` | Prévia recebida no pacote; não é uma captura produzida nesta revisão. |
| `README-PTBR.txt` / `README-EN.txt` | Guias de instalação fornecidos. |
| `TEST-RESULTS.txt` | Registro de verificações anterior, recebido com o pacote. |
| `.hidden` | Lista de auxiliares para gerenciadores de arquivos Linux compatíveis. |
| `.github/workflows/build-native.yml` | Rotina de verificações para os três sistemas no GitHub Actions. |

Hashes e tamanhos individuais estão em [INVENTARIO.json](INVENTARIO.json).

## Arquivos gerados pela instalação

| Sistema | Aplicativo e inicializadores | Dados locais |
| --- | --- | --- |
| Windows | Aplicativo em `%LOCALAPPDATA%/TrunGameFreeMega/App`; `.lnk` na pasta extraída. | `%LOCALAPPDATA%/TrunGameFreeMega/DataSense` |
| Linux | Aplicativo em `~/.local/share/TrunGameFreeMega/App`; `.desktop` na pasta extraída e no menu. | `~/.local/share/TrunGameFreeMega/DataSense` |
| macOS | `.app` compilado na pasta extraída. | `~/Library/Application Support/TrunGameFreeMega/DataSense` |

O histórico usa TSV no Windows/Linux e JSON no macOS. A preferência fica em `language.txt`. Os instaladores também gravam registros locais.

O README principal, os créditos e os documentos desta pasta descrevem a versão 2.2. `RELEASE-1.0.md` permanece como registro histórico; as notas atuais estão em [RELEASE-2.2.md](RELEASE-2.2.md).
