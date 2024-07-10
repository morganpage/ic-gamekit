import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";

export function AchievementAdd({ game, onGameChange}) {
  const { actor } = useActor();

  const createAchievement = async (e) => {
    e.preventDefault();
    const name = e.target.elements.name.value;
    const description = e.target.elements.description.value;
    actor.createAchievement(game.name,name,description,1,false,false).then((achievement) => {
      console.log(achievement);
      onGameChange(achievement.ok.gameName);
    });
    e.target.reset();
  };

  return (
    <>
    <div className="panelCard">
      <h2>Add Achievement</h2>
      <form onSubmit={createAchievement}>
          <input type="text" id="name" placeholder="Achievement Name" style={{maxWidth:"120px"}} />
          <input type="text" id="description" placeholder="Achievement Description" style={{minWidth:"180px"}} />
          <button type="submit">+</button>
      </form>
    </div>
    </>
  );
}