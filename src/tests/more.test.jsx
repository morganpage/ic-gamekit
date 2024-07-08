import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { adminActor } from "./actor";

test("adminActor should have correct principal", async () => {
  const agent = Actor.agentOf(adminActor);
  let principal = await agent.getPrincipal();
  expect(principal.toText()).toBe("rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae");
});

test("adminActor should be listed in admins", async () => {
  const result1 = await adminActor.listAdmins();
  let adminPrinciples = result1.map(adminPrinciple => adminPrinciple.toText());
  expect(adminPrinciples).toContain("rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae");
});

test("adminActor should be an admin", async () => {
  const result1 = await adminActor.isAdmin();
  expect(result1).toBe(true);
});

test("should be able to add a game if an admin", async () => {
  const result1 = await adminActor.createGame("Test Game", "Test Game Description");
  expect(result1.ok.name).toBe("Test Game");
});

test("should be able to add an achievement if creator", async () => {
  const result1 = await adminActor.createAchievement("Test Game", "Test Achievement", "Test Achievement Description", 1, false, false);
  console.log(result1);
  expect(result1.ok.name).toBe("Test Achievement");
});

test("should be able to list achievements", async () => {
  const result1 = await adminActor.listAchievements("Test Game");
  console.log(result1);
  expect(result1.ok.length).toBe(1);
});

test("should be able to list achievements with details", async () => {
  const result1 = await adminActor.listAchievementsWithDetails("Test Game");
  console.log(result1);
  expect(result1.ok.length).toBe(1);
});

test("should be able to increment a player achievement", async () => {
  const result1 = await adminActor.incrementPlayerAchievement("Test Achievement", "Player1");
  console.log(result1);
  expect(result1.ok.progress).toBe(1);
});

