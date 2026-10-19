# Estado atual — prévia 0.3.0

A 0.3.0 reúne as correções locais abaixo e adiciona consulta de versões ao abrir e pelo menu. Instalação ainda manual: falta certificado Apple Developer. Consulte [atualizações](../ATUALIZACOES.md). Os registros abaixo são históricos e descrevem a disponibilidade na data indicada. A validação interativa de colagem no segundo Mac continua pendente.

# Estado das versões

Referência: 15/10/2026. “Implementado” não significa “disponível no ZIP público”.

| Recurso | Release pública 0.2.0 | Código 0.2.1 em desenvolvimento |
|---|---|---|
| Fn segurado / Fn + Espaço | Disponível; validado pelo usuário no Mac de desenvolvimento | Mantido |
| Motor de transcrição | `whisper-server`, carregado ao abrir | `Lume Server`, sob demanda, encerra após inatividade |
| Memória em repouso | Modelo permanece carregado | Motor libera memória após dois minutos sem uso |
| Captura com motor frio | Requer motor pronto | Captura começa sem aguardar carregamento do modelo |
| Botão Stop | Visível durante a gravação, inclusive segurando Fn | Preparado para aparecer só no modo fixo |
| Importação na primeira abertura | Não há assistente; ferramentas de importação no código | Pergunta opcional e ação no menu, implementadas e testadas com dados sintéticos |
| Histórico, áudio, copiar, recuperação | Disponíveis | Mantidos |
| Distribuição | ZIPs Apple Silicon e Intel publicados | Pacote Apple Silicon gerado localmente; sem nova release pública |

## Evidências

- Pública: 13 testes automatizados e teste nativo de atalho aprovados localmente antes da publicação.
- Pública: motores arm64 e x64 testados com áudio sintético e silêncio; x64 executado via Rosetta, não em hardware Intel.
- Pública: arquivos da release conferidos por tamanho e SHA-256 após upload.
- Local: 20 testes aprovados, incluindo repouso/reinício e importação sem duplicar dados.
- Local: encerramento do motor real por inatividade observado; transcrição sintética com `Lume Server` aprovada.
- Local: visibilidade do Stop verificada por estados em teste isolado. Ainda requer confirmação visual/funcional na versão instalada após aplicar esse pacote.
- Local: importação por worker testada com banco sintético. O diálogo de primeira abertura ainda requer teste completo em instalação limpa.

O pacote 0.2.1 foi instalado no Mac de desenvolvimento com economia de memória, assistente de importação, Stop exclusivo do modo fixo e ícone na barra de menus. Fn e Acessibilidade foram reconectados após a atualização. A confirmação visual do Stop e o fluxo de importação em instalação limpa ainda estão pendentes; os downloads públicos permanecem em 0.2.0.

## Pendências comuns

Notarização e assinatura Developer ID, validação em segundo Mac, hardware Intel e diferentes versões do macOS. O workflow público não concluiu uma compilação: os jobs foram bloqueados antes de iniciar. Consulte a aba Actions para o estado atual; não use esse bloqueio como evidência de falha do código nem como aprovação de CI.

Release disponível: [v0.2.0-preview.1](https://github.com/torriani/lume-flow/releases/tag/v0.2.0-preview.1).

## Interface e colaboração

O código 0.2.1 inclui ícone monocromático próprio na barra de menus, sem o texto “Lume”. Capturas de telas reais com dados fictícios estão no README. O guia de contribuição, modelos de issues e pull requests estão em português; @torriani é o mantenedor indicado em CODEOWNERS. Os instaladores públicos continuam em 0.2.0 até uma nova release.

## Correção de voz baixa e interrupções (código 0.2.1)

Instalada localmente: remoção do descarte por volume, ganho limitado na cópia de reconhecimento, som inicial após prontidão do microfone, cancelamento silencioso e reconexão do monitor sem cancelar a sessão. Teste real do motor com referência sintética reduzida a 1/20 do volume reconheceu a frase; silêncio retornou vazio. A validação com a voz do usuário após a atualização ainda está pendente. Os ZIPs públicos continuam na 0.2.0.

## Colagem e indicador — revisão de 16/10/2026

Código e pacote local atualizados para capturar o destino por sessão ao encerrar, distinguir campo indisponível de destino alterado, habilitar a árvore de acessibilidade de aplicativos Electron e posicionar a barrinha na tela da janela ativa. Testes de política de destino e 20 testes Node aprovados. Teste interativo no Claude e no Claude Code do terminal ainda pendente; compilação não comprova inserção real. A ferramenta de controle do ambiente não permite operar o Terminal.
