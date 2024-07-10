import { useEffect, useState } from "react";
import { useActor } from "../ic/Actors";
import { Principal } from '@dfinity/principal';

export function Admins() {
  const { actor } = useActor();
  const [admins, setAdmins] = useState([]);

  useEffect(() => {
    if (!actor) return;
    refreshAdmins();
  }, [actor]);

  const refreshAdmins = async () => {
    actor.listAdmins().then((a) => {
      let adminNames = [];
      a.forEach((admin) => {
        adminNames.push(admin.toString());
      });
      setAdmins(adminNames);
    });
  }



  const addAdmin = async (e) => {
    e.preventDefault();
    const name = e.target.elements.name.value;
    try {
      actor.addAdmin(Principal.fromText(name)).then((a) => {
        refreshAdmins();
      });
    } catch (error) {
      alert(error.message);
    }
    e.target.reset();
  };

  const removeAdmin = async (name) => {
    try {
      actor.removeAdmin(Principal.fromText(name)).then((a) => {
        refreshAdmins();
      });
    } catch (error) {
      alert(error.message);
    }
  }

  return (
    <div className="panelCard">
      <h2>Admins</h2>
      <p>If you are seeing this, you are an admin!</p>
      <form onSubmit={addAdmin} >
          <input type="text" id="name" placeholder="Enter Principal" style={{ minWidth:"320px"}} />
          <button type="submit">+</button>
      </form>
      <div className="panelCard">
          {admins.map((admin,index) => (
            <div key={index} style={{display:"flex", alignItems:"center", justifyContent:"space-between" }} >
              <p style={{fontSize:"0.5em"}}>{admin}</p>
              <button className="deleteButton" onClick={e => removeAdmin(admin)}>x</button>
            </div>
          ))}
      </div>
    </div>
  );
}