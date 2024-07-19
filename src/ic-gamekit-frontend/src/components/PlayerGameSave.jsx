import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";
import { useInternetIdentity } from "ic-use-internet-identity";



export function PlayerGameSave({game}) {
  const { actor } = useActor();
  const [playerId, setPlayerId] = useState("");
  const { identity } = useInternetIdentity();
  const [gameSaveName, setGameSaveName] = useState("");
  const [gameSaveData, setGameSaveData] = useState("");
  const [updating, setUpdating] = useState(false);
  const [playerGameSaves, setPlayerGameSaves] = useState([]);

  useEffect(() => {
    if(!actor) return;
    if(!identity) return;
    setPlayerId(identity.getPrincipal().toText());
  }, [actor]);

  useEffect(() => {
    refreshPlayerGameSaves();
  }
  ,[actor,playerId,game]);

  const refreshPlayerGameSaves = async () => {
    if(!actor) return;
    if(!playerId) return;
    if(!game || !game.name) return;
    actor.listGameSaves(game.name,playerId).then((saves) => {
      setPlayerGameSaves(saves);
    });
  }


  const createGameSave = async () => {
    setUpdating(true);
    actor.createGameSave(gameSaveName,game.name,playerId,gameSaveData).then((kv) => {
      setUpdating(false);
      console.log(kv);
      if(kv.err){
        alert(kv.err);
        return;
      }
      refreshPlayerGameSaves();
      setGameSaveName("");
      setGameSaveData("");
    });
  }

  const deleteGameSaveData = async (gsName) => {
    //Immediately update the UI
    let filtered = playerGameSaves.filter((a) => a.gameSaveName !== gsName);
    setPlayerGameSaves([...filtered]);
    actor.deleteGameSave(gsName,game.name,playerId).then((kv) => {
      if(kv.err){
        alert(kv.err);
        return;
      }
      refreshPlayerGameSaves();
    });
  }

  return (
    <div className="panelCard">
      <h3>Game Saves for player:</h3>
      <p>{playerId}</p>
      <table>
        <thead>
        <tr>
          <th>Save Name</th>
          <th>Save Data</th>
        </tr>
        <tr>
          <td><input type="text" id="gameSaveName" placeholder="Save name" value={gameSaveName} onChange={e => setGameSaveName(e.target.value)} /> </td>
          <td><input type="text" id="gameSaveData" placeholder="Save json data" value={gameSaveData} onChange={e => setGameSaveData(e.target.value)}/></td>
          <td><button onClick={createGameSave} disabled={updating}>+</button></td>
        </tr>
      </thead>
      <tbody>
      {playerGameSaves?.map((playerGameSave,index) => (
        <tr key={index}>
          <td>{playerGameSave.id}</td>
          <td>{playerGameSave.gameSaveName}</td>
          <td>{playerGameSave.gameSaveData}</td>
          <td><button className="deleteButton" onClick={() => deleteGameSaveData(playerGameSave.gameSaveName)}>x</button></td>
        </tr>
      ))}
      </tbody>
      </table>
    </div>
  );
}