import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";
import { useInternetIdentity } from "ic-use-internet-identity";

export function PlayerData() {
  const { actor } = useActor();
  const [playerId, setPlayerId] = useState("");
  const { identity } = useInternetIdentity();
  const [playerData, setPlayerData] = useState([]);
  const [key, setKey] = useState("");
  const [value, setValue] = useState("");
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    if (!actor) return;
    if(!identity) return;
    setPlayerId(identity.getPrincipal().toText());
  }, [actor,identity]);

  useEffect(() => {
    refreshPlayerData();
  }
  ,[actor,playerId]);

  const refreshPlayerData = async () => {
    if (!actor) return;
    if(!playerId) return;
    actor.listPlayerData(playerId).then((pData) => {
      setPlayerData(pData);
    });
  }

  const addPlayerData = async () => {
    setUpdating(true);
    actor.updatePlayerData(playerId,key,value).then((kv) => {
      setUpdating(false);
      refreshPlayerData();
      setKey("");
      setValue("");
    });
  }
  const deletePlayerData = async (key) => {
    //Immediately update the UI
    let filtered = playerData.filter((a) => a.key !== key);
    setPlayerData([...filtered]);
    actor.deletePlayerData(playerId,key).then((kv) => {
      refreshPlayerData();
    });
  }

  const updatePlayerData = async (key,value) => {
    actor.updatePlayerData(playerId,key,value).then((kv) => {
      let index = playerData.findIndex((a) => a.key === key);
      playerData[index].updated = false;
      setPlayerData([...playerData]);
    });
  }

  const handleChange = (e,index) => {
    playerData[index][e.target.name]= e.target.value;
    playerData[index].updated = true;
    setPlayerData([...playerData]);
  }

  return (
    <div className="panelCard">
      <h3>Player Specific Data</h3>
      <table>
        <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
        <tr>
          <td><input type="text" id="key" placeholder="Add a key" value={key} onChange={e => setKey(e.target.value)} /> </td>
          <td><input type="text" id="value" placeholder="Add a json data" value={value} onChange={e => setValue(e.target.value)}/></td>
          <td><button onClick={addPlayerData} disabled={updating}>+</button></td>
        </tr>
        </thead>
        <tbody>
      {playerData?.map((data,index) => (
        <tr key={index}>
          <td>{data.key}</td>
          <td><input type="text" name="value" placeholder="Add a json data" value={data.value} onChange={e => handleChange(e,index)}  /></td>
          <td><button className="deleteButton" onClick={() => deletePlayerData(data.key)}>x</button></td>
          <td><button className="button" onClick={() => updatePlayerData(data.key,data.value)  } disabled={!data.updated}>update</button></td>
          </tr>
      ))
      }
      </tbody>
      </table>
      </div>
  );
}