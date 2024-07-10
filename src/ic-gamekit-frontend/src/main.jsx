import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.scss';
import { InternetIdentityProvider } from "ic-use-internet-identity";
import Actors from "./ic/Actors.tsx";
import ClickerGameActor from "./ic/ClickerGameActor.tsx";


ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <InternetIdentityProvider>
    <Actors>
      <ClickerGameActor>
      <App />
      </ClickerGameActor>
    </Actors>
    </InternetIdentityProvider>
  </React.StrictMode>,
);
