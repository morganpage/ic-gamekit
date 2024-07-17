import ICGameKitCanister "canister:ic-gamekit-backend";
import Types "../ic-gamekit-backend/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Random "mo:base/Random";

actor class ClickerGame() {
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type PlayerAchievement = Types.PlayerAchievement;
  type PlayerGameSave = Types.PlayerGameSave;
  type Achievement = Types.Achievement;
  type KeyValue = Types.KeyValue;


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
    //isSetup := false;
    if(isSetup == false){
      await setup();
      isSetup := true;
    };
    //Possible chance to get a reward
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

  public func checkForReward() : async Nat8 {
    //Check if player has earned a reward
    let random = Random.Finite(await Random.blob());
    switch (random.byte()) {
      case (?b){
        if(b < 128){
          return 1;
        };
        return 0;
      };
      case (_)
        return 0;
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

  public shared ({ caller }) func getGameRewards() : async Text {
    let playerId = Principal.toText(caller);
    return await ICGameKitCanister.getGameSaveData( gameSaveName,gameName, playerId);
  };

}