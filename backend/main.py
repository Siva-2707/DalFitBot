from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the Dalhousie Athletics API!"}

@app.post("/chat")
def ask_question(query: str):
    from chatbot import ask_ollama
    response = ask_ollama(query)
    return {"answer": response}

