TRUN GAME FREE MEGA 2.2 - NATIVE RED EDITION
=================================================

VERSAO CORRIGIDA - MENU E INSTALACAO

WINDOWS 10/11
1. Extraia o ZIP inteiro para uma pasta propria.
2. Execute "Installer Windows.bat".
3. Se a verificacao for concluida, aparece a janela "BUILD SUCCESS".
4. O icone "Trun Game Free Mega" (.lnk) aparece NESTA MESMA PASTA,
   NAO na Area de Trabalho.
5. Abra este icone. O menu usa Windows Forms/.NET, nao Python nem navegador.

Os arquivos auxiliares (inclusive instaladores) sao ocultados no Windows.
Para ve-los novamente: Explorador de Arquivos -> Exibir -> Mostrar -> Itens ocultos.
O icone de abertura continua visivel. A pasta principal nao e ocultada.
Um atalho antigo na Area de Trabalho so e retirado se for identificado
como pertencente a este projeto. Nenhum outro atalho sera modificado.

BUILD SUCCESS / BUILD FATAL ERROR
- BUILD SUCCESS: arquivos copiados, validacao da interface executada e atalho
  criado e verificado. Nao e garantia de funcionamento em todas as maquinas.
- BUILD FATAL ERROR: instalacao ou inicializacao com falha.
- Botao "Read More": abre uma SEGUNDA JANELA com os detalhes do erro ou sucesso.
- Os registros sao locais: %LOCALAPPDATA%\TrunGameFreeMega\DataSense
- "Repair Windows.bat" repete a instalacao; os dados DataSense sao preservados.

O atalho aponta para a instalacao em %LOCALAPPDATA% para que mover a pasta
baixada depois nao quebre a inicializacao. Cada PC deve executar seu installer.

LINUX
1. Tenha Tcl/Tk (wish). Ex.: sudo apt install tk
2. Execute: sh "Installer Linux.sh"
3. O inicializador "Trun Game Free Mega.desktop" aparecera NESTA PASTA,
   alem do menu de aplicativos; nenhum icone sera criado na Area de Trabalho.
4. No Linux, arquivos auxiliares sao listados em .hidden, respeitado por
   gerenciadores de arquivos que oferecem esse recurso. Outros podem exibi-los.
5. O status de build aparece em uma janela Tk e Read More abre mais detalhes.

MACOS
1. Sao necessarias as ferramentas Swift/Xcode na primeira compilacao.
2. Execute "Installer macOS.command".
3. Um aplicativo SwiftUI REAL, "Trun Game Free Mega.app", sera criado
   NESTA PASTA; nenhum atalho sera criado na Mesa/Area de Trabalho.
4. Arquivos auxiliares sao ocultados com chflags (Finder).
5. "Read More" abre os detalhes do build no TextEdit.
Observacao: o .app nao vem precompilado neste pacote. Para publicar um
binario ao publico, execute o build em um Mac e assine/notarize a distribuicao.

PROTECAO DE DADOS
Historico de links copiados e idioma sao salvos localmente em DataSense.
A instalacao e reparacao nao apagam esses dados.

VALIDACAO
Linux: instalador, atalhos, dados e dialogo Read More testados neste ambiente.
Windows: codigo revisado e checagens de preflight configuradas, MAS a nova
versao ainda precisa ser executada em Windows 10/11 para verificar visual.
macOS: sintaxe do instalador conferida, mas app SwiftUI exige teste em um Mac.

AVISO DE DIREITOS
Os links apontam para sites externos. Use apenas jogos e arquivos para os
quais voce possua autorizacao legal de acesso e distribuicao.
