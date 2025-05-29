#!/bin/sh
ollama serve &
sleep 5
ollama run llama3
tail -f /dev/null
