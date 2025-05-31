from sentence_transformers import SentenceTransformer
import chromadb
import requests


# Step 1: Load the model and database
model = SentenceTransformer("all-MiniLM-L6-v2")
client = chromadb.PersistentClient(path="./chroma_storage")
collection = client.get_or_create_collection(name="markdown_vectors")

# Step 3: Embed the query
def get_context(query):
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
    return context_string

def ask_ollama(query):

    context = get_context(query)
    prompt = f"Context:\n{context}\n\nQuestion: {query}\nAnswer:"

    try:
        response = requests.post(
            "http://ollama:11434/api/chat",
            # "http://localhost:11434/api/chat",
            json={
                "model": "tinyllama", 
                "messages": [{"role": "user", "content": prompt}],
                "stream": False
            },
            timeout=20
        )
    except requests.exceptions.RequestException as e:
        print(f"Error connecting to Ollama: {e}")
        return {"error": str(e)}

    # If stream=False, the output is valid JSON
    try:
        print("----------Printing------",response.json())
        return response.json()["message"]["content"]
    except requests.exceptions.JSONDecodeError as e:
        print("Failed to decode JSON:", e)
        print("Raw response content:", response.text)
        return "Sorry, I couldn't parse the response."


