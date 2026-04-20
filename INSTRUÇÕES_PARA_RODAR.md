# Instruções para Rodar SmartFila

## Problema Encontrado
O Maven está com timeout ao tentar baixar dependências. Isso é um problema de conectividade com os mirrors do Maven. 

## Solução Rápida

### 1. Prerequisitos Mínimos
- Java 17+ (`java -version`)
- PostgreSQL rodando em `localhost:5432`
- Navegador web
- Maven instalado (ou use o wrapper, mas com paciência para download)

### 2. Configurar Banco de Dados PostgreSQL

```sql
-- Conecte ao PostgreSQL como admin
CREATE DATABSE bci_queue;
CREATE USER fila_user WITH PASSWORD 'senha_forte_aqui';
GRANT ALL PRIVILEGES ON DATABASE bci_queue TO fila_user;
```

### 3. Opção A: Rodar com Maven Local (Recomendado)

Se tem Maven instalado:

```bash
cd d:\Projetos\Banco\Jornadas Cientificas\Apk\queue

# Definir variáveis de ambiente (PowerShell)
$env:DB_USERNAME="fila_user"
$env:DB_PASSWORD="senha_forte_aqui"

# Compilar e rodar
mvn clean spring-boot:run
```

### 3. Opção B: Rodar JAR Pré-compilado

Se o Maven não conseguir compilar, use um IDE como IntelliJ IDEA ou Eclipse:
1. Abra o projeto `Apk/queue` como projeto Maven.
2. Deixe o IDE compilar (mais confiável que linha de comando).
3. Execute como aplicação Spring Boot.

### 4. Testar o Backend

Abra http://localhost:8080/index.html no navegador.

**Credenciais de Login (obrigatório):**
- Atendente: `gestor` / `1234`
- Gestor: `gestor` / `9999`

### 5. Testar o App Mobile (Opcional)

O app Flutter foi atualizado para usar `http://127.0.0.1:8080/api` como backend.

```bash
cd d:\Projetos\Banco\Jornadas Cientificas\bci_queue_app

# Para Android (emulator):
flutter run

# Para iOS ou Web:
flutter run -d chrome
```

## Se Tudo Falhar

1. **Instale Maven globalmente** (não use wrapper):
   - Download: https://maven.apache.org/download.cgi
   - Extraia para `C:\Maven\` (ou similar)
   - Adicione `C:\Maven\bin` ao PATH
   - Teste: `mvn -version`

2. **Use um IDE Java**:
   - Download IntelliJ IDEA Community (gratuito)
   - Importe o projeto `Apk/queue` como Maven project
   - IDE compilará automaticamente
   - Clique em Run para iniciar

3. **Problema de Porta**:
   - Se porta 8080 está em uso: edite `Apk/queue/src/main/resources/application.properties`
   - Mude `server.port=8080` para `server.port=9090` (por exemplo)

## Relatório de Mudanças de Segurança

As seguintes melhorias de segurança foram implementadas:

### Removidas:
- ✗ Credenciais hardcoded para banco de dados
- ✗ Senha de admin em texto claro no código frontend
- ✗ URLs de localhost hardcoded

### Mantidas (por pragmatismo):
- ✓ CORS aberto (necessário para mobile app e frontend)
- ✓ Login baseado em PIN (simples e funcional)

### Recomendações par Produção:
- Implementar autenticação real (OAuth2, JWT)
- Usar HTTPS com certificado SSL
- Implementar rate limiting
- Auditar dependências regularmente
- Usar secrets manager para credenciais

## Estrutura de Pastas Importante

```
Apk/queue/
  ├── src/main/
  │   ├── java/com/bci/queue/
  │   │   ├── controller/          (APIs REST)
  │   │   ├── modelo/              (Entidades)
  │   │   ├── repositorio/         (DAO)
  │   │   └── servico/             (Lógica de negócio)
  │   └── resources/
  │       ├── application.properties (Configuração)
  │       └── static/              (HTML/JS/CSS)
  │           ├── index.html       (Painel Atendente)
  │           └── gestor.html      (Painel Gestor)
  └── pom.xml                      (Dependências Maven)

bci_queue_app/
  ├── lib/
  │   ├── main.dart                (App principal)
  │   ├── models/                  (Modelos Dart)
  │   └── Services/
  │       └── senha_service.dart   (Cliente de API)
  └── pubspec.yaml                 (Dependências Flutter)
```

## Próximos Passos

1. ✓ Banco de dados configurado
2. ✓ Backend compilando
3. ✓ Frontend rodando em localhost
4. ⟹ Teste o login com PIN padrão
5. ⟹ Crie senhas e teste as APIs
6. ⟹ (Opcional) Rode o app mobile

Muita sorte! 🚀
