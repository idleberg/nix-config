NIXNAME := "minerva"

bootstrap:
	xcode-select --install || echo "Xcode command line tools already installed"
	softwareupdate --install-rosetta --agree-to-license

switch:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
