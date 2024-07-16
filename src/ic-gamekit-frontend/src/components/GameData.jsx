import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function GameData({game}) {
  const { actor } = useActor();
  const [gameData, setGameData] = useState([]);
  const [key, setKey] = useState("");
  const [value, setValue] = useState("");
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    refreshGameData();
  }, [actor,game]);

  const refreshGameData = async () => {
    if (!actor) return;
    if(!game || !game.name) return;
    actor.listGameData(game.name).then((gData) => {
      setGameData(gData);
    });
  }

  const addGameData = async () => {
    setUpdating(true);
    actor.updateGameData(game.name,key,value).then((kv) => {
      setUpdating(false);
      //setGameData([...gameData, kv.ok]);
      refreshGameData();
      setKey("");
      setValue("");
    });
  }
  const deleteGameData = async (key) => {
    //Immediately update the UI
    let filtered = gameData.filter((a) => a.key !== key);
    setGameData([...filtered]);
    actor.deleteGameData(game.name,key).then((kv) => {
      refreshGameData();
    });
  }

  const updateGameData = async (key,value) => {
    actor.updateGameData(game.name,key,value).then((kv) => {
      let index = gameData.findIndex((a) => a.key === key);
      gameData[index].updated = false;
      setGameData([...gameData]);
    });
  }

  const handleChange = (e,index) => {
    gameData[index][e.target.name]= e.target.value;
    gameData[index].updated = true;
    setGameData([...gameData]);
  }

  return (
    <div className="panelCard">
      <h3>Game Specific Data</h3>
      <table>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
        <tr>
          <td><input type="text" id="key" placeholder="Add a key" value={key} onChange={e => setKey(e.target.value)} /> </td>
          <td><input type="text" id="value" placeholder="Add a json data" value={value} onChange={e => setValue(e.target.value)}/></td>
          <td><button onClick={addGameData} disabled={updating}>+</button></td>
        </tr>
      {gameData?.map((data,index) => (
        <tr key={index}>
          <td>{data.key}</td>
          <td><input type="text" name="value" placeholder="Add a json data" value={data.value} onChange={e => handleChange(e,index)}  /></td>
          <td><button className="deleteButton" onClick={() => deleteGameData(data.key)}>x</button></td>
          <td><button className="button" onClick={() => updateGameData(data.key,data.value)  } disabled={!data.updated}>update</button></td>
          </tr>
      ))
      }
      </table>
      </div>
  );
}