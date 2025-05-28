from sentence_transformers import SentenceTransformer
import chromadb
import requests


# Step 1: Load the model and database
model = SentenceTransformer("all-MiniLM-L6-v2")
client = chromadb.PersistentClient(path="./chroma_storage")
collection = client.get_or_create_collection(name="markdown_vectors")

# Step 2: Take user query input
query = input("Enter your question: ")

# Step 3: Embed the query
query_embedding = model.encode([query])[0]

# Step 4: Query Chroma for similar documents
results = collection.query(
    query_embeddings=[query_embedding.tolist()],
    n_results=8,  # Number of chunks to retrieve
    include=["documents", "distances"]
)

# Step 5: Display the matching context
contexts = results["documents"][0]
print("\nTop matching contexts:\n")
for i, ctx in enumerate(contexts):
    print(f"--- Context {i+1} ---\n{ctx}\n")

# Optional: Concatenate the contexts as input to LLM
context_string = "\n---\n".join(contexts)

# Step 6: Ready to pass `context_string` to an LLM prompt
print("✅ Context ready to pass to LLM.")

def ask_ollama(context, query):
    prompt = f"Context:\n{context}\n\nQuestion: {query}\nAnswer:"

    response = requests.post(
        "http://localhost:11434/api/chat",
        json={
            "model": "llama3",  # or your ollama model name
            "messages": [{"role": "user", "content": prompt}],
            "stream": False  # Set to True if you want to stream
        }
    )

    # If stream=False, the output is valid JSON
    try:
        return response.json()["message"]["content"]
    except requests.exceptions.JSONDecodeError as e:
        print("Failed to decode JSON:", e)
        print("Raw response content:", response.text)
        return "Sorry, I couldn't parse the response."

answer = ask_ollama(context_string, query)
print("🔍 LLM Answer:\n", answer)


