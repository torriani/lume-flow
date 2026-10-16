# Como o LumeFlow funciona

## Componentes

| Componente | Responsabilidade |
|---|---|
| Electron main | Estado da sessão, SQLite, arquivos, IPC, motor e coordenação da colagem |
| Janela principal | Histórico, vocabulário, preferências e Insights |
| Renderer de captura | `getUserMedia`, AudioContext e AudioWorklet |
| Overlay sem foco | Barrinha, atividade de áudio e Stop |
| `lume-helper` | Fn/Espaço/Escape, foco do macOS e emissão de Cmd+V |
| Motor whisper.cpp | Reconhecimento de áudio local com Whisper e Silero VAD |

Não há serviço instalado no launchd nem necessidade de um servidor remoto. O processo do motor pertence ao aplicativo e é encerrado ao sair. O nome `Lume Server` na alteração local não muda a tecnologia Whisper utilizada nem suas licenças.

## Fluxo de um ditado

1. O helper informa o gesto Fn ao main; uma máquina de estados distingue segurar de modo fixo.
2. O main cria o registro e o WAV antes de solicitar captura.
3. O renderer solicita o microfone e inicializa áudio mono a 16 kHz. A primeira amostra depende da autorização/dispositivo e da inicialização do AudioContext; não há garantia de atraso zero desde a tecla física.
4. AudioWorklet converte amostras para PCM16 e envia blocos sequenciados. O main grava o conteúdo e atualiza o cabeçalho WAV incrementalmente.
5. Após pelo menos três segundos acumulados e 600 ms de silêncio, ou ao atingir 15 segundos, um bloco pode entrar na fila de reconhecimento. O limiar RMS pode descartar fala muito baixa.
6. O motor reconhece os blocos sequencialmente; a sessão guarda as partes.
7. Ao finalizar, o microfone é fechado, o arquivo sincronizado e a fila drenada.
8. Regras de vocabulário, formatação, estilo e categoria são aplicadas; texto, duração e diagnóstico são salvos.
9. O helper valida o destino e tenta colar. O histórico continua disponível independentemente da colagem.

O máximo é cinco minutos por ditado. A captura confirma início em até dez segundos; o encerramento tem timeout de cinco segundos. Inicialização do modelo tem limite aproximado de 60 segundos e uma requisição de transcrição pode aguardar até 120 segundos. Esses limites são de erro, não metas de desempenho.

## Estados

`idle → starting → recording → stopping → processing → idle`.

Cancelamento invalida a sessão, fecha a captura e preserva o áudio recebido. Uma inferência em andamento pode continuar até terminar; seu resultado é descartado. IDs e sequência de blocos evitam que eventos atrasados sejam aplicados a outra sessão. A finalização é protegida contra execução duplicada.

## Motor e memória

Na 0.2.0 pública, o motor é iniciado ao abrir e permanece carregado. Nas alterações locais 0.2.1, inicia ao ditar ou ao preparar explicitamente e entra em repouso após dois minutos sem uso. O timer não encerra durante uma sessão ativa, recuperação ou requisição de transcrição. Um novo início espera o processo anterior terminar se houver encerramento em curso.

Abrir/fechar esse processo é uma operação normal do sistema; o custo relevante é recarregar os pesos, alocar memória e preparar o motor. Na 0.2.1, a captura é solicitada sem esperar esse carregamento, mas um ditado curto pode terminar antes de o modelo ficar pronto e esperar pelo texto. Ainda requer validação com microfone real após repouso. Não existe garantia de resposta em menos de um segundo.

A interface e o helper continuam consumindo memória em repouso. Memória varia com histórico, sistema, GPU, compressão e uso. Não confundir tamanho do instalador, memória virtual, RSS e footprint. “Motor desligado” não significa consumo zero do aplicativo.

## Reconhecimento e rede

Modelo padrão: `ggml-large-v3-turbo-q5_0.bin`; VAD: `ggml-silero-v5.1.2.bin`. Português é solicitado explicitamente. O servidor escuta em `127.0.0.1`, numa porta escolhida em execução, com caminho aleatório de 192 bits. Esse caminho reduz acesso casual, mas não é uma fronteira contra processos maliciosos no mesmo usuário/Mac.

Não há transmissão dos ditados a uma API de nuvem no fluxo implementado. Os downloads dos modelos durante o build usam internet. O aplicativo não faz streaming token a token; reconhece blocos. O corte de 15 segundos não tem alinhamento com sobreposição e pode prejudicar palavras nas fronteiras.

## Foco e colagem

Ao encerrar por Fn, o helper registra PID, nome do aplicativo e elemento AX focado. Para Stop, o main solicita captura do foco; se não houver resposta em 400 ms, salva o texto sem escolher um destino inseguro. O overlay não deve roubar foco.

Antes de colar, o helper compara novamente aplicativo e elemento. Usa a área de transferência e Cmd+V. A restauração do clipboard anterior ocorre após 700 ms apenas se seu conteúdo não mudou nesse intervalo. Campos seguros ou aplicativos com comportamento especial podem rejeitar a colagem.

## Recuperação

O áudio existente é convertido com `/usr/bin/afconvert` para WAV PCM16 mono 16 kHz, validado e reconhecido em blocos de 30 segundos. O registro é atualizado somente após obter texto; falhas preservam texto anterior e áudio. O resultado usa as regras atuais, pode diferir do original e nunca é colado automaticamente.
