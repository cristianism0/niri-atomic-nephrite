<div align="center">

# niri-atomic-nephrite

**A Fedora Atomic desktop built around [Niri](https://github.com/YaLTeR/niri), the scrollable-tiling Wayland compositor.**

Immutable base. Atomic updates. One-command rollback.

[![build](https://github.com/cristianism0/niri-atomic-nephrite/actions/workflows/build.yml/badge.svg)](https://github.com/cristianism0/niri-atomic-nephrite/actions/workflows/build.yml)
[![license](https://img.shields.io/github/license/cristianism0/niri-atomic-nephrite)](LICENSE)

**English** · [Português (Brasil)](docs/README_ptBR.md)

</div>

> NOTE: The current build (not tested on real machines) does not work since niri cannot start the session.

## What is this?

`niri-atomic-nephrite` is a personal, custom operating system image. It takes Fedora's image-based (bootc / rpm-ostree) foundation and adds a Niri desktop session with the Noctalia shell, ready to boot.

Because it is image-based, the whole system is built in CI, shipped as a single container image, and swapped in atomically. If an update misbehaves, the previous version is one reboot away.

> **Status: experimental.** Built for my own machines and shared as-is. Expect rough edges, and try it in a VM first.

## Highlights

- **Niri desktop**: scrollable-tiling Wayland compositor with the Noctalia shell, Alacritty and Fuzzel.
- **Atomic by design**: updates replace the whole system image; nothing is half-installed.
- **Rollback built in**: the previous deployment stays in the boot menu.
- **Built in the open**: every change goes through GitHub Actions, and images are signed with [cosign](https://github.com/sigstore/cosign).
- **Flatpak-first apps**: Firefox and Loupe preinstalled; everything else is a Flatpak away.
- **Small, readable recipe**: the entire definition lives in [`recipes/recipe.yml`](recipes/recipe.yml).

## What's inside

| Layer | Contents |
|---|---|
| Base | `fedora-bootc`, Fedora 45 (current version - check recipe) |
| Compositor and shell | Niri, Noctalia |
| Terminal | Alacritty |
| Login | greetd with tuigreet |
| Portals and helpers | xdg-desktop-portal (GNOME and GTK), MATE polkit, wl-clipboard, brightnessctl, playerctl |
| Shell | zsh, bash |
| Apps (Flatpak) | Firefox, Loupe |

>The recipe is where the real packages installed are listed; this table may lag behind it.

## Installation

There is **no ISO**. Install any Fedora Atomic edition (Silverblue, Kinoite, ...) first, then rebase onto this image:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/cristianism0/niri-atomic-nephrite:latest
systemctl reboot
```

Notes:

- This command **does not verify the image signature**. The public key is in [`cosign.pub`](cosign.pub) if you want to verify manually with `cosign verify`.
- The package on GHCR must be public for the rebase to work without credentials.
- Your home directory and user Flatpaks are preserved.

### Updating

```bash
sudo rpm-ostree upgrade
systemctl reboot
```

### Rolling back

```bash
sudo rpm-ostree rollback
systemctl reboot
```

## Building it yourself

```bash
bluebuild validate recipes/recipe.yml
bluebuild build recipes/recipe.yml
```

To publish your own fork:

1. Fork this repository.
2. Generate a signing key pair with `cosign generate-key-pair` (leave the password empty).
3. Add the private key as the repository secret `SIGNING_SECRET` and commit `cosign.pub`. **Never commit `cosign.key`.**
4. Push. The workflow builds, signs and publishes the image to GHCR.

### Repository layout

```
.
├── recipes/recipe.yml      # image definition (base, packages, modules)
├── files/system/           # files copied into / on the image
├── cosign.pub              # public signing key
└── .github/workflows/      # CI build and publish
```

## FAQ

**Is there an ISO?**
No. Installing from an existing Fedora Atomic system and rebasing is the supported path.

**Is it ready for daily use?**
It is my daily setup, but it is unstable by nature. Test in a VM before trusting it.

**Can I change the package list?**
Yes. Edit `recipes/recipe.yml`, push, and let CI build the new image.

## License

The code in this repository (recipes, scripts and configuration) is released under the license Apache 2.0 in [`LICENSE`](LICENSE).

The resulting image bundles third-party software, each under its own license, as provided by Fedora and any enabled repositories. This repository's license does not apply to those components.

## Credits

- [BlueBuild](https://blue-build.org) for the tooling and template.
- [Fedora Project](https://fedoraproject.org) for the base.
- [Niri](https://github.com/YaLTeR/niri) and Noctalia for the desktop.
