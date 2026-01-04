# AgentLab

A security research environment for testing **Indirect Prompt Injection** and **Data Theft** attacks against LLM-based autonomous agents.

## 🧪 Scenarios

### 1. Indirect Prompt Injection Lab
A basic proof-of-concept demonstrating how an LLM agent reading a malicious website can be manipulated via hidden prompts.

**Location:** `indirect_prompt_injection_lab/`

### 2. Data Theft Lab
An advanced scenario where an LLM agent with access to simulated email data is tricked into searching for and exfiltrating sensitive PII (Bank Details, IBANs) to an attacker-controlled server.

**Location:** `data_theft_lab/`

## 🏗️ Architecture
The labs are built using:
- **Docker Compose**: Orchestration of victim agent, attacker server, and mailhog.
- **LangChain & Ollama**: The victim agent is powered by Llama 3 via Ollama.
- **MailHog**: Simulated email server for the agent to access.

## 🚀 Usage
See `setup_and_run.ps1` in the respective lab directories for startup instructions.
