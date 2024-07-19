import { expect, test } from "vitest";
import { Actor } from "@dfinity/agent";
import { actor,gameCanister } from "./gameActor";
import { adminActor } from "./actor";

const timeout = 9000;

test("Game canister should be an admin", async () => {
  const result1 = await actor.isGameCanisterAdmin();
  expect(result1).toBe(true);
}, timeout);

test("Should be able to click", async () => {
  const result1 = await actor.click();
  expect(result1.ok).not.toBe(null);
}, timeout);

test("Should be able to get number of clicks", async () => {
  const result1 = await actor.getClicks();
  expect(result1.ok).not.toBe(null);
}, timeout);

test("Initial number of clicks should be 0", async () => {
  await adminActor.deleteAllPlayerAchievements();
  const result1 = await actor.getClicks();
  expect(result1).toBe(0n);
}, timeout);

test("Click once, click count should be 1", async () => {
  const result1 = await actor.click();
  expect(result1.ok.progress).toBe(1n);
}, timeout);

test("Expect an achievement for the 1st click", async () => {
  const result1 = await actor.getPlayerAchievements();
  console.log(result1);
  expect(result1.ok.length).toBe(1);
}, timeout);

test("Click twice, click count should be 2", async () => {
  const result1 = await actor.click();
  expect(result1.ok.progress).toBe(2n);
}, timeout);

