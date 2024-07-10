import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function AchievementsEdit({ game }) {
  const { actor } = useActor();
  const [achievements, setAchievements] = useState([]);

  useEffect(() => {
    if (!actor) return;
    if(!game || !game.name) return;
    actor.listAchievementsWithDetails(game.name).then((a) => {
        setAchievements(a.ok);
        console.log(a.ok);
      }
    );
  }, [actor,game]);

  const handleMaxProgressChange = (e,index) => {
    e.preventDefault();
    console.log(name);
    const maxProgress = parseInt(e.target.value);
    console.log(maxProgress);
    //Update the maxProgress of the achievement
    achievements[index].maxProgress = maxProgress;
    setAchievements([...achievements]);
    console.log(maxProgress);
    //Update achievement
    actor.createAchievement(game.name,achievements[index].name,achievements[index].description,maxProgress,achievements[index].hidden,achievements[index].secret).then((a) => {
      console.log(a);
    } );


  }


  return (
    <>
        <div className="panelCard">
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
                  <td>{achievement.description}</td>
                  <td><input type="text" id="maxProgress" value={achievement.maxProgress.toString()} onChange={(e) => handleMaxProgressChange(e,index)} style={{maxWidth:"70px"}} /></td>
                  <td>{achievement.hidden ? "Yes" : "No"}</td>
                  <td>{achievement.secret ? "Yes" : "No"}</td>
                </tr>
              ))
              }
            </tbody>
          </table>
        </div>

    </>
  );

}

