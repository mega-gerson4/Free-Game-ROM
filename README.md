<img src="https://github.com/mega-gerson4/Free-Game-ROM/releases/download/v2.2/MEGA-Logo.png" alt="Logo MEGA — chapéu vermelho" width="110">

# Free Game ROM

**Versão atual: 2.2 — Trun Game Free Mega.**

**A versão 2.2 chegou com força!** O catálogo ganhou nova logo, mais plataformas, busca, filtros e histórico local, com interfaces para Windows, Linux e macOS.

O projeto reúne **40 links** de páginas de jogos nas categorias Nintendo, Sony/PlayStation, Microsoft/Xbox, Sega, Capcom e Commodore. O pacote contém o aplicativo, instaladores, arquivos de texto, créditos e imagens. Jogos e ROMs não estão incluídos no download.

**[BAIXAR ZIP — recomendado](https://github.com/mega-gerson4/Free-Game-ROM/releases/download/v2.2/01-Trun-Game-Free-Mega-2.2.zip)** · **[BAIXAR RAR](https://github.com/mega-gerson4/Free-Game-ROM/releases/download/v2.2/02-Trun-Game-Free-Mega-2.2.rar)**

[Instruções e detalhes da release 2.2](https://github.com/mega-gerson4/Free-Game-ROM/releases/tag/v2.2)

## O que chegou na versão 2.2

- Nova logo do chapéu vermelho e visual **Native Red Edition**.
- Catálogo ampliado para **40 entradas**, distribuídas em seis categorias.
- Busca por nome, categoria ou endereço, com filtros na interface.
- Botões **COPIAR** e **ABRIR** para usar os links.
- **DataSense:** histórico local de links copiados e preferência de idioma.
- Instaladores e reparadores próprios para Windows, Linux e macOS.

## Download e instalação

1. Abra **Releases** e escolha a **versão 2.2**.
2. Em **Assets**, baixe **01-Trun-Game-Free-Mega-2.2.zip**. O RAR original também está disponível.
3. Extraia **todos os arquivos** para uma pasta no computador.
4. Execute o instalador correspondente ao seu sistema, conforme a tabela abaixo.
5. Aguarde o resultado da instalação antes de abrir o programa.
6. Abra o atalho ou aplicativo criado na pasta extraída.

| Sistema | Instalador | Como abrir depois |
| --- | --- | --- |
| Windows 10/11 | `Installer Windows.bat` | `Trun Game Free Mega.lnk`, na pasta extraída. |
| Linux com Tcl/Tk | `sh "Installer Linux.sh"` | Atalho `.desktop`, na pasta ou no menu de aplicativos. |
| macOS com ferramentas Swift | `Installer macOS.command` | Aplicativo `.app` compilado na pasta. |

No Windows, o instalador copia a aplicação para `%LOCALAPPDATA%\TrunGameFreeMega\App` e cria o atalho para esse computador. No Linux, a cópia instalada fica em `~/.local/share/TrunGameFreeMega/App`. No macOS, é necessário ter as ferramentas Swift para compilar o aplicativo.

O arquivo **SHA256SUMS.txt**, disponível na release, contém os hashes do ZIP e do RAR. As instruções adicionais estão em **README-PTBR.txt** e **README-EN.txt**, dentro do pacote.

## Arquivos ocultos e reparação

Após a instalação no Windows, os instaladores, catálogos e arquivos auxiliares ficam ocultos. **O atalho de abertura permanece visível.** Para encontrar os auxiliares novamente, ative **Itens ocultos** no Explorador de Arquivos.

No Linux, a lista `.hidden` é respeitada por gerenciadores de arquivos compatíveis. No macOS, o instalador oculta os auxiliares no Finder.

Se precisar repetir a instalação ou recriar o inicializador, use **Repair Windows.bat**, **Repair Linux.sh** ou **Repair macOS.command**, conforme seu sistema. Os reparadores preservam os dados locais do DataSense.

## Como usar

- Escolha uma categoria ou use a busca para localizar uma entrada.
- Clique em **COPIAR** para copiar o endereço; se quiser, cole no navegador com **Ctrl+V**.
- Clique em **ABRIR** para acessar o endereço no navegador padrão.
- Consulte o histórico local do **DataSense** para ver os links copiados.
- Se aparecer **BUILD SUCCESS** ou **FATAL ERROR**, consulte os detalhes em **Read More**, quando disponível.

O conteúdo e a disponibilidade de cada página externa dependem do próprio site.

## Plataformas do catálogo

| Categoria | Entradas |
| --- | ---: |
| Nintendo | 16 |
| Sony / PlayStation | 6 |
| Microsoft / Xbox | 7 |
| Sega | 7 |
| Capcom | 2 |
| Commodore | 2 |
| **Total** | **40** |

Esses números representam **entradas de links**. As plataformas são categorias do catálogo; os jogos e emuladores possuem requisitos próprios.

## O que existe no pacote e no código

| Componente | Função |
| --- | --- |
| Windows: Batch, PowerShell e VBScript | Instalação, atalhos, inicialização e interface Windows Forms. |
| Linux: Shell e Tcl/Tk | Instalação, inicialização, interface e atalhos `.desktop`. |
| macOS: Shell e SwiftUI | Instalação e compilação da interface para Mac. |
| `catalog.tsv` e `catalog-original.txt` | Lista estruturada de links e referência original. |
| Logos em PNG e ICO | Identidade visual do programa e dos atalhos. |
| `credits.txt` e arquivos README | Créditos e orientações de uso. |

**Os arquivos do programa ficam nos pacotes de Releases.** Este repositório mantém a página de apresentação no README.

## Compatibilidade: em quais computadores roda?

| Item | Informação disponível |
| --- | --- |
| Windows | Código voltado para Windows 10/11, com Windows PowerShell, Windows Forms e Windows Script Host/VBScript disponíveis. |
| Linux | Precisa de ambiente gráfico, Tcl/Tk (`wish`) e `xdg-open` para abrir links. |
| macOS | O pacote contém código SwiftUI e precisa das ferramentas Swift para compilar o aplicativo. |
| Processador (CPU) | Não há requisito mínimo medido nem lista de modelos Intel, AMD ou ARM validados. O desempenho influencia as etapas locais. |
| Placa de vídeo (GPU) | Não há lista de GPUs testadas individualmente. Os requisitos dos jogos e emuladores são separados dos requisitos deste catálogo. |
| Memória e armazenamento | Não há mínimos medidos. Reserve espaço para o pacote extraído, a aplicação instalada e os dados locais. |
| Internet | Usada para baixar o pacote e acessar os sites. No Windows, a criação do atalho ocorre localmente. |

O criador relata uso no próprio computador. A revisão feita nesta publicação foi estática; os instaladores e as interfaces não foram executados nos três sistemas. A compatibilidade depende dos componentes disponíveis no sistema, e ainda não existe validação para todos os modelos de computador.

## Quanto tempo pode demorar?

Em uma execução anterior, o criador relatou aproximadamente **50 segundos** e usou **1 a 3 minutos** como referência informal. O tempo da versão 2.2 pode variar conforme o computador e a etapa; ainda não há medições publicadas por configuração.

| Etapa | O que pode deixar mais rápido ou mais lento |
| --- | --- |
| Download do ZIP ou RAR | Velocidade da internet, servidor e condições da rede. |
| Extração | Processador, SSD ou HD e verificações de segurança do sistema. |
| Instalação e criação do atalho | Inicialização dos scripts, armazenamento, permissões e verificações do sistema. |
| Primeira abertura | Carregamento dos componentes da interface e desempenho do computador. |
| Compilação no macOS | Ferramentas Swift disponíveis e desempenho do Mac. |
| Acesso às páginas do catálogo | Conexão e funcionamento de cada site. |

| Conexão | Como influencia |
| --- | --- |
| Wi-Fi lento | Pode aumentar o tempo do download e da navegação. |
| Wi-Fi rápido ou cabo | Pode reduzir o tempo do download e do acesso aos sites. |
| Sem conexão, após baixar e extrair | As rotinas locais de criação do atalho no Windows não dependem de baixar arquivos; os sites externos precisam de internet. |

**Uma internet melhor ajuda no download e na navegação. Para extrair, instalar e carregar a interface, o computador tem maior influência.** Não há uma tabela validada de minutos por CPU, placa de vídeo ou velocidade de Wi-Fi.

## Avisos do Windows

O Windows pode mostrar **“Fornecedor desconhecido”** ou **“O Windows protegeu o computador”** ao abrir arquivos sem assinatura ou reputação estabelecida. Confira a origem do download e os arquivos antes de decidir executar. Mantenha as proteções do sistema ativas.

A leitura do código não equivale a uma certificação de segurança e não abrange os sites externos acessados pelo catálogo.

## Problemas comuns

| Problema | O que conferir |
| --- | --- |
| O programa não abre ou fecha logo | Confirme que extraiu todos os arquivos e que as dependências do seu sistema estão disponíveis. Consulte também o histórico de proteção do sistema. |
| O atalho não funciona | Use o arquivo **Repair** correspondente ao seu sistema para recriar o inicializador. |
| O instalador desapareceu | No Windows, ative **Itens ocultos**. Os auxiliares são ocultados após instalar. |
| Apareceu FATAL ERROR | Consulte **Read More**, quando disponível, e envie os detalhes ao suporte. |
| O link foi copiado, mas o navegador não abriu | Use **ABRIR** ou cole o endereço no navegador. |
| Uma página externa deixou de funcionar | Informe a categoria e o endereço afetado no contato abaixo. |
| Está demorando mais que o esperado | Identifique se a demora está no download, extração, instalação ou abertura; cada etapa depende de fatores diferentes. |

## Créditos e suporte

Ruros, MEGA GERSON, Gerson Speed Minecraft, Dash X, Game Fun Mega, Night Friends, Jan Jan Boy, BunJun Fun LKJ, JJNS, No Game, Yafek JKS, Makerzin, Animazin, Club OBC, Club 2017 Neus e Club Mega ++.

**Suporte:** [mega.gerson44888@gmail.com](mailto:mega.gerson44888@gmail.com).

Ao relatar um problema, informe a versão **2.2**, o sistema operacional, a etapa em que ocorreu e a mensagem exibida.

Obrigado por acompanhar e apoiar o projeto!
