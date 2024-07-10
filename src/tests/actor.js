import { Actor, HttpAgent } from "@dfinity/agent";
import fetch from "isomorphic-fetch";
import canisterIds from ".dfx/local/canister_ids.json";
import { idlFactory } from "../declarations/ic-gamekit-backend/ic-gamekit-backend.did.js";
import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1";
import { canisterId, createActor } from "../declarations/ic-gamekit-backend/index.js";

const HOST = "http://127.0.0.1:4943";


export const backendCanister = canisterId ?? canisterIds["ic-gamekit-backend"].local;
// Completely insecure seed phrase. Do not use for any purpose other than testing.
// Resolves to "rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae"
const seed = "test test test test test test test test test test test test";

const adminAgent = new HttpAgent({
  identity: Secp256k1KeyIdentity.fromSeedPhrase(seed),
  host: HOST,
  fetch,
});

export const adminActor = await createActor(backendCanister, {
  agent: adminAgent,
  agentOptions: { host: HOST, fetch },
});
