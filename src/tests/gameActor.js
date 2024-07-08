import { Actor, HttpAgent } from "@dfinity/agent";
import fetch from "isomorphic-fetch";
import canisterIds from ".dfx/local/canister_ids.json";
import { idlFactory } from "../declarations/clicker-game/clicker-game.did.js";
import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1";
//import { createActor } from "../declarations/icrc7/index.js";
import { canisterId, createActor } from "../declarations/clicker-game/index.js";


// Imports and re-exports candid interface
//import { idlFactory } from './cert_var.did.js';



const HOST = "http://127.0.0.1:4943";
const gameCanister = canisterId ?? canisterIds["clicker-game"].local;

export const actor = await createActor(gameCanister, {
  agentOptions: { host: HOST, fetch },
});


// export const createActorLocal = async (canisterId, options) => {
//   const agent = new HttpAgent({ ...options?.agentOptions });
//   await agent.fetchRootKey();
//   // Creates an actor with using the candid interface and the HttpAgent
//   return Actor.createActor(idlFactory, {
//     agent,
//     canisterId,
//     ...options?.actorOptions,
//   });
// };

// export const backendActor = await createActorLocal(backendCanister, {
//   agentOptions: { host: HOST, fetch },
// });

// export const backendCanister = canisterId ?? canisterIds["ic-gamekit-backend"].local;
// // Completely insecure seed phrase. Do not use for any purpose other than testing.
// // Resolves to "rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae"
// const seed = "test test test test test test test test test test test test";

// const adminAgent = new HttpAgent({
//   identity: Secp256k1KeyIdentity.fromSeedPhrase(seed),
//   host: HOST,
//   fetch,
// });

// export const adminActor = await createActor(backendCanister, {
//   agent: adminAgent,
//   agentOptions: { host: HOST, fetch },
// });
