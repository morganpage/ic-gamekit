import { html, render } from 'lit-html';
import { clicker_game, canisterId, createActor } from 'declarations/clicker-game';
import logo from './logo2.svg';
import { AuthClient } from "@dfinity/auth-client";
import { DelegationIdentity, Ed25519PublicKey, ECDSAKeyIdentity, DelegationChain } from "@dfinity/identity";
import { HttpAgent } from "@dfinity/agent";
import { fromHexString } from '@dfinity/candid';

class App {
  playerPrinciple = '';
  actor = clicker_game;
  middleKeyIdentity = null;
  middleIdentity = null;
  appPublicKey = null;
  opener = null;
  websocket = null;

  constructor() {
    this.websocket = new WebSocket('ws://127.0.0.1:3333');
    this.websocket.addEventListener('open', () => {
      console.log('WebSocket connection established.');
    });

    BigInt.prototype.toJSON = function () {
      return Number(this);
    };
    this.referrer = document.referrer;
    let url = window.location.href;
    let publicKeyIndex = url.indexOf("sessionkey=");
    if (publicKeyIndex !== -1) {
      // Parse the public key.
      let publicKeyString = url.substring(publicKeyIndex + "sessionkey=".length);
      this.appPublicKey = Ed25519PublicKey.fromDer(fromHexString(publicKeyString));
      console.log(publicKeyString, this.appPublicKey);
    }
    this.#render();
  }

  #login = async (e) => {
    this.middleKeyIdentity = await ECDSAKeyIdentity.generate();
    let authClient = await AuthClient.create({
      identity: this.middleKeyIdentity,
    });
    await new Promise((resolve) => {
      authClient.login({
        identityProvider: process.env.DFX_NETWORK === "ic" ? "https://identity.ic0.app/#authorize" : `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`,
        onSuccess: resolve,
      });
    });
    this.middleIdentity = authClient.getIdentity();
    this.playerPrinciple = this.middleIdentity.getPrincipal().toText();
    const agent = HttpAgent.create({ identity: this.middleIdentity });
    this.actor = createActor(canisterId, { agentOptions: { identity: this.middleIdentity } });

    if (this.appPublicKey != null && this.middleIdentity instanceof DelegationIdentity) {
      let delegationChain = await DelegationChain.create(
        this.middleKeyIdentity,
        this.appPublicKey,
        new Date(Date.now() + 15 * 60 * 1000),
        { previous: this.middleIdentity.getDelegation() },
      );
      var delegationString = JSON.stringify(delegationChain.toJSON());
      try {
        window.parent.postMessage(delegationString, document.referrer);
      } catch (error) {
        console.log(error);
      }
      if (this.websocket != null) {
        this.websocket.send(delegationString);
      }
    } else {
      console.log("No public key or no delegation identity");
    }
    this.#render();
  };

  #click = async (e) => {
    let data = await this.actor.click();
    this.output = JSON.stringify(data);
    this.#render();
  };

  #render() {
    let body = html`
      <main>
        <section id="playerPrinciple">${this.playerPrinciple}</section>
        <div class="container">
          <button @click=${this.#login}>LOGIN to the Clicker Game</button>
          ${this.appPublicKey == null ? html`<button @click=${this.#click}>Test Clicker</button>` : html``}
        </div>
        <section id="output">${this.output}</section>
      </main>
    `;
    render(body, document.getElementById('root'));
  }
}

export default App;
