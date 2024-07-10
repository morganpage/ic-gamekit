import { useInternetIdentity } from "ic-use-internet-identity";

export function LoginButton() {
  const { login, loginStatus,identity,clear } = useInternetIdentity();

  const disabled = loginStatus === "logging-in" || loginStatus === "success";
  const text = loginStatus === "logging-in" ? "Logging in..." : "Login";
  //console.log(identity);
  return (
    <>
    { identity ?
    <button onClick={clear} >
      Logout
    </button>
    : <button onClick={login} disabled={disabled}>
      {text}
    </button>
}
    <p style={{fontSize:"0.4em"}}>Logged in as: {identity?.getPrincipal().toText()}</p>
    </>
  );
}