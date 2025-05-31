import React, { useState } from "react";
import { fetchAuthSession } from '@aws-amplify/auth';

function Chatbot({ user }) {
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);

  const sendMessage = async () => {
    const session = await fetchAuthSession();
    console.log("User session:", session);
    const idToken = session.tokens?.idToken?.toString();
    console.log("ID Token:", idToken);

    if (!idToken) throw new Error("Failed to get ID token");

    setLoading(true);

    const response = await fetch(`${import.meta.env.VITE_CHAT_API_URL}/chat`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${idToken}`,
      },
      body: JSON.stringify({ query : input }),
    });

    const data = await response.json();
    console.log("Response from API:", data);
    
    setMessages([...messages, { user: input, bot: data.answer }]);
    setInput("");
    setLoading(false);
  };

  return (
    <div>
      <div style={{ marginBottom: "1rem" }}>
        {loading && <p>Loading...</p>}
        {messages.map((msg, idx) => (
          <div key={idx}>
            <p><strong>You:</strong> {msg.user}</p>
            <p><strong>Bot:</strong> {msg.bot}</p>
          </div>
        ))}
      </div>
      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
        placeholder="Ask something..."
      />
      <button onClick={sendMessage}>Send</button>
    </div>
  );
}

export default Chatbot;