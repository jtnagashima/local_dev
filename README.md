# Objectives:
[] Using Terraform, create a local kubernetes cluster using the Podman engine.
[] Create manifests and apply them to the kubernetes cluster.

# Setup
1. Install homebrew: https://brew.sh/
2. Install git and just via homebrew: `brew install git just` 
3. Clone the repo: `git clone git@github.com:jtnagashima/local_dev.git`
4. Run `just setup` from the project root. Setup will:
    - install any missing dependencies: mainly Podman for now.
    - symlink scripts in Scripts/ to `/usr/local/bin/`. Commands are run using containers instead of local binaries.
    - start the podman VM instance and run terraform to create a kuberentes (KinD) cluster (it will ask for user prompt before doing so)
    - export the kubeconfig file
    - give you instructions on how to set the env var $KUBECONFIG to the location of the kubeconfig file

At the end of the setup, you should be able to have a working cluster and `kubectl get nodes`.

# Depenedencies
- Homebrew
- Just
- Git
- Podman
