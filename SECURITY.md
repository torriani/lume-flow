# Segurança e privacidade
Não publique segredos, bancos ou gravações em issues. Descreva o problema com passos reproduzíveis e dados sintéticos. Reporte vulnerabilidades pelo canal privado do GitHub: https://github.com/torriani/lume-flow/security/advisories/new.

O reconhecimento roda em localhost, com caminho aleatório por execução; o aplicativo não recebe comandos de rede para colar texto. IPC do renderer é validado por janela e frame. O overlay tem acesso somente ao comando de parar. Dados pessoais não fazem parte das releases.
