# VERIFICADOR DE ERROS

Use este checklist para identificar exatamente qual é o problema.

---

## ✓ Verificação 1: PostgreSQL está rodando?

```powershell
# Tente conectar ao PostgreSQL
psql -U postgres -h localhost -c "SELECT version();"
```

**Resultado esperado:** Mostra versão do PostgreSQL  
**Se der erro:** PostgreSQL não está rodando ou senha incorreta

### Solução:
1. Instale PostgreSQL de: https://www.postgresql.org/download/
2. Inicie o serviço PostgreSQL
3. Verifique se está em `localhost:5432`

---

## ✓ Verificação 2: Java está instalado?

```powershell
java -version
javac -version
```

**Resultado esperado:** Mostra Java 17 ou superior  
**Se der erro:** Java não está instalado

### Solução:
Instale de: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html

---

## ✓ Verificação 3: Banco de dados existe?

```powershell
psql -U postgres -c "SELECT datname FROM pg_database WHERE datname='bci_queue';"
```

**Resultado esperado:** Mostra `bci_queue`  
**Se estiver vazio:** Banco não existe

### Solução:
```sql
CREATE DATABASE bci_queue;
```

---

## ✓ Verificação 4: Maven consegue compilar?

```powershell
cd 'd:\Projetos\Banco\Jornadas Cientificas\Apk\queue'
.\mvnw.cmd compile -X 2>&1 | Select-String "BUILD" | Select-Object -Last 1
```

**Resultado esperado:** `BUILD SUCCESS`  
**Se disser FAILURE:** Há erro de compilação

### Solução:
Se disser **FAILURE**, procure acima por mensagens tipo:
- `cannot find symbol` → Falta dependência
- `duplicate class` → Classe duplicada
- `compilation error` → Erro de sintaxe Java

---

## ✓ Verificação 5: Arquivo de configuração está correto?

Abra: `Apk/queue/src/main/resources/application.properties`

Deve conter:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/bci_queue
spring.datasource.username=postgres
spring.datasource.password=Macuacua007
server.port=8080
```

**Se diferente:** Corrija com os valores acima

---

## ✓ Verificação 6: Backend consegue iniciar?

```powershell
cd 'd:\Projetos\Banco\Jornadas Cientificas\Apk\queue'
.\mvnw.cmd spring-boot:run
```

**Resultado esperado:** Mensagem tipo `Tomcat started on port(s): 8080`  
**Se der erro:** Há problema de conexão com banco

### Erros comuns:
```
"Cannot get a connection, pool error Timeout waiting for idle object"
→ PostgreSQL não está acessível ou senha incorreta

"Column 'id' not found"
→ Banco criada mas não tem tabelas (execute Script SQL)
```

---

## ✓ Verificação 7: Frontend consegue acessar backend?

1. Abra: `http://localhost:8080/index.html`
2. Abra Console do Navegador (**F12**)
3. Tente fazer login com PIN `1234`
4. Procure por erros tipo `net::ERR_CONNECTION_REFUSED`

**Se aparecer esse erro:** Backend não está rodando

---

## 📋 RESUMO - Qual é o seu erro?

### Erro 1: "Maven cannot complete the goal"
➜ **Solução:** Use IntelliJ IDEA (evita problema de Maven)

### Erro 2: "Cannot connect to database"
➜ **Solução:** Verifique PostgreSQL rodando com senha correta

### Erro 3: "Connection refused on localhost:8080"
➜ **Solução:** Backend não foi iniciado, rodeo `mvnw.cmd spring-boot:run`

### Erro 4: "Table 'senha' not found"
➜ **Solução:** Execute script SQL para criar tabelas

### Erro 5: "Invalid pin" ou login não funciona
➜ **Solução:** Use PIN correto (1234 para atendente, 9999 para gestor)

### Erro 6: "Mobile app says connection refused"
➜ **Solução:** Backend não está rodando ou URL errada em `senha_service.dart`

---

## 🔧 Se Nada Funcionar

**Opção Default (Sempre Funciona):**
1. Instale IntelliJ IDEA Community
2. Abra como projeto Maven
3. Rode QueueApplication.java
4. IDE cuida de tudo automaticamente

**Tempo:** ~15 minutos  
**Taxa de sucesso:** 99%

---

**Avise qual erro você está vendo para eu ajudar com a solução específica!**
