<#
.SYNOPSIS
Interactive chat client for Ollama API (Streaming)
.DESCRIPTION
Connects to localhost:11434 and facilitates a chat session with the 'llama3' model.
Handles streaming responses for a responsive experience.
#>

$OLLAMA_API = "http://localhost:11434/api/chat"
$MODEL = "llama3"

# Initialize conversation history with a system prompt if desired, or empty
$history = @()

Write-Host "[-] Connecting to Ollama API ($OLLAMA_API)..." -ForegroundColor Cyan
Write-Host "[-] Model: $MODEL" -ForegroundColor Cyan
Write-Host "[-] Type '/bye' to exit." -ForegroundColor Yellow
Write-Host ""

# Ensure we can use proper .NET HttpClient
Add-Type -AssemblyName System.Net.Http

$client = [System.Net.Http.HttpClient]::new()
$client.Timeout = [TimeSpan]::FromMinutes(10)

while ($true) {
    # 1. Get User Input
    $userParam = Read-Host -Prompt "You"
    if ([string]::IsNullOrWhiteSpace($userParam)) { continue }
    if ($userParam -eq "/bye" -or $userParam -eq "exit") { break }

    # 2. Add to history
    $history += @{ role = "user"; content = $userParam }

    # 3. Construct Payload
    $payload = @{
        model = $MODEL
        messages = $history
        stream = $true
    } | ConvertTo-Json -Depth 10 -Compress

    # 4. Send Request (Streaming)
    Write-Host "Llama3: " -NoNewline -ForegroundColor Green
    
    try {
        $content = [System.Net.Http.StringContent]::new($payload, [System.Text.Encoding]::UTF8, "application/json")
        $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, $OLLAMA_API)
        $request.Content = $content

        # SendAsync with ResponseHeadersRead to allow streaming
        $responseTask = $client.SendAsync($request, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead)
        $responseTask.Wait()
        $response = $responseTask.Result


        if (-not $response.IsSuccessStatusCode) {
            Write-Error "API Error: $($response.StatusCode) - $($response.ReasonPhrase)"
            $content = $response.Content.ReadAsStringAsync().Result
            Write-Host "Response Body: $content" -ForegroundColor Red
            continue
        }

        # Read the stream
        $streamTask = $response.Content.ReadAsStreamAsync()
        $streamTask.Wait()
        $stream = $streamTask.Result
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)

        $assistantMessage = ""

        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLineAsync().Result
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                try {
                    $json = $line | ConvertFrom-Json
                    if ($json.message -and $json.message.content) {
                        $chunk = $json.message.content
                        Write-Host $chunk -NoNewline
                        $assistantMessage += $chunk
                    }
                    if ($json.done) {
                        # Request complete
                    }
                } catch {
                    # Ignore JSON parse errors on partial lines (rare but possible)
                }
            }
        }
        
        # 5. Append full response to history
        Write-Host "" # Newline after response
        $history += @{ role = "assistant"; content = $assistantMessage }
        Write-Host ""

    } catch {
        Write-Error "Connection failed: $_"
    }
}

$client.Dispose()
Write-Host "[-] Goodbye." -ForegroundColor Yellow
