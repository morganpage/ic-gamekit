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

  /////////////////
  // GAME //
  ///////////////
  public shared ({ caller }) func createGame(name : Text,description : Text) : async Result<Game,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let game : Game = { name = name; description = description; creator = caller; created = Time.now(); };
    games := Trie.replace(games, key(name), Text.equal, ?game).0;
    return #ok(game);
  };

  public query func getGame(name : Text) : async ?Game {
    if(_isAdmin(caller) == false){return null;};
    let result = Trie.find(games, key(name), Text.equal);
    return result;
  };

  public shared ({ caller }) func deleteGame(name : Text) : async Result<(),Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
    switch (existingGame){
      case (?v) {
        games := Trie.replace(games, key(name), Text.equal, null).0;
      };
      case (_) {};
    };
    return #ok();
  };

  public query ({ caller }) func listGames() : async [Game] {
    return Iter.toArray(Iter.map(Trie.iter(games), func (kv : (Text, Game)) : Game = kv.1))
  };

  /////////////////
  // ACHIEVEMENT //
  ///////////////

  public shared ({ caller }) func createAchievement(gameName : Text, name : Text, description : Text,maxProgress : Nat, secret : Bool, hidden : Bool) : async Result<Achievement,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        let achievement : Achievement = { name = name;
                                          created = Time.now();
                                          description = description;
                                          gameName;
                                          maxProgress;
                                          secret;
                                          hidden;
                                          };
        achievements := Trie.replace(achievements, key(name), Text.equal, ?achievement).0;
        return #ok(achievement);
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  public query func getAchievement(name : Text) : async ?Achievement {
    if(_isAdmin(caller) == false){return null;};
    let result = Trie.find(achievements, key(name), Text.equal);
    return result;
  };

  //List all achievements for a game
  public query ({ caller }) func listAchievements(gameName : Text) : async Result<[Achievement],Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingGame : ?Game = Trie.find(games, key(gameName), Text.equal);
    switch (existingGame){
      case (?v) {
        let allAchievements = Trie.filter<Text, Achievement>(achievements, func (k, v) { v.gameName == gameName } );
        return #ok(Iter.toArray(Iter.map(Trie.iter(allAchievements), func (kv : (Text, Achievement)) : Achievement = kv.1)));
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  public shared ({ caller }) func deleteAchievement(achievementName : Text) : async Result<(),Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    switch (existingAchievement){
      case (?v) {
        achievements := Trie.replace(achievements, key(achievementName), Text.equal, null).0;
      };
      case (_) {};
    };
    return #ok();
  };

  /////////////////
  // PLAYERACHIEVEMENT //
  ///////////////

  public shared ({ caller }) func incrementPlayerAchievement(achievementName : Text, playerId : Text,increment : Nat) : async Result<PlayerAchievement,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    var maxProgress : Nat = 0;
    var gameName : Text = "";
    switch (existingAchievement){
      case (?v) {
        if(v.hidden == true){
          return #err("Achievement is hidden!");
        };
        maxProgress := v.maxProgress;
        gameName := v.gameName;
      };
      case (_) {
        return #err("Achievement does not exist!");
      };
    };
    let playerAchievementId = playerId # "_" # gameName # "_" # achievementName;
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
                                                      gameName;
                                                      progress = v.progress + increment;
                                                      updated = Time.now();
                                                      earned = v.progress + increment >= maxProgress;
                                                      };
        playerAchievements := Trie.replace(playerAchievements, key(playerAchievementId), Text.equal, ?playerAchievement).0;
        return #ok(playerAchievement);
      };
      case (_) {
        let playerAchievement : PlayerAchievement = { id = playerAchievementId;
                                                      player = playerId;
                                                      achievementName;
                                                      gameName;
                                                      progress = increment;
                                                      updated = Time.now();
                                                      earned = increment >= maxProgress;
                                                      };
        playerAchievements := Trie.replace(playerAchievements, key(playerAchievementId), Text.equal, ?playerAchievement).0;
        return #ok(playerAchievement);
      };
    };
  };

  //List all the playerachievements for the specified playerId, gameName and whether we want to see earned or non-earned achievements
  public query ({ caller }) func listMyPlayerAchievements(playerId : Text, gameName : Text, earned : Bool) : async Result<[PlayerAchievement],Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let trieOfOwnPlayerAchievements = Trie.filter<Text, PlayerAchievement>(playerAchievements, func (k, v) { v.player == playerId and v.gameName == gameName and v.earned == earned } );
    return #ok(Iter.toArray(Iter.map(Trie.iter(trieOfOwnPlayerAchievements), func (kv : (Text, PlayerAchievement)) : PlayerAchievement = kv.1)));
  };

  //List all the playerachievements for this achievement if you are an admin
  public query ({ caller }) func listPlayerAchievements(achievementName : Text) : async Result<[PlayerAchievement],Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingAchievement : ?Achievement = Trie.find(achievements, key(achievementName), Text.equal);
    switch (existingAchievement){
      case (?v) {
        if(_isAdmin(caller) == false){
          return #err("You are not an admin!");
        };
        let trieOfOwnPlayerAchievements = Trie.filter<Text, PlayerAchievement>(playerAchievements, func (k, v) { v.achievementName == achievementName } );
        return #ok(Iter.toArray(Iter.map(Trie.iter(trieOfOwnPlayerAchievements), func (kv : (Text, PlayerAchievement)) : PlayerAchievement = kv.1)));
      };
      case (_) {
        return #err("Achievement does not exist!");
      };
    };
  };

  //Delete all player achievements - mostly for testing purposes
  public shared ({ caller }) func deleteAllPlayerAchievements() : async Result<(),Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
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
