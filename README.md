# The IC GameKit

## Design and GameKit architecture

The IC GameKit is drop-in solution for adding achievements, game and user data saves. The GameKit consists of 2 main canisters, a back-end canister that persists all the data associated with the achievements, game saves etc and the front-end that is a react web app that can be used to manage this data. Additionally a demo game canister is included that shows how a typical game canister can make use of the GameKit. All data relevant data is held in stable memory and hence will persist across upgrades.

Multiple games can be created inside a single GameKit back-end canister hence it is envisaged that a game studio may only need one canister deployed to cater for all their games. Additionally, multiple admins can be added to the GameKit canister to enable easy management across a team. Each game that wants to utilise the GameKit should have its own canister and that canister should be added as an admin too.

The front-end react web app enables you to:
- Add / remove admins
- Create a new game
- Specify achievements associated with that game
- Save game data viewing
- User data viewing

### Game Specific Data
Data can be stored against each game set up in the IC GameKit. For instance you may want to have a list of pets that can be randomly earned in the game and that you can add to easily without redeploying your game. You can set up multiple key/value pairs, both are held as strings so you can store your list of pets in json format and retrieve them in-game as needed. This would look like:
```bash
# Pets
Key       Value
rewards  { "pets" :
[
  { "name": "Mouse", "url" : "https://roguefoxguild.mypinata.cloud/ipfs/QmXXba3DLd8y6DyM7rri1aQap5p8LTtcTaz7TLN4wS846B" },
  { "name": "Cat", "url" : "https://roguefoxguild.mypinata.cloud/ipfs/QmNPhRKoQPppkQ6GxbiUniyyUkjY9Tht7Vyn1pvQ1DDEiY" },
  { "name": "Dog", "url" : "https://roguefoxguild.mypinata.cloud/ipfs/QmecJRNGz44hvvMQLayQH6tDM2BQgYP7dDLGprMbd4o6Kt" }
]
          }
```
### Player Specific Data
This is where you can store data about a player that is consistent across all your games. This will most likely be profile data like social links, display name etc.

### Game Save Data
Specific to a player within a game, game saves can be used to store the progress that a player has made in a particular game.

## Admins
Only Admins can create games and add achievements. You can add a wallet prinicipal as an admin with:

```bash
# Adds a new Admin
dfx canister call ic-gamekit-backend addAdmin '(principal "ns7tc-nfpjp-wggqg-o5bag-feolr-dlb5q-3zcdz-vcavb-hyw2u-ypiwj-7ae")'
```
The deploying identity automatically becomes an Admin.

## Installing the project locally

Install dfx by following [these](https://internetcomputer.org/docs/current/developer-docs/getting-started/install/) instructions.

```bash
# Install mops (npm i -g ic-mops) , the motoko package manager and install dependencies with
mops install
# Install all other dependencies with
npm install
```

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.

If you have made changes to your backend canister, you can generate a new candid interface with

```bash
npm run generate
```

at any time. This is recommended before starting the frontend development server, and will be run automatically any time you run `dfx deploy`.

If you are making frontend changes, you can start a development server with

```bash
npm start
```

Which will start a server at `http://localhost:8080`, proxying API requests to the replica at port 4943.


# Testing
You will need to run the following command to add the test Admin user before running the tests.

```bash
# Adds a test Admin
dfx canister call ic-gamekit-backend addAdmin '(principal "rwbxt-jvr66-qvpbz-2kbh3-u226q-w6djk-b45cp-66ewo-tpvng-thbkh-wae")'
```
Then run the tests with:
```bash
# Runs test
npm run test
```

### Unity Login - The unity-login folder
To enable logging in to a Unity game via Internet Identity, I have included an example login page. A Unity application can load this login page into an iframe and when the login process is complete, this page will create a delegation chain that it passes to the Unity application via a postMessage. To enable testing in the Unity Editor, this page also supports sending the delegation chain via websockets. An example Unity game that utilises this can be found [here](https://github.com/morganpage/ic-clicker-game). For more information on delegtaion chains checkout the official ICP documentation [here](https://internetcomputer.org/docs/current/references/ii-spec#introduction).

### Note on frontend environment variables

If you are hosting frontend code somewhere without using DFX, you may need to make one of the following adjustments to ensure your project does not fetch the root key in production:

- set`DFX_NETWORK` to `ic` if you are using Webpack
- use your own preferred method to replace `process.env.DFX_NETWORK` in the autogenerated declarations
  - Setting `canisters -> {asset_canister_id} -> declarations -> env_override to a string` in `dfx.json` will replace `process.env.DFX_NETWORK` with the string in the autogenerated declarations
- Write your own `createActor` constructor
