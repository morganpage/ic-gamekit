import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function Player() {

  const { actor } = useActor();
  const [achievements, setAchievements] = useState([]);
  const [playerAchievements, setPlayerAchievements] = useState([]);

  useEffect(() => {
    refreshPlayerAchievements();
  }
  , [actor]);

  const refreshPlayerAchievements = async () => {
    if (!actor) return;
    actor.listMyPlayerAchievements().then((a) => {
      setPlayerAchievements(a.ok);
    }
    );
  }

  const handleChangeGameName = async (e) => {
    e.preventDefault();
    const name = e.target.elements.name.value;
    console.log(name);
    if (!actor) return;
    actor.listAchievementsWithDetails(name).then((a) => {
      setAchievements(a.ok);
    }
    );
  };

  const incrementPlayerAchievement = async (name) => {
    console.log(name);
    actor.incrementPlayerAchievement(name).then((a) => {
      console.log(a);
      refreshPlayerAchievements();
    });
  };


  return (
    <>
    <div className="panelCard">
    <form onSubmit={handleChangeGameName}>
      <label style={{display:"flex"}}>Game:
      <input style={{marginLeft:"10px"}} type="text" id="name" placeholder="Enter Game Name" /></label>
      <button type="submit">OK</button>
    </form>
    </div>
    <div className="panelCard">
      <h4>Available Achievements</h4>
      {achievements?.map((achievement,index) => (
        <div key={index} className="row"  >
          <div className="namedesc">
          <p>{achievement.name}</p>
          <p>{achievement.description}</p>
          </div>
          <button onClick={() => incrementPlayerAchievement(achievement.name)}>+</button>
        </div>
      ))
      }
    </div>
    <div className="panelCard">
      <h4>Current Achievements</h4>
      {playerAchievements?.map((playerAchievement,index) => (
        <div key={index} className="row"  >
          <div className="namedesc">
          <p>{playerAchievement.achievementName}</p>
          <p>Progress: {playerAchievement.progress.toString()}</p>
          <p>Earned: {playerAchievement.earned ? "Yes":"No"}  </p>
          </div>
        </div>
      ))
      }
    </div>


    </>
  );
}