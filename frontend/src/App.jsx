import React from "react";
import { Authenticator } from "@aws-amplify/ui-react";
import "@aws-amplify/ui-react/styles.css";
import Chatbot from "./Chatbot";

function App() {
  return (
    <Authenticator>
      {({ signOut, user }) => (
        <div style={{ padding: "1rem" }}>
          <header style={{ display: "flex", justifyContent: "space-between" }}>
            <p>Welcome, {user?.username}</p>
            <button onClick={signOut}>Sign Out</button>
          </header>
          <Chatbot user={user} />
        </div>
      )}
    </Authenticator>
  );
}

export default App;