#!/usr/bin/env bash
# install-deps.sh — Dependencias de compilación para Essora kernel-kit
#
# autor: josejp2424 para Essora Linux
#
# Instala todos los paquetes necesarios para:
#   - Compilar el kernel Linux y generar .deb (bindeb-pkg)
#   - Herramientas de desarrollo GTK3, Qt6, Mesa, XCB
#   - Compiladores, herramientas Python, ccache
#
# Uso:
#   sudo bash install-deps.sh
#   sudo bash install-deps.sh --check    # solo verificar sin instalar
#   sudo bash install-deps.sh --quiet    # instalar sin preguntas
#

set -euo pipefail

RED='\033[1;31m'; GRN='\033[1;32m'; YLW='\033[1;33m'; BLU='\033[1;34m'; RST='\033[0m'

log_info()  { printf "\n${GRN}[INFO]${RST} %s\n" "$*"; }
log_warn()  { printf "\n${YLW}[WARN]${RST} %s\n" "$*"; }
log_error() { printf "\n${RED}[ERR ]${RST} %s\n" "$*"; }
log_step()  { printf "\n${BLU}[====]${RST} %s\n" "$*"; }
die()       { log_error "$*"; exit 1; }

CHECK_ONLY="no"
QUIET="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)  CHECK_ONLY="yes"; shift ;;
        --quiet)  QUIET="yes"; shift ;;
        -h|--help)
            echo "Uso: sudo bash $0 [--check] [--quiet]"
            echo "  --check   Solo verifica qué falta, sin instalar"
            echo "  --quiet   Instala sin pedir confirmación"
            exit 0 ;;
        *) die "Opción desconocida: $1" ;;
    esac
done

[[ "${CHECK_ONLY}" == "no" ]] && [[ "$(id -u)" -ne 0 ]] && die "Ejecutar como root: sudo bash $0"

KERNEL_BUILD=(
    build-essential
    bc
    flex
    bison
    libncurses-dev
    libssl-dev
    libelf-dev
    libdw-dev
    dwarves
    pahole
    binutils-dev
    kmod
    libzstd-dev
    liblzma-dev
    fakeroot
    dpkg-dev
    debhelper
    rsync
    cpio
    xz-utils
    zstd
    make
    gcc
    g++
)


KERNEL_PERF=(
    libcap-dev
    libunwind-dev
    libtraceevent-dev
    libpci-dev
    libnewt-dev
    libdwarf-dev
    libiberty-dev
)


COMPILERS=(
    ccache
    clang
    llvm
    nasm
    autoconf
    automake
    libtool
    cmake
    meson
    ninja-build
    pkg-config
    git
    curl
    tar
    ca-certificates
    gnupg2
)


PYTHON=(
    python3
    python3-dev
    python3-full
    python3-setuptools
    python3-pip
    python3-toml
    python3-zstandard
    python3-appdirs
    python3-ordered-set
    libpython3-all-dev
    cython3
    patchelf
)


GTK=(
    libgtk2.0-dev
    libgtk-3-dev
    libgladeui-dev
    gtk2-engines-pixbuf
    libgtk2.0-bin
    libglib2.0-dev
    libgdk-pixbuf-2.0-dev
    librsvg2-dev
    intltool
    gtk-doc-tools
)


QT=(
    qt6-base-dev
    qt6-tools-dev
    libqt6core6t64
    libqt6gui6
)


GRAPHICS=(
    libdrm-dev
    libglvnd-dev
    mesa-common-dev
    libudev-dev
    libpciaccess-dev
    libx11-xcb-dev
    libxcb1-dev
    libxcb-util-dev
    libxcb-dri2-0-dev
    libxcb-dri3-dev
    libxcb-present-dev
    libxcb-sync-dev
    libxshmfence-dev
    libxcb-xfixes0-dev
    libxcb-randr0-dev
    libxcb-render0-dev
    libxcb-icccm4-dev
    libxcb-xkb-dev
    libxcb-render-util0-dev
    libxcb-image0-dev
    libxcb-keysyms1-dev
    libxcb-glx0-dev
    libxcb-xv0-dev
    libxcb-composite0-dev
    libxcb-damage0-dev
    libxfont-dev
)


COMPOSITOR=(
    libev-dev
    libconfig++-dev
    libconfig-dev
    uthash-dev
    asciidoctor
)


SECURITY=(
    libgcrypt20-dev
    libssl-dev
    libcap-dev
)


DEBIAN_TOOLS=(
    devscripts
    git-buildpackage
    base-files
    lintian
)


check_and_install() {
    local group_name="$1"
    shift
    local pkgs=("$@")
    local missing=()
    local optional_miss=()

    for pkg in "${pkgs[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        printf "  ${GRN}✓${RST} %-30s todos instalados\n" "[${group_name}]"
        return 0
    fi

    printf "  ${YLW}!${RST} %-30s faltan %d: %s\n" \
        "[${group_name}]" "${#missing[@]}" "${missing[*]}"

    [[ "${CHECK_ONLY}" == "yes" ]] && return 0

    log_info "Instalando [${group_name}]..."
    apt-get install -y --ignore-missing "${missing[@]}" 2>&1 \
        || log_warn "Algunos paquetes de [${group_name}] no se pudieron instalar (pueden no existir en este repo)"
}

# ── MAIN ──────────────────────────────────────────────────────────────────────

echo
echo "  ╔════════════════════════════════════════════╗"
echo "  ║   Essora kernel-kit — install-deps.sh     ║"
echo "  ╚════════════════════════════════════════════╝"
echo

if [[ "${CHECK_ONLY}" == "yes" ]]; then
    log_step "Modo verificación — no se instala nada"
else
    log_step "Actualizando lista de paquetes..."
    apt-get update -qq || log_warn "apt update con advertencias"
fi

echo
log_step "Estado de dependencias:"
echo

check_and_install "kernel-build"    "${KERNEL_BUILD[@]}"
check_and_install "kernel-perf"     "${KERNEL_PERF[@]}"
check_and_install "compilers"       "${COMPILERS[@]}"
check_and_install "python"          "${PYTHON[@]}"
check_and_install "gtk"             "${GTK[@]}"
check_and_install "qt6"             "${QT[@]}"
check_and_install "graphics-xcb"    "${GRAPHICS[@]}"
check_and_install "compositor"      "${COMPOSITOR[@]}"
check_and_install "security"        "${SECURITY[@]}"
check_and_install "debian-tools"    "${DEBIAN_TOOLS[@]}"

echo

if [[ "${CHECK_ONLY}" == "yes" ]]; then
    log_info "Verificación completa."
    echo "  Para instalar todo: sudo bash $0"
else
    log_step "Verificación post-instalación:"
    echo
    ALL_OK=1
    CRITICAL=(gcc make flex bison libssl-dev libelf-dev libdw-dev pahole fakeroot dpkg-dev kmod ccache)
    for pkg in "${CRITICAL[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            printf "  ${GRN}✓${RST} %s\n" "$pkg"
        else
            printf "  ${RED}✗${RST} %s  ← CRÍTICO: sin esto no compila el kernel\n" "$pkg"
            ALL_OK=0
        fi
    done

    echo
    if [[ "$ALL_OK" -eq 1 ]]; then
        log_info "Todo listo. Podés compilar el kernel con: sudo bash build.sh"
    else
        log_warn "Algunos paquetes críticos no se instalaron."
        echo "  Revisá los errores arriba o intentá manualmente:"
        echo "  sudo apt install -f"
    fi
fi

echo
