import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { actor,gameCanister } from "./gameActor";
import { adminActor } from "./actor";

test("WhoAmi should return value", async () => {
  //console.log(actor);
  const result1 = await actor.whoAmI();
  //console.log(result1);
  expect(result1).not.toBe(null);
});

test("WhoAmi2 should return value", async () => {
  //console.log(actor);
  const result1 = await actor.whoAmI2();
  //console.log(result1.toText());
  expect(result1).not.toBe(null);
});

test("should ba able to setup game", async () => {
  //console.log(actor);
  const result1 = await actor.setup();
  console.log(result1.toText());
  expect(result1).not.toBe(null);
});



test("Should be able to click", async () => {
  //Get the principal of the clicker-game and add it to the admins
  //let clickGamePrincipal = Actor.canisterIdOf(actor);
  //console.log(clickGamePrincipal.toText());
  //const result2 = await adminActor.addAdmin(clickGamePrincipal);
  //console.log(result2);
  // const result2 = await adminActor.createAchievement("Clicker Game", "Test Achievement", "Test Achievement Description", 5, false, false);
  // console.log(result2);


  const result1 = await actor.click("Player1");
  console.log(result1);

  expect(result1.err).toBe("Clicker Game");
});