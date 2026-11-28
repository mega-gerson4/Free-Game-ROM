# Revisão do pacote 2.2

**Data:** 28/11/2026. Foram lidos scripts, catálogos, créditos, guias e a rotina de build. Nenhum instalador foi executado no computador do usuário.

## Comportamento encontrado

- As interfaces carregam 40 registros de `catalog.tsv` e 16 nomes de `credits.txt`.
- COPIAR escreve a URL na área de transferência e registra a cópia localmente. ABRIR usa o navegador padrão por uma ação do usuário.
- O instalador Windows prepara arquivos em uma pasta temporária, testa componentes e troca a cópia instalada em LocalAppData. Há rotinas de restauração da aplicação anterior em determinadas falhas.
- O atalho Windows fica na pasta extraída e aponta para `App/windows/Launcher.vbs`. Não é criado um novo atalho na área de trabalho; um atalho antigo só é removido quando identificado como sendo do projeto.
- Windows e macOS ocultam auxiliares conhecidos. No Linux há uma lista `.hidden`, aplicada por gerenciadores compatíveis.
- Os instaladores preservam DataSense. Apagar o histórico é uma ação separada; Windows e Linux pedem confirmação.
- Os inicializadores Windows usam `-ExecutionPolicy Bypass` na sessão iniciada e o VBS oculta o console. Não foi encontrada alteração permanente da política de execução.
- O instalador macOS compila SwiftUI e tenta uma assinatura ad hoc local; isso não equivale à notarização da Apple.
- Não foram encontradas rotinas de download automático de jogos, coleta de credenciais, envio de histórico ou inicialização automática com o sistema nos scripts da aplicação examinados.

## Limites e pontos para conferir

- Os sites externos não foram auditados. Nomes e URLs foram preservados; há endereços repetidos, e rótulos como Switch 1 and 2 não validam conteúdo para ambos os consoles.
- A opção japonesa do Windows/Linux ainda contém textos em inglês.
- A interface Linux reduz a logo por um fator fixo de dois. Com a imagem de 1254 × 1254 pixels, o enquadramento deve ser conferido em ambiente gráfico. A imagem original foi preservada.
- O instalador macOS declara mínimo 11.0 no Info.plist. O mínimo efetivo depende das APIs e do alvo do compilador; não foi certificada compatibilidade com versões específicas do macOS.
- O `TEST-RESULTS.txt` recebido relata testes anteriores, não uma execução nova desta atualização.
- Não há medições para certificar todas as CPUs/GPUs ou prometer tempos por hardware e rede.

Veja [VALIDACAO-2.2.md](VALIDACAO-2.2.md) para as verificações desta publicação. Inspeção de código e hashes não constituem certificação de segurança ou funcionamento em todos os sistemas.
