import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function Games({ game, onGameChange }) {
  const [games, setGames] = useState([]);
  const { actor } = useActor();

  useEffect(() => {
    if (!actor) return;
    actor.listGames().then((games) => {
      console.log(games);
      setGames(games);
      if(games.length > 0) onGameChange(games[0]);
    }
    );
  }, [actor]);

  const createGame = async (e) => {
    e.preventDefault();
    const name = e.target.elements.name.value;
    const description = e.target.elements.description.value;
    actor.createGame(name,description).then((game) => {
      setGames([...games, game.ok]);
      onGameChange(game.ok);
    });
    e.target.reset();
  };

  const onSelectChange = (gameName) => {
    console.log(gameName);
    const game = games.find((a) => a.name === gameName);
    onGameChange(game);
  }

  const deleteGame = async (gameName) => {
    actor.deleteGame(gameName).then((a) => {
      if(a.err){
        alert(a.err);
        return;
      }
      let filtered = games.filter((a) => a.name !== gameName);
      setGames([...filtered]);
      if(filtered.length > 0){
        console.log("Games left",filtered);
        onGameChange(filtered[0]);
      }
      else{
        console.log("No games left");
        onGameChange(null);
      }
    });
  }
  return (
    <div className="panelCard" >
      <h2>Games</h2>
      <form onSubmit={createGame}>
        <input type="text" id="name" placeholder="Add a Game Name" />
        <input type="text" id="description" placeholder="Add a Game Description" />
        <button type="submit">+</button>
      </form>
      <div className="panelCard">
        <label>
        {/* <h3>Choose a Game:</h3> */}
        <select id="games" name="games" onChange={e => onSelectChange(e.target.value)} value={game?.name} >
          {games.map((game,index) => (
              <option key={game.name} value={game.name}>
                {game.name}</option>
            ))}
        </select></label>
        <button className="deleteButton" onClick={e => deleteGame(game.name)}>Delete Game</button>
        {game &&
        <div>
        <table>
          <tbody>
              <tr>
                <td>Name:</td>
                <td>{game.name}</td>
              </tr>
              <tr>
                <td>Description:</td>
                <td>{game.description}</td>
              </tr>
              </tbody>
        </table>
        </div>}
      </div>
    </div>
  );
}
