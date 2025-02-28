# Dockerfile for Flask Kubernetes Application
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/app.py .

# Expose the port Flask runs on
EXPOSE 5000

# Start the application
CMD ["python", "app.py"]