# Script para rodar SmartFila Backend
# Uso: PowerShell -ExecutionPolicy Bypass -File RUN_BACKEND.ps1

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SmartFila - Sistema de Gestão de Filas       ║" -ForegroundColor Cyan
Write-Host "║                  INICIALIZADOR                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar Java
Write-Host "[1/5] Verificando Java..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Java encontrado" -ForegroundColor Green
    Write-Host $javaVersion[0] -ForegroundColor Gray
} else {
    Write-Host "✗ Java não encontrado!" -ForegroundColor Red
    Write-Host "    Instale Java 17+ de: https://www.oracle.com/java/technologies/javase-jdk17-downloads.html" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/5] Definindo variáveis de ambiente..." -ForegroundColor Yellow

# Defina credenciais do banco de dados
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "Macuacua007"  # MUDE PARA UMA SENHA FORTE!

Write-Host "✓ DB_USERNAME = $env:DB_USERNAME" -ForegroundColor Green
Write-Host "⚠ DB_PASSWORD definida (mude a padrão em produção!)" -ForegroundColor Yellow

Write-Host ""
Write-Host "[3/5] Verificando PostgreSQL..." -ForegroundColor Yellow

# Tentar conectar ao PostgreSQL (requer psql instalado)
# Ignorar se não estiver disponível
if (Get-Command psql -ErrorAction SilentlyContinue) {
    try {
        psql -U postgres -c "SELECT version();" 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ PostgreSQL conectado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "⚠ PostgreSQL pode não estar acessível ou credenciais incorretas" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ Não foi possível verificar PostgreSQL (pode estar desligado)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ psql não encontrado (PostgreSQL pode estar rodando, mas não consegui verificar)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/5] Compilando backend com Maven..." -ForegroundColor Yellow
Write-Host "      (Isso pode levar alguns minutos na primeira vez...)" -ForegroundColor Gray

$queuePath = "d:\Projetos\Banco\Jornadas Cientificas\Apk\queue"
Set-Location $queuePath

# Tentar compilar
.\mvnw.cmd clean compile -q -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Compilação bem-sucedida!" -ForegroundColor Green
} else {
    Write-Host "✗ Erro na compilação. Tente:" -ForegroundColor Red
    Write-Host "   1. Instale Maven globalmente" -ForegroundColor Yellow
    Write-Host "   2. Use IntelliJ IDEA para compilar (mais confiável)" -ForegroundColor Yellow
    Write-Host "   3. Verifique a conexão de internet" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[5/5] Iniciando aplicação Spring Boot..." -ForegroundColor Yellow
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        Backend iniciado com sucesso! 🚀            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "URLs disponíveis:" -ForegroundColor Green
Write-Host "  • Painel Atendente: http://localhost:8080/index.html" -ForegroundColor Cyan
Write-Host "  • Painel Gestor:    http://localhost:8080/gestor.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "Credenciais de acesso:" -ForegroundColor Green
Write-Host "  • Usuário: gestor" -ForegroundColor Cyan
Write-Host "  • PIN Atendente: 1234" -ForegroundColor Cyan
Write-Host "  • PIN Gestor:    9999" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione Ctrl+C para parar o servidor" -ForegroundColor Yellow
Write-Host ""

# Rodar Spring Boot
.\mvnw.cmd spring-boot:run
