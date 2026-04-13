#!/usr/bin/env bash
# build-kernel-deb.sh — kernel-kit Debian/Devuan (essora)
#
# autor: josejp2424 para Essora Linux
#
# Requisitos (una sola vez):
#   sudo apt update
#   sudo apt install -y build-essential bc flex bison libncurses-dev libssl-dev libelf-dev dwarves \
#     ccache rsync python3 pahole fakeroot devscripts gnupg2 ca-certificates xz-utils zstd cpio curl \
#     cmake cmake-extras automake libgtk2.0-dev libgladeui-dev gtk2-engines-pixbuf libgtk2.0-bin \
#     qt6-base-dev qt6-tools-dev dpkg-dev
#

set -euo pipefail

KERNEL_KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="${KERNEL_KIT_DIR}/configs_x86_64"
WORK_DIR="${KERNEL_KIT_DIR}/builds"
OUT_BASE="${WORK_DIR}/out"
LOG_FILE="${KERNEL_KIT_DIR}/build-kernel-deb.log"

LOCALVERSION_SUFFIX="-essora"
JOBS="$(nproc 2>/dev/null || echo 4)"
AUTO="no"
DO_CLEAN=""
KERNEL_VERSION=""
CONFIG_CHOSEN=""
FORCE_DOWNLOAD=""

RED='\033[1;31m'; GRN='\033[1;32m'; YLW='\033[1;33m'; BLU='\033[1;34m'; RST='\033[0m'

log_msg()   { printf "%s\n"              "$*" | tee -a "$LOG_FILE"; }
log_info()  { printf "\n${GRN}[INFO]${RST} %s\n" "$*" | tee -a "$LOG_FILE"; }
log_warn()  { printf "\n${YLW}[WARN]${RST} %s\n" "$*" | tee -a "$LOG_FILE"; }
log_error() { printf "\n${RED}[ERR ]${RST} %s\n" "$*" | tee -a "$LOG_FILE"; }
log_step()  { printf "\n${BLU}[====]${RST} %s\n" "$*" | tee -a "$LOG_FILE"; }

die() { log_error "$*"; echo; read -rp "ENTER para salir..." _; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Falta comando: $1"; }
pause() { echo; read -rp "${1:-Presiona ENTER para continuar...}" _; }

do_kernel_config() {
    log_info "make $1"
    make "$1" || die "Error al ejecutar make $1"
    pause "Configuración completada. ENTER para continuar, CTRL+C para cancelar"
}

trap 'log_error "Fallo en línea $LINENO — comando: $BASH_COMMAND"
      pause "ENTER para salir..."' ERR


setup_ccache() {
    if command -v ccache >/dev/null 2>&1; then
        export CC="ccache gcc"
        export CXX="ccache g++"
        export KBUILD_BUILD_TIMESTAMP="$(date -u +%F)"
        ccache --max-size=5G >/dev/null 2>&1 || true
        log_info "ccache activo (max 5G) — CC=$CC"
    else
        log_warn "ccache no encontrado; compilando sin caché (instala: apt install ccache)"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)  CONFIG_CHOSEN="${2:-}"; shift 2 ;;
        --auto)    AUTO="yes"; shift ;;
        --force)   FORCE_DOWNLOAD="yes"; shift ;;
        --jobs)    JOBS="${2:-$JOBS}"; shift 2 ;;
        clean)     DO_CLEAN=1; shift ;;
        -h|--help)
            echo "Uso: $0 [--config FILE] [--auto] [--force] [--jobs N] [clean]"
            echo ""
            echo "  --config FILE   Nombre del DOTconfig-* a usar (sin ruta)"
            echo "  --auto          No pide confirmaciones (usa menuconfig por defecto)"
            echo "  --force         Fuerza re-descarga del tarball aunque exista"
            echo "  --jobs N        Número de jobs paralelos (defecto: nproc=$JOBS)"
            echo "  clean           Borra builds/, out/ y el log"
            exit 0 ;;
        *) die "Opción desconocida: $1" ;;
    esac
done

for c in curl tar xz make gcc flex bison sed awk dpkg-deb sha256sum fakeroot; do
    need_cmd "$c"
done

if [[ -n "${DO_CLEAN:-}" ]]; then
    log_info "Limpiando builds/, out/ y log..."
    rm -rf "${WORK_DIR}" "${OUT_BASE}" "${LOG_FILE}"
    log_info "Limpiado."
    exit 0
fi

: > "$LOG_FILE"
log_step "Essora kernel-kit — $(date)"

