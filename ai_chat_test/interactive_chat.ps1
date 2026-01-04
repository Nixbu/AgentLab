# launch_chat.ps1
# Launches an interactive chat session with the Llama 3 model running in the Docker container.
# This bypasses the Agent/LangChain layer.

Write-Host "[-] Connecting to Ollama (llama3)..." -ForegroundColor Cyan
Write-Host "[-] Type /bye to exit." -ForegroundColor Yellow

docker exec -it ollama-server ollama run llama3
