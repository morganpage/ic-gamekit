import ICGameKitCanister "canister:ic-gamekit-backend";

actor class ClickerGame() {

  public query ({ caller }) func whoAmI() : async Principal {
		return caller;
	};

  // Call ICGameKitCanister whoAmI
  public shared ({ caller }) func whoAmI2() : async Principal {
    return await ICGameKitCanister.whoAmIFunc();
  };


  public shared ({ caller }) func click() : async Text {
    // Figure out if there are any existing player achievements for this player
    //let achievements = await ICGameKitCanister.getAchievements({caller = caller});

    return "Clicker Game";
  };

}