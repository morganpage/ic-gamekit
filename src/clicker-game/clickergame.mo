import ICGameKitCanister "canister:ic-gamekit-backend";
import Types "../ic-gamekit-backend/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";

actor class ClickerGame() {
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type PlayerAchievement = Types.PlayerAchievement;
  type Achievement = Types.Achievement;
  type KeyValue = Types.KeyValue;


  let gameName : Text = "Clicker Game";
  let gameDescription : Text = "A simple clicker game";
  var isSetup : Bool = false;

  public query ({ caller }) func playerPrincipal() : async Principal {
		return caller;
	};

  public shared ({ caller = _ }) func gameCanisterPrincipal() : async Principal {
    return await ICGameKitCanister.whoAmIFunc();
  };

  //Called once to set up all the achievements
  private func setup() : async () {
    let _gameSetup = await ICGameKitCanister.createGame(gameName, gameDescription);
    let _achievement1 = await ICGameKitCanister.createAchievement(gameName,"1 Click","1 Click", 1, false, false);
    let _achievement2 = await ICGameKitCanister.createAchievement(gameName,"10 Clicks","10 Clicks", 10, false, false);
    let _achievement3 = await ICGameKitCanister.createAchievement(gameName,"100 Clicks","100 Clicks", 100, false, false);
    let _achievement4 = await ICGameKitCanister.createAchievement(gameName,"1000 Clicks","1000 Clicks", 1000, false, false);
    let _achievement5 = await ICGameKitCanister.createAchievement(gameName,"Click Counter","Click Counter", 1000000, true, false);
  };

  public shared ({ caller }) func click() : async Result<PlayerAchievement,Text> {
    let playerId = Principal.toText(caller);
    //isSetup := false;
    if(isSetup == false){
      await setup();
      isSetup := true;
    };
    let result = await ICGameKitCanister.incrementPlayerAchievement("Click Counter", playerId,1);
    switch (result) {
      case (#ok(playerAchievement)) {
        let counter : Nat = playerAchievement.progress;
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

}