import ICGameKitCanister "canister:ic-gamekit-backend";
import Types "../ic-gamekit-backend/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";
import {JSON} "mo:serde";

actor class ClickerGame() {
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type PlayerAchievement = Types.PlayerAchievement;
  type PlayerGameSave = Types.PlayerGameSave;
  type Achievement = Types.Achievement;
  type KeyValue = Types.KeyValue;
  type GameSave = {
    rewards : [Text];
  };
  type Pet = {
    name : Text;
    url : Text;
  };
  type GameRewards = {
    pets : [Pet];
  };


  let gameName : Text = "Clicker Game";
  let gameDescription : Text = "A simple clicker game";
  let gameSaveName : Text = "ClickSave"; //Just one default save for each player
  var isSetup : Bool = false;

  public query ({ caller }) func playerPrincipal() : async Principal {
		return caller;
	};

  public shared ({ caller = _ }) func gameCanisterPrincipal() : async Principal {
    return await ICGameKitCanister.whoAmIFunc();
  };

  //Check if the game canister has been set up correctly as an admin
  public shared func isGameCanisterAdmin() : async Bool {
    return await ICGameKitCanister.isAdmin();
  };

  //Called once to set up all the achievements, rewards etc
  private func setup() : async () {
    let _gameSetup = await ICGameKitCanister.createGame(gameName, gameDescription);
    let _achievement1 = await ICGameKitCanister.createAchievement(gameName,"1 Click","1 Click", 1, false, false);
    let _achievement2 = await ICGameKitCanister.createAchievement(gameName,"10 Clicks","10 Clicks", 10, false, false);
    let _achievement3 = await ICGameKitCanister.createAchievement(gameName,"100 Clicks","100 Clicks", 100, false, false);
    let _achievement4 = await ICGameKitCanister.createAchievement(gameName,"1000 Clicks","1000 Clicks", 1000, false, false);
    let _achievement5 = await ICGameKitCanister.createAchievement(gameName,"Click Counter","Click Counter", 1000000, true, false);
    let _rewards = await ICGameKitCanister.updateGameData(gameName, "rewards", "
    { \"pets\" :
    [
      { \"name\": \"Mouse\", \"url\" : \"https://roguefoxguild.mypinata.cloud/ipfs/QmXXba3DLd8y6DyM7rri1aQap5p8LTtcTaz7TLN4wS846B\" },
      { \"name\": \"Cat\", \"url\" : \"https://roguefoxguild.mypinata.cloud/ipfs/QmNPhRKoQPppkQ6GxbiUniyyUkjY9Tht7Vyn1pvQ1DDEiY\" },
      { \"name\": \"Dog\", \"url\" : \"https://roguefoxguild.mypinata.cloud/ipfs/QmecJRNGz44hvvMQLayQH6tDM2BQgYP7dDLGprMbd4o6Kt\" }
    ]
    }
    ");
    
  };

  public shared ({ caller }) func click() : async Result<PlayerAchievement,Text> {
    let playerId = Principal.toText(caller);
    if(isSetup == false){
      await setup();
      isSetup := await isGameCanisterAdmin();//Setup will fail otherwise
    };
    //Possible chance to get a reward
    let result = await ICGameKitCanister.incrementPlayerAchievement("Click Counter", playerId,1);
    switch (result) {
      case (#ok(playerAchievement)) {
        let counter : Nat = playerAchievement.progress;
        //Check if player has earned a reward
        let reward = await checkForReward();
        if(reward != ""){
          let _ = await addReward(playerId,reward);
        };
        if(counter == 1){
          return await ICGameKitCanister.incrementPlayerAchievement("1 Click", playerId,1);
        };
        if(counter == 10){
          return await ICGameKitCanister.incrementPlayerAchievement("10 Clicks", playerId,10);
        };
        if(counter == 100){
          return await ICGameKitCanister.incrementPlayerAchievement("100 Clicks", playerId,100);
        };
        if(counter == 1000){
          return await ICGameKitCanister.incrementPlayerAchievement("1000 Clicks", playerId,1000);
        };
        return result;
      };
      case (#err(_)) {
        return result;
      };
    };
  };

  public func checkForReward() : async Text {
    //Check if player has earned a reward
    let random = Random.Finite(await Random.blob());
    switch (random.byte()) {
      case (?b){
        if(b < 10){//b's range is 0-255 so if 10 or less then give a reward, roughly 4% chance of reward
          // Get all existing rewards
          let bNat : Nat = Nat8.toNat(b);
          return await getRandomReward(bNat);
        };
        return "";
      };
      case (_)
        return "";
    };
  };

  private func getRandomReward(randomNumber : Nat) : async Text {
    let jsonText = await getAvailableGameRewards();
    let result = JSON.fromText(jsonText, null);
    switch (result) {
      case (#ok(blob)) {
        let gameRewards : ?GameRewards = from_candid(blob);
        switch (gameRewards) {
          case (?gameRewards) {
            let numberOfPets = gameRewards.pets.size();
            //Choose a random reward
            let index = randomNumber % numberOfPets;
            let randomPet = gameRewards.pets.get(index);
            return randomPet.name;
          };
          case (_) {
            return "";
          };
        };
      };
      case (#err(_)) {
        return "";
      };
    };
  };


  // Get Current number of clicks - held in Click Counter achievement
  public shared ({ caller }) func getClicks() : async Nat {
    let playerId = Principal.toText(caller);
    let playerAchievements = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,false);
    switch (playerAchievements) {
      case (#ok(playerAchievements)) {
        for (playerAchievement in playerAchievements.vals()) {
          if(playerAchievement.achievementName == "Click Counter"){
            return playerAchievement.progress;
          };
        };
        return 0;
      };
      case (#err(_)) {
        return 0;
      };
    };
  };

  public shared ({ caller }) func getPlayerAchievements() : async Result<[PlayerAchievement],Text> {
    let playerId = Principal.toText(caller);
    let playerAchievements = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,true);
    return playerAchievements;
  };

  public func getAvailableGameRewards() : async Text {
    let gameData : [KeyValue] = await ICGameKitCanister.listGameData(gameName);
    let rewards = Array.find<KeyValue>(gameData, func (kv) = kv.key == "rewards");
    return switch (rewards) {
      case (?v) {
        return v.value;
      };
      case (_) {
        return "";
      }
    };
  };

  //// Player Profile Functions
  public shared ({ caller }) func updateProfileName(profileName : Text) :  async Result<KeyValue,Text> {
    let playerId = Principal.toText(caller);
    return await ICGameKitCanister.updatePlayerData(playerId,"profileName",profileName);
  };

  public shared ({ caller }) func getProfileName() : async Result<KeyValue,Text> {
    let playerId = Principal.toText(caller);
    return await ICGameKitCanister.getPlayerData(playerId,"profileName");
  };
  //////

  public shared ({ caller }) func getGameRewards() : async Text {
    let playerId = Principal.toText(caller);
    return await ICGameKitCanister.getGameSaveData( gameSaveName,gameName, playerId);
  };

  private func addReward(playerId : Text,reward : Text) : async Bool {
    let gameSaveData = await ICGameKitCanister.getGameSaveData( gameSaveName,gameName, playerId);
    switch (JSON.fromText(gameSaveData, null)) {
      case (#ok(blob)) {
        let gameSave : ?GameSave = from_candid(blob);
        switch (gameSave) {
          case (?gameSave) {
            //Add the new reward
            return await createGameSaveFromRewards(playerId,Array.append(gameSave.rewards,[reward]));
          };
          case (_) {
            return false;
          };
      };
      };
      case (#err(_)) {
        //No existing game data so add the first reward
        return await createGameSaveFromRewards(playerId,[reward]);
      };
    };
  };

  private func createGameSaveFromRewards(playerId : Text,rewards : [Text]) : async Bool {
    let newGameSave : GameSave = { rewards = rewards };
    let blob = to_candid(newGameSave);
    let json_result = JSON.toText(blob,["rewards"],null);
    return switch (json_result) {
      case (#ok(json_result)) {
        let _ = await ICGameKitCanister.createGameSave(gameSaveName, gameName, playerId, json_result);
        return true;
      };
      case (#err(_)) {
        return false;
      };
    };
  };
}