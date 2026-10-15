# Critérios de release

## Validado neste Mac Apple Silicon
- Fn + Espaço mantendo gravação após soltar as teclas, confirmado pelo usuário.
- Ditado segurando Fn, transcrição local, áudio salvo e cópia.
- Seleção do campo de destino antes de finalizar.
- Indicador compacto, reprodução de áudio e ações rápidas.
- Testes automatizados de dados, recuperação, atalhos, áudio e histórico.

## Pendente antes de anunciar versão estável
- Botão de parar do overlay preservando o campo de destino.
- Instalação limpa em outro Apple Silicon, microfone e permissões.
- Execução em hardware Intel e latência nessa arquitetura.
- Testar macOS 14 e versões posteriores separadamente.
- Assinatura Developer ID, hardened runtime/entitlements e notarização.
- Workflow de CI concluído no repositório público. A primeira execução foi bloqueada pelo GitHub antes de iniciar os jobs por indisponibilidade dos runners; builds locais não substituem essa validação.

Pacotes cross-compilados não equivalem a testes em hardware real. Não marcar os itens acima como concluídos apenas por existirem arquivos ou por compilar.
