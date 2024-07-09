import ICGameKitCanister "canister:ic-gamekit-backend";
import Types "../ic-gamekit-backend/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Array "mo:base/Array";

actor class ClickerGame() {
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type PlayerAchievement = Types.PlayerAchievement;
  type Achievement = Types.Achievement;

  let gameName : Text = "Clicker Game";
  let gameDescription : Text = "A simple clicker game";
  var isSetup : Bool = false;

  public query ({ caller }) func whoAmI() : async Principal {
		return caller;
	};

  // Call ICGameKitCanister whoAmI
  public shared ({ caller = _ }) func whoAmI2() : async Principal {
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

  public shared ({ caller }) func click2(playerId : Text) : async Result<PlayerAchievement,Text> {
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


  // public shared ({ caller }) func click(playerId : Text) : async Result<PlayerAchievement,Text> {
  //   // Figure out if there are any existing player achievements for this player
  //   //let achievements = await ICGameKitCanister.getAchievements({caller = caller});
  //   //Check if the caller is an admin
  //   let isAdmin = await ICGameKitCanister.isAdmin();
  //   if (isAdmin == false) {
  //     return #err("You are not an admin! - " # Principal.toText(caller));
  //   };
  //   //We are an admin, so we can click
  //   //First try and find any existing player achievements for this player
  //   //let playerAchievementsResult = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,false);
  //   // if(playerAchievementsResult == null){
  //   //   //No player achievements found, so we need to create one, but which one?
  //   // };
  //   if(isSetup == false){
  //     await setup();
  //     isSetup := true;
  //   };
  //   let currentAchievement = await findCurrentAchievement(playerId);
  //   switch (currentAchievement) {
  //     case null {
  //       //No achievements found so we need to create one
  //       let result = await ICGameKitCanister.incrementPlayerAchievement("1 Click", playerId);
  //       return result;
  //     };
  //     case(?v) {
  //       //We have an achievement, so we need to increment it
  //       let _result = await ICGameKitCanister.incrementPlayerAchievement(v, playerId);
  //       return #err(v);
  //     };
  //   };


  //   return #err("Clicker Game");
  // };

  private func findCurrentAchievement(playerId : Text) : async ?Text {
    let playerAchievementsUnearned = await ICGameKitCanister.listMyPlayerAchievements2(playerId,gameName,false);
    if(playerAchievementsUnearned.size() == 0){
      //No unearned achievements found, so find the highest earned achievement
      let playerAchievementsEarned = await ICGameKitCanister.listMyPlayerAchievements2(playerId,gameName,true);
      if(playerAchievementsEarned.size() == 0){
        //No achievements found at all, so must be first click
        return null;
      } else {
        //We have an earned achievement, so return the highest one
        let highestEarned = findHighestEarned(playerAchievementsEarned);
        //Filter out any achievements that are
        return ?Nat.toText(highestEarned);
      };
    } else {
      //We have an unearned achievement, so return it, should only be one at a time
      return ?playerAchievementsUnearned[0].achievementName;
    }
  };


  private func findHighestEarned(playerAchievements : [PlayerAchievement]) : Nat {
    func order (a: PlayerAchievement, b: PlayerAchievement) : Order.Order {
            return Nat.compare(b.progress, a.progress);
    };
    let sorted = Array.sort(playerAchievements, order);
    return sorted[0].progress;
  };

  // private func findHighestEarned(playerId : Text) : async Nat {
  //   let playerAchievementsEarned = await ICGameKitCanister.listMyPlayerAchievements2(playerId,gameName,true);
  //   if(playerAchievementsEarned.size() == 0){
  //     return 0;
  //   } else {
  //     return playerAchievementsEarned[0].progress;
  //   }
  // };


  //Find earned achievement with the highest progress
  // private func findHighestAchievement(playerId : Text) : async ?Text {
  //   //let playerAchievementsResult = await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,true);

  //   switch (await ICGameKitCanister.listMyPlayerAchievements(playerId,gameName,true)) {
  //     case (#Ok(playerAchievements)) {
  //       var highestAchievement = null;
  //       for (playerAchievement in playerAchievements) {
  //         switch(highestAchievement) {
  //           case null {
  //             highestAchievement := playerAchievement;
  //           };
  //           case(?v) {
  //             switch(v.progress > playerAchievement.progress) {
  //               case true {
  //                 highestAchievement := playerAchievement;
  //               };
  //               case false {};
  //             };
  //           };
  //         };
  //       };
  //       switch(highestAchievement) {
  //         case null {
  //           return null;
  //         };
  //         case(?v) {
  //           return v.achievementName;
  //         };
  //       };
  //     };
  //     case (#Err(_)) {
  //       return null;
  //     };

  //     //   case (#Ok(playerAchievements)) {
  //     //     // if(playerAchievements == null or playerAchievements == []){
  //     //     //   return null;
  //     //     // };
  //     //     // var highestAchievement = null;
  //     //     // for (playerAchievement in playerAchievements) {
  //     //     //   if(highestAchievement == null){
  //     //     //     highestAchievement := playerAchievement;
  //     //     //   } else {
  //     //     //     if(playerAchievement.progress > highestAchievement.progress){
  //     //     //       highestAchievement := playerAchievement;
  //     //     //     };
  //     //     //   };
  //     //     // };
  //     //     // return highestAchievement.achievementName;
  //     //     return null;
  //     //   };

  //     // case (#Err(err)) { return null; };
  //   };



  //   //let playerAchievements = playerAchievementsResult.ok;


  //   // if(playerAchievements == null or playerAchievements == []){
  //   //   return null;
  //   // };
  //   // var highestAchievement = null;
  //   // for (playerAchievement in playerAchievements) {
  //   //   if(highestAchievement == null){
  //   //     highestAchievement := playerAchievement;
  //   //   } else {
  //   //     if(playerAchievement.progress > highestAchievement.progress){
  //   //       highestAchievement := playerAchievement;
  //   //     }
  //   //   };
  //   // };
  //   // return highestAchievement.achievementName;
  //   return null;
  // }


}