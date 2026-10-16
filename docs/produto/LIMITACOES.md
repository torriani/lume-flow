# Limitações, falhas e diagnóstico

## O que o produto não promete

- Compatibilidade com qualquer Mac, Windows, Linux ou dispositivos móveis.
- Resultado idêntico ao Wispr Flow, reconhecimento perfeito ou latência fixa.
- Reescrita semântica com IA generativa, compreensão completa de intenção ou execução de prompts.
- Aprendizagem automática a partir de toda correção, treinamento/fine-tuning pessoal.
- Transcrição de reuniões, separação de falantes, gravação de áudio do sistema ou tradução.
- Sincronização na nuvem, contas, cobrança, times, leaderboard ou compartilhamento automático.
- Recuperar áudio ausente, dados apagados ou histórico exclusivamente remoto.
- Confirmar que um aplicativo externo aceitou a colagem.
- Atualizador automático, instalador notarizado, banco criptografado pelo próprio aplicativo ou política de exclusão automática.

## Diagnóstico por sintoma

| Sintoma | Verificar | Alternativa |
|---|---|---|
| Fn não faz nada | Ativar Fn nas preferências; Monitoração de Entrada; conflito com outro ditado; ação Fn do macOS | Reabrir após autorizar e testar Gravar aqui |
| Barrinha aparece mas não capta voz | Microfone autorizado, dispositivo conectado, entrada correta | Gravação curta de teste; conferir mensagem de erro |
| Texto demora depois de soltar | Motor carregando, memória/CPU pressionadas, fila de transcrição | Aguardar; em modo de repouso o primeiro uso é mais lento |
| Texto não aparece no destino | Acessibilidade, campo focado antes de finalizar, troca de foco durante processamento | Copiar pelo histórico |
| “Texto enviado”, mas campo vazio | O app externo pode rejeitar Cmd+V; status é envio do comando | Colagem manual; relatar qual aplicativo/campo |
| Áudio salvo, texto vazio | Volume baixo, silêncio, idioma, limiar de voz ou falha do motor | Ouvir e tentar Recuperar |
| Recuperação falha | WAV presente e íntegro, motor disponível, fala audível | O original permanece; não repetir esperando recuperar áudio inexistente |
| Importação falha | Banco local correto, esquema compatível, arquivo acessível | Fechar Wispr e tentar de novo; dados de nuvem não são buscados |
| Histórico sem Play | Áudio não foi armazenado/importado | Texto ainda pode ser copiado; não há reconstrução do áudio original |
| Insights diferentes do Wispr | Período, origem, registros locais disponíveis e fórmula | Comparar os mesmos dados; não preencher lacunas com números fictícios |
| macOS bloqueia instalação | Prévia ad-hoc, sem notarização | Não desativar proteções globais; aguardar distribuição assinada quando necessário |
| Permissão parece ativa após update, mas Fn falha | Assinatura de desenvolvimento mudou; registro antigo pode ficar inválido | Renovar autorização do LumeFlow nos Ajustes e reabrir; não modificar o banco TCC manualmente |

## Limites técnicos conhecidos

Ditados de até cinco minutos. Áudio precisa ser capturado a 16 kHz. Amostragem incompatível, microfone removido ou sequência de blocos inválida geram erro. Cortes de áudio sem sobreposição podem perder contexto. Limpeza e comandos falados são regras literais e podem produzir formatação indesejada. Português é o idioma padrão fixado no motor.

Não há processamento ilimitado de múltiplas sessões simultâneas. Recuperação impede ditado concorrente. A importação do assistente local também bloqueia novas sessões. Cancelar não implica interromper imediatamente a inferência já enviada.

## Como relatar um problema

Informe versão do aplicativo/release, modelo e arquitetura do Mac, versão do macOS, sequência exata de teclas, se ocorreu após repouso ou atualização, estado das permissões e mensagem apresentada. Use uma frase sintética, por exemplo “Este é um teste do LumeFlow”. Diferencie gravação, reconhecimento, formatação e colagem: são etapas distintas.

Um teste de áudio sintético não comprova microfone, Fn ou foco. Um teste via Rosetta não comprova funcionamento em hardware Intel. Testes unitários aprovados não substituem o fluxo completo numa instalação limpa.
