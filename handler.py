import os
from openCHA import openCHA

def handler(event):
    try:
        # Extract API keys from event payload if provided
        api_keys = event.get('input', {}).get('api_keys', {})
        
        # Set environment variables for API keys
        if 'openai_key' in api_keys:
            os.environ['OPENAI_API_KEY'] = api_keys['openai_key']
        if 'serpapi_key' in api_keys:
            os.environ['SERPAPI_API_KEY'] = api_keys['serpapi_key']
        
        # Initialize CHA
        cha = openCHA()
        
        # Configure the interface
        interface = cha.run_with_interface()
        
        return {
            "status": "success",
            "url": f"http://0.0.0.0:7860"
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }
