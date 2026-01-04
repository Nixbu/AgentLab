import requests
import json
import sys

# Configuration
OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL = "llama3"

def chat():
    """
    Interactive chat loop with Ollama (Llama 3).
    Maintains conversation history and streams responses.
    """
    history = []
    
    print(f"[-] Connecting to Ollama API: {OLLAMA_URL}")
    print(f"[-] Model: {MODEL}")
    print("[-] Type '/bye' or 'exit' to quit.\n")

    while True:
        # 1. Get User Input
        try:
            user_input = input("You: ").strip()
            if not user_input:
                continue
            if user_input.lower() in ["/bye", "exit", "quit"]:
                print("[-] Goodbye.")
                break
        except (EOFError, KeyboardInterrupt):
            print("\n[-] Exiting...")
            break

        # 2. Add to History
        history.append({"role": "user", "content": user_input})

        # 3. Prepare Payload
        payload = {
            "model": MODEL,
            "messages": history,
            "stream": True
        }

        # 4. Stream Response
        print("Llama3: ", end="", flush=True)
        full_response = ""

        try:
            # Use requests with stream=True to handle the ndjson response
            with requests.post(OLLAMA_URL, json=payload, stream=True) as response:
                response.raise_for_status()
                
                for line in response.iter_lines():
                    if line:
                        # Decode the byte line to string
                        decoded_line = line.decode('utf-8')
                        try:
                            # Parse JSON object
                            json_obj = json.loads(decoded_line)
                            
                            # Extract content chunk
                            if "message" in json_obj and "content" in json_obj["message"]:
                                chunk = json_obj["message"]["content"]
                                print(chunk, end="", flush=True)
                                full_response += chunk
                            
                            # Check for completion
                            if json_obj.get("done", False):
                                pass 
                                
                        except json.JSONDecodeError:
                            continue
                            
            # 5. Update History with full assistant response
            print("\n") # Newline after response
            history.append({"role": "assistant", "content": full_response})

        except Exception as e:
            print(f"\n[!] Error communicating with Ollama: {e}")
            print(f"[!] Ensure the Docker container is running and port 11434 is open.\n")

if __name__ == "__main__":
    # Check if requests is installed, otherwise warn
    try:
        import requests
    except ImportError:
        print("[-] Error: 'requests' library is missing.")
        print("[-] Please install it via: pip install requests")
        sys.exit(1)
        
    chat()
