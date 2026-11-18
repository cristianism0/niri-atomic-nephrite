<div align="center">

# niri-atomic-nephrite

**Um desktop Fedora Atomic construído em torno do [Niri](https://github.com/YaLTeR/niri), o compositor Wayland de tiling com rolagem.**

Base imutável. Atualizações atômicas. Rollback com um comando.

[![build](https://github.com/cristianism0/niri-atomic-nephrite/actions/workflows/build.yml/badge.svg)](https://github.com/<usuario>/niri-atomic-nephrite/actions/workflows/build.yml)
[![licença](https://img.shields.io/github/license/<usuario>/niri-atomic-nephrite)](../LICENSE)

[English](../README.md) · **Português (Brasil)**

</div>


## O que é isto?

`niri-atomic-nephrite` é uma imagem de sistema operacional pessoal e customizada. Ela parte da base baseada em imagem do Fedora (bootc / rpm-ostree) e acrescenta uma sessão Niri com o shell Noctalia, pronta para iniciar.

Por ser baseada em imagem, o sistema inteiro é construído na CI, distribuído como uma única imagem de container e trocado de forma atômica. Se uma atualização der problema, a versão anterior está a um reboot de distância.

> **Status: experimental.** Feita para as minhas máquinas e compartilhada como está. Espere arestas e teste primeiro em uma VM.

## Destaques

- **Desktop Niri**: compositor Wayland de tiling com rolagem, com o shell Noctalia, Alacritty e Fuzzel.
- **Atômica por design**: as atualizações substituem a imagem inteira; nada fica pela metade.
- **Rollback embutido**: a implantação anterior permanece no menu de boot.
- **Construída às claras**: toda mudança passa pelo GitHub Actions, e as imagens são assinadas com [cosign](https://github.com/sigstore/cosign).
- **Apps via Flatpak**: Firefox e Loupe pré-instalados; o resto está a um Flatpak de distância.
- **Recipe pequeno e legível**: toda a definição está em [`recipes/recipe.yml`](../recipes/recipe.yml).

## O que há dentro

| Camada | Conteúdo |
|---|---|
| Base | `fedora-bootc`, Fedora 45 (versão atual - cheque o recipe) |
| Compositor e shell | Niri, Noctalia |
| Terminal | Alacritty |
| Login | greetd com tuigreet |
| Portais e auxiliares | xdg-desktop-portal (GNOME e GTK), polkit do MATE, wl-clipboard, brightnessctl, playerctl |
| Shell | bash e zsh |
| Apps (Flatpak) | Firefox, Loupe |

>O recipe é onde os pacotes reais estão listados; esta tabela pode ficar defasada em relação a ele.

## Instalação

**Não há ISO.** Instale primeiro qualquer edição do Fedora Atomic (Silverblue, Kinoite, ...) e depois faça o rebase para esta imagem:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/<usuario>/niri-atomic-nephrite:latest
systemctl reboot
```

Observações:

- Este comando **não verifica a assinatura** da imagem. A chave pública está em [`cosign.pub`](../cosign.pub) caso queira verificar manualmente com `cosign verify`.
- O pacote no GHCR precisa estar público para o rebase funcionar sem credenciais.
- Seu diretório pessoal e os Flatpaks de usuário são preservados.

### Atualizando

```bash
sudo rpm-ostree upgrade
systemctl reboot
```

### Revertendo

```bash
sudo rpm-ostree rollback
systemctl reboot
```

## Construindo por conta própria

```bash
bluebuild validate recipes/recipe.yml
bluebuild build recipes/recipe.yml
```

Para publicar o seu próprio fork:

1. Faça um fork deste repositório.
2. Gere um par de chaves com `cosign generate-key-pair` (deixe a senha em branco).
3. Cadastre a chave privada como secret `SIGNING_SECRET` do repositório e commite o `cosign.pub`. **Nunca commite o `cosign.key`.**
4. Faça o push. O workflow constrói, assina e publica a imagem no GHCR.

### Estrutura do repositório

```
.
├── recipes/recipe.yml      # definição da imagem (base, pacotes, módulos)
├── files/system/           # arquivos copiados para / na imagem
├── cosign.pub              # chave pública de assinatura
└── .github/workflows/      # CI de build e publicação
```

## FAQ

**Existe uma ISO?**
Não. Instalar a partir de um Fedora Atomic existente e fazer o rebase é o caminho suportado.

**Está pronta para uso diário?**
É o meu setup diário, embora atômica é instável por natureza. Teste em uma VM antes de confiar nela.

**Posso alterar a lista de pacotes?**
Sim. Edite `recipes/recipe.yml`, faça o push e deixe a CI construir a nova imagem.

## Licença

O código deste repositório (recipes, scripts e configuração) é distribuído sob a licença Apache 2.0 em [`LICENSE`](../LICENSE).

A imagem resultante reúne software de terceiros, cada um sob sua própria licença, conforme fornecido pelo Fedora e pelos repositórios habilitados. A licença deste repositório não se aplica a esses componentes.

## Créditos

- [BlueBuild](https://blue-build.org) pela ferramenta e pelo template.
- [Fedora Project](https://fedoraproject.org) pela base.
- [Niri](https://github.com/YaLTeR/niri) e Noctalia pelo desktop.
