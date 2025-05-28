from sentence_transformers import SentenceTransformer
from langchain.text_splitter import RecursiveCharacterTextSplitter
import chromadb
import os

# Load the Markdown file
def load_markdown(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read()

def embed_and_store_markdown(filename):
    # Step 1: Load text
    md_text = load_markdown(filename)

    # Step 2: Split into chunks (Chroma prefers small chunks)
    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    docs = splitter.create_documents([md_text])
    texts = [doc.page_content for doc in docs]

    # Step 3: Generate vector embeddings
    model = SentenceTransformer("all-MiniLM-L6-v2")
    embeddings = model.encode(texts, show_progress_bar=True)

    # Step 4: Show a part of the first embedding
    print("First embedding (partial):", embeddings[0][:10])

    # ✅ New Chroma client
    client = chromadb.PersistentClient(path="./chroma_storage")
    collection = client.get_or_create_collection(name="markdown_vectors")

    # Add to DB
    collection.add(
        documents=texts,
        embeddings=[embedding.tolist() for embedding in embeddings],
        ids=[f"chunk_{i}" for i in range(len(texts))]
    )

    print("✅ Embeddings stored successfully in Chroma.")

def get_all_markdown_files(directory):
    return [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.md')]

for md_file in get_all_markdown_files("./scraped"):
    print(f"Processing file: {md_file}")
    embed_and_store_markdown(md_file)
    print(f"✅ Finished processing {md_file}\n")