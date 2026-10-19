# Atualizações do LumeFlow

A partir da prévia 0.3.0, o aplicativo consulta as releases públicas de `torriani/lume-flow` ao abrir, quando estiver ocioso. Também existe **LumeFlow → Buscar atualizações…**, inclusive no menu do ícone na barra do macOS.

A consulta envia somente uma requisição pública ao GitHub, sem áudio, histórico, vocabulário ou credenciais. Sem internet, a abertura continua normalmente. Gravação, recuperação e importação adiam o aviso. A comparação usa a versão numérica e seleciona o ZIP da arquitetura do aplicativo (arm64 ou x64). Releases experimentais entram nessa consulta; drafts e uploads incompletos são ignorados.

## Instalação nesta prévia

**A instalação não é automática.** Ao escolher “Baixar atualização”, o navegador baixa o ZIP oficial. Termine o ditado, encerre o LumeFlow, extraia o ZIP e substitua o aplicativo em Aplicativos. Reabra e confira as permissões de Microfone, Acessibilidade e Monitoração de Entrada. A assinatura ad-hoc pode exigir remover e adicionar novamente o LumeFlow nas permissões.

O histórico permanece em `~/Library/Application Support/Lume Flow`, separado do aplicativo. Não apague essa pasta. Faça um backup pelas preferências antes de trocar versões se desejar.

Instalações 0.1 e 0.2 não possuem essa consulta: precisam receber a 0.3.0 manualmente uma vez. A versão aparece em Finder → Aplicativos → LumeFlow → Obter Informações ou no menu Sobre.

## O que falta para instalar automaticamente

O atualizador nativo do Electron no macOS exige assinatura de código. Para distribuir com identidade estável e notarização, falta configurar o certificado Developer ID da conta Apple Developer do mantenedor. Não contornamos Gatekeeper nem desabilitamos verificações de assinatura. Esta versão não promete instalação silenciosa.

Referência: [autoUpdater do Electron](https://www.electronjs.org/docs/latest/api/auto-updater).

## Publicar outra versão

1. Atualize `package.json` e `package-lock.json` com uma versão numérica maior.
2. Execute testes Node e nativos, compile helper e motor para cada arquitetura e empacote.
3. Crie os ZIPs com nomes `LumeFlow-VERSAO-mac-arm64.zip` e `LumeFlow-VERSAO-mac-x64.zip`.
4. Exporte o código limpo, revise os arquivos e gere SHA-256.
5. Crie uma release em rascunho, suba os quatro arquivos e confira tamanho e digest remoto.
6. Publique a prévia com tag `vVERSAO-preview.1`. Não reutilize a mesma versão numérica para mudanças: os aplicativos instalados só oferecem versões maiores.

Não altere a versão antiga nem remova os downloads anteriores. Uma publicação só está concluída depois de conferir os arquivos remotos. Testes automatizados não substituem a validação de Fn e colagem em outro Mac.
