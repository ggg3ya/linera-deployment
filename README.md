


## Description
Linera Link is a web3 application that combines the power of blockchain technology with the simplicity of social connections. The platform empowers creators, supports their work, and makes it easier than ever to give and receive donations.

Share link – get support.

## Deployment
- Install [Rust](https://www.rust-lang.org/tools/install), [Linera](https://linera.dev/) and [Node.JS](https://nodejs.org/) on your local machine.
- Start local network and initialize local variables `LINERA_WALLET` and `LINERA_STORAGE`:
```bash
linera net up
```
- Clone this repository, then run deploy script:
```bash
./simple.sh <working directory>
```
E.g. `./simple.sh /tmp/.tmpguVRWj`

- Start frontend:
```bash
cd frontend && npm install && npm run dev
```
Enjoy.
