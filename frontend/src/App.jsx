import React from "react";
import { Authenticator } from "@aws-amplify/ui-react";
import "@aws-amplify/ui-react/styles.css";
import Chatbot from "./Chatbot";

function App() {
  return (
    <Authenticator
      formFields={{
        signUp: {
        email: {
          label: "Email",
          placeholder: "you@example.com",
          isRequired: true,
        },
        password: {
          label: "Password",
          isRequired: true,
        },
      },
      }}
    >
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
    // <Chatbot user={"siva"} />
  );
}

export default App;