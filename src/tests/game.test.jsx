import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { actor } from "./gameActor";

test("WhoAmi should return value", async () => {
  console.log(actor);
  const result1 = await actor.whoAmI();
  console.log(result1);
  expect(result1).not.toBe(null);
});

test("WhoAmi2 should return value", async () => {
  console.log(actor);
  const result1 = await actor.whoAmI2();
  console.log(result1.toText());
  expect(result1).not.toBe(null);
});

