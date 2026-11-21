<p align="center">
  <img src="assets/MEGA-Logo.png" alt="Logo MEGA" width="64" height="64">
</p>

# Free Game ROM

Repositório do **Trun Game Free Mega**, um catálogo para Windows que reúne links de páginas de jogos por plataforma: Nintendo, Sony/PlayStation e Microsoft/Xbox.

O pacote 1.0 contém **19 entradas de links**, uma interface, instalador de atalhos, arquivos de texto e a logo. Os jogos e ROMs não estão incluídos no ZIP. Ao clicar em uma entrada, o programa copia o endereço para a área de transferência; você escolhe se deseja acessá-lo no navegador.

**Versão do pacote:** 1.0 · **Próxima versão:** 2.0, em breve, sem data confirmada.

## Download e instalação

1. Abra a seção **Releases** deste repositório e escolha a versão disponível.
2. Em **Assets**, baixe o arquivo `Trun-Game-Free-Mega-1.0.zip` anexado à release.
3. Extraia todo o ZIP para uma pasta em que deseja manter o programa.
4. Abra a pasta extraída e dê dois cliques em **`Installer Links.bat`**. Se o Windows esconder extensões, o nome pode aparecer apenas como **Installer Links**.
5. Aguarde a mensagem de conclusão e pressione uma tecla para fechar o instalador.
6. Abra o atalho **Trun Game Free Mega** na área de trabalho ou **Trun Game Free Mega 1.0** na pasta do programa.

O instalador foi escrito para funcionar com as permissões do usuário atual. Ele cria os atalhos e uma pequena pasta de inicialização em `%LOCALAPPDATA%\TrunGameFreeMega`. A pasta extraída continua sendo necessária para abrir o catálogo.

Depois da instalação, quatro arquivos recebem o atributo **Oculto**: `Installer Links.bat`, `Installer Links.ps1`, `Launcher Links.ps1` e `Abrir Launcher.vbs`. Eles continuam na pasta e podem ser visualizados pela opção **Itens ocultos** do Explorador de Arquivos.

Se a seção Releases ainda estiver vazia, o pacote ainda não foi publicado ali. O ZIP de código-fonte gerado pelo GitHub possui outra estrutura: nesse caso, os arquivos do aplicativo ficam dentro de **`launcher`**, e é nessa pasta que está o instalador.

## Como usar

- Clique em uma entrada para **copiar o link**.
- Cole o endereço no navegador com **Ctrl+V** para acessá-lo.
- A interface mostra uma confirmação e tenta exibir uma notificação do Windows. A opção **View last notification** permite consultar a última cópia.
- Arraste o cabeçalho para mover a janela.
- A tecla **Enter** foi desativada na interface. Para fechar a janela principal, use **Alt+F4**.

Os sites externos têm funcionamento e conteúdo próprios. A presença de um endereço no catálogo não confirma disponibilidade, segurança ou compatibilidade dos arquivos oferecidos por esse site.

## Plataformas listadas

| Grupo do catálogo | Entradas | Quantidade |
| --- | --- | ---: |
| Nintendo | Nintendo Switch 1 and 2; Nintendo 64; GameCube; Game Boy Color; Game Boy; Game Boy Advance; Nintendo DS; Pokemon Mini; Nintendo 3DS; NES | 10 |
| Sony / PlayStation | PS4; PS2; PS1 | 3 |
| Microsoft | Xbox 360; Windows; Windows 3.x; MSX; MSX 2; Classic Xbox | 6 |
| **Total** | **Entradas de links, não quantidade de jogos** | **19** |

Os nomes acima reproduzem as categorias do código original. A entrada “Nintendo Switch 1 and 2” contém um único endereço; esse rótulo não comprova suporte a jogos de Switch 2. As plataformas listadas são categorias de sites e não sistemas em que este aplicativo executa jogos.

## O que existe no código

| Componente | Função |
| --- | --- |
| Batch (`.bat`) | Inicia os scripts de instalação e da interface. |
| PowerShell (`.ps1`) | Cria os atalhos, grava o caminho da pasta, repara caminhos e monta a interface. |
| VBScript (`.vbs`) | Abre os inicializadores sem deixar a janela de console visível. |
| Windows Forms / System.Drawing | Desenha a interface, as notificações e as janelas de reparo. |
| Pequeno trecho em C# | Trata a tecla Enter e permite arrastar a janela pelo cabeçalho. É compilado localmente por `Add-Type`. |
| `appearance.json` | Define cores e tamanho inicial da janela. |
| Textos e logo | Preservam as listas de links, os créditos e a identidade visual. |

Veja a função de cada arquivo em [docs/ARQUIVOS.md](docs/ARQUIVOS.md) e a avaliação técnica em [docs/REVISAO.md](docs/REVISAO.md).

## Compatibilidade

O código tem como alvo **Windows 10 e Windows 11**, com Windows PowerShell, Windows Forms, System.Drawing e Windows Script Host/VBScript disponíveis. O criador relata uso no próprio computador; esta revisão não executou o aplicativo em Windows.

