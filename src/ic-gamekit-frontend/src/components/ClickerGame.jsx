import { useEffect, useState } from "react";
import { useActor } from "../ic/ClickerGameActor";

export function ClickerGame() {
  const { actor } = useActor();

  const [clickCount, setClickCount] = useState(0);
  const [gameCanisterPrincipal, setGameCanisterPrincipal] = useState("");
  const [playerId, setPlayerId] = useState("");
  const [playerAchievements, setPlayerAchievements] = useState([]);

  useEffect(() => {
    if (!actor) return;
    refreshPlayerAchievements();
    actor.gameCanisterPrincipal().then((principal) => {
      setGameCanisterPrincipal(principal.toString());
    });
    actor.playerPrincipal().then((principal) => {
      setPlayerId(principal.toString());
    });
    actor.getClicks().then((clicks) => {
      setClickCount(parseInt(clicks));
    });
  }, [actor]);

  const clickHandler = async (e) => {
    e.preventDefault();
    try {
      actor.click().then((a) => {
        console.log(a);
        if(a.err){
          alert(a.err);
          return;
        }
        setClickCount(parseInt(a.ok.progress));
        refreshPlayerAchievements();
      });
    } catch (error) {
      alert(error.message);
    }
  };

  const refreshPlayerAchievements = async () => {
    if (!actor) return;
    actor.getPlayerAchievements().then((achievements) => {
      if(achievements.err){
        alert(achievements.err);
        return;
      }
      setPlayerAchievements(achievements.ok);
    });
  }

  return (
    <div className="panelCard">
      <h2>Clicker Game</h2>
      <p>Game Canister Principal (must be an admin): {gameCanisterPrincipal}</p>
      <p>Player Id: {playerId}</p>
      <form onSubmit={clickHandler}>
        <button type="submit">CLICK</button>
        <p>Click Count: {clickCount}</p>
      </form>
      <h4>Unlocked Achievements</h4>
      {playerAchievements?.map((achievement, index) => (
        <div key={index} >
          <div>
            <p>{achievement.achievementName}</p>
          </div>
        </div>
      ))}

    </div>
  );

}