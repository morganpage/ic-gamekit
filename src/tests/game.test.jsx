import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { actor,gameCanister } from "./gameActor";
import { adminActor } from "./actor";

test("Should be able to click", async () => {
  const result1 = await actor.click();
  console.log(result1);
  expect(result1.ok).not.toBe(null);
});