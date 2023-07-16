{pkgs, ...}:
with pkgs; {
  toolchains = rec {
    cc = [clang-tools clang];

    devops =
      py
      ++ tfm
      ++ golang
      ++ k8s
      ++ sys
      ++ [
        yaml-language-server
        pre-commit
      ];

    golang = [go go2nix gotools gopls];

    k8s = [kubectl kubectx k9s kubernetes-helm minikube];

    node = [nodejs yarn] ++ (with nodePackages; [pnpm]);

    py = [
      python310
      nodePackages.pyright
      python310Packages.requests
      python310Packages.beautifulsoup4
      poetry
    ];

    rust = [
      rustup
      pkg-config
      rust-analyzer
    ];

    sys = [dig];

    tfm = [terraform terragrunt terraform-ls tflint];
  };
}
