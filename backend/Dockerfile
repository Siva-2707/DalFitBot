# Use a slim Python base image
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Install required system tools
RUN apt-get update 

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .


# Make the startup script executable
RUN chmod +x startup.sh

# Expose the port FastAPI will run on
EXPOSE 8080

# Run the startup script and then launch the FastAPI app
CMD ["sh", "-c", "./startup.sh && app/uvicorn main:app --host 0.0.0.0 --port 8080"]
