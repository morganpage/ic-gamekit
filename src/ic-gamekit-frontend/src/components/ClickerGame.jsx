import { useEffect, useState } from "react";
import { useActor } from "../ic/ClickerGameActor";

export function ClickerGame() {
  const { actor } = useActor();

  const [clickCount, setClickCount] = useState(0);
  const [gameCanisterPrincipal, setGameCanisterPrincipal] = useState("");
  const [playerId, setPlayerId] = useState("");
  const [playerAchievements, setPlayerAchievements] = useState([]);
  const [availableGameRewards, setAvailableGameRewards] = useState({});
  const [gameRewards, setGameRewards] = useState([]);

  useEffect(() => {
    if (!actor) return;
    refreshPlayerAchievements();
    refreshAvailableGameRewards();
    refreshGameRewards();
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

  const refreshAvailableGameRewards = async () => {
    if (!actor) return;
    actor.getAvailableGameRewards().then((rewards) => {
      try {
        //convert json string to json object
        let json = JSON.parse(rewards);
        setAvailableGameRewards(json);
        console.log(json);
      } catch (error) {
        console.log(error);
      }
    });
  }

  const refreshGameRewards = async () => {
    if (!actor) return;
    actor.getGameRewards().then((rewards) => {
      try {
        console.log(rewards);
        //convert json string to json object
        let json = JSON.parse(rewards);
        setGameRewards(json.rewards);
      } catch (error) {
        console.log(error);
      }
    });
  }

  const rewardNameToUrl = (rewardName) => {
    let filtered = availableGameRewards["Pets"].filter((a) => a.name === rewardName);
    if(filtered.length > 0){
      return filtered[0].url;
    }
    return "";
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
      <h4>Rewards</h4>
      <div className="rewards">
        {gameRewards?.map((reward, index) => (
          <div key={index} >
            <div>
              <img src={rewardNameToUrl(reward)} alt="reward" />
            </div>
          </div>
        ))}
      </div>
      <h4>Unlocked Achievements</h4>
      {playerAchievements?.map((achievement, index) => (
        <div key={index} >
          <div>
            <p>{achievement.achievementName}</p>
          </div>
        </div>
      ))}
      <h4>Available Rewards</h4>
      <div>
          {Object.keys(availableGameRewards).map((key, index) => (
            <div key={index} >
              <div>
                <p>{key}:</p>
                {availableGameRewards[key].map((reward, index) => (
                  <ul key={index} >
                    <li>{reward.name}</li>
                  </ul>
                ))}
              </div>
            </div>
          ))}
      </div>

    </div>
  );

}