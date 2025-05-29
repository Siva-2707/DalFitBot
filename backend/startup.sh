#!/bin/bash

# Run Embed and store script
echo "Running embed and store script..."
# Check if the scraped directory exists and is not empty. If it is empty, run the scraper script.
if [ ! -d "./scraped" ] || [ -z "$(ls -A ./scraped)" ]; then
    echo "Scraped directory is empty or does not exist, running scraper..."
    python3 ./data_ingestion/scraper.py
else
    echo "Scraped directory already has data."
fi
# Run the embed and store script
python3 ./data_ingestion/embed_and_store.py


