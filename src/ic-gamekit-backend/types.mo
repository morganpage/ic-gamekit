import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";
import List "mo:base/List";
import Text "mo:base/Text";
import Trie "mo:base/Trie";

module {
  public type Result<Ok, Err> = Result.Result<Ok, Err>;
  public type List<T> = List.List<T>;
  type Trie<K, V> = Trie.Trie<K, V>;

  public type Game = {
    name : Text; // The name of the game and key
    creator : Principal; // The member who created the game
    created : Time.Time; // The time the game was created
    description : Text; // The description of the game
    gameData : Trie<Text, Text>; // The game specific data
  };

  public type Achievement = {
    name : Text; // The name of the achievement and key
    created : Time.Time; // The time the achievement was created
    description : Text; // The description of the achievement
    gameName : Text; // The name of the game the achievement belongs to
    maxProgress : Nat; // The maximum progress of the achievement
    secret : Bool; // Whether the achievement is secret or not
    hidden : Bool; // Whether the achievement is hidden or not
  };


  public type PlayerAchievement = {
    id : Text; // The id of the player achievement mix of player id, game name and achievement name
    achievementName : Text; // The name of the achievement
    player : Text; // The player who has the achievement
    gameName : Text; // The name of the game the achievement belongs to
    progress : Nat; // The progress of the achievement
    updated : Time.Time; // The time the playerachievement was updated
    earned : Bool; // Whether the playerachievement has been earned or not
  };

  public type Player = {
    id : Text; // The id of the player
    created : Time.Time; // The time the player was created
    playerData : Trie<Text, Text>; // The player specific data
  };

  public type PlayerGameSave = {
    id : Text; // The id of the player game save: mix of player id, game name and game save name
    gameSaveName : Text; // The name of the game save
    playerId : Text; // The player who has the game save
    gameName : Text; // The name of the game the game save belongs to
    gameSaveData : Text; // The game save specific data
    created : Time.Time; // The time the player was created
  };

  public type KeyValue = {
    key : Text; // The key of the key value pair
    value : Text; // The value of the key value pair
  };

};