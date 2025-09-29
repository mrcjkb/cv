# Marc Jakobi – Detailed CV

This repository contains the LaTeX source of my detailed curriculum vitae.

Focus Areas:

- Distributed & functional backend systems (Haskell, Nix, Rust)
- Virtual power plant, Home energy management, IoT device data pipelines
- Reproducible infra & deployment (Nix/NixOS, Hydra CI)
- Integration / property testing
- Open source maintenance (NixOS, Neovim plugins, Lux package manager)
- Renewable energy simulation & control (PV, batteries, heat pumps, sector coupling)

For a short CV or specific format requests, [feel free to reach out](https://mrcjkb.dev/contact.html).

## Build

```bash
nix develop 
# or
direnv allow

xelatex <cv>.tex

# or
nix build # outputs into `result/cv_en_detailed.pdf`
```
