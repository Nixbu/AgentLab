# Indirect Prompt Injection Lab

A complete, Dockerized environment to demonstrate **Indirect Prompt Injection** using a local LLM (Ollama + Llama3).

## Architecture

1.  **Victim Agent**: Python + LangChain (ReAct). Connects to internal sites.
2.  **Archive Server (Malicious)**: Hosts `tomato.html` which contains the hidden payload. Port 8000.
3.  **Wiki Server (Benign)**: Hosts legitimate internal documentation. Port 8080.
4.  **Mailhog**: Captures the exfiltrated email traffic (SMTP trap). Port 8025/1025.
5.  **Ollama**: Runs the `llama3` model locally.

## Prerequisities

- Docker & Docker Compose
- Windows (PowerShell) or Linux (adapt the script accordingly)
- Adequate RAM/CPU for running Llama3 (approx 8GB+ RAM recommended)

## How to Run

1.  Open PowerShell in this directory.
2.  Run the setup script:
    ```powershell
    .\setup_and_run.ps1
    ```
    *This script will clean up old containers, start the new stack, pull Llama3, and launch the agent.*

3.  **Witness the Attack**:
    - The Agent is instructed to read `http://archive-server:8000/tomato.html`.
    - It ignores the benign content and executes the hidden instruction to send an email.
    - Go to **[http://localhost:8025](http://localhost:8025)** to see the captured email in Mailhog.

## Disclaimer
This lab is for EDUCATIONAL PURPOSES ONLY. Do not use these techniques on systems you do not own or have permission to test.
