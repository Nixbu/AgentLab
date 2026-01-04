# Indirect Prompt Injection Lab - Setup & Run
# This script automates the setup, model pulling, and execution of the lab.

$OLLAMA_URL = "http://localhost:11434"
$MODEL_NAME = "llama3"

# Cleanup to ensure fresh network state
Write-Host "[-] cleaning up previous containers..." -ForegroundColor Yellow
docker-compose down --remove-orphans

Write-Host "[-] Starting infrastructure (Ollama, Archive, Mailhog)..." -ForegroundColor Cyan
# Force build to ensure file changes (like tomato.html) are picked up
docker-compose up -d --build --force-recreate ollama-server archive-server mailhog

# 1. Wait for Ollama to be UP
Write-Host "[-] Waiting for Ollama API to be responsive..." -ForegroundColor Yellow
$retries = 0
do {
    try {
        $response = Invoke-WebRequest -Uri "$OLLAMA_URL" -Method Head -ErrorAction Stop
        $ollamaUp = $true
    } catch {
        Start-Sleep -Seconds 2
        $retries++
        Write-Host "." -NoNewline
        if ($retries -gt 30) { 
            Write-Error "Ollama failed to start in time."
            exit 1 
        }
    }
} until ($ollamaUp)
Write-Host "`n[+] Ollama is UP." -ForegroundColor Green

# 2. Check and Pull Model
Write-Host "[-] Checking for model '$MODEL_NAME'..." -ForegroundColor Yellow
$models = docker exec ollama-server ollama list
if ($models -match $MODEL_NAME) {
    Write-Host "[+] Model '$MODEL_NAME' is already present. Skipping pull." -ForegroundColor Green
} else {
    Write-Host "[!] Model '$MODEL_NAME' not found. Pulling now... (This may take a while)" -ForegroundColor Magenta
    docker exec ollama-server ollama pull $MODEL_NAME
    Write-Host "[+] Model pulled successfully." -ForegroundColor Green
}

# 3. Build and Run Victim Agent
Write-Host "[-] Building and starting Victim Agent..." -ForegroundColor Cyan
# We verify everything is built
docker-compose build victim-agent

# We run the agent explicitly attached so we can see output, OR detached.
# Since it's a "one-shot" script, let's run it and follow logs.
docker-compose up -d victim-agent

Write-Host "[-] Agent is running. Following logs..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
docker logs -f victim-agent

Write-Host "`n[+] Lab Execution Complete." -ForegroundColor Green
Write-Host "Check Mailhog at http://localhost:8025 to see the stolen data!" -ForegroundColor Green
