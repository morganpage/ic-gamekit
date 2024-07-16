import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function AchievementsEdit({ game }) {
  const { actor } = useActor();
  const [achievements, setAchievements] = useState([]);

  useEffect(() => {
    if (!actor) return;
    if(!game || !game.name) return;
    actor.listAchievements(game.name).then((a) => {
        setAchievements(a.ok);
      }
    );
  }, [actor,game]);

  const handleMaxProgressChange = (e,index) => {
    e.preventDefault();
    const maxProgress = parseInt(e.target.value);
    achievements[index].maxProgress = maxProgress;
    achievements[index].updated = true;
    setAchievements([...achievements]);
  }

  const handleChange = (e,index) => {
    achievements[index][e.target.name]= e.target.value;
    achievements[index].updated = true;
    setAchievements([...achievements]);
    console.log(achievements);
  }
  const handleChangeBoolean = (e,index) => {
    achievements[index][e.target.name]= e.target.value === "true" ? true : false;
    achievements[index].updated = true;
    setAchievements([...achievements]);
    console.log(achievements);
  }

  const createAchievement = async (e) => {
    e.preventDefault();
    const name = e.target.elements.name.value;
    const description = e.target.elements.description.value;
    actor.createAchievement(game.name,name,description,1,false,false).then((achievement) => {
      console.log(achievement);
      setAchievements([...achievements, achievement.ok]);
    });
    e.target.reset();
  };

  const deleteAchievement = async (achievementName) => {
    actor.deleteAchievement(achievementName).then((a) => {
      if(a.err){
        alert(a.err);
        return;
      }
      let filtered = achievements.filter((a) => a.name !== achievementName);
      setAchievements([...filtered]);
    });
  }

  const updateAchievement = async (achievementName) => {
    const achievement = achievements.find((a) => a.name === achievementName);
    actor.createAchievement(game.name,achievement.name,achievement.description,achievement.maxProgress,achievement.hidden,achievement.secret).then((a) => {
      console.log(a);
      if(a.err){
        alert(a.err);
        return;
      }
      achievement.updated = false;
      setAchievements([...achievements]);
    });
  }

  return (
    <>
      <div className="panelCard">
      <h2>Add Achievement</h2>
      <form onSubmit={createAchievement}>
          <input type="text" id="name" placeholder="Achievement Name" style={{maxWidth:"120px"}} />
          <input type="text" id="description" placeholder="Achievement Description" style={{minWidth:"180px"}} />
          <button type="submit">+</button>
      </form>
      <h2>Edit Achievements</h2>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Desc</th>
              <th>Max Prog</th>
              <th>Hidden</th>
              <th>Secret</th>
            </tr>
          </thead>
          <tbody>
            {achievements?.map((achievement,index) => (
              <tr key={index}>
                <td>{achievement.name}</td>
                <td><input type="text" name="description" value={achievement.description} onChange={(e) => handleChange(e,index)} style={{maxWidth:"120px"}} /></td>
                <td><input type="text" id="maxProgress" value={achievement.maxProgress.toString()} onChange={(e) => handleMaxProgressChange(e,index)} style={{maxWidth:"70px"}} /></td>
                <td>
                  <select name="hidden" value={achievement.hidden} onChange={(e) => handleChangeBoolean(e,index)}>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                  </select>
                </td>
                <td>
                  <select name="secret" value={achievement.secret} onChange={(e) => handleChangeBoolean(e,index)}>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                  </select>
                </td>
                <td><button className="deleteButton" onClick={e => deleteAchievement(achievement.name)}>x</button></td>
                <td><button className="button" onClick={e => updateAchievement(achievement.name)  } disabled={!achievement.updated}>update</button></td>
              </tr>
            ))
            }
          </tbody>
        </table>
      </div>
    </>
  );

}

