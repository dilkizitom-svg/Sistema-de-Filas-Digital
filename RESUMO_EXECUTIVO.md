# RESUMO EXECUTIVO - SmartFila
## O que Foi Feito e Como Usar

---

## ✅ STATUS ATUAL

| Componente | Status | Descrição |
|-----------|--------|-----------|
| Backend Java | 🔧 Pronto para rodar | Spring Boot 3.5.11, PostgreSQL |
| Frontend (Atendente) | 🔧 Pronto para rodar | HTML/JS, Login com PIN `1234` |
| Frontend (Gestor) | 🔧 Pronto para rodar | HTML/JS, Login com PIN `9999` |
| App Mobile (Flutter) | ✓ Reconfigurado | Aponta para `http://127.0.0.1:8080/api` |
| Banco de Dados | ℹ️ Requer setup | PostgreSQL local em `localhost:5432` |

---

## 🚀 COMO COMEÇAR AGORA

### Passo 1: Instalar PostgreSQL
1. Download: https://www.postgresql.org/download/
2. Instale e anote a **senha de admin** (ex: `postgres` user)
3. Verifique que está rodando: `localhost:5432`

### Passo 2: Rodar o Backend
**Opção A (Recomendado - Script PowerShell):**
```powershell
# Abra PowerShell como Admin
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
cd 'd:\Projetos\Banco\Jornadas Cientificas'
.\RUN_BACKEND.ps1
```

**Opção B (Manual):**
```cmd
cd d:\Projetos\Banco\Jornadas Cientificas\Apk\queue
set DB_USERNAME=postgres
set DB_PASSWORD=Macuacua007
mvnw.cmd spring-boot:run
```

**Opção C (IntelliJ IDEA):**
1. Abra a pasta `Apk/queue`
2. Clique em "Run" → "Run 'QueueApplication'"

### Passo 3: Abrir no Navegador
```
http://localhost:8080/index.html
```

**Fazer Login:**
- Nome: `gestor` (ou qualquer nome)
- Senha: `1234` (PIN Atendente) ou `9999` (PIN Gestor)

### Passo 4 (Opcional): Compilar App Mobile
```bash
cd d:\Projetos\Banco\Jornadas Cientificas\bci_queue_app
flutter pub get
flutter run  # Para Android emulator
```

---

## 🛡️ SEGURANÇA - O QUE MUDOU

### Vulnerabilidades Corrigidas
- ✓ Removida senha do PostgreSQL do código (`Macuacua007` → variável de ambiente)
- ✓ Atualizado app mobile para usar URL local em vez de ngrok
- ✓ Configuração do Spring simplificada e funcional

### Vulnerabilidades Mantidas (Por Pragmatismo)
- ℹ️ CORS aberto (necessário para mobile + frontend funcionado)
- ℹ️ PIN simple (recomendado substituir por JWT em produção)
- ℹ️ Sem HTTPS local (use em produção)

### Para Produção (Antes de Deploy)
1. Implementar autenticação JWT/OAuth2
2. Ativar HTTPS com certificado
3. Restringir CORS para domínios conhecidos
4. Configurar firewall de aplicação
5. Implementar rate limiting

---

## 📁 ARQUIVOS IMPORTANTES

```
d:\Projetos\Banco\Jornadas Cientificas\
├── RUN_BACKEND.ps1                    ← Script para rodar backend
├── INSTRUÇÕES_PARA_RODAR.md           ← Guia detalhado
├── RELATÓRIO_VULNERABILIDADES.md      ← Para seu trabalho teórico
├── Apk\queue\                         ← Backend Spring Boot
│   ├── src\main\resources\
│   │   ├── application.properties     ← Config (DB, servidor)
│   │   └── static\
│   │       ├── index.html             ← Painel Atendente
│   │       └── gestor.html            ← Painel Gestor
│   └── pom.xml                        ← Dependências Maven
├── bci_queue_app\                     ← App Flutter
│   ├── lib\Services\
│   │   └── senha_service.dart         ← Cliente API
│   └── pubspec.yaml                   ← Dependências Flutter
└── .gitignore                         ← Arquivos ignorados (credenciais)
```

