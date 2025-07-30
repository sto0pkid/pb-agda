# Agda Proof Checker Worker

This repository defines a minimal containerized proof checker for Agda-based proofs, intended to be run as part of a larger proof bounty platform.

It is designed to:
- Include a self-contained Agda runtime with the standard library
- Run proofs in a sandboxed container environment
- Accept dynamically-mounted directories containing `Goal.agda`, `Proof.agda`, and context files
- Validate proofs using Agda with safe and deterministic settings

---

## 🔧 Project Structure

├── docker/
│ ├── check-proof # Entrypoint script for checking a proof
│ ├── check-disproof # Entrypoint script for checking a disproof
│ ├── Check.agda # Imports Goal.agda + Proof.agda to validate proof
│ └── CheckNeg.agda # Imports Goal.agda + Proof.agda to validate disproof
├── docker.nix # Builds the container image using Nix
└── README.md # You're here

---

## 🚀 Building the Docker Image (via Nix)

You must have [Nix](https://nixos.org) installed.

```bash
nix build .#dockerImage
```

This will build a Docker image named agda-proof-checker:latest with Agda, standard library, and your custom check script included.

To load it into Docker:

```bash
docker load < result
```

## 🚀 Run it

Accepted proof:

```bash
docker run --rm -v ./example/accepted:/work/Input agda-proof-checker proof
echo $? # 0
```

Rejected proof:
```bash
docker run --rm -v ./example/rejected:/work/Input agda-proof-checker proof
echo $? # 1
```

Accepted disproof:
```bash
docker run --rm -v ./example/disproof:/work/Input agda-proof-checker disproof
echo $? # 0
```