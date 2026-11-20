# niri-atomic-nephrite
# Fedora bootc image with Niri and the Noctalia shell.
#
# Build via ./build.sh (it passes BASE_IMAGE from build.env).
# Manual build:
#   sudo podman build --build-arg "BASE_IMAGE=${BASE_IMAGE}" -t "${LOCAL_IMAGE}" .

# BASE_IMAGE intentionally has no default: the build must fail instead of
# silently producing an image from an unintended base. Pass it via build.sh
# (value comes from build.env).
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN set -eux; \
    dnf5 -y install \
        NetworkManager \
        NetworkManager-wifi \
        NetworkManager-tui \
        iw \
        upower \
        power-profiles-daemon \
        linux-firmware \
        wpa_supplicant \
        bluez \
        flatpak \
        toolbox \
        nautilus \
        niri \
        noctalia \
        alacritty \
        xdg-desktop-portal-gnome \
        xdg-desktop-portal-gtk \
        mate-polkit \
        greetd \
        tuigreet \
        wl-clipboard \
        brightnessctl \
        playerctl \
        pipewire \
        pipewire-pulseaudio \
        wireplumber \
        dejavu-sans-fonts \
        google-noto-sans-fonts \
        google-noto-emoji-fonts \
        mesa-dri-drivers \
        mesa-vulkan-drivers \
        libva-utils \
        plymouth \
        plymouth-theme-spinner \
        xdg-user-dirs \
        which \
        zsh \
        qt6-qtwayland \
        qt5-qtwayland \
        gvfs \
        vim \
        git \
        glibc-langpack-pt \
        glibc-langpack-en \
        adwaita-icon-theme \
        ffmpeg-free \
        tmux \
        xwayland-satellite \
        ddcutil \
        libheif; \
    dnf5 clean all;

# Configuration files
COPY files/system/ /

# Services
RUN set -eux; \
    systemctl enable \
        greetd.service \
        NetworkManager.service \
        bluetooth.service; \
    systemctl set-default graphical.target; \
    plymouth-set-default-theme spinner;

# Regenerate the initramfs for every installed kernel
RUN set -eux; \
    mkdir -p /var/roothome; \
    for kernel in /usr/lib/modules/*/; do \
        kver="$(basename "${kernel}")"; \
        DRACUT_NO_XATTR=1 dracut \
            --kver "${kver}" \
            --force \
            --add ostree \
            --no-hostonly \
            --reproducible \
            "/usr/lib/modules/${kver}/initramfs.img"; \
        chmod 0600 "/usr/lib/modules/${kver}/initramfs.img"; \
    done

RUN set -eux; \
    rm -rf /run/dnf /run/selinux-policy; \
    find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} +; \
    rm -rf /var/cache/* /var/log/dnf5.log*


RUN bootc container lint
