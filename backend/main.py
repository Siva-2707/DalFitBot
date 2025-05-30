from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class QueryRequest(BaseModel):
    query: str

@app.get("/")
def read_root():
    return {"message": "Welcome to the Dalhousie Athletics API!"}

@app.post("/chat")
def ask_question(request: QueryRequest):
    from chatbot import ask_ollama
    response = ask_ollama(request.query)
    return {"answer": response}

