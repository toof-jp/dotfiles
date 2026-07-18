# git-worktree-runner (`git gtr`) — not in nixpkgs, so packaged here.
# Pure bash; the scripts locate their lib/ relative to the resolved script
# path, so the whole tree is installed and bin/ is symlinked.
{ stdenvNoCC, fetchFromGitHub, bash }:

stdenvNoCC.mkDerivation rec {
  pname = "git-worktree-runner";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "coderabbitai";
    repo = "git-worktree-runner";
    tag = "v${version}";
    hash = "sha256-KZsAx80sScdH8AKCFgmQ6gdVViaN3h1VHiE/pSoCm8o=";
  };

  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/git-worktree-runner $out/bin
    cp -r bin lib adapters templates $out/share/git-worktree-runner/
    ln -s $out/share/git-worktree-runner/bin/git-gtr $out/bin/git-gtr
    ln -s $out/share/git-worktree-runner/bin/gtr $out/bin/gtr

    install -Dm644 completions/_git-gtr $out/share/zsh/site-functions/_git-gtr

    runHook postInstall
  '';

  meta.description = "Git worktree management (git gtr)";
}
