import ICGameKitCanister "canister:ic-gamekit-backend";
import Types "../ic-gamekit-backend/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor class ClickerGame() {
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type Game = Types.Game;
  type PlayerAchievement = Types.PlayerAchievement;

  private stable var gameName : Text = "Clicker Game";
  private stable var gameDescription : Text = "A simple clicker game";

  public query ({ caller }) func whoAmI() : async Principal {
		return caller;
	};

  // Call ICGameKitCanister whoAmI
  public shared ({ caller }) func whoAmI2() : async Principal {
    return await ICGameKitCanister.whoAmIFunc();
  };

  //Called once to set up all the achievements
  public shared ({ caller }) func setup() {
    let gameSetup = await ICGameKitCanister.createGame(gameName, gameDescription);
    let achievement1 = await ICGameKitCanister.createAchievement(gameName,"Test1","Test 1 dsfs", 5, false, false);
  };


  public shared ({ caller }) func click(playerId : Text) : async Result<PlayerAchievement,Text> {
    // Figure out if there are any existing player achievements for this player
    //let achievements = await ICGameKitCanister.getAchievements({caller = caller});
    //Check if the caller is an admin
    let isAdmin = await ICGameKitCanister.isAdmin();
    if (isAdmin == false) {
      return #err("You are not an admin! - " # Principal.toText(caller));
    };
    //We are an admin, so we can click
    //First try and find any existing player achievements for this player
    //let playerAchievementsResult = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,false);
    // if(playerAchievementsResult == null){
    //   //No player achievements found, so we need to create one, but which one?
    // };



    let highestAchievement = await findHighest(playerId);
    switch (highestAchievement) {
      case null {
        //No achievements found so we need to create one
        let result = await ICGameKitCanister.incrementPlayerAchievement("Test1", playerId);
        return result;
      };
      case(?v) {
        return #err(v);
      };
    };


    return #err("Clicker Game");
  };

  private func findHighest(playerId : Text) : async ?Text {
    let playerAchievements = await ICGameKitCanister.listMyPlayerAchievements2(playerId,gameName,true);
    if(playerAchievements.size() == 0){
      return null;
    } else {
      return ?playerAchievements[0].achievementName;
    }
  };



  //Find earned achievement with the highest progress
  private func findHighestAchievement(playerId : Text) : async ?Text {
    //let playerAchievementsResult = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,true);

    switch (await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,true)) {
      case (#Ok(playerAchievements)) {
        var highestAchievement = null;
        for (playerAchievement in playerAchievements) {
          switch(highestAchievement) {
            case null {
              highestAchievement := playerAchievement;
            };
            case(?v) {
              switch(v.progress > playerAchievement.progress) {
                case true {
                  highestAchievement := playerAchievement;
                };
                case false {};
              };
            };
          };
        };
        switch(highestAchievement) {
          case null {
            return null;
          };
          case(?v) {
            return v.achievementName;
          };
        };
      };
      case (#Err(_)) {
        return null;
      };

      //   case (#Ok(playerAchievements)) {
      //     // if(playerAchievements == null or playerAchievements == []){
      //     //   return null;
      //     // };
      //     // var highestAchievement = null;
      //     // for (playerAchievement in playerAchievements) {
      //     //   if(highestAchievement == null){
      //     //     highestAchievement := playerAchievement;
      //     //   } else {
      //     //     if(playerAchievement.progress > highestAchievement.progress){
      //     //       highestAchievement := playerAchievement;
      //     //     };
      //     //   };
      //     // };
      //     // return highestAchievement.achievementName;
      //     return null;
      //   };

      // case (#Err(err)) { return null; };
    };



    //let playerAchievements = playerAchievementsResult.ok;


    // if(playerAchievements == null or playerAchievements == []){
    //   return null;
    // };
    // var highestAchievement = null;
    // for (playerAchievement in playerAchievements) {
    //   if(highestAchievement == null){
    //     highestAchievement := playerAchievement;
    //   } else {
    //     if(playerAchievement.progress > highestAchievement.progress){
    //       highestAchievement := playerAchievement;
    //     }
    //   };
    // };
    // return highestAchievement.achievementName;
    return null;
  }


}