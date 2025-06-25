 TrustChain-DID

**TrustChain-DID** is a Clarity smart contract for decentralized identity (DID) registration, resolution, and trust attestation on the Stacks blockchain. It provides a trustless framework to establish and manage self-sovereign identities anchored in the Bitcoin-secured Stacks network.

---

 Features

-  Register and manage DIDs (Decentralized Identifiers)
-  Link metadata and public keys to DIDs
-  Allow trusted parties to issue trust attestations
-  Resolve identity data via read-only functions
-  Build a web-of-trust on-chain

---

 Contract Overview

| Function Name         | Access        | Description                                      |
|----------------------|---------------|--------------------------------------------------|
| `register-did`       | Public        | Register a unique DID for the caller            |
| `update-did-meta`    | Public        | Update metadata (e.g., public key, profile CID) |
| `attest-did`         | Public        | Attest trust for another DID                    |
| `resolve-did`        | Read-only     | Get metadata for a DID                          |
| `get-attestations`   | Read-only     | View trust attestations issued by a user        |

---

