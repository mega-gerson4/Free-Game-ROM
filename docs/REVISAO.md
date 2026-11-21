# Revisão estática do pacote recebido

**Data:** 21/11/2026. **Método:** leitura dos scripts e textos, inspeção do ícone, decodificação dos campos principais do atalho e inventário do ZIP. Os scripts não foram executados.

Arquivo avaliado: `Trun Game Free Mega 1.0(1).zip`.

SHA-256 do arquivo original:

```text
f311dae8e157e2c1f1d5f9b3b374e6e9fcf5ff6420e8a5102de5f20be2559e49
```

Esse hash identifica o ZIP original recebido, não o novo ZIP de distribuição nem o ZIP deste repositório. Os hashes individuais estão em `INVENTARIO.json`.

## Comportamento encontrado

| Área | Evidência no código | Resultado da leitura |
| --- | --- | --- |
| Instalação | `Installer Links.ps1`, linhas 19–34 e 49–71 | Grava arquivos em LocalAppData, registra a pasta do projeto e cria atalhos do usuário. |
| Arquivos ocultos | `Installer Links.ps1`, linhas 74–82 | Aplica o atributo Hidden a quatro arquivos na pasta de origem. Não é exclusão dos arquivos. |
| Abertura | Os dois VBS, o Batch principal e `Launcher Links.ps1` | Iniciam scripts locais. A ausência do console visível é intencional. |
| Política de execução | Parâmetros dos comandos em BAT e VBS | Usa `-ExecutionPolicy Bypass` no processo iniciado; não contém `Set-ExecutionPolicy` permanente. |
| Reparo | `Launcher Links.ps1`, linhas 111–136 | Pede ao usuário uma nova pasta e atualiza configuração e atalhos. |
| Catálogo | `Trun-Game-Free-Mega.ps1`, linhas 67–87 | Define 19 endereços fixos em três grupos. |
| Clique no catálogo | `Trun-Game-Free-Mega.ps1`, linhas 260–275 | Escreve o endereço escolhido na área de transferência e mostra confirmação. Não abre o navegador. |
| C# e DLL do Windows | `Trun-Game-Free-Mega.ps1`, linhas 7–46 | O trecho C# trata Enter e usa `user32.dll` para arrastar a janela. |
| Rede | Scripts completos | Não foram encontradas requisições de rede ou comandos de download. Os endereços aparecem como dados do catálogo. |
| Inicialização com o Windows | Scripts completos | Não foram encontradas tarefas agendadas, serviços ou entradas de inicialização automática. |
| Credenciais e envio de dados | Scripts completos | Não foram encontradas rotinas para coletar credenciais ou enviar dados. O instalador registra localmente caminhos e data/hora. |

## Atalho original

O arquivo `.lnk` original aponta para `wscript.exe`, passando como argumento um caminho absoluto para `Abrir Launcher.vbs` dentro do perfil Windows do computador de origem. O diretório de trabalho e o ícone também usam caminhos desse perfil.

Isso explica por que esse atalho pode falhar em outro computador antes da instalação. Ele foi retirado da nova cópia de distribuição. Os scripts originais, que geram o atalho correto para cada usuário, foram mantidos.

## Pontos para futuras melhorias

- **Identificação de versão:** a pasta e o nome do pacote indicam 1.0; o instalador e o reparador gravam 1.1 no JSON local. Convém unificar esses rótulos numa atualização de código.
- **Validação incompleta da pasta:** as funções `Test-Project` verificam alguns arquivos principais, mas não incluem `appearance.json`. Uma pasta sem esse JSON pode passar pela validação e falhar ao abrir a interface.
- **Diagnóstico da interface:** a inicialização sem console pode esconder erros. Um registro de erro ou uma mensagem clara ajudaria a identificar a causa.
- **Teste de compatibilidade:** não há medições reproduzíveis por CPU, GPU, RAM ou rede no material recebido. Não foi fornecida uma matriz de computadores testados.
- **Rótulos do catálogo:** “Nintendo Switch 1 and 2” é somente o nome de uma entrada. O destino não foi inspecionado, portanto não comprova conteúdo para os dois consoles.
- **Manutenção de dados:** a lista original está no TXT e também no PowerShell. Alterar um deles não atualiza o outro automaticamente.

Esses pontos foram documentados. O código de aplicação não foi modificado nesta preparação.

## Limites da conclusão

A leitura não revelou uma rotina explicitamente maliciosa nos scripts examinados. Isso não permite declarar o pacote “100% seguro”. Não houve execução em Windows, teste de antivírus, teste de todas as interações, auditoria dos sites externos ou certificação de compatibilidade.

Não há base para atribuir falhas a uma GPU específica, recomendar apagar arquivos do programa ou prometer tempos por modelo de computador. Quando ocorrer um problema, o texto do erro e a etapa afetada são as evidências úteis para investigar.

Segundo a [documentação do SmartScreen](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation), assinatura e reputação do arquivo influenciam os avisos. A [documentação do Windows PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1) explica que a política definida no processo é temporária e pode ser subordinada a políticas administrativas. Essas informações não validam o programa ou seus links externos.
