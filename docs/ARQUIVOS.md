# Conteúdo do pacote

O ZIP original tem **12 arquivos**, **37.385 bytes descompactados** e **14.857 bytes compactados**. A entrada de diretório do ZIP não foi contada como arquivo.

| Arquivo original | Tamanho | Função | Nova distribuição |
| --- | ---: | --- | --- |
| `Abrir Launcher.vbs` | 397 bytes | Abre `Launcher Links.ps1` em uma sessão PowerShell sem console visível. | Preservado |
| `Abrir-sem-janela-preta.vbs` | 357 bytes | Abre o Batch da interface sem exibir o console. | Preservado |
| `appearance.json` | 151 bytes | Cores e dimensões iniciais, 940 × 690 pixels. | Preservado |
| `Installer Links.bat` | 826 bytes | Inicia o instalador PowerShell e mostra o resultado. | Preservado |
| `Installer Links.ps1` | 4.427 bytes | Copia três arquivos para LocalAppData, grava configuração, gera atalhos e oculta quatro arquivos de origem. | Preservado |
| `Launcher Links.ps1` | 7.077 bytes | Lê a configuração, abre a interface e oferece reparo de caminho. | Preservado |
| `MEGA-Logo.ico` | 4.286 bytes | Ícone original de 32 × 32 pixels usado nos atalhos. | Preservado |
| `Trun Game Free Mega 1.0.lnk` | 2.183 bytes | Atalho já criado no computador de origem. | Gerado pelo instalador; não redistribuído pronto |
| `Trun Game Free Mega Beta – Unused.txt` | 409 bytes | Lista histórica beta com cinco links Nintendo. Não é carregada pela interface. | Preservado |
| `Trun Game Mega Original – Free Edition 1.0.txt` | 1.871 bytes | Lista com 19 links e os 16 créditos. A interface mantém uma cópia desses dados no código. | Preservado |
| `Trun-Game-Free-Mega.bat` | 359 bytes | Inicia o script PowerShell da interface. | Preservado |
| `Trun-Game-Free-Mega.ps1` | 15.042 bytes | Interface Windows Forms, links, cópia para a área de transferência, notificações e créditos. | Preservado |

## Organização do repositório

| Caminho | Conteúdo |
| --- | --- |
| `README.md` | Apresentação, instalação, uso, compatibilidade e suporte. |
| `CREDITS.md` | Os 16 créditos originais. |
| `CHANGELOG.md` | Conteúdo recebido e anúncio da versão 2.0. |
| `launcher/` | Os 11 arquivos originais redistribuídos, juntos e sem alteração de conteúdo. |
| `assets/MEGA-Logo.png` | Conversão da logo original para uso no README. |
| `docs/ARQUIVOS.md` | Este inventário explicado. |
| `docs/REVISAO.md` | Leitura técnica e limites da avaliação. |
| `docs/INVENTARIO.json` | Tamanhos e hashes SHA-256 dos 12 arquivos originais. |
| `docs/RELEASE-1.0.md` | Texto preparado para a release 1.0. |
| `docs/PUBLICAR.md` | Orientação para colocar o pacote no GitHub. |
| `docs/DESCRICAO.txt` | Descrição curta sugerida para o campo About. |

## Arquivos criados pelo instalador

| Local | Conteúdo ou efeito |
| --- | --- |
| `%LOCALAPPDATA%\TrunGameFreeMega` | Cópias de `Launcher Links.ps1`, `Abrir Launcher.vbs` e `MEGA-Logo.ico`. |
| `%LOCALAPPDATA%\TrunGameFreeMega\config.json` | Pasta do projeto, caminhos dos atalhos, data/hora e identificação interna `1.1`. |
| Área de trabalho | `Trun Game Free Mega.lnk`; atualiza também um atalho antigo com nome de versão, se já existir. |
| Pasta extraída | Gera `Trun Game Free Mega 1.0.lnk`. Oculta o Batch e o PowerShell do instalador, o PowerShell do launcher e `Abrir Launcher.vbs`. |

O instalador não copia a interface principal para LocalAppData: ela continua na pasta extraída. Mantenha os 11 arquivos de origem juntos. A extração do ZIP é uma etapa manual anterior à execução do instalador.