setup_ccache

[[ -d "${CONFIGS_DIR}" ]] || die "No existe ${CONFIGS_DIR}"

mapfile -t CONFIGS < <(find "${CONFIGS_DIR}" -maxdepth 1 -type f -name 'DOTconfig-*' -printf '%f\n' | sort)
[[ ${#CONFIGS[@]} -gt 0 ]] || die "No hay DOTconfig-* en ${CONFIGS_DIR}"

if [[ -z "${CONFIG_CHOSEN}" ]]; then
    log_info "Configuraciones disponibles:"
    for i in "${!CONFIGS[@]}"; do
        printf "  %2d) %s\n" "$((i+1))" "${CONFIGS[i]}"
    done
    echo
    read -rp "Número: " idx
    [[ "$idx" =~ ^[0-9]+$ ]] || die "Selección inválida"
    (( idx >= 1 && idx <= ${#CONFIGS[@]} )) || die "Selección inválida"
    CONFIG_CHOSEN="${CONFIGS[$((idx-1))]}"
fi

[[ -f "${CONFIGS_DIR}/${CONFIG_CHOSEN}" ]] || die "No existe ${CONFIGS_DIR}/${CONFIG_CHOSEN}"
log_info "Config seleccionado: ${CONFIG_CHOSEN}"

KERNEL_VERSION="$(echo "${CONFIG_CHOSEN}" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?(-rc[0-9]+)?' || true)"
[[ -n "${KERNEL_VERSION}" ]] || die "No se pudo extraer versión desde ${CONFIG_CHOSEN}"

KERNEL_BASE="$(echo "${KERNEL_VERSION}" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?')"
RC_SUFFIX="$(echo "${KERNEL_VERSION}"  | grep -oE '\-rc[0-9]+$' || true)"
MAJOR="$(echo "${KERNEL_BASE}" | cut -d. -f1)"

log_info "Kernel versión : ${KERNEL_VERSION}  (base=${KERNEL_BASE}  rc=${RC_SUFFIX:-ninguno})"
log_info "Jobs paralelos : ${JOBS}"

mkdir -p "${WORK_DIR}" "${OUT_BASE}"
cd "${WORK_DIR}"

SRC_DIR="linux-${KERNEL_VERSION}"

if [[ -n "${RC_SUFFIX}" ]]; then
    TARBALL="linux-${KERNEL_VERSION}.tar.gz"
    TARBALL_URL="https://git.kernel.org/torvalds/t/${TARBALL}"
    EXTRACT_CMD="tar -xzf"
else
    TARBALL="linux-${KERNEL_VERSION}.tar.xz"
    TARBALL_URL="https://www.kernel.org/pub/linux/kernel/v${MAJOR}.x/${TARBALL}"
    EXTRACT_CMD="tar -xf"
fi
SUMFILE="${TARBALL}.sha256"

log_info "Tarball  : ${TARBALL}"
log_info "Fuente   : ${TARBALL_URL}"

if [[ -f "${TARBALL}" && -f "${SUMFILE}" ]] && sha256sum -c "${SUMFILE}" >/dev/null 2>&1; then
    log_info "Tarball existente verificado OK — no se descarga de nuevo."
    log_msg  "  (usa --force para forzar re-descarga)"
else
    if [[ -f "${TARBALL}" && -z "${FORCE_DOWNLOAD}" ]]; then
        log_warn "Tarball existe pero sin checksum válido — regenerando checksum y continuando."
        sha256sum "${TARBALL}" > "${SUMFILE}"
    else
        log_step "Descargando ${TARBALL}..."
        curl -L --progress-bar -o "${TARBALL}" "${TARBALL_URL}" \
            || die "Falló descarga: ${TARBALL_URL}"
        sha256sum "${TARBALL}" > "${SUMFILE}"
        log_info "Descarga completa. Checksum guardado."
    fi
fi

if [[ -d "${SRC_DIR}" ]]; then
    log_info "Fuentes ya extraídas en ${SRC_DIR}"
else
    log_step "Extrayendo fuentes..."
    ${EXTRACT_CMD} "${TARBALL}" || die "Falló extracción del tarball"
    log_info "Extracción completa."
fi

cd "${SRC_DIR}"

log_info "Copiando configuración..."
cp "${CONFIGS_DIR}/${CONFIG_CHOSEN}" .config || die "No pude copiar .config"

log_info "make olddefconfig"
yes "" | make olddefconfig 2>&1 | tee -a "${LOG_FILE}" || log_warn "olddefconfig con advertencias, continuando"

if [[ "${AUTO}" == "yes" ]]; then
    log_info "Modo --auto: saltando configuración interactiva"
else
    echo
    printf "${BLU}Configuración del kernel:${RST}\n"
    echo "  1. make menuconfig  [predeterminado]"
    echo "  2. make xconfig     (Qt)"
    echo "  s. saltar"
    echo
    read -rp "Opción: " kernelcfg
    case "${kernelcfg:-1}" in
        1|"") do_kernel_config menuconfig ;;
        2)    do_kernel_config xconfig    ;;
        s|S)  log_msg "Saltando configuración del kernel" ;;
        *)    do_kernel_config menuconfig ;;
    esac
fi

sed -i "s|^CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"${LOCALVERSION_SUFFIX}\"|" .config 2>/dev/null || true
grep -q '^CONFIG_LOCALVERSION=' .config \
    || echo "CONFIG_LOCALVERSION=\"${LOCALVERSION_SUFFIX}\"" >> .config

sed -i 's|^CONFIG_LOCALVERSION_AUTO=.*|# CONFIG_LOCALVERSION_AUTO is not set|' .config 2>/dev/null || true
grep -q '^# CONFIG_LOCALVERSION_AUTO is not set' .config \
    || echo '# CONFIG_LOCALVERSION_AUTO is not set' >> .config

if ! command -v pahole >/dev/null 2>&1; then
    sed -i 's|^CONFIG_DEBUG_INFO_BTF=.*|# CONFIG_DEBUG_INFO_BTF is not set|' .config 2>/dev/null || true
    grep -q '^# CONFIG_DEBUG_INFO_BTF is not set' .config \
        || echo '# CONFIG_DEBUG_INFO_BTF is not set' >> .config
    log_warn "pahole no encontrado — desactivado CONFIG_DEBUG_INFO_BTF"
fi

log_step "Resumen de compilación"
echo "  Kernel      : ${KERNEL_VERSION}${LOCALVERSION_SUFFIX}"
echo "  Config      : ${CONFIG_CHOSEN}"
echo "  Jobs        : ${JOBS}"
echo "  Destino     : ${OUT_BASE}/${KERNEL_VERSION}/"
if command -v ccache >/dev/null 2>&1; then
    echo "  ccache stats: $(ccache -s 2>/dev/null | grep 'cache hit\|hit rate' | tr '\n' ' ')"
fi
echo

if [[ "${AUTO}" != "yes" ]]; then
    read -rp "¿Iniciar compilación? [S/n]: " confirm
    [[ "${confirm,,}" =~ ^(s|si|yes|y|)$ ]] || { log_warn "Compilación cancelada."; exit 0; }
fi

log_step "Compilando kernel (jobs=${JOBS})..."
START_TIME="$(date +%s)"

make clean 2>/dev/null || true
fakeroot make -j"${JOBS}" bindeb-pkg 2>&1 | tee -a "${LOG_FILE}" \
    || die "Falló bindeb-pkg — revisa ${LOG_FILE}"

END_TIME="$(date +%s)"
ELAPSED=$(( END_TIME - START_TIME ))
log_info "Compilación completada en $(( ELAPSED / 60 ))m $(( ELAPSED % 60 ))s"

cd "${WORK_DIR}"
log_step "Generando linux-libc-dev_${KERNEL_VERSION}-essora_amd64.deb..."

LIBCDEV_DIR="${WORK_DIR}/libc-dev-${KERNEL_VERSION}-essora"
rm -rf "${LIBCDEV_DIR}"
mkdir -p "${LIBCDEV_DIR}/usr/include" "${LIBCDEV_DIR}/usr/include/asm"

cp -a "${SRC_DIR}/include/uapi/"*    "${LIBCDEV_DIR}/usr/include/"    2>/dev/null || true
cp -a "${SRC_DIR}/arch/x86/include/uapi/"* "${LIBCDEV_DIR}/usr/include/asm/" 2>/dev/null || true

mkdir -p "${LIBCDEV_DIR}/DEBIAN"
cat > "${LIBCDEV_DIR}/DEBIAN/control" <<EOF
Package: linux-libc-dev
Version: ${KERNEL_VERSION}-essora
Section: devel
Priority: optional
Architecture: amd64
Maintainer: josejp2424
Description: Linux kernel UAPI headers for userspace development (essora)
EOF

dpkg-deb --build "${LIBCDEV_DIR}" \
    "${WORK_DIR}/linux-libc-dev_${KERNEL_VERSION}-essora_amd64.deb" \
    || die "Falló dpkg-deb linux-libc-dev"

log_step "Generando linux-kbuild-${KERNEL_VERSION}-essora_amd64.deb..."

KBUILD_DIR="${WORK_DIR}/kbuild-${KERNEL_VERSION}-essora"
KBUILD_DEST="${KBUILD_DIR}/usr/lib/linux-kbuild-${KERNEL_VERSION}-essora"
rm -rf "${KBUILD_DIR}"
mkdir -p "${KBUILD_DEST}/include" "${KBUILD_DEST}/arch/x86"

cp -a "${SRC_DIR}/scripts"                          "${KBUILD_DEST}/"               2>/dev/null || true
cp -a "${SRC_DIR}/include/config"                   "${KBUILD_DEST}/include/"       2>/dev/null || true
cp -a "${SRC_DIR}/include/generated"                "${KBUILD_DEST}/include/"       2>/dev/null || true
cp -a "${SRC_DIR}/arch/x86/include/generated"       "${KBUILD_DEST}/arch/x86/"      2>/dev/null || true

if [[ -f "${SRC_DIR}/tools/objtool/objtool" ]]; then
    mkdir -p "${KBUILD_DEST}/tools/objtool"
    cp -a "${SRC_DIR}/tools/objtool/objtool" "${KBUILD_DEST}/tools/objtool/"
fi

for f in Makefile Kbuild Kconfig arch/x86/Makefile arch/x86/Makefile_32.cpu; do
    [[ -f "${SRC_DIR}/${f}" ]] || continue
    mkdir -p "${KBUILD_DEST}/$(dirname "$f")"
    cp -a "${SRC_DIR}/${f}" "${KBUILD_DEST}/${f}"
done

find "${KBUILD_DEST}/scripts" \
    \( -name "*.o" -o -name "*.a" -o -name ".*.cmd" \) \
    -delete 2>/dev/null || true

mkdir -p "${KBUILD_DIR}/DEBIAN"
cat > "${KBUILD_DIR}/DEBIAN/control" <<EOF
Package: linux-kbuild-${KERNEL_VERSION}-essora
Version: ${KERNEL_VERSION}-essora
Section: kernel
Priority: optional
Architecture: amd64
Maintainer: josejp2424
Provides: linux-kbuild-${KERNEL_VERSION}
Description: Kbuild infrastructure for Linux ${KERNEL_VERSION}-essora
 Scripts and tools needed to build out-of-tree kernel modules
 against the ${KERNEL_VERSION}-essora kernel.
EOF

dpkg-deb --build "${KBUILD_DIR}" \
    "${WORK_DIR}/linux-kbuild-${KERNEL_VERSION}-essora_amd64.deb" \
    || die "Falló dpkg-deb linux-kbuild"

log_info "linux-kbuild generado OK"

OUT_DIR="${OUT_BASE}/${KERNEL_VERSION}"
mkdir -p "${OUT_DIR}"
mv -f "${WORK_DIR}"/*.deb "${OUT_DIR}/" 2>/dev/null || true
cd "${OUT_DIR}"

log_info "Renombrando .deb a <paquete>_amd64.deb ..."
rename_one() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    local pkg="${f%%_*}"
    local arch
    arch="$(echo "$f" | sed -E 's/.*_([a-z0-9]+)\.deb$/\1/')"
    local new="${pkg}_${arch}.deb"
    [[ "$f" == "$new" ]] || mv -v "$f" "$new"
}
for f in *.deb; do rename_one "$f"; done

log_step "Paquetes generados en ${OUT_DIR}:"
ls -lh "${OUT_DIR}"/*.deb 2>/dev/null || log_warn "No se encontraron .deb en ${OUT_DIR}"

echo
printf "${GRN}Para instalar:${RST}\n"
echo "  cd \"${OUT_DIR}\""
echo "  sudo dpkg -i linux-image-*_amd64.deb linux-headers-*_amd64.deb linux-kbuild-*_amd64.deb linux-libc-dev_amd64.deb"
echo "  sudo apt-get -f install    # resuelve dependencias si faltan"
echo "  sudo update-grub"
echo
if command -v ccache >/dev/null 2>&1; then
    log_info "ccache stats finales:"
    ccache -s 2>/dev/null | grep -E 'hit|miss|size' | sed 's/^/  /' || true
fi
echo
pause "ENTER para salir..."
