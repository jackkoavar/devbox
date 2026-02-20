# Cloud Init Helper for macOS (VMWare Fusion)

Small helper project to run disposable cloud images on macOS using VMWare Fusion. It provides scripts and guidance to build a cloud-init seed ISO, convert cloud images to VMDK, and boot throwaway VMs that register with Tailscale for easy SSH access.

Contents
- Overview
- Files
- Prerequisites
- Prepare
- Per-environment steps
- Manual checks
- Troubleshooting
- Tips & improvements

Overview
--------
- Use a Debian/Ubuntu cloud image and a cloud-init seed ISO to automatically set up provision a VM with preinstalled tooling.
- Convert raw/cloud images to VMDK for VMWare Fusion.
- Use Tailscale to handle networking and SSH access to the VM.

Files
-----
- `scripts/build_iso.sh` — generates `seed.iso` from templates and `.env` values.
- `scripts/convert_vmdk.sh` — converts a raw image to a VMDK for Fusion.
- `user-data.tmp` — cloud-init template used by `build_iso.sh` (contains placeholders).

Prerequisites (one-time on your Mac)
-----------------------------------
- macOS with Homebrew and VMWare Fusion
- Install QEMU and cdrtools:

```sh
brew install qemu
brew install cdrtools
```

- Ensure you have an SSH key (example):

```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Prepare
-------
1. Get a Tailscale auth key from https://login.tailscale.com/admin/settings/keys.
2. Create a `.env` file in the project root with at least:

```env
TAILSCALE_AUTH_KEY=your_tailscale_auth_key_here
SSH_PUBKEY="$(cat ~/.ssh/id_ed25519.pub)"
VM_HOSTNAME="devbox-vm"
```

3. (Optional) Add the SSH config snippet below to `~/.ssh/config` to simplify connections to disposable VMs:

```sh
# Match disposable VM hostnames (example)
Host devbox-vm*
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null
	LogLevel ERROR
	ForwardAgent yes
```

Per-environment steps (every new VM)
----------------------------------
Run `make`. The makefile generates the `.env` file, from which you fill in the parameter details.
Two files are generated:
- `seed.iso`
- a `.vmdk` file, which is your cloud init hard disk

3. Create a new VM in VMWare Fusion

- In Fusion: Create a new virtual machine and configure its disk to use the generated `.vmdk`.
- Attach the `seed.iso` to the VM's CD/DVD (SATA) drive.
- Ensure the VM has network access on first boot (so Tailscale can register).

4. Boot the VM

- Cloud-init will read `seed.iso` and configure users, packages, and the Tailscale auth key.
- Wait for cloud-init to finish (first boot provisioning can take a couple minutes).

5. Find the VM on Tailscale

- Check the Tailscale admin console or your Tailscale client to find the VM's IP or hostname.

6. SSH into the VM

```sh
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh -A devuser@<tailscale-ip-or-hostname>
```

Manual checks after deployment
------------------------------
- Confirm the machine shows in the Tailscale admin console.
- Confirm `devuser` exists and that your SSH key is present in `~/.ssh/authorized_keys`.
- Confirm `ForwardAgent` works if you need GitHub access from inside the VM.

Troubleshooting
---------------
- cloud-init didn't apply: make sure the ISO is attached and labelled `cidata` and that the VM had network access during first boot.
- VM not in Tailscale: verify `TAILSCALE_AUTH_KEY` in `.env` and that Tailscale was able to start and reach the internet.
- Permission errors building ISO: ensure `cdrtools` is installed and that `build_iso.sh` is executable (`chmod +x scripts/build_iso.sh`).

Tips
---------------
- Add a friendly `~/.ssh/config` entry for the VM once you know its Tailscale host or IP:

```sh
Host devvm
	HostName <tailscale-host-or-ip>
	User devuser
	ForwardAgent yes
```

- To keep hosts disposable, reuse the same `user-data.tmp` and `.env` values and recreate VMs as needed.
- Use a new unused tailscale key per VM boot

References
----------
- Tailscale keys: https://login.tailscale.com/admin/settings/keys
- Debian cloud images: https://cdimage.debian.org/images/cloud/
