<p align="center">
  <img src="assets/MEGA-Logo.png" alt="Nova logo MEGA: chapéu vermelho com faixa preta" width="160" height="160">
</p>

# Free Game ROM — Trun Game Free Mega 2.2

**Native Red Edition.** Catálogo com **40 links**, nova logo e interfaces para **Windows, Linux e macOS**. Encontre uma plataforma pela busca, filtre por categoria e consulte seu histórico local de cópias.

**[Baixar a versão 2.2](https://github.com/mega-gerson4/Free-Game-ROM/releases/tag/v2.2)** · [Histórico](CHANGELOG.md) · [Créditos](CREDITS.md)

O pacote contém o aplicativo, seus instaladores e endereços de sites externos. Jogos e ROMs não estão incluídos.

## Novidades da versão 2.2

- Nova logo do chapéu vermelho com faixa preta e visual Native Red Edition.
- Catálogo ampliado de 19 para 40 entradas, em seis categorias.
- Busca por nome, categoria ou endereço; filtros na barra lateral.
- Botões **COPIAR** e **ABRIR** em cada entrada.
- **DataSense:** histórico de links copiados e preferência de idioma salvos localmente.
- Instaladores e reparadores próprios para Windows, Linux e macOS.
- Janelas **BUILD SUCCESS**, **BUILD FATAL ERROR** e detalhes em **Read More**.
- Atalho Windows dentro da pasta extraída e arquivos auxiliares ocultos após instalar.

## Download e instalação

Abra a [release 2.2](https://github.com/mega-gerson4/Free-Game-ROM/releases/tag/v2.2), baixe **Trun-Game-Free-Mega-2.2.zip** em **Assets** e extraia o pacote inteiro. O RAR original também está disponível. O arquivo **SHA256SUMS.txt** identifica os dois pacotes publicados.

| Sistema | Instalar após extrair | Abrir depois da instalação |
| --- | --- | --- |
| Windows 10/11 | Dê dois cliques em **Installer Windows.bat**. | **Trun Game Free Mega.lnk**, na mesma pasta extraída. |
| Linux | Com Tcl/Tk (`wish`) disponível, execute `sh "Installer Linux.sh"`. | **Trun Game Free Mega.desktop**, na pasta extraída ou no menu de aplicativos. |
| macOS | Com as ferramentas Swift da Apple disponíveis, execute **Installer macOS.command**. | **Trun Game Free Mega.app**, compilado na mesma pasta. |

No Windows, aguarde a mensagem de resultado. A aplicação é copiada para `%LOCALAPPDATA%/TrunGameFreeMega/App`, e o instalador gera um atalho específico para o computador. Não cria um novo atalho na área de trabalho. Um atalho antigo só é removido quando identificado como pertencente ao projeto.

No Linux, o aplicativo fica em `~/.local/share/TrunGameFreeMega/App`. É necessário um ambiente gráfico e Tcl/Tk. O botão **ABRIR** utiliza `xdg-open`.

No macOS, este pacote contém **código-fonte SwiftUI**: é necessário compilar em um Mac. A release de código-fonte não é um aplicativo previamente compilado e notarizado.

## Arquivos ocultos e reparação

Após instalar no Windows, os instaladores, catálogos e pastas auxiliares recebem o atributo **Oculto**. O atalho de abertura permanece visível. Para acessar novamente os auxiliares, ative **Itens ocultos** no Explorador de Arquivos.

No Linux, a lista `.hidden` é aplicada por gerenciadores de arquivos compatíveis. No macOS, o instalador oculta os auxiliares no Finder. A exibição varia conforme o sistema e o gerenciador de arquivos.

Para repetir a instalação ou recriar o inicializador, use **Repair Windows.bat**, **Repair Linux.sh** ou **Repair macOS.command**. Os reparadores foram escritos para preservar DataSense. No Windows e Linux, o inicializador aponta para a cópia instalada na pasta do usuário; mover a pasta baixada não altera esse destino.

## Como usar

1. Escolha **Todos** ou uma categoria na barra lateral.
2. Digite na busca para filtrar nomes, categorias ou endereços.
3. Clique em **COPIAR** para colocar o endereço na área de transferência e registrar a cópia no histórico local.
4. Clique em **ABRIR** para enviar o endereço ao navegador padrão.
5. Use **HISTÓRICO** para consultar as cópias e **CRIADORES** para os créditos.

O seletor oferece Auto, inglês, português, espanhol, francês, alemão e japonês. A tradução varia entre as interfaces: no Windows/Linux, vários textos da opção japonesa ainda usam inglês.

## Categorias do catálogo

| Categoria | Entradas |
| --- | ---: |
| Nintendo | 16 |
| Sony / PlayStation | 6 |
| Microsoft / Xbox / PC | 7 |
| Sega | 7 |
| Capcom | 2 |
| Commodore | 2 |
| **Total** | **40** |

Os nomes e endereços estão em [catalog.tsv](catalog.tsv). As categorias representam páginas externas; não comprovam compatibilidade de jogos com este aplicativo ou com um computador específico.

## Dados locais e diagnósticos

| Sistema | Pasta DataSense |
| --- | --- |
| Windows | `%LOCALAPPDATA%/TrunGameFreeMega/DataSense` |
| Linux | `~/.local/share/TrunGameFreeMega/DataSense` |
| macOS | `~/Library/Application Support/TrunGameFreeMega/DataSense` |

DataSense guarda o histórico de cópias, o idioma escolhido e registros de instalação/erro. Consultar o catálogo local não precisa de internet; baixar o pacote e visitar os sites externos precisa de conexão. Os scripts não baixam jogos nem dependências automaticamente.

**BUILD SUCCESS** informa que as verificações daquela etapa passaram. **BUILD FATAL ERROR** indica falha; use **Read More** para os detalhes. No macOS, os detalhes do instalador são abertos no TextEdit.

## Compatibilidade e validação

O Windows usa PowerShell, Windows Forms/.NET Framework e Windows Script Host; o Linux usa Tcl/Tk; o macOS usa SwiftUI/AppKit. Não existe uma lista certificada de todas as CPUs e GPUs, nem tempos garantidos por computador ou rede.

Nesta atualização foram conferidos os 40 registros, os 16 créditos, as imagens, a sintaxe dos cinco scripts de shell e a integridade dos pacotes. As interfaces nativas não foram executadas neste ambiente. O registro `TEST-RESULTS.txt` recebido no pacote relata verificações anteriores, distintas destas. Veja [docs/VALIDACAO-2.2.md](docs/VALIDACAO-2.2.md).

Esta revisão não certifica segurança. Caso o sistema apresente avisos de fornecedor desconhecido ou proteção, confira a origem e os arquivos antes de decidir executar. O comportamento dos scripts e os limites da avaliação estão em [docs/REVISAO.md](docs/REVISAO.md).

## Código e documentos

| Caminho | Conteúdo |
| --- | --- |
| `windows/` | Interface Windows Forms, instalador, inicializador e diálogos. |
| `linux/` | Interface Tcl/Tk, inicializador e diálogos. |
| `macos/` | Código-fonte da interface SwiftUI. |
| `assets/` | Nova logo principal e variante, em PNG e ICO. |
| `catalog.tsv` / `catalog-original.txt` | Catálogo estruturado e referência original. |
| `credits.txt` / `CREDITS.md` | Os 16 créditos do projeto. |
| `docs/` | Inventário, revisão, validação e notas das releases. |

A [release 1.0](https://github.com/mega-gerson4/Free-Game-ROM/releases/tag/v1.0) e seu código na tag `v1.0` continuam disponíveis no histórico. As instruções atuais usam os novos instaladores da versão 2.2.

## Créditos e suporte

**Ruros · MEGA GERSON · Gerson Speed Minecraft · Dash X · Game Fun Mega · Night Friends · Jan Jan Boy · BunJun Fun LKJ · JJNS · No Game · Yafek JKS · Makerzin · Animazin · Club OBC · Club 2017 Neus · Club Mega ++**

Problemas e sugestões: **[mega.gerson44888@gmail.com](mailto:mega.gerson44888@gmail.com)**. Informe o sistema, a etapa e os detalhes mostrados em **Read More**.
