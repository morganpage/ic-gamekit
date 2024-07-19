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

////////////////////////
// Achievement Tests //
///////////////////////

test("should be able to add an achievement if an admin", async () => {
  const result1 = await adminActor.createAchievement("Test Game", "Test Achievement", "Test Achievement Description", 1, false, false);
  expect(result1.ok.name).toBe("Test Achievement");
});

test("should be able to list achievements if an admin", async () => {
  const result1 = await adminActor.listAchievements("Test Game");
  expect(result1.ok.length).toBeGreaterThan(0);
});

test("should be able to increment a player achievement if an admin", async () => {
  //First delete any existing player achievements
  const result2 = await adminActor.deleteAllPlayerAchievements();
  const result1 = await adminActor.incrementPlayerAchievement("Test Achievement", "Player1",1);
  expect(result1.ok.progress).toBe(1n);
});

test("should be able to list player achievements if an admin", async () => {
  const result1 = await adminActor.listMyPlayerAchievements("Player1","Test Game",true);
  expect(result1.ok.length).toBe(1);
});

////////////////////////
// Game Save Tests //
///////////////////////
const GAME_NAME = "Some Game Name";
const GAME_SAVE_NAME = "Game Save Name";
const GAME_SAVE_DATA = "Some Json Game Save Data here...";
const PLAYER_ID = "PlayerId 123";

test("should be able to create a game save if an admin", async () => {
  const result1 = await adminActor.createGameSave(GAME_SAVE_NAME, GAME_NAME,PLAYER_ID, GAME_SAVE_DATA);
  expect(result1.ok.gameSaveData).toBe(GAME_SAVE_DATA);
});

test("should be able to get a game save if an admin", async () => {
  const result1 = await adminActor.getGameSaveData(GAME_SAVE_NAME,GAME_NAME,PLAYER_ID);
  expect(result1).toBe(GAME_SAVE_DATA);
});

test("should be able to list game saves if an admin", async () => {
  const result1 = await adminActor.listGameSaves(GAME_NAME,PLAYER_ID);
  expect(result1.length).toBe(1);
});

////////////////////////
// Game Data Tests //
///////////////////////
const GAME_DATA_KEY = "Game Data Test Key";
const GAME_DATA_VALUE = "Game Data Test Value";
test("should be able to update game data if an admin", async () => {
  await adminActor.createGame(GAME_NAME,"Test Game Description");
  const result1 = await adminActor.updateGameData(GAME_NAME,GAME_DATA_KEY,GAME_DATA_VALUE);
  expect(result1.ok.key).toBe(GAME_DATA_KEY) && expect(result1.ok.value).toBe(GAME_DATA_VALUE);
});

test("should be able to list game data if an admin", async () => {
  const result1 = await adminActor.listGameData(GAME_NAME);
  expect(result1.length).toBeGreaterThan(0) && expect(result1[0].key).toBe(GAME_DATA_KEY) && expect(result1[0].value).toBe(GAME_DATA_VALUE);
});

test("should be able to delete game data if an admin", async () => {
  const result1 = await adminActor.deleteGameData(GAME_NAME,GAME_DATA_KEY);
  expect(result1.ok).toBe(null);
});

////////////////////////////
// Player Data Save Tests //
///////////////////////////
const PLAYER_DATA_KEY = "Player Data Test Key";
const PLAYER_DATA_VALUE = "Player Data Test Value";
test("should be able to update player data if an admin", async () => {
  const result1 = await adminActor.updatePlayerData("Player1",PLAYER_DATA_KEY,PLAYER_DATA_VALUE);
  expect(result1.ok.key).toBe(PLAYER_DATA_KEY) && expect(result1.ok.value).toBe(PLAYER_DATA_VALUE);
});
