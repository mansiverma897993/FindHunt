# FindHunt

FindHunt is a demo-friendly crypto personal-finance dashboard: **trading-style charts**, **crypto SIP** projections, **bills & subscriptions** templates (streaming, SaaS, GPT, rent, school fees), and **Hela Testnet** wallet flows (vault, budget, subscriptions, mock LP). The UI runs fully **without** contracts; on-chain features activate after you deploy and set `NEXT_PUBLIC_*` addresses.

---

## Requirements

- **Node.js** 20+ (LTS recommended)
- **npm** 10+
- A wallet with **Hela Testnet** HLUSD for gas (from the official faucet)
- Optional: **PostgreSQL** if you use Prisma-backed APIs later

---

## Quick start (local UI demo)

```bash
git clone <your-repo-url> findhunt
cd findhunt
npm install
cd contracts && npm install && cd ..
npm run dev
```

Open **http://localhost:3000**.

Charts, SIP calculator, and bill templates work without contracts. Wallet connect targets **Hela Testnet** (chain ID `666888`).

---

## Hela Testnet reference

| Item | Value |
|------|--------|
| **Chain ID** | `666888` |
| **RPC** | `https://testnet-rpc.helachain.com` |
| **Explorer** | https://testnet-blockexplorer.helachain.com |
| **Faucet** | https://testnet-faucet.helachain.com/ |

Add the network in MetaMask (or use RainbowKit’s network switcher) using the above RPC and chain ID.

---

## Deploy smart contracts to Hela Testnet

Contracts live in `contracts/` (Hardhat + Solidity 0.8.20).

### 1. Fund a deployer wallet

Create or use an account, export its **private key** (with `0x` prefix), and send it **testnet HLUSD** from the faucet.

### 2. Configure environment (project root)

Create **`.env.local`** in the **repository root** (same folder as `package.json`):

```env
# Required for deploy (never commit this file)
DEPLOYER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Optional — defaults to public RPC if omitted
HELA_TESTNET_RPC_URL=https://testnet-rpc.helachain.com
```

Hardhat loads `.env` and **`.env.local`** from the project root.

### 3. Compile

```bash
npm run contracts:compile
```

### 4. Deploy

```bash
npm run deploy:hela
```

On success you get:

- **`deployed-addresses.json`** — JSON with all addresses  
- **`hela-contracts.env`** — ready-to-paste `NEXT_PUBLIC_*` lines for Next.js  

The script also prints **direct block explorer links** for each contract, for example:

`https://testnet-blockexplorer.helachain.com/address/<CONTRACT_ADDRESS>`

### 5. Point the frontend at your deployment

Append the contents of **`hela-contracts.env`** to **`.env.local`**, then add:

```env
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_reown_walletconnect_project_id
```

Get a project ID from [Reown Cloud](https://cloud.reown.com) (reduces WalletConnect console warnings).

Restart the dev server:

```bash
npm run dev
```

---

## Environment variables (summary)

| Variable | When |
|----------|------|
| `DEPLOYER_PRIVATE_KEY` | Deploy only (root `.env.local`) |
| `HELA_TESTNET_RPC_URL` | Optional custom RPC |
| `NEXT_PUBLIC_TREASURER_VAULT` | After deploy |
| `NEXT_PUBLIC_STRATEGY_EXECUTOR` | After deploy |
| `NEXT_PUBLIC_BUDGET_CONTROLLER` | After deploy |
| `NEXT_PUBLIC_SUBSCRIPTION_MANAGER` | After deploy |
| `NEXT_PUBLIC_MOCK_LP_POOL` | After deploy |
| `NEXT_PUBLIC_HELA_RPC_URL` | Optional; wallet RPC |
| `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` | Recommended for WalletConnect |
| `OPENAI_API_KEY` | Optional; AI agent uses heuristics if unset |
| `DATABASE_URL` | Optional; Prisma / PostgreSQL |

See **`.env.example`** in the repo root for a template.

---

## Production build

```bash
npm run build
npm start
```

---

## Deploy the **website** (Vercel / Netlify / etc.)

1. Push the repo to GitHub/GitLab.
2. Create a project in Vercel (or similar), root directory = repo root.
3. Set the same **`NEXT_PUBLIC_*`** and **`NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`** in the host’s environment UI.
4. Build command: `npm run build`, output: Next.js default.

Your **public app URL** will be whatever the host assigns (e.g. `https://findhunt.vercel.app`). **Contract “links”** are always on the Hela explorer:  
`https://testnet-blockexplorer.helachain.com/address/<address>`.

---

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Next.js dev server |
| `npm run build` | Production build |
| `npm run contracts:compile` | Hardhat compile |
| `npm run contracts:test` | Hardhat tests |
| `npm run deploy:hela` | Deploy all contracts to Hela Testnet |

---

## Project layout

- `src/app/` — Next.js App Router pages (dashboard, trading, SIP, bills, etc.)
- `src/components/` — UI, layout, charts, FindHunt logo
- `src/lib/` — Wagmi chain config, ABIs, helpers
- `contracts/` — Hardhat project and Solidity sources
- `prisma/` — Optional PostgreSQL schema

---

## Security

- Never commit **private keys** or **`.env.local`**.
- `deployed-addresses.json` and `hela-contracts.env` are gitignored by default; they only contain **public** contract addresses.

