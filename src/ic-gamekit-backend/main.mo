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
  type Player = Types.Player;
  type PlayerGameSave = Types.PlayerGameSave;
  type KeyValue = Types.KeyValue;

  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type List<T> = List.List<T>;

  private func key(t: Text) : Key<Text> { { hash = Text.hash t; key = t } };

  private stable var games : Trie<Text, Game> = Trie.empty();
  private stable var achievements : Trie<Text, Achievement> = Trie.empty();
  private stable var playerAchievements : Trie<Text, PlayerAchievement> = Trie.empty();
  private stable var admins : List<Principal> = ?(caller, null);
  private stable var players : Trie<Text, Player> = Trie.empty();
  private stable var playerGameSaves : Trie<Text, PlayerGameSave> = Trie.empty();

  /////////////////
  // GAME //
  ///////////////
  public shared ({ caller }) func createGame(name : Text,description : Text) : async Result<Game,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    //let t1 = Trie.empty();
    //let game : Game = { name = name; description = description; creator = caller; created = Time.now(); gameData = Trie.put(t1, key "key1", Text.equal, "{\"testNumber\": 0.1 , \"testString\":\"hello\" }").0};
    let game : Game = { name = name; description = description; creator = caller; created = Time.now(); gameData = Trie.empty()};
    games := Trie.replace(games, key(name), Text.equal, ?game).0;
    return #ok(game);
  };

  // public shared ({ caller }) func updateGame(name : Text,description : Text, gameData : Trie<Text, Text>) : async Result<Game,Text> {
  //   if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
  //   let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
  //   switch (existingGame){
  //     case (?v) {
  //       let game : Game = { name = name; description = description; creator = v.creator; created = v.created; gameData = gameData};
  //       games := Trie.replace(games, key(name), Text.equal, ?game).0;
  //       return #ok(game);
  //     };
  //     case (_) {
  //       return #err("Game does not exist!");
  //     };
  //   };
  // };

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

  public query ({ caller }) func listGameData(name : Text) : async [KeyValue] {
    switch (Trie.find(games, key(name), Text.equal)){
      case (?v) {
        return Iter.toArray(Iter.map(Trie.iter(v.gameData), func (kv : (Text, Text)) : KeyValue = { key = kv.0; value = kv.1 }));
      };
      case (_) {
        return [];
      };
    };
  };

  public shared ({ caller }) func updateGameData(name : Text, gameDataKey : Text, gameDataValue : Text) : async Result<KeyValue,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
    switch (existingGame){
      case (?v) {
        let game : Game = { name = name; description = v.description; creator = v.creator; created = v.created; gameData = Trie.put(v.gameData, key(gameDataKey), Text.equal, gameDataValue).0};
        games := Trie.replace(games, key(name), Text.equal, ?game).0;
        let kv : KeyValue = { key = gameDataKey; value = gameDataValue };
        return #ok(kv);
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
  };

  public shared ({ caller }) func deleteGameData(name : Text, gameDataKey : Text) : async Result<(),Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let existingGame : ?Game = Trie.find(games, key(name), Text.equal);
    switch (existingGame){
      case (?v) {
        let game : Game = { name = name; description = v.description; creator = v.creator; created = v.created; gameData = Trie.replace(v.gameData, key(gameDataKey), Text.equal, null).0};
        games := Trie.replace(games, key(name), Text.equal, ?game).0;
        return #ok();
      };
      case (_) {
        return #err("Game does not exist!");
      };
    };
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
  // GAME SAVE //
  ///////////////
  public shared ({ caller }) func createGameSave(gameSaveName : Text, gameName : Text, playerId : Text,gameSaveData : Text) : async Result<PlayerGameSave,Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let id = playerId # "_" # gameName # "_" # gameSaveName;
    let playerGameSave : PlayerGameSave = { id; gameSaveName; playerId; gameName; gameSaveData; created = Time.now()};
    playerGameSaves := Trie.replace(playerGameSaves, key(id), Text.equal, ?playerGameSave).0;
    return #ok(playerGameSave);
    // let existingGameSave : ?PlayerGameSave = Trie.find(playerGameSaves, key(id), Text.equal);
    // switch (existingGameSave){
    //   case (?v) {
    //     let playerGameSave : PlayerGameSave = { id; gameSaveName; playerId; gameName; gameSaveData = Trie.put(v.gameSaveData, key(gameSaveDataKey), Text.equal, gameSaveDataValue).0; created = Time.now()};
    //     playerGameSaves := Trie.replace(playerGameSaves, key(gameSaveName), Text.equal, ?playerGameSave).0;
    //     return #ok(playerGameSave);
    //   };
    //   case (_) {//New game save
    //     let playerGameSave : PlayerGameSave = { id; gameSaveName; playerId; gameName; gameSaveData = Trie.put(Trie.empty(), key(gameSaveDataKey), Text.equal, gameSaveDataValue).0; created = Time.now()};
    //     playerGameSaves := Trie.replace(playerGameSaves, key    return result?.gameSaveData;ayerGameSave).0;
    //     return #ok(playerGameSave);
    //   };
    // };
  };

  public query ({ caller }) func getGameSaveData(gameSaveName : Text, gameName : Text, playerId : Text) : async Text {
    if(_isAdmin(caller) == false){return "";};
    let id = playerId # "_" # gameName # "_" # gameSaveName;
    let result = Trie.find(playerGameSaves, key(id), Text.equal);
    switch (result){
      case (?v) {
        return v.gameSaveData;
      };
      case (_) {
        return "";
      };
    };
    //return result.gameSaveData;
    //return result;
  };

  public query ({ caller }) func listGameSaves(playerId : Text, gameName : Text) : async [PlayerGameSave] {
    if(_isAdmin(caller) == false){return [];};
    let trieOfOwnGameSaves = Trie.filter<Text, PlayerGameSave>(playerGameSaves, func (k, v) { v.playerId == playerId and v.gameName == gameName } );
    return Iter.toArray(Iter.map(Trie.iter(trieOfOwnGameSaves), func (kv : (Text, PlayerGameSave)) : PlayerGameSave = kv.1));
  };

  public shared ({ caller }) func deleteGameSave(gameSaveName : Text, gameName : Text, playerId : Text) : async Result<(),Text> {
    if(_isAdmin(caller) == false){return #err("You are not an admin! - " # Principal.toText(caller));};
    let id = playerId # "_" # gameName # "_" # gameSaveName;
    let existingGameSave : ?PlayerGameSave = Trie.find(playerGameSaves, key(id), Text.equal);
    switch (existingGameSave){
      case (?v) {
        playerGameSaves := Trie.replace(playerGameSaves, key(id), Text.equal, null).0;
      };
      case (_) {};
    };
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