| Item | Situação conhecida |
| --- | --- |
| CPU | Não há uma lista de modelos Intel, AMD ou ARM testados, nem requisito mínimo medido. |
| Placa de vídeo | O código não consulta modelos de GPU nem usa um motor de jogos. Placas integradas e dedicadas não receberam validação individual nesta revisão. |
| RAM e armazenamento | Não há mínimos medidos. É necessário espaço para o pacote extraído e os arquivos locais criados pelo instalador. |
| Internet | Necessária para baixar o ZIP e visitar os sites. Os scripts não fazem requisições de rede para criar atalhos ou copiar os links. |
| Outros sistemas | Linux e macOS não têm inicializador nativo neste pacote. |
| Jogos e emuladores | Possuem requisitos próprios, que não são definidos por este catálogo. |

Não é possível afirmar suporte a qualquer computador ou atribuir uma falha à placa de vídeo apenas pelo comportamento observado.

## Quanto tempo pode demorar?

O criador relatou uma execução de aproximadamente **50 segundos** e mencionou uma referência informal de **1 a 3 minutos**. Esses relatos não separam download, extração, instalação e abertura, e não são medições por configuração.

| Etapa | O que pode influenciar |
| --- | --- |
| Download do ZIP | Velocidade da conexão, servidor e condições da rede. |
| Extração do ZIP | Armazenamento, CPU e verificações de segurança do sistema. A extração é feita pelo usuário. |
| Criação dos atalhos | Inicialização do PowerShell, disco, permissões e verificações do Windows. O instalador não baixa nem extrai arquivos. |
| Primeira abertura | Inicialização do PowerShell, carregamento das bibliotecas e compilação local do pequeno trecho em C#. |
| Acesso aos sites | Conexão e funcionamento de cada site externo. |

| Condição da rede | Instalação e abertura após extrair o ZIP |
| --- | --- |
| Sem conexão | O código dessas etapas funciona localmente; o sistema ainda pode realizar verificações próprias de segurança. |
| Wi-Fi lento | Não existe no programa uma espera de rede para gerar o atalho. |
| Wi-Fi rápido ou cabo | Pode acelerar o download e a navegação; não determina o tempo dos scripts locais. |

Não há dados suficientes para publicar minutos exatos por CPU, GPU ou velocidade de Wi-Fi.

## Avisos do Windows

Arquivos sem assinatura ou sem reputação estabelecida podem exibir **“Fornecedor desconhecido”** ou **“O Windows protegeu o computador”**. Esses avisos, sozinhos, não comprovam que o arquivo é malicioso nem que é seguro. Antes de decidir executar, confira a origem do download e os arquivos que serão iniciados. Mantenha as proteções do Windows ativas.

Os inicializadores usam `-ExecutionPolicy Bypass` para a sessão de PowerShell que abrem e usam janelas de console ocultas. Isso deve ser considerado ao revisar o pacote. Não há nos scripts uma alteração permanente da política de execução do Windows, e políticas administrativas ainda podem impedir a execução.

A avaliação foi uma **leitura estática dos arquivos**: não encontrou rotinas de download automático, coleta de credenciais ou inicialização automática com o Windows. Ela não equivale a uma certificação de segurança e não abrange os sites externos.

Referências: [Microsoft — SmartScreen](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation) e [Microsoft — políticas de execução do Windows PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1).

## Problemas comuns

| Problema | Como verificar |
| --- | --- |
| “Diretório não reconhecido” ou “Repository not found” | Abra o atalho, clique em **Reparar problema** e selecione a pasta que contém os arquivos principais. |
| O atalho recebido antes da instalação não abre | Execute `Installer Links.bat` para gerar um atalho com os caminhos deste computador. O atalho pronto do ZIP original não foi incluído no novo pacote de distribuição. |
| A janela não aparece ou fecha logo | Confira se extraiu todos os arquivos, incluindo `appearance.json`, e consulte o histórico de proteção do Windows para identificar bloqueios. |
| O instalador desapareceu da pasta | Ative **Itens ocultos** no Explorador de Arquivos. Esse comportamento está previsto no instalador. |
| A pasta foi movida | Use **Reparar problema** no atalho. Se necessário, execute novamente o instalador na pasta atual. |
| Link copiado, mas nenhum site abriu | Esse é o comportamento previsto. Cole o link no navegador. |
| Uma página externa deixou de funcionar | Informe a plataforma e o endereço afetado no contato abaixo. |

Para remover o programa, feche a janela, remova os atalhos criados e, se não quiser mais usá-lo, exclua a pasta extraída e `%LOCALAPPDATA%\TrunGameFreeMega`.

## Versão 2.0

**Em breve.** A equipe anunciará os recursos, a data e os arquivos da versão 2.0 quando estiverem prontos. O pacote analisado nesta documentação é o 1.0; ele já contém um componente de atalhos que grava a identificação interna `1.1`.

## Créditos e contato

**Ruros · MEGA GERSON · Gerson Speed Minecraft · Dash X · Game Fun Mega · Night Friends · Jan Jan Boy · BunJun Fun LKJ · JJNS · No Game · Yafek JKS · Makerzin · Animazin · Club OBC · Club 2017 Neus · Club Mega ++**

A relação completa, na ordem original, está em [CREDITS.md](CREDITS.md).

Problemas, sugestões e suporte: **[mega.gerson44888@gmail.com](mailto:mega.gerson44888@gmail.com)**. Informe a versão do Windows, a etapa em que ocorreu o erro e o texto da mensagem exibida.

Obrigado por acompanhar e apoiar o projeto!
