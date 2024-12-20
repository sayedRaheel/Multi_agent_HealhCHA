# Use Python 3.11 slim image to reduce size
FROM python:3.11-slim

# Set environment variables
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV GRADIO_SERVER_PORT=7860

# Set up a new user
RUN useradd -m -u 1000 user

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Switch to the user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set up the application directory
WORKDIR $HOME/app

# Copy the application files
COPY --chown=user . $HOME/app

# Install Python dependencies
RUN pip install --no-cache-dir -e '.[all]' && \
    playwright install

# Expose the Gradio port
EXPOSE 7860

# Create a handler script for RunPod
COPY --chown=user <<EOF handler.py
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

EOF

# Start command for RunPod
CMD ["python", "handler.py"]
