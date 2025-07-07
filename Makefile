NIXNAME := "minerva"

bootstrap:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Bootstrap requires sudo privileges. Please run 'sudo make bootstrap'."; \
		exit 1; \
	fi

	xcode-select --install || echo "Xcode command line tools already installed"
	softwareupdate --install-rosetta --agree-to-license

switch:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
