# LumeFlow 0.2 — decisões

Produto independente do LIA Reuniões. Implementação própria; nenhum bundle ou binário do Wispr foi incorporado.

Electron 44.7.2 contém renderer isolado, preload limitado e main. SQLite nativo do Node fica no main; WAV PCM16 mono 16kHz é persistido incrementalmente, com cabeçalho atualizado a cada pacote. Arquivos não ficam dentro do aplicativo: cada usuário recebe sua pasta Application Support/Lume Flow. O limite inicial é 5 minutos por ditado e o histórico tem paginação de 100 registros e busca por origem.

Helper Objective-C próprio observa flagsChanged para Fn (keycode 63) e Escape. Não suprime a função padrão da tecla: o usuário precisa evitar conflito com ditado macOS/Wispr. O helper verifica PID e elemento AX focado antes de emitir Cmd+V. Reporta envio do evento, não confirmação de texto inserido pelo aplicativo. Não há retry automático. Clipboard anterior só é restaurado se não mudou desde a colagem.

A captura usa AudioWorklet e getUserMedia. Fonte de fixture sintética existe somente no modo desenvolvimento (`!app.isPackaged` e LUME_TEST_FIXTURE); nunca é acionada pelo pacote de distribuição. O indicador é uma janela sem foco, sempre visível e com botão de parar no modo fixo, sem ativar a janela.

Um servidor whisper.cpp próprio é iniciado pelo main em loopback, porta aleatória e caminho aleatório de 192 bits. O modelo fica carregado. Em pausas (600ms) após ao menos 3s de áudio, ou em 15s, um bloco é enviado ao motor; os resultados permanecem privados até a finalização. Não é streaming token-a-token. Cortes de 15s podem afetar palavras de fronteira e exigem evolução com overlap/alinhamento. Silero VAD no motor filtra silêncio. O limiar RMS atual pode descartar fala muito baixa; precisa calibração com voz real.

Formatação V0: pontuação produzida pelo ASR, capitalização, correções literais por limites Unicode, comandos nova linha/novo tópico e modo de tópicos. Não implementa ainda reorganização semântica por LLM equivalente ao Wispr. Correções alimentam o prompt de vocabulário do ASR e são aplicadas novamente ao texto. Edições não treinam um modelo nem viram regras implicitamente.

Cancelamento invalida a sessão, fecha captura e preserva áudio. Uma inferência já enviada pode continuar no motor; seu resultado é descartado. Eventos antigos e finalizações duplicadas não podem colar. O processo do motor é encerrado ao sair; não há daemon ou configuração global.

Distribuição: Electron, helper, motor estático, shaders Metal embutidos, fontes e modelos via caminhos relativos. Nenhuma dependência de Homebrew, Node instalado, Claude CLI, LIA ou REA no computador destino. Sem conta, token ou endpoint pessoal. Há builds separados arm64 e x64, macOS14+. x64 ainda precisa teste real; a seleção de arquitetura é conferida antes do pacote. Não é universal.

O pacote local usa assinatura ad hoc. Para distribuição normal a alunos via download, falta assinatura Developer ID e notarização Apple, além de teste em Mac limpo. Não desativar Gatekeeper como parte da instalação. Cada Mac deve conceder suas próprias permissões de microfone e acessibilidade; permissões não vão dentro do backup.