---

## ❓ PROBLEMAS COMUNS

### "A aplicação não está respondendo"
**Solução:**
1. Verifique se backend está rodando (console do RUN_BACKEND.ps1)
2. Confira se PostgreSQL está rodando
3. Tente parar (Ctrl+C) e rodar novamente
4. Verifique logs para erros de conexão

### "PostgreSQL error: role 'postgres' not found"
**Solução:**
1. Use o usuário padrão PostgreSQL (geralmente `postgres`)
2. Verifique a senha correta
3. Ou crie um novo usuário PostgreSQL

### "Port 8080 is already in use"
**Solução:**
1. Edite `Apk/queue/src/main/resources/application.properties`
2. Mude `server.port=8080` para `server.port=9090`
3. Acesse `http://localhost:9090/index.html`

### "Flutter app says 'connection refused'"
**Solução:**
1. Verifique se backend está rodando em `http://127.0.0.1:8080`
2. Se usar Android emulator, use `10.0.2.2:8080` (não `127.0.0.1`)
3. Edite `bci_queue_app/lib/Services/senha_service.dart` com a URL correta

---

## 📋 CHECKLIST VOCÊ DEVE FAZER

- [ ] Instalar PostgreSQL
- [ ] Rodar `RUN_BACKEND.ps1` (ou equivalente)
- [ ] Acessar `http://localhost:8080/index.html`
- [ ] Fazer login com PIN `1234`
- [ ] Criar uma senha (clique "Chamar Próxima")
- [ ] Concluir atendimento
- [ ] Acessar `http://localhost:8080/gestor.html`
- [ ] Fazer login com PIN `9999` (gestor)
- [ ] Ver dashboard e histórico
- [ ] (Opcional) Compilar app Flutter

---

## 🎓 PARA SEU TRABALHO TEÓRICO

Use os seguintes arquivos como base:

1. **RELATÓRIO_VULNERABILIDADES.md**
   - Detalhado, com CVSS scores
   - Refere OWASP Top 10
   - Exemplos de exploração

2. **INSTRUÇÕES_PARA_RODAR.md**
   - Estrutura técnica
   - Pré-requisitos
   - Troubleshooting

3. **Este arquivo (RESUMO_EXECUTIVO.md)**
   - Visão geral
   - Checklist
   - Problemas comuns

**Sugestão de Seções para Trabalho:**
- Introdução: Problema de segurança em aplicações web
- Metodologia: Análise estática e revisão de código
- Resultados: Vulnerabilidades encontradas e CVSS scores
- Discussão: Mitigações implementadas vs. recomendações
- Conclusão: Estado de segurança da aplicação

---

## 📞 PRÓXIMAS AÇÕES

**Imediato (Hoje):**
1. Rodar backend e testar login
2. Confirmar que tudo funciona

**Curto Prazo (Esta semana):**
1. Implementar autenticação JWT
2. Adicionar HTTPS com certificado auto-assinado
3. Implementar testes de segurança

**Médio Prazo (Este mês):**
1. Deploy em ambiente de staging
2. Pentest/ethical hacking
3. Conformidade LGPD

---

## 📝 NOTAS

- **Segurança Local**: A configuração atual é APENAS para desenvolvimento
- **Não usar em Produção**: Sem os passos de hardening recomendados
- **Credenciais**: Mude `Macuacua007` para uma senha forte
- **Monitoramento**: Implemente logging centralizado antes de produção

---

**Criado em:** 11 de Abril de 2026  
**Versão:** 1.0  
**Status:** Pronto para Desenvolvimento Local  
**Próxima Revisão:** Após implementação de JWT
