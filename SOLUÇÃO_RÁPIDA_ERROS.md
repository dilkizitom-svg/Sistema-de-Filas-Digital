# SOLUÇÃO RÁPIDA - Se Maven Não Funciona

## O Problema
Maven está demorando muito ou dando timeout ao tentar baixar dependências.

## Soluções (em ordem de facilidade)

### ✅ SOLUÇÃO 1: Usar IntelliJ IDEA Community (RECOMENDADO)

**Passo 1:** Download gratuito
```
https://www.jetbrains.com/idea/download/
```
Escolha "Community Edition" (é grátis)

**Passo 2:** Abrir projeto
1. Abra IntelliJ IDEA
2. "File" → "Open"
3. Selecione pasta `d:\Projetos\Banco\Jornadas Cientificas\Apk\queue`
4. Escolha "Open as Project"

**Passo 3:** Deixar IDE compilar
- IDE automaticamente:
  - Detecta que é projeto Maven
  - Baixa dependências (mais rápido/confiável que terminal)
  - Compila o projeto

**Passo 4:** Rodar
- Localize classe `QueueApplication.java`
- Clique com botão direito → "Run 'QueueApplication.main()'"
- Servidor inicia em `http://localhost:8080`

### ✅ SOLUÇÃO 2: Usar Eclipse IDE

**Passo 1:** Download
```
https://www.eclipse.org/downloads/
```

**Passo 2:** Abrir projeto
1. Abra Eclipse
2. "File" → "Open Projects from File System"
3. Selecione `Apk/queue`
4. Clique "Finish"

**Passo 3:** Esperar compilação automática
- Eclipse compila automaticamente
- Pode levar 2-3 minutos primeira vez

**Passo 4:** Rodar
- Clique direito em `QueueApplication.java`
- "Run As" → "Java Application"

### ✅ SOLUÇÃO 3: Instalar Maven Global (Avançado)

Se quer usar linha de comando, instale Maven:

**Passo 1:** Download Maven
```
https://maven.apache.org/download.cgi
```

**Passo 2:** Extrair
- Extraia para `C:\Maven` (ou caminho sem espaços)

**Passo 3:** Adicionar ao PATH
1. Abra "System Properties" (Win+Pause/Break)
2. "Advanced system settings"
3. "Environment Variables"
4. "Path" → "Edit"
5. Adicione `C:\Maven\bin`
6. Clique OK

**Passo 4:** Verificar instalação
```powershell
mvn -version
```

Deve mostrar versão do Maven.

**Passo 5:** Rodar projeto
```powershell
cd 'd:\Projetos\Banco\Jornadas Cientificas\Apk\queue'
mvn clean spring-boot:run
```

---

## ❓ Qual usar?

| Método | Tempo Setup | Confiabilidade | Velocidade |
|--------|------------|-----------------|-----------|
| IntelliJ IDEA | 5 min | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Eclipse | 5 min | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Maven Global | 10 min | ⭐⭐⭐ | ⭐⭐⭐⭐ |

**Recomendação: SOLUÇÃO 1 (IntelliJ)**
- Feito em 5 minutos
- Mais confiável
- Integrado para debug

---

## ✅ Após Conseguir Rodar Backend

Uma vez que o servidor estiver rodando (seja qual for o método):

1. Abra navegador
2. Vá para `http://localhost:8080/index.html`
3. Login:
   - Nome: `gestor`
   - Senha: `1234` (Atendente) ou `9999` (Gestor)

4. Pronto! Sistema funcional.

---

## 🚨 Se Tudo Falhar

Use **Visual Studio Code + Terminal**:

```powershell
# 1. Instale Java 17+
# https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html

# 2. Instale Maven como descrito acima

# 3. No VS Code, abra terminal integrado (Ctrl+ˋ)

# 4. Execute:
cd 'd:\Projetos\Banco\Jornadas Cientificas\Apk\queue'
mvn clean spring-boot:run
```

---

**Escolha 1 método acima e avise qual funcionou!**
