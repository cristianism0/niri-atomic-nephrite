<div align="center">

# fedora-niri-atomic-nephrite

**A Fedora Atomic desktop built around [Niri](https://github.com/YaLTeR/niri).**

[![build](https://github.com/cristianism0/fedora-niri-atomic-nephrite/actions/workflows/build.yml/badge.svg)](https://github.com/cristianism0/fedora-niri-atomic-nephrite/actions/workflows/build.yml)
[![license](https://img.shields.io/github/license/cristianism0/fedora-niri-atomic-nephrite)](LICENSE)

**English** · [Português (Brasil)](docs/README_ptBR.md)

</div>

## What is this?

`fedora-niri-atomic-nephrite` is a personal, custom operating system image. It builds on Fedora's image-based foundation ([bootc](https://github.com/bootc-dev/bootc) / [rpm-ostree](https://coreos.github.io/rpm-ostree/)) and adds a ready-to-boot [Niri](https://github.com/YaLTeR/niri) session with the [Noctalia](https://github.com/noctalia-dev/noctalia-shell) shell.

Because it is image-based, the whole system is built in CI, shipped as a single container image, and swapped in atomically. If an update misbehaves, the previous version is one reboot away.

> **Status: experimental.** Built for my own machines and shared as-is. Expect rough edges, and try it in a VM first.

## Highlights

- **Niri desktop**: a scrollable-tiling Wayland compositor, with the Noctalia shell and [Alacritty](https://alacritty.org).
- **Atomic by design**: updates replace the whole system image; nothing is half-installed.
- **Rollback built in**: the previous deployment stays in the boot menu.
- **Built in the open**: every change goes through GitHub Actions, and images are signed with [cosign](https://github.com/sigstore/cosign).
- **Flatpak-first apps**: Firefox and Loupe come preinstalled; everything else is a [Flatpak](https://flatpak.org) away.
- **Small, readable Containerfile**: the entire definition lives in [`Containerfile`](Containerfile).

## What's inside

| Layer | Contents |
|---|---|
| Base | [`fedora-bootc`](https://docs.fedoraproject.org/en-US/bootc/), Fedora 45 (current version: see [`build.env`](build.env)) |
| Compositor and shell | Niri, Noctalia |
| Terminal | Alacritty |
| Login | [greetd](https://sr.ht/~kennylevinsen/greetd/) with [tuigreet](https://github.com/apognu/tuigreet) |
| Portals and helpers | xdg-desktop-portal (GNOME and GTK), MATE polkit, wl-clipboard, brightnessctl, playerctl |
| Shell | bash, zsh |
| Apps (Flatpak) | Firefox, Loupe |

> The [`Containerfile`](Containerfile) is the source for installed packages; this table may lag behind it.

## Installation

### From an existing Fedora Atomic system (rebase)

Install any Fedora Atomic edition first (Silverblue, Kinoite, ...), then rebase onto this image:

```bash
sudo bootc switch ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest
systemctl reboot
```

On systems that only have the classic rpm-ostree interface, the equivalent is:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest
systemctl reboot
```

Notes:

- These commands **do not verify the image signature**. The public key is in [`cosign.pub`](cosign.pub) if you want to verify it manually with `cosign verify`.
- The package on GHCR must be public for the rebase to work without credentials.
- Your home directory and user Flatpaks are preserved.

### From scratch with the Anaconda installer ISO

**EXPERIMENTAL**:You can also install on bare metal or in a VM without a pre-existing Fedora Atomic system. Build the installer ISO locally:

```bash
./build.sh
```

The ISO is written to `output/` and boots [Anaconda](https://github.com/rhinstaller/anaconda) with this image as the payload. The installer is interactive and includes the usual **user creation** screen, so you can create your account (and set a root password) during installation. The installed system then tracks `ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest` for updates.

Notes:

- The ISO is **not published**. It is built locally because the full image is embedded for an offline install.
- `build.sh` needs `image-builder`, rootful Podman and `sudo`.
- The installer and ISO are only needed to install from scratch. Updating an installed system uses `bootc` / `rpm-ostree` as usual.
- The ISO build follows the [image-builder guide for bootc generic ISOs](https://osbuild.org/docs/developer-guide/projects/image-builder/bootc-generic-iso/).

### Updating

```bash
sudo bootc upgrade
systemctl reboot
```

Or, with the classic interface: `sudo rpm-ostree upgrade`.

### Rolling back

```bash
sudo bootc rollback
systemctl reboot
```

Or, with the classic interface: `sudo rpm-ostree rollback`.

## Building it yourself

The image is a plain bootc container image, so any OCI builder works. `BASE_IMAGE` intentionally has no default: the build fails instead of silently using an unintended base. Its value comes from [`build.env`](build.env):

```bash
source build.env
sudo podman build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    -t "${TARGET_IMAGE}" .
```

Then push it to a registry the target machine can reach.

To build the desktop image **and** the Anaconda installer ISO in one go:

```bash
./build.sh
```

`build.sh` builds the image, builds the installer container from [`installer/Containerfile`](installer/Containerfile), and runs `image-builder` with the `generic-iso` image type. The ISO lands in `output/`.

To publish your own fork:

1. Fork this repository.
2. In [`build.env`](build.env), change `REGISTRY` (and the image name, if you like) to your own.
3. Generate a signing key pair with `cosign generate-key-pair` (leave the password empty).
4. Add the private key as the repository secret `SIGNING_SECRET` and commit `cosign.pub`. **Never commit `cosign.key`.**
5. Push. The workflow builds, signs and publishes the image to GHCR.

### Repository layout

```
.
├── Containerfile            # image definition (base, packages, services)
├── installer/
│   └── Containerfile        # Anaconda installer image used for the ISO
├── build.sh                 # builds the image and the installer ISO
├── build.env                # versions, image names, ISO label and derived values
├── files/system/            # files copied into / on the image
├── cosign.pub               # public signing key
├── LICENSE                  # Apache 2.0
└── .github/workflows/       # CI build and publish
```

## FAQ

**Is there an ISO?**
Not a published one, but [`build.sh`](build.sh) builds one locally with Anaconda, including the user creation screen. Installing from an existing Fedora Atomic system with `bootc switch` remains the simplest path.

**Can I change the package list?**
Yes. Edit the `Containerfile`, push, and let CI build the new image.

## License

The code in this repository (Containerfile, scripts and configuration) is released under the Apache 2.0 license in [`LICENSE`](LICENSE).

The resulting image bundles third-party software, each under its own license, as provided by Fedora and any enabled repositories. This repository's license does not apply to those components.

## Credits

- [Fedora Project](https://fedoraproject.org) for the base.
- [Niri](https://github.com/YaLTeR/niri) and [Noctalia](https://github.com/noctalia-dev/noctalia-shell) for the desktop.
- [osbuild / image-builder](https://osbuild.org) for the installer ISO tooling.
