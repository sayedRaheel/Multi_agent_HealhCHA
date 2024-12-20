import runpod
import os
from openCHA import openCHA

# Initialize CHA outside handler to avoid reinitializing
cha = openCHA()

# Create the interface outside handler
interface = cha.run_with_interface()
interface.queue()  # Enable queuing
interface.launch(server_name="0.0.0.0", 
                server_port=7860,
                share=True,
                prevent_thread_lock=True)  # Prevent blocking

def handler(event):
    """Handle API requests while UI is running"""
    try:
        job_input = event["input"]
        
        # Handle API keys if provided
        api_keys = job_input.get('api_keys', {})
        if 'openai_key' in api_keys:
            os.environ['OPENAI_API_KEY'] = api_keys['openai_key']
        if 'serpapi_key' in api_keys:
            os.environ['SERPAPI_API_KEY'] = api_keys['serpapi_key']
        
        # Handle any API-specific logic here
        response = {
            "status": "success",
            "ui_url": "https://u8hee2v5mqigb9-7860.proxy.runpod.net"
        }
        
        return response
    except Exception as e:
        return {"status": "error", "error": str(e)}

# Start the serverless handler
runpod.serverless.start({"handler": handler})
