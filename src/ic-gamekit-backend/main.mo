import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Types "types";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Iter "mo:base/Iter";

shared ({caller}) actor class ICPGameKit() {
  type Game = Types.Game;
  type Achievement = Types.Achievement;
  type PlayerAchievement = Types.PlayerAchievement;

  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type List<T> = List.List<T>;

  private func key(t: Text) : Key<Text> { { hash = Text.hash t; key = t } };

  private stable var games : Trie<Text, Game> = Trie.empty();
  private stable var achievements : Trie<Text, Achievement> = Trie.empty();
  private stable var playerAchievements : Trie<Text, PlayerAchievement> = Trie.empty();
  private stable var admins : List<Principal> = ?(caller, null);

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  //Show principal of caller
  public shared({caller}) func showCaller() : async Text {
    return "Caller: " # Principal.toText(caller);
  };

  /////////////////
  // GAME //
  ///////////////
  public shared ({ caller }) func createGame(name : Text,description : Text) : async Result<Game,Text> {
    if(_isAdmin(caller) == false){
      //Display error message and calling principal
      return #err("You are not an admin! - " # Principal.toText(caller));
    };
    // Check if the game already exists
    let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
    var a : List<Text> = List.nil();
    switch (existingGame){
      case (?v) {
        if(v.creator != caller){
          return #err("Game already exists and you are not the creator!");
        };
        a := v.achievements;
      };
      case (_) {};
    };
    let game : Game = { name = name; description = description; creator = caller; created = Time.now(); achievements = a;};
    games := Trie.replace(games, key(name), Text.equal, ?game).0;
    return #ok(game);
  };

  func _updateGame(game : Game) : () {
    games := Trie.replace(games, key(game.name), Text.equal, ?game).0;
  };

  public query func getGame(name : Text) : async ?Game {
    let result = Trie.find(games, key(name), Text.equal);
    return result;
  };

  public shared ({ caller }) func deleteGame(name : Text) : async Result<(),Text> {
    let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
    switch (existingGame){
      case (?v) {
        if(v.creator != caller){
          return #err("Game already exists and you are not the creator!");
        } else {
          games := Trie.replace(games, key(name), Text.equal, null).0;
          // if(List.size(v.achievements) > 0){
          //   return #err("Game has achievements, delete them first!");
          // } else {
          //   games := Trie.replace(games, key(name), Text.equal, null).0;
          // };
        }
      };
      case (_) {};
    };
    return #ok();
  };
  //List all games
  // public query ({ caller }) func listGames() : async [(Text,Game)] {
  //   //let result = Iter.toArray(Trie.iter(games));
  //   let trieOfOwnGames = Trie.filter<Text, Game>(games, func (k, v) { v.creator == caller } );
  //   return Iter.toArray(Trie.iter(trieOfOwnGames));
  // };

  public query ({ caller }) func listGames() : async [Game] {
    //let result = Iter.toArray(Trie.iter(games));
    let trieOfOwnGames = Trie.filter<Text, Game>(games, func (k, v) { v.creator == caller } );
    return Iter.toArray(Iter.map(Trie.iter(trieOfOwnGames), func (kv : (Text, Game)) : Game = kv.1))
  };

  /////////////////
  // ACHIEVEMENT //
  ///////////////

  public shared ({ caller }) func createAchievement(gameName : Text, name : Text, description : Text,maxProgress : Nat, secret : Bool, hidden : Bool) : async Result<Achievement,Text> {
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        if(v.creator != caller){
          return #err("You are not the creator of the game!");
        };
        //Add the achievement to the game
        let achievement : Achievement = { name = name;
                                          created = Time.now();
                                          description = description;
                                          gameName;
                                          maxProgress;
                                          secret;
                                          hidden;
                                          };
        achievements := Trie.replace(achievements, key(name), Text.equal, ?achievement).0;
        //Only add the achievement to the game if it does not already exist
        if(List.find(v.achievements, func (x : Text) : Bool = x == name ) == null){
          let updatedGame : Game = { name = v.name; description = v.description; creator = v.creator; created = v.created; achievements = List.push(name,v.achievements);};
          _updateGame(updatedGame);
        };
        // let updatedGame : Game = { name = v.name; description = v.description; creator = v.creator; created = v.created; achievements = List.push(name,v.achievements);};
        // _updateGame(updatedGame);
        return #ok(achievement);
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  public query func getAchievement(name : Text) : async ?Achievement {
    let result = Trie.find(achievements, key(name), Text.equal);
    return result;
  };

  //List all achievements for a game
  public query ({ caller }) func listAchievements(gameName : Text) : async Result<[Text],Text> {
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        if(_isAdmin(caller) == true){
          return #ok(List.toArray(v.achievements));//Admins see all achievements
        } else {
          let visibleAchievements = Trie.filter<Text, Achievement>(achievements, func (k, v) { v.secret == false and v.hidden == false and v.gameName == gameName } );
          return #ok(Iter.toArray(Iter.map(Trie.iter(visibleAchievements), func (kv : (Text, Achievement)) : Text = kv.1.name)));
        };
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  //List all achievements for a game
  public query ({ caller }) func listAchievementsWithDetails(gameName : Text) : async Result<[Achievement],Text> {
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        if(_isAdmin(caller) == true){
          let allAchievements = Trie.filter<Text, Achievement>(achievements, func (k, v) { v.gameName == gameName } );
          return #ok(Iter.toArray(Iter.map(Trie.iter(allAchievements), func (kv : (Text, Achievement)) : Achievement = kv.1)));
        } else {
          let visibleAchievements = Trie.filter<Text, Achievement>(achievements, func (k, v) { v.secret == false and v.hidden == false and v.gameName == gameName } );
          //return #ok(Iter.toArray(Iter.map(Trie.iter(visibleAchievements), func (kv : (Text, Achievement)) : Achi = kv.1.name)));
          return #ok(Iter.toArray(Iter.map(Trie.iter(visibleAchievements), func (kv : (Text, Achievement)) : Achievement = kv.1)));
        };
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  public shared ({ caller }) func deleteAchievement(achievementName : Text) : async Result<(),Text> {
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    switch (existingAchievement){
      case (?v) {
        if(_isCreatorOfGame(caller, v.gameName) == false){
          return #err("You are not the creator of the game!");
        };
        //Remove the achievement from the game
        let existingGame : ?Game = Trie.find(games, key(v.gameName), Text.equal);
        switch (existingGame){
          case (?game) {
            let updatedGame : Game = { name = game.name; description = game.description; creator = game.creator; created = game.created; achievements = List.filter(game.achievements, func (x : Text) : Bool = x != achievementName);};
            _updateGame(updatedGame);
          };
          case (_) {};
        };
        achievements := Trie.replace(achievements, key(achievementName), Text.equal, null).0;
      };
      case (_) {};
    };
    return #ok();
  };

  func _isCreatorOfGame(caller : Principal, gameName : Text) : Bool {
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        return v.creator == caller;
      };
      case (_) {
        return false;
      };
    };
  };

  /////////////////
  // PLAYERACHIEVEMENT //
  ///////////////

  public shared ({ caller }) func incrementPlayerAchievement(achievementName : Text, playerId : Text) : async Result<PlayerAchievement,Text> {
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    var maxProgress : Nat = 0;
    switch (existingAchievement){
      case (?v) {
        if(v.hidden == true){
          return #err("Achievement is hidden!");
        };
        maxProgress := v.maxProgress;
      };
      case (_) {
        return #err("Achievement does not exist!");
      };
    };
    let playerAchievementId = playerId # "_" # achievementName;
    let existingPlayerAchievement : ?PlayerAchievement = Trie.find(playerAchievements, key(playerAchievementId), Text.equal);
    switch (existingPlayerAchievement){
      case (?v) {
        if(v.earned == true){
          return #err("Achievement has already been earned!");
        };
        if(v.progress >= maxProgress){
          return #err("Progress exceeds max progress!");
        };
        let playerAchievement : PlayerAchievement = { id = playerAchievementId;
                                                      player = playerId;
                                                      achievementName;
                                                      progress = v.progress + 1;
                                                      updated = Time.now();
                                                      earned = v.progress + 1 >= maxProgress;
                                                      };
        playerAchievements := Trie.replace(playerAchievements, key(playerAchievementId), Text.equal, ?playerAchievement).0;
        return #ok(playerAchievement);
      };
      case (_) {
        let playerAchievement : PlayerAchievement = { id = playerAchievementId;
                                                      player = playerId;
                                                      achievementName;
                                                      progress = 1;
                                                      updated = Time.now();
                                                      earned = 1 >= maxProgress;
                                                      };
        playerAchievements := Trie.replace(playerAchievements, key(playerAchievementId), Text.equal, ?playerAchievement).0;
        return #ok(playerAchievement);
      };
    };
  };

  //List all the playerachievements for the specified playerId
  public query ({ caller }) func listMyPlayerAchievements(playerId : Text) : async Result<[PlayerAchievement],Text> {
    let trieOfOwnPlayerAchievements = Trie.filter<Text, PlayerAchievement>(playerAchievements, func (k, v) { v.player == playerId } );
    return #ok(Iter.toArray(Iter.map(Trie.iter(trieOfOwnPlayerAchievements), func (kv : (Text, PlayerAchievement)) : PlayerAchievement = kv.1)));
  };

  //List all the playerachievements for this achievement if you are an admin
  public query ({ caller }) func listPlayerAchievements(achievementName : Text) : async Result<[PlayerAchievement],Text> {
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    switch (existingAchievement){
      case (?v) {
        if(_isAdmin(caller) == false){
          return #err("You are not an admin!");
        };
        // if(_isCreatorOfGame(caller, v.gameName) == false){
        //   return #err("You are not the creator of the game!");
        // };
        let trieOfOwnPlayerAchievements = Trie.filter<Text, PlayerAchievement>(playerAchievements, func (k, v) { v.achievementName == achievementName } );
        return #ok(Iter.toArray(Iter.map(Trie.iter(trieOfOwnPlayerAchievements), func (kv : (Text, PlayerAchievement)) : PlayerAchievement = kv.1)));
      };
      case (_) {
        return #err("Achievement does not exist!");
      };
    };


    // let trieOfOwnPlayerAchievements = Trie.filter<Text, PlayerAchievement>(playerAchievements, func (k, v) { v.player == playerId } );
    // return #ok(Iter.toArray(Iter.map(Trie.iter(trieOfOwnPlayerAchievements), func (kv : (Text, PlayerAchievement)) : PlayerAchievement = kv.1)));
  };

  //Delete all player achievements - mostly for testing purposes
  public shared ({ caller }) func deleteAllPlayerAchievements() : async Result<(),Text> {
    if(_isAdmin(caller) == false){
      return #err("You are not an admin!");
    };
    playerAchievements := Trie.empty();
    return #ok();
  };

  /////////////////
  // ADMIN //
  ///////////////
  public query ({ caller }) func whoAmI() : async Principal {
		return caller;
	};

  public shared ({ caller }) func whoAmIFunc() : async Principal {
		return caller;
	};

  private func _isAdmin(caller : Principal) : Bool {
    return List.find(admins, func (p : Principal) : Bool { p == caller }) != null;
  };

  public query ({ caller }) func isAdmin() : async Bool {
    return List.find(admins, func (p : Principal) : Bool { p == caller }) != null;
  };

  public shared({caller}) func removeAdmin(a : Principal) {
    if(_isAdmin(caller) == false) return;
    admins := List.filter(admins, func (p : Principal) : Bool = p != a);
  };

  public shared({caller}) func addAdmin(a : Principal) {
    if(_isAdmin(caller) == false) return;
    admins := ?(a, admins);
  };

  public query({caller}) func listAdmins() : async [Principal] {
    List.toArray(admins);
  };


};
