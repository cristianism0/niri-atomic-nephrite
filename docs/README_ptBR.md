<div align="center">

# fedora-niri-atomic-nephrite

**Um desktop Fedora Atomic construído em torno do [Niri](https://github.com/YaLTeR/niri).**

[![build](https://github.com/cristianism0/fedora-niri-atomic-nephrite/actions/workflows/build.yml/badge.svg)](https://github.com/cristianism0/fedora-niri-atomic-nephrite/actions/workflows/build.yml)
[![licença](https://img.shields.io/github/license/cristianism0/fedora-niri-atomic-nephrite)](../LICENSE)

[English](../README.md) · **Português (Brasil)**

</div>

## O que é?

`fedora-niri-atomic-nephrite` é uma imagem de sistema operacional pessoal e customizada. Ela parte da base baseada em imagem do Fedora ([bootc](https://github.com/bootc-dev/bootc) / [rpm-ostree](https://coreos.github.io/rpm-ostree/)) e acrescenta uma sessão [Niri](https://github.com/YaLTeR/niri) com o shell [Noctalia](https://github.com/noctalia-dev/noctalia-shell), pronta para iniciar.

Por ser baseada em imagem, o sistema inteiro é construído na CI, distribuído como uma única imagem de container e trocado de forma atômica. Se uma atualização der problema, a versão anterior está a um reboot de distância.

> **Status: experimental.** Feita para as minhas máquinas e compartilhada como está. Espere arestas e teste primeiro em uma VM.

## Destaques

- **Desktop Niri**: compositor Wayland de tiling com rolagem, com o shell Noctalia e o [Alacritty](https://alacritty.org).
- **Atômica por design**: as atualizações substituem a imagem inteira; nada fica pela metade.
- **Rollback embutido**: a implantação anterior permanece no menu de boot.
- **Construída às claras**: toda mudança passa pelo GitHub Actions, e as imagens são assinadas com [cosign](https://github.com/sigstore/cosign).
- **Apps via Flatpak**: Firefox e Loupe vêm pré-instalados; o resto está a um [Flatpak](https://flatpak.org) de distância.
- **Containerfile pequeno e legível**: toda a definição está no [`Containerfile`](../Containerfile).

## O que há dentro

| Camada | Conteúdo |
|---|---|
| Base | [`fedora-bootc`](https://docs.fedoraproject.org/en-US/bootc/), Fedora 45 (versão atual: veja o [`build.env`](../build.env)) |
| Compositor e shell | Niri, Noctalia |
| Terminal | Alacritty |
| Login | [greetd](https://sr.ht/~kennylevinsen/greetd/) com [tuigreet](https://github.com/apognu/tuigreet) |
| Portais e auxiliares | xdg-desktop-portal (GNOME e GTK), polkit do MATE, wl-clipboard, brightnessctl, playerctl |
| Shell | bash e zsh |
| Apps (Flatpak) | Firefox, Loupe |

> O [`Containerfile`](../Containerfile) é a base para os pacotes instalados; esta tabela pode ficar defasada em relação a ele.

## Instalação

### A partir de um Fedora Atomic existente (rebase)

Instale primeiro qualquer edição do Fedora Atomic (Silverblue, Kinoite, ...) e depois faça o rebase para esta imagem:

```bash
sudo bootc switch ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest
systemctl reboot
```

Em sistemas que só têm a interface clássica do rpm-ostree, o equivalente é:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest
systemctl reboot
```

Observações:

- Esses comandos **não verificam a assinatura** da imagem. A chave pública está em [`cosign.pub`](../cosign.pub), caso queira verificar manualmente com `cosign verify`.
- O pacote no GHCR precisa estar público para o rebase funcionar sem credenciais.
- Seu diretório pessoal e os Flatpaks de usuário são preservados.

### Do zero, com a ISO do instalador Anaconda

**EXPERIMENTAL**: Também é possível instalar em bare metal ou em uma VM sem ter um Fedora Atomic já instalado. Construa a ISO do instalador localmente:

```bash
./build.sh
```

A ISO é gerada em `output/` e inicia o [Anaconda](https://github.com/rhinstaller/anaconda) com esta imagem como payload. O instalador é interativo e inclui a tela habitual de **criação de usuário**, então você pode criar sua conta (e definir a senha de root) durante a instalação. Depois disso, o sistema instalado passa a acompanhar `ghcr.io/cristianism0/fedora-niri-atomic-nephrite:latest` para atualizações.

Observações:

- A ISO **não é publicada**. Ela é construída localmente porque a imagem inteira é embutida para permitir uma instalação offline.
- O `build.sh` precisa de `image-builder`, Podman rootful e `sudo`.
- O instalador e a ISO só são necessários para instalar do zero. Atualizações usam `bootc` / `rpm-ostree` normalmente.
- A construção da ISO segue o [guia do image-builder para ISOs genéricas com bootc](https://osbuild.org/docs/developer-guide/projects/image-builder/bootc-generic-iso/).

### Atualizando

```bash
sudo bootc upgrade
systemctl reboot
```

Ou, pela interface clássica: `sudo rpm-ostree upgrade`.

### Revertendo

```bash
sudo bootc rollback
systemctl reboot
```

Ou, pela interface clássica: `sudo rpm-ostree rollback`.

## Construindo por conta própria

A imagem é uma imagem bootc comum, então qualquer builder OCI funciona. O `BASE_IMAGE` não tem valor padrão de propósito: o build falha em vez de usar, sem aviso, uma base não intencional. O valor vem do [`build.env`](../build.env):

```bash
source build.env
sudo podman build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    -t "${TARGET_IMAGE}" .
```

Depois, envie a imagem para um registro que a máquina de destino consiga acessar.

Para construir a imagem do desktop **e** a ISO do instalador Anaconda de uma só vez:

```bash
./build.sh
```

O `build.sh` constrói a imagem, constrói o container do instalador a partir de [`installer/Containerfile`](../installer/Containerfile) e executa o `image-builder` com o tipo `generic-iso`. A ISO fica em `output/`.

Para publicar o seu próprio fork:

1. Faça um fork deste repositório.
2. No [`build.env`](../build.env), troque o `REGISTRY` (e o nome da imagem, se quiser) pelos seus.
3. Gere um par de chaves com `cosign generate-key-pair` (deixe a senha em branco).
4. Cadastre a chave privada como secret `SIGNING_SECRET` do repositório e faça o commit do `cosign.pub`. **Nunca faça commit do `cosign.key`.**
5. Faça o push. O workflow constrói, assina e publica a imagem no GHCR.

### Estrutura do repositório

```
.
├── Containerfile            # definição da imagem (base, pacotes, serviços)
├── installer/
│   └── Containerfile        # imagem do instalador Anaconda usada na ISO
├── build.sh                 # constrói a imagem e a ISO do instalador
├── build.env                # versões, nomes de imagem, rótulo da ISO e valores derivados
├── files/system/            # arquivos copiados para / na imagem
├── cosign.pub               # chave pública de assinatura
├── LICENSE                  # Apache 2.0
└── .github/workflows/       # CI de build e publicação
```

## FAQ

**Existe uma ISO?**
Não uma publicada, mas o [`build.sh`](../build.sh) constrói uma localmente com o Anaconda, incluindo a tela de criação de usuário. Instalar a partir de um Fedora Atomic existente com `bootc switch` continua sendo o caminho mais simples.

**Posso alterar a lista de pacotes?**
Sim. Edite o `Containerfile`, faça o push e deixe a CI construir a nova imagem.

## Licença

O código deste repositório (Containerfile, scripts e configuração) é distribuído sob a licença Apache 2.0, em [`LICENSE`](../LICENSE).

A imagem resultante reúne software de terceiros, cada um sob sua própria licença, conforme fornecido pelo Fedora e pelos repositórios habilitados. A licença deste repositório não se aplica a esses componentes.

## Créditos

- [Fedora Project](https://fedoraproject.org) pela base.
- [Niri](https://github.com/YaLTeR/niri) e [Noctalia](https://github.com/noctalia-dev/noctalia-shell) pelo desktop.
- [osbuild / image-builder](https://osbuild.org) pelas ferramentas da ISO do instalador.
