import { useState,useEffect } from 'react';
import { useActor } from "./ic/Actors";
import { LoginButton } from './components/LoginButton';
import { Admins } from './components/Admins';
import { Games } from './components/Games';
import { AchievementAdd } from './components/AchievementAdd';
import { AchievementsEdit } from './components/AchievementsEdit';
import { Player } from './components/Player';
import { ClickerGame } from './components/ClickerGame';


function App() {
  const [game, setGame] = useState({});
  const { actor } = useActor();
  const [isAdmin, setIsAdmin] = useState(false);
  const [showAdminPanels, setShowAdminPanels] = useState(false);
  const [showGamePanel, setShowGamePanel] = useState(false);

  useEffect(() => {
    if (!actor) return;
    actor.isAdmin().then((a) => {
        setIsAdmin(a);
      }
    );
  }, [actor]);


  return (
    <main>
      <LoginButton/>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <div style={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
        <div>
        <h1 style={{textAlign:"center", marginTop:"10px" }}>The ICP Gamekit</h1>
        {!actor ? <p style={{textAlign:"center", marginTop:"10px" }}>Login to get started</p>
        :
        <>
          { showAdminPanels && <>
          {isAdmin && <Admins />}
          {isAdmin && <Games game={game} onGameChange={setGame} />}
          <AchievementAdd game={game} />
          <AchievementsEdit game={game} />
          <Player />
          </>
          }
          <ClickerGame />
        </>
        }

        </div>
      </div>
    </main>
  );
}

export default App;
