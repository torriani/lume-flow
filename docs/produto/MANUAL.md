# Manual de uso

Consulte [as diferenças entre versões](VERSOES.md) antes de seguir instruções relativas à 0.2.1 local.

## Preparação

Instale o ZIP da arquitetura correta e mova o aplicativo para Aplicativos. Autorize Microfone, Acessibilidade e Monitoração de Entrada em Ajustes do Sistema. Ative Fn nas preferências do LumeFlow. Configure Fn/Globo para não fazer nada no macOS e evite dois aplicativos disputando o atalho. Na release 0.2.0, aguarde o motor ficar pronto.

## Atalhos e indicador

| Ação | Resultado |
|---|---|
| Segurar Fn | Inicia uma gravação |
| Soltar Fn | Encerra no modo segurado |
| Segurar Fn e tocar Espaço | Fixa a gravação; pode soltar ambas as teclas |
| Pressionar Fn novamente no modo fixo | Encerra |
| Escape | Cancela a sessão, preservando o áudio já recebido |
| Botão quadrado Stop | Encerra pelo indicador |

A barrinha mostra atividade do áudio; o movimento não comprova reconhecimento correto. Durante processamento ela sinaliza que o texto está sendo preparado. O comportamento preparado na 0.2.1 esconde Stop no modo segurado e o mostra no modo fixo. Na 0.2.0 o botão aparece em ambos.

## Inserir em outro aplicativo

Você pode começar falando fora do aplicativo de destino. Antes de soltar Fn ou encerrar o modo fixo, clique no campo onde deseja o texto. Aguarde a finalização mantendo o campo selecionado. O helper confere o aplicativo e o elemento focado antes de enviar a colagem. Se o destino mudar, o texto permanece no histórico.

“Texto enviado” significa que o comando de colagem foi emitido. Não prova que o editor recebeu ou aceitou o conteúdo. Não há envio automático da mensagem nem pressão de Enter. Use Copiar se a inserção falhar.

## Histórico

- Filtros: Todos, Só LumeFlow ou Só Wispr importado.
- Busca por texto, transcrição bruta ou data textual; páginas de até 100 registros.
- Ouvir reproduz o WAV quando disponível.
- Copiar coloca o texto final na área de transferência.
- Abrir permite revisar o texto, consultar original/diagnóstico e mudar categoria.
- Salvar revisão altera o registro; não cria automaticamente uma regra de vocabulário.
- Recuperar tenta transcrever novamente um áudio disponível. Não restaura gravação ausente e não cola automaticamente o resultado.

Não há exclusão em massa, sincronização entre Macs ou política automática de retenção implementadas.

## Vocabulário

Cadastre “Quando reconhecer” e “Escreva assim”. Exemplo sintético: `lumiflow` → `LumeFlow`. A correção considera limites de palavras, ignora diferença de caixa e prioriza expressões maiores; não encadeia substituições no mesmo passe. Até 80 substituições são usadas como contexto do reconhecedor, além da aplicação das regras ao texto final.

O aplicativo não treina um modelo pessoal, não aprende implicitamente com toda edição e não garante reconhecimento de um nome apenas por cadastrá-lo.

## Formatação e estilo

Natural preserva uma sequência de frases com ajustes locais. “Em tópicos” separa frases/linhas em itens. Diga “nova linha” ou “novo parágrafo” para inserir uma quebra de parágrafo e “novo tópico” ou “próximo tópico” para inserir item.

Formal expande algumas expressões (`pra`, `tô`, `tá`); Casual preserva essas expressões; Muito casual pode retirar o ponto final de textos curtos. A limpeza remove hesitações explícitas e duplicações simples. Essas regras podem interpretar literalmente uma expressão que você queria mencionar. Não há reescrita semântica por LLM.

Preferências por contexto: trabalho, e-mail, pessoal e outros. A categoria inferida ajuda a escolher o estilo; é uma heurística, não compreensão garantida da intenção.

## Sons

Perfis Suave, Pop, Cristal e Original, com prévia de início/fim e opção de silenciar. São sons próprios do LumeFlow; não são arquivos extraídos do Wispr Flow.

## Insights

Períodos de 7, 30, 90 dias ou todo o período; filtro por origem. Palavras por minuto são calculadas dividindo a soma de palavras com duração conhecida pela soma desses minutos, não pela média simples de velocidades por gravação. Pausas dentro do áudio afetam o indicador.

Categorias usam primeiro o aplicativo, depois preferências importadas e regras simples de texto: Codex/Claude/editores de código → prompts; clientes de e-mail → e-mails; Slack/Teams → trabalho; mensageiros → pessoal; editores de documentos → documentos. Isso pode classificar uma mensagem incorretamente.

As barras representam quantidade de ditados por categoria. O calendário mostra cerca de seis meses; sequências usam dias com palavras e podem considerar ontem se hoje ainda não houve uso. Calendário e sequências usam o histórico da origem selecionada, não apenas o período dos cartões. A comparação percentual usa os últimos 30 dias contra os 30 anteriores; sem base anterior, não há percentual.

Não há ranking global, percentil entre usuários, equipe, sincronização móvel ou equivalência garantida com números da nuvem do Wispr. Contagem de correções depende dos metadados disponíveis; zero não comprova ausência de erros.
