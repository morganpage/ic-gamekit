import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { actor,gameCanister } from "./gameActor";
import { adminActor } from "./actor";


test("Should be able to click", async () => {
  //Get the principal of the clicker-game and add it to the admins
  //let clickGamePrincipal = Actor.canisterIdOf(actor);
  //console.log(clickGamePrincipal.toText());
  //const result2 = await adminActor.addAdmin(clickGamePrincipal);
  //console.log(result2);
  // const result2 = await adminActor.createAchievement("Clicker Game", "Test Achievement", "Test Achievement Description", 5, false, false);
  // console.log(result2);


  const result1 = await actor.click();
  console.log(result1);

  expect(result1.ok).not.toBe(null);
});