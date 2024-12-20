FROM python:3.11-slim

# Set environment variables
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV GRADIO_SERVER_PORT=7860
ENV GRADIO_ALLOW_ORIGINS="*"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install RunPod SDK
RUN pip install --no-cache-dir runpod

# Set up a new user
RUN useradd -m -u 1000 user

# Switch to the user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set working directory
WORKDIR $HOME/app

# Copy your application files
COPY --chown=user . $HOME/app

# Install Python dependencies
RUN pip install --no-cache-dir -e '.[all]' && \
    playwright install

# Expose Gradio port
EXPOSE 7860

# Start both UI and handler
CMD ["python", "handler.py"]
