```sh
# Install the Nix package manager
sh <(curl -L https://nixos.org/nix/install)

# Install Nix Darwin
nix main nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ./flake.nix 
```
