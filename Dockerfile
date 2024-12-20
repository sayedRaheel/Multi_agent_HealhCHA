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

# Start command for RunPod
CMD ["python", "handler.py"]
