import { expect, test } from "vitest";
import { Actor, CanisterStatus, HttpAgent } from "@dfinity/agent";
import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1";
import { canisterId, createActor } from "../declarations/ic-gamekit-backend/index.js";

const HOST = "http://127.0.0.1:4943";
// Completely insecure seed phrase. Do not use for any purpose other than testing.
// Resolves to "rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae"
const seed = "test test test test test test test test test test test test";

const adminAgent = new HttpAgent({
  identity: Secp256k1KeyIdentity.fromSeedPhrase(seed) as any,
  host: HOST,
  fetch,
});

test("should handle a basic greeting", async () => {
  const agent = new HttpAgent({ fetch, host: HOST });
  const adminActor = await createActor(canisterId, {
    agent,
  });
  //const agent = Actor.agentOf(adminActor) as HttpAgent;
  let principal = await agent.getPrincipal();
  console.log(principal.toText());
  // const result1 = await adminActor.greet("testing");
  // console.log(result1);
  // const result2 = await adminActor.showCaller();
  // console.log(result2);
  // expect(result1).toBe("Hello, testing!");
});
