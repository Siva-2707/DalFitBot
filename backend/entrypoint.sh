#!/bin/sh
ollama serve &
sleep 5
ollama run tinyllama
tail -f /dev/null
