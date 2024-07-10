import { Actor, HttpAgent } from "@dfinity/agent";
import fetch from "isomorphic-fetch";
import canisterIds from ".dfx/local/canister_ids.json";
import { idlFactory } from "../declarations/clicker-game/clicker-game.did.js";
import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1";
import { canisterId, createActor } from "../declarations/clicker-game/index.js";


const HOST = "http://127.0.0.1:4943";
export const gameCanister = canisterId ?? canisterIds["clicker-game"].local;

export const actor = await createActor(gameCanister, {
  agentOptions: { host: HOST, fetch },
});


