import { useState,useEffect } from 'react';
import { useActor } from "./ic/Actors";
import { LoginButton } from './components/LoginButton';
import { Admins } from './components/Admins';
import { Games } from './components/Games';
import { AchievementAdd } from './components/AchievementAdd';
import { AchievementsEdit } from './components/AchievementsEdit';
import { Player } from './components/Player';
import { ClickerGame } from './components/ClickerGame';
import { useInternetIdentity } from "ic-use-internet-identity";


function App() {
  const { loginStatus,identity ,isInitializing } = useInternetIdentity();
  const [game, setGame] = useState({});
  const { actor } = useActor();
  const [isAdmin, setIsAdmin] = useState(false);
  const [showAdminPanels, setShowAdminPanels] = useState(false);

  useEffect(() => {
    if (!identity) setIsAdmin(false);
  }, [identity]);


  useEffect(() => {
    if (!actor) return;
    try {
      actor.isAdmin().then((a) => {
          setIsAdmin(a);
        }
      );
    } catch (error) {
      console.log("Error",error);
    }
  }, [actor]);

  return (
    <main>
      <LoginButton/>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <div style={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
        <div>
        <h1 style={{textAlign:"center", marginTop:"10px" }}>The ICP Gamekit</h1>
        {!identity ? <p style={{textAlign:"center", marginTop:"10px" }}>Login to get started</p>
        :
        <>
        {isAdmin && <button className='button' onClick={() => setShowAdminPanels(!showAdminPanels)}>{showAdminPanels ? "Hide Admin Panels":"Show Admin Panels"}</button>}
        { showAdminPanels && <>
          {isAdmin && <Admins />}
          {isAdmin && <Games game={game} onGameChange={setGame} />}
          {/* <AchievementAdd game={game} onGameChange={setGame}/> */}
          {isAdmin && <AchievementsEdit game={game} />}
          {/* <Player /> */}
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
