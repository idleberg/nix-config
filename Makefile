bootstrap:
	xcode-select --install || echo "Xcode command line tools already installed"
	softwareupdate --install-rosetta --agree-to-license
