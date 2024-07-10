import { ReactNode } from "react";
import { ActorProvider, createActorContext, createUseActorHook } from "ic-use-actor";
import { useInternetIdentity } from "ic-use-internet-identity";
import { canisterId, idlFactory } from "../../../declarations/ic-gamekit-backend";
import { _SERVICE } from "../../../declarations/ic-gamekit-backend/ic-gamekit-backend.did";

const actorContext = createActorContext<_SERVICE>();
export const useActor = createUseActorHook<_SERVICE>(actorContext);

export default function Actors({ children }: { children: ReactNode }) {
  const { identity } = useInternetIdentity();

  return (
    <ActorProvider<_SERVICE> canisterId={canisterId} context={actorContext} identity={identity} idlFactory={idlFactory}>
      {children}
    </ActorProvider>
  );
}
