#!/usr/bin/env bash
# essorakb-gui.sh — EssoraKB Kernel Builder GUI
# autor: josejp2424 para Essora Linux
# Requiere: yad, xterm

set -euo pipefail

ESSORAKB_DIR="/opt/EssoraKB"
CONFIGS_DIR="${ESSORAKB_DIR}/configs_x86_64"
ICON="${ESSORAKB_DIR}/EssoraKB.png"
TITLE="EssoraKB — Kernel Builder v0.1.2"

setup_i18n() {
    local lang="${LANG:-en}"
    local lc="${lang:0:2}"

    T_HEADER="<b>Kernel Builder for Essora Linux</b>"
    T_HEADER_PLAIN="Kernel Builder for Essora Linux"
    T_AVAIL="Available configurations"
    T_NONE="(none)"
    T_ACTION="Select an action:"
    T_COL_ACT="Action"
    T_COL_DESC="Description"
    T_BTN_RUN="Execute"
    T_BTN_EXIT="Exit"
    T_ACT_INSTALL="Install dependencies"
    T_ACT_CHECK="Check dependencies"
    T_ACT_BUILD="Build kernel"
    T_ACT_CLEAN="Clean builds"
    T_DESC_INSTALL="Install all packages needed to compile"
    T_DESC_CHECK="Only check what is missing, without installing"
    T_DESC_BUILD="Download sources and build kernel .deb packages"
    T_DESC_CLEAN="Delete builds/, out/ folder and build log"
    T_CONFIRM_INSTALL="All build dependencies will be installed.\n\n<b>sudo (root password)</b> will be required.\n\nContinue?"
    T_BTN_INSTALL="Install"
    T_BTN_CANCEL="Cancel"
    T_NO_CONFIGS="No <b>DOTconfig-*</b> files found in:\n${CONFIGS_DIR}"
    T_BUILD_TITLE="Build Options"
    T_BUILD_TEXT="<b>Configure kernel compilation</b>"
    T_FIELD_CONFIG="Kernel configuration"
    T_FIELD_JOBS="Parallel jobs (0=auto)"
    T_FIELD_AUTO="Automatic mode (no prompts)"
    T_FIELD_FORCE="Force re-download"
    T_BTN_BUILD="Build"
    T_CONFIRM_CLEAN="The <b>builds/, out/</b> directories and build log will be deleted.\n\nContinue?"
    T_BTN_CLEAN="Clean"
    T_PRESS_ENTER="Press ENTER to close..."
    T_MISSING_DEP="Missing dependency"
    T_INSTALL_WITH="Install with: sudo apt install"
    T_NOT_FOUND="Directory not found"
    T_INSTALL_PKG="Please install the EssoraKB package first."
    T_AUTH_TITLE="Authentication"
    T_AUTH_TEXT="Authentication required\nfor user: <b>${USER}</b>"
    T_AUTH_PASS=" Password: "
    T_AUTH_WRONG=" Wrong password, please try again"
    T_AUTH_OK="--button=Authenticate:0"
    T_AUTH_CANCEL="--button=Cancel:1"

    case "${lc}" in
    es)
        T_HEADER="<b>Compilador de Kernel para Essora Linux</b>"
        T_HEADER_PLAIN="Compilador de Kernel para Essora Linux"
        T_AVAIL="Configuraciones disponibles"
        T_NONE="(ninguna)"
        T_ACTION="Seleccioná una acción:"
        T_COL_ACT="Acción"
        T_COL_DESC="Descripción"
        T_BTN_RUN="Ejecutar"
        T_BTN_EXIT="Salir"
        T_ACT_INSTALL="Instalar dependencias"
        T_ACT_CHECK="Verificar dependencias"
        T_ACT_BUILD="Compilar kernel"
        T_ACT_CLEAN="Limpiar builds"
        T_DESC_INSTALL="Instala todos los paquetes necesarios para compilar"
        T_DESC_CHECK="Solo verifica qué falta, sin instalar nada"
        T_DESC_BUILD="Descarga fuentes y construye los .deb del kernel"
        T_DESC_CLEAN="Borra la carpeta builds/, out/ y el log"
        T_CONFIRM_INSTALL="Se instalarán las dependencias de compilación del kernel.\n\nSe solicitará contraseña de <b>root (sudo)</b>.\n\n¿Continuar?"
        T_BTN_INSTALL="Instalar"
        T_BTN_CANCEL="Cancelar"
        T_NO_CONFIGS="No se encontraron archivos <b>DOTconfig-*</b> en:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Opciones de compilación"
        T_BUILD_TEXT="<b>Configurar compilación del kernel</b>"
        T_FIELD_CONFIG="Configuración del kernel"
        T_FIELD_JOBS="Jobs paralelos (0=auto)"
        T_FIELD_AUTO="Modo automático (sin preguntas)"
        T_FIELD_FORCE="Forzar re-descarga"
        T_BTN_BUILD="Compilar"
        T_CONFIRM_CLEAN="Se borrarán <b>builds/, out/</b> y el log de compilación.\n\n¿Continuar?"
        T_BTN_CLEAN="Limpiar"
        T_PRESS_ENTER="Presioná ENTER para cerrar..."
        T_MISSING_DEP="Falta dependencia"
        T_INSTALL_WITH="Instalá con: sudo apt install"
        T_NOT_FOUND="Directorio no encontrado"
        T_INSTALL_PKG="Instalá el paquete EssoraKB primero."
        T_AUTH_TITLE="Autenticación"
        T_AUTH_TEXT="Se requiere autenticación\npara el usuario: <b>${USER}</b>"
        T_AUTH_PASS=" Contraseña: "
        T_AUTH_WRONG=" Contraseña incorrecta, inténtelo de nuevo"
        T_AUTH_OK="--button=Autenticar:0"
        T_AUTH_CANCEL="--button=Cancelar:1"
        ;;
    fr)
        T_HEADER="<b>Compilateur de noyau pour Essora Linux</b>"
        T_HEADER_PLAIN="Compilateur de noyau pour Essora Linux"
        T_AVAIL="Configurations disponibles"
        T_NONE="(aucune)"
        T_ACTION="Sélectionnez une action :"
        T_COL_ACT="Action"
        T_COL_DESC="Description"
        T_BTN_RUN="Exécuter"
        T_BTN_EXIT="Quitter"
        T_ACT_INSTALL="Installer les dépendances"
        T_ACT_CHECK="Vérifier les dépendances"
        T_ACT_BUILD="Compiler le noyau"
        T_ACT_CLEAN="Nettoyer les builds"
        T_DESC_INSTALL="Installe tous les paquets nécessaires à la compilation"
        T_DESC_CHECK="Vérifie seulement ce qui manque, sans installer"
        T_DESC_BUILD="Télécharge les sources et construit les paquets .deb"
        T_DESC_CLEAN="Supprime builds/, out/ et le journal de compilation"
        T_CONFIRM_INSTALL="Les dépendances de compilation seront installées.\n\nLe <b>mot de passe root (sudo)</b> sera demandé.\n\nContinuer ?"
        T_BTN_INSTALL="Installer"
        T_BTN_CANCEL="Annuler"
        T_NO_CONFIGS="Aucun fichier <b>DOTconfig-*</b> trouvé dans :\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Options de compilation"
        T_BUILD_TEXT="<b>Configurer la compilation du noyau</b>"
        T_FIELD_CONFIG="Configuration du noyau"
        T_FIELD_JOBS="Jobs parallèles (0=auto)"
        T_FIELD_AUTO="Mode automatique (sans questions)"
        T_FIELD_FORCE="Forcer le re-téléchargement"
        T_BTN_BUILD="Compiler"
        T_CONFIRM_CLEAN="Les dossiers <b>builds/, out/</b> et le journal seront supprimés.\n\nContinuer ?"
        T_BTN_CLEAN="Nettoyer"
        T_PRESS_ENTER="Appuyez sur ENTRÉE pour fermer..."
        T_MISSING_DEP="Dépendance manquante"
        T_INSTALL_WITH="Installez avec : sudo apt install"
        T_NOT_FOUND="Répertoire introuvable"
        T_INSTALL_PKG="Veuillez installer le paquet EssoraKB d'abord."
        T_AUTH_TITLE="Authentification"
        T_AUTH_TEXT="Authentification requise\npour l'utilisateur : <b>${USER}</b>"
        T_AUTH_PASS=" Mot de passe : "
        T_AUTH_WRONG=" Mot de passe incorrect, réessayez"
        T_AUTH_OK="--button=Authentifier:0"
        T_AUTH_CANCEL="--button=Annuler:1"
        ;;
    de)
        T_HEADER="<b>Kernel-Compiler für Essora Linux</b>"
        T_HEADER_PLAIN="Kernel-Compiler für Essora Linux"
        T_AVAIL="Verfügbare Konfigurationen"
        T_NONE="(keine)"
        T_ACTION="Wählen Sie eine Aktion:"
        T_COL_ACT="Aktion"
        T_COL_DESC="Beschreibung"
        T_BTN_RUN="Ausführen"
        T_BTN_EXIT="Beenden"
        T_ACT_INSTALL="Abhängigkeiten installieren"
        T_ACT_CHECK="Abhängigkeiten prüfen"
        T_ACT_BUILD="Kernel kompilieren"
        T_ACT_CLEAN="Builds bereinigen"
        T_DESC_INSTALL="Installiert alle zum Kompilieren benötigten Pakete"
        T_DESC_CHECK="Prüft nur, was fehlt, ohne zu installieren"
        T_DESC_BUILD="Lädt Quellen herunter und baut Kernel-.deb-Pakete"
        T_DESC_CLEAN="Löscht builds/, out/ und das Build-Protokoll"
        T_CONFIRM_INSTALL="Alle Build-Abhängigkeiten werden installiert.\n\n<b>sudo (Root-Passwort)</b> wird benötigt.\n\nFortfahren?"
        T_BTN_INSTALL="Installieren"
        T_BTN_CANCEL="Abbrechen"
        T_NO_CONFIGS="Keine <b>DOTconfig-*</b>-Dateien in:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Build-Optionen"
        T_BUILD_TEXT="<b>Kernel-Kompilierung konfigurieren</b>"
        T_FIELD_CONFIG="Kernel-Konfiguration"
        T_FIELD_JOBS="Parallele Jobs (0=auto)"
        T_FIELD_AUTO="Automatischer Modus (keine Rückfragen)"
        T_FIELD_FORCE="Download erzwingen"
        T_BTN_BUILD="Kompilieren"
        T_CONFIRM_CLEAN="Die Verzeichnisse <b>builds/, out/</b> und das Protokoll werden gelöscht.\n\nFortfahren?"
        T_BTN_CLEAN="Bereinigen"
        T_PRESS_ENTER="EINGABE drücken zum Schließen..."
        T_MISSING_DEP="Fehlende Abhängigkeit"
        T_INSTALL_WITH="Installieren mit: sudo apt install"
        T_NOT_FOUND="Verzeichnis nicht gefunden"
        T_INSTALL_PKG="Bitte installieren Sie das EssoraKB-Paket zuerst."
        T_AUTH_TITLE="Authentifizierung"
        T_AUTH_TEXT="Authentifizierung erforderlich\nfür Benutzer: <b>${USER}</b>"
        T_AUTH_PASS=" Passwort: "
        T_AUTH_WRONG=" Falsches Passwort, bitte erneut versuchen"
        T_AUTH_OK="--button=Authentifizieren:0"
        T_AUTH_CANCEL="--button=Abbrechen:1"
        ;;
    it)
        T_HEADER="<b>Compilatore del kernel per Essora Linux</b>"
        T_HEADER_PLAIN="Compilatore del kernel per Essora Linux"
        T_AVAIL="Configurazioni disponibili"
        T_NONE="(nessuna)"
        T_ACTION="Seleziona un'azione:"
        T_COL_ACT="Azione"
        T_COL_DESC="Descrizione"
        T_BTN_RUN="Esegui"
        T_BTN_EXIT="Esci"
        T_ACT_INSTALL="Installa dipendenze"
        T_ACT_CHECK="Verifica dipendenze"
        T_ACT_BUILD="Compila kernel"
        T_ACT_CLEAN="Pulisci build"
        T_DESC_INSTALL="Installa tutti i pacchetti necessari per compilare"
        T_DESC_CHECK="Verifica solo cosa manca, senza installare"
        T_DESC_BUILD="Scarica i sorgenti e crea i pacchetti .deb del kernel"
        T_DESC_CLEAN="Elimina builds/, out/ e il log di compilazione"
        T_CONFIRM_INSTALL="Verranno installate le dipendenze di compilazione.\n\nSarà richiesta la password di <b>root (sudo)</b>.\n\nContinuare?"
        T_BTN_INSTALL="Installa"
        T_BTN_CANCEL="Annulla"
        T_NO_CONFIGS="Nessun file <b>DOTconfig-*</b> trovato in:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Opzioni di compilazione"
        T_BUILD_TEXT="<b>Configura la compilazione del kernel</b>"
        T_FIELD_CONFIG="Configurazione del kernel"
        T_FIELD_JOBS="Job paralleli (0=auto)"
        T_FIELD_AUTO="Modalità automatica (senza conferme)"
        T_FIELD_FORCE="Forza ri-scaricamento"
        T_BTN_BUILD="Compila"
        T_CONFIRM_CLEAN="Le cartelle <b>builds/, out/</b> e il log verranno eliminati.\n\nContinuare?"
        T_BTN_CLEAN="Pulisci"
        T_PRESS_ENTER="Premi INVIO per chiudere..."
        T_MISSING_DEP="Dipendenza mancante"
        T_INSTALL_WITH="Installa con: sudo apt install"
        T_NOT_FOUND="Directory non trovata"
        T_INSTALL_PKG="Installa prima il pacchetto EssoraKB."
        T_AUTH_TITLE="Autenticazione"
        T_AUTH_TEXT="Autenticazione richiesta\nper l'utente: <b>${USER}</b>"
        T_AUTH_PASS=" Password: "
        T_AUTH_WRONG=" Password errata, riprovare"
        T_AUTH_OK="--button=Autentica:0"
        T_AUTH_CANCEL="--button=Annulla:1"
        ;;
    pt)
        T_HEADER="<b>Compilador de Kernel para Essora Linux</b>"
        T_HEADER_PLAIN="Compilador de Kernel para Essora Linux"
        T_AVAIL="Configurações disponíveis"
        T_NONE="(nenhuma)"
        T_ACTION="Selecione uma ação:"
        T_COL_ACT="Ação"
        T_COL_DESC="Descrição"
        T_BTN_RUN="Executar"
        T_BTN_EXIT="Sair"
        T_ACT_INSTALL="Instalar dependências"
        T_ACT_CHECK="Verificar dependências"
        T_ACT_BUILD="Compilar kernel"
        T_ACT_CLEAN="Limpar builds"
        T_DESC_INSTALL="Instala todos os pacotes necessários para compilar"
        T_DESC_CHECK="Apenas verifica o que falta, sem instalar"
        T_DESC_BUILD="Baixa fontes e constrói pacotes .deb do kernel"
        T_DESC_CLEAN="Apaga builds/, out/ e o log de compilação"
        T_CONFIRM_INSTALL="As dependências de compilação serão instaladas.\n\nA senha de <b>root (sudo)</b> será solicitada.\n\nContinuar?"
        T_BTN_INSTALL="Instalar"
        T_BTN_CANCEL="Cancelar"
        T_NO_CONFIGS="Nenhum arquivo <b>DOTconfig-*</b> encontrado em:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Opções de compilação"
        T_BUILD_TEXT="<b>Configurar compilação do kernel</b>"
        T_FIELD_CONFIG="Configuração do kernel"
        T_FIELD_JOBS="Jobs paralelos (0=auto)"
        T_FIELD_AUTO="Modo automático (sem perguntas)"
        T_FIELD_FORCE="Forçar novo download"
        T_BTN_BUILD="Compilar"
        T_CONFIRM_CLEAN="As pastas <b>builds/, out/</b> e o log serão apagados.\n\nContinuar?"
        T_BTN_CLEAN="Limpar"
        T_PRESS_ENTER="Pressione ENTER para fechar..."
        T_MISSING_DEP="Dependência ausente"
        T_INSTALL_WITH="Instale com: sudo apt install"
        T_NOT_FOUND="Diretório não encontrado"
        T_INSTALL_PKG="Instale o pacote EssoraKB primeiro."
        T_AUTH_TITLE="Autenticação"
        T_AUTH_TEXT="Autenticação necessária\npara o usuário: <b>${USER}</b>"
        T_AUTH_PASS=" Senha: "
        T_AUTH_WRONG=" Senha incorreta, tente novamente"
        T_AUTH_OK="--button=Autenticar:0"
        T_AUTH_CANCEL="--button=Cancelar:1"
        ;;
    ar)
        T_HEADER="<b>مُجمِّع نواة Essora Linux</b>"
        T_HEADER_PLAIN="مُجمِّع نواة Essora Linux"
        T_AVAIL="الإعدادات المتاحة"
        T_NONE="(لا شيء)"
        T_ACTION="اختر إجراءً:"
        T_COL_ACT="الإجراء"
        T_COL_DESC="الوصف"
        T_BTN_RUN="تنفيذ"
        T_BTN_EXIT="خروج"
        T_ACT_INSTALL="تثبيت التبعيات"
        T_ACT_CHECK="فحص التبعيات"
        T_ACT_BUILD="تجميع النواة"
        T_ACT_CLEAN="تنظيف البناء"
        T_DESC_INSTALL="تثبيت جميع الحزم اللازمة للتجميع"
        T_DESC_CHECK="فحص ما يُفقد فقط، دون تثبيت"
        T_DESC_BUILD="تنزيل المصادر وبناء حزم .deb للنواة"
        T_DESC_CLEAN="حذف مجلدات builds/ و out/ وسجل البناء"
        T_CONFIRM_INSTALL="سيتم تثبيت تبعيات التجميع.\n\nستحتاج إلى كلمة مرور <b>root (sudo)</b>.\n\nهل تريد المتابعة؟"
        T_BTN_INSTALL="تثبيت"
        T_BTN_CANCEL="إلغاء"
        T_NO_CONFIGS="لا توجد ملفات <b>DOTconfig-*</b> في:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="خيارات البناء"
        T_BUILD_TEXT="<b>تكوين تجميع النواة</b>"
        T_FIELD_CONFIG="إعداد النواة"
        T_FIELD_JOBS="وظائف متوازية (0=تلقائي)"
        T_FIELD_AUTO="الوضع التلقائي (بدون أسئلة)"
        T_FIELD_FORCE="إجبار إعادة التنزيل"
        T_BTN_BUILD="تجميع"
        T_CONFIRM_CLEAN="سيتم حذف <b>builds/ و out/</b> وسجل البناء.\n\nهل تريد المتابعة؟"
        T_BTN_CLEAN="تنظيف"
        T_PRESS_ENTER="اضغط ENTER للإغلاق..."
        T_MISSING_DEP="تبعية مفقودة"
        T_INSTALL_WITH="ثبّت بالأمر: sudo apt install"
        T_NOT_FOUND="المجلد غير موجود"
        T_INSTALL_PKG="يرجى تثبيت حزمة EssoraKB أولاً."
        T_AUTH_TITLE="المصادقة"
        T_AUTH_TEXT="المصادقة مطلوبة\nللمستخدم: <b>${USER}</b>"
        T_AUTH_PASS=" كلمة المرور: "
        T_AUTH_WRONG=" كلمة مرور خاطئة، حاول مرة أخرى"
        T_AUTH_OK="--button=مصادقة:0"
        T_AUTH_CANCEL="--button=إلغاء:1"
        ;;
    ca)
        T_HEADER="<b>Compilador de nucli per a Essora Linux</b>"
        T_HEADER_PLAIN="Compilador de nucli per a Essora Linux"
        T_AVAIL="Configuracions disponibles"
        T_NONE="(cap)"
        T_ACTION="Seleccioneu una acció:"
        T_COL_ACT="Acció"
        T_COL_DESC="Descripció"
        T_BTN_RUN="Executar"
        T_BTN_EXIT="Sortir"
        T_ACT_INSTALL="Instal·lar dependències"
        T_ACT_CHECK="Verificar dependències"
        T_ACT_BUILD="Compilar nucli"
        T_ACT_CLEAN="Netejar builds"
        T_DESC_INSTALL="Instal·la tots els paquets necessaris per compilar"
        T_DESC_CHECK="Només verifica el que falta, sense instal·lar"
        T_DESC_BUILD="Descarrega fonts i construeix paquets .deb del nucli"
        T_DESC_CLEAN="Esborra builds/, out/ i el registre de compilació"
        T_CONFIRM_INSTALL="S'instal·laran les dependències de compilació.\n\nCal la contrasenya de <b>root (sudo)</b>.\n\nContinuar?"
        T_BTN_INSTALL="Instal·lar"
        T_BTN_CANCEL="Cancel·lar"
        T_NO_CONFIGS="No s'han trobat fitxers <b>DOTconfig-*</b> a:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Opcions de compilació"
        T_BUILD_TEXT="<b>Configurar la compilació del nucli</b>"
        T_FIELD_CONFIG="Configuració del nucli"
        T_FIELD_JOBS="Treballs paral·lels (0=auto)"
        T_FIELD_AUTO="Mode automàtic (sense preguntes)"
        T_FIELD_FORCE="Forçar re-descàrrega"
        T_BTN_BUILD="Compilar"
        T_CONFIRM_CLEAN="S'esborraran <b>builds/, out/</b> i el registre.\n\nContinuar?"
        T_BTN_CLEAN="Netejar"
        T_PRESS_ENTER="Premeu ENTER per tancar..."
        T_MISSING_DEP="Dependència que falta"
        T_INSTALL_WITH="Instal·leu amb: sudo apt install"
        T_NOT_FOUND="Directori no trobat"
        T_INSTALL_PKG="Instal·leu primer el paquet EssoraKB."
        T_AUTH_TITLE="Autenticació"
        T_AUTH_TEXT="Cal autenticació\nper a l'usuari: <b>${USER}</b>"
        T_AUTH_PASS=" Contrasenya: "
        T_AUTH_WRONG=" Contrasenya incorrecta, torneu-ho a intentar"
        T_AUTH_OK="--button=Autenticar:0"
        T_AUTH_CANCEL="--button=Cancel·lar:1"
        ;;
    hu)
        T_HEADER="<b>Kernel fordító az Essora Linuxhoz</b>"
        T_HEADER_PLAIN="Kernel fordító az Essora Linuxhoz"
        T_AVAIL="Elérhető konfigurációk"
        T_NONE="(nincs)"
        T_ACTION="Válasszon műveletet:"
        T_COL_ACT="Művelet"
        T_COL_DESC="Leírás"
        T_BTN_RUN="Futtatás"
        T_BTN_EXIT="Kilépés"
        T_ACT_INSTALL="Függőségek telepítése"
        T_ACT_CHECK="Függőségek ellenőrzése"
        T_ACT_BUILD="Kernel fordítása"
        T_ACT_CLEAN="Buildek törlése"
        T_DESC_INSTALL="Telepíti a fordításhoz szükséges összes csomagot"
        T_DESC_CHECK="Csak ellenőrzi, mi hiányzik, telepítés nélkül"
        T_DESC_BUILD="Letölti a forrásokat és .deb csomagokat készít"
        T_DESC_CLEAN="Törli a builds/, out/ mappát és a naplót"
        T_CONFIRM_INSTALL="A fordítási függőségek telepítésre kerülnek.\n\n<b>root (sudo) jelszó</b> szükséges.\n\nFolytatja?"
        T_BTN_INSTALL="Telepítés"
        T_BTN_CANCEL="Mégse"
        T_NO_CONFIGS="Nem találhatók <b>DOTconfig-*</b> fájlok:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Build beállítások"
        T_BUILD_TEXT="<b>Kernel fordítás beállítása</b>"
        T_FIELD_CONFIG="Kernel konfiguráció"
        T_FIELD_JOBS="Párhuzamos feladatok (0=auto)"
        T_FIELD_AUTO="Automatikus mód (kérdések nélkül)"
        T_FIELD_FORCE="Letöltés kényszerítése"
        T_BTN_BUILD="Fordítás"
        T_CONFIRM_CLEAN="A <b>builds/, out/</b> mappák és a napló törlésre kerülnek.\n\nFolytatja?"
        T_BTN_CLEAN="Törlés"
        T_PRESS_ENTER="Nyomjon ENTER-t a bezáráshoz..."
        T_MISSING_DEP="Hiányzó függőség"
        T_INSTALL_WITH="Telepítse ezzel: sudo apt install"
        T_NOT_FOUND="Könyvtár nem található"
        T_INSTALL_PKG="Kérjük, először telepítse az EssoraKB csomagot."
        T_AUTH_TITLE="Hitelesítés"
        T_AUTH_TEXT="Hitelesítés szükséges\na felhasználóhoz: <b>${USER}</b>"
        T_AUTH_PASS=" Jelszó: "
        T_AUTH_WRONG=" Hibás jelszó, próbálja újra"
        T_AUTH_OK="--button=Hitelesítés:0"
        T_AUTH_CANCEL="--button=Mégse:1"
        ;;
    ru)
        T_HEADER="<b>Компилятор ядра для Essora Linux</b>"
        T_HEADER_PLAIN="Компилятор ядра для Essora Linux"
        T_AVAIL="Доступные конфигурации"
        T_NONE="(нет)"
        T_ACTION="Выберите действие:"
        T_COL_ACT="Действие"
        T_COL_DESC="Описание"
        T_BTN_RUN="Выполнить"
        T_BTN_EXIT="Выход"
        T_ACT_INSTALL="Установить зависимости"
        T_ACT_CHECK="Проверить зависимости"
        T_ACT_BUILD="Собрать ядро"
        T_ACT_CLEAN="Очистить сборку"
        T_DESC_INSTALL="Устанавливает все пакеты для компиляции"
        T_DESC_CHECK="Только проверяет, что отсутствует, без установки"
        T_DESC_BUILD="Загружает исходники и создаёт .deb пакеты ядра"
        T_DESC_CLEAN="Удаляет builds/, out/ и журнал сборки"
        T_CONFIRM_INSTALL="Будут установлены зависимости для сборки.\n\nПотребуется пароль <b>root (sudo)</b>.\n\nПродолжить?"
        T_BTN_INSTALL="Установить"
        T_BTN_CANCEL="Отмена"
        T_NO_CONFIGS="Файлы <b>DOTconfig-*</b> не найдены в:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="Параметры сборки"
        T_BUILD_TEXT="<b>Настройка компиляции ядра</b>"
        T_FIELD_CONFIG="Конфигурация ядра"
        T_FIELD_JOBS="Параллельные задачи (0=авто)"
        T_FIELD_AUTO="Автоматический режим (без вопросов)"
        T_FIELD_FORCE="Принудительная повторная загрузка"
        T_BTN_BUILD="Собрать"
        T_CONFIRM_CLEAN="Будут удалены <b>builds/, out/</b> и журнал сборки.\n\nПродолжить?"
        T_BTN_CLEAN="Очистить"
        T_PRESS_ENTER="Нажмите ENTER для закрытия..."
        T_MISSING_DEP="Отсутствует зависимость"
        T_INSTALL_WITH="Установите командой: sudo apt install"
        T_NOT_FOUND="Директория не найдена"
        T_INSTALL_PKG="Пожалуйста, сначала установите пакет EssoraKB."
        T_AUTH_TITLE="Аутентификация"
        T_AUTH_TEXT="Требуется аутентификация\nдля пользователя: <b>${USER}</b>"
        T_AUTH_PASS=" Пароль: "
        T_AUTH_WRONG=" Неверный пароль, попробуйте снова"
        T_AUTH_OK="--button=Войти:0"
        T_AUTH_CANCEL="--button=Отмена:1"
        ;;
    ja)
        T_HEADER="<b>Essora Linux カーネルビルダー</b>"
        T_HEADER_PLAIN="Essora Linux カーネルビルダー"
        T_AVAIL="利用可能な構成"
        T_NONE="(なし)"
        T_ACTION="アクションを選択:"
        T_COL_ACT="アクション"
        T_COL_DESC="説明"
        T_BTN_RUN="実行"
        T_BTN_EXIT="終了"
        T_ACT_INSTALL="依存関係のインストール"
        T_ACT_CHECK="依存関係の確認"
        T_ACT_BUILD="カーネルのビルド"
        T_ACT_CLEAN="ビルドのクリーン"
        T_DESC_INSTALL="コンパイルに必要なすべてのパッケージをインストール"
        T_DESC_CHECK="不足しているものだけ確認、インストールなし"
        T_DESC_BUILD="ソースをダウンロードしてカーネル.debパッケージを構築"
        T_DESC_CLEAN="builds/、out/フォルダとビルドログを削除"
        T_CONFIRM_INSTALL="ビルド依存関係がインストールされます。\n\n<b>root (sudo) パスワード</b>が必要です。\n\n続行しますか？"
        T_BTN_INSTALL="インストール"
        T_BTN_CANCEL="キャンセル"
        T_NO_CONFIGS="<b>DOTconfig-*</b>ファイルが見つかりません:\n${CONFIGS_DIR}"
        T_BUILD_TITLE="ビルドオプション"
        T_BUILD_TEXT="<b>カーネルコンパイルの設定</b>"
        T_FIELD_CONFIG="カーネル構成"
        T_FIELD_JOBS="並列ジョブ数 (0=自動)"
        T_FIELD_AUTO="自動モード (確認なし)"
        T_FIELD_FORCE="強制再ダウンロード"
        T_BTN_BUILD="ビルド"
        T_CONFIRM_CLEAN="<b>builds/、out/</b>とビルドログが削除されます。\n\n続行しますか？"
        T_BTN_CLEAN="クリーン"
        T_PRESS_ENTER="Enterキーを押して閉じる..."
        T_MISSING_DEP="依存関係が見つかりません"
        T_INSTALL_WITH="インストール: sudo apt install"
        T_NOT_FOUND="ディレクトリが見つかりません"
        T_INSTALL_PKG="最初にEssoraKBパッケージをインストールしてください。"
        T_AUTH_TITLE="認証"
        T_AUTH_TEXT="認証が必要です\nユーザー: <b>${USER}</b>"
        T_AUTH_PASS=" パスワード: "
        T_AUTH_WRONG=" パスワードが違います。再試行してください"
        T_AUTH_OK="--button=認証:0"
        T_AUTH_CANCEL="--button=キャンセル:1"
        ;;
    zh)
        T_HEADER="<b>Essora Linux 内核构建器</b>"
        T_HEADER_PLAIN="Essora Linux 内核构建器"
        T_AVAIL="可用配置"
        T_NONE="（无）"
        T_ACTION="选择操作："
        T_COL_ACT="操作"
        T_COL_DESC="描述"
        T_BTN_RUN="执行"
        T_BTN_EXIT="退出"
        T_ACT_INSTALL="安装依赖"
        T_ACT_CHECK="检查依赖"
        T_ACT_BUILD="编译内核"
        T_ACT_CLEAN="清理构建"
        T_DESC_INSTALL="安装编译所需的所有软件包"
        T_DESC_CHECK="仅检查缺少什么，不安装"
        T_DESC_BUILD="下载源码并构建内核 .deb 包"
        T_DESC_CLEAN="删除 builds/、out/ 目录和构建日志"
        T_CONFIRM_INSTALL="将安装编译依赖。\n\n需要 <b>root (sudo) 密码</b>。\n\n继续？"
        T_BTN_INSTALL="安装"
        T_BTN_CANCEL="取消"
        T_NO_CONFIGS="在以下目录未找到 <b>DOTconfig-*</b> 文件：\n${CONFIGS_DIR}"
        T_BUILD_TITLE="构建选项"
        T_BUILD_TEXT="<b>配置内核编译</b>"
        T_FIELD_CONFIG="内核配置"
        T_FIELD_JOBS="并行任务数 (0=自动)"
        T_FIELD_AUTO="自动模式（无提示）"
        T_FIELD_FORCE="强制重新下载"
        T_BTN_BUILD="编译"
        T_CONFIRM_CLEAN="将删除 <b>builds/、out/</b> 目录和构建日志。\n\n继续？"
        T_BTN_CLEAN="清理"
        T_PRESS_ENTER="按 ENTER 键关闭..."
        T_MISSING_DEP="缺少依赖"
        T_INSTALL_WITH="安装命令：sudo apt install"
        T_NOT_FOUND="目录未找到"
        T_INSTALL_PKG="请先安装 EssoraKB 软件包。"
        T_AUTH_TITLE="身份验证"
        T_AUTH_TEXT="需要身份验证\n用户: <b>${USER}</b>"
        T_AUTH_PASS=" 密码: "
        T_AUTH_WRONG=" 密码错误，请重试"
        T_AUTH_OK="--button=验证:0"
        T_AUTH_CANCEL="--button=取消:1"
        ;;
    esac
}
setup_i18n

# wmctrl/xdotool son opcionales (hide/show GUI); xdpyinfo para centrar xterm
for cmd in yad xterm xdpyinfo; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        yad --error --title="EssoraKB" --center \
            --window-icon="${ICON}" \
            --text="${T_MISSING_DEP}: <b>${cmd}</b>\n${T_INSTALL_WITH} ${cmd}" \
            --button="OK":0 2>/dev/null || echo "ERROR: missing $cmd" >&2
        exit 1
    fi
done

WIN_ICON_OPT=""
[[ -f "${ICON}" ]] && WIN_ICON_OPT="--window-icon=${ICON}"

get_screen_geometry() {
    xdpyinfo 2>/dev/null \
        | awk '/dimensions:/{split($2,a,"x"); print a[1], a[2]; exit}' \
        || echo "1920 1080"
}
read -r SCR_W SCR_H <<< "$(get_screen_geometry)"

get_configs() {
    find "${CONFIGS_DIR}" -maxdepth 1 -type f -name 'DOTconfig-*' -printf '%f\n' \
        | sort 2>/dev/null || true
}

build_combo() {
    local first=1 result=""
    while IFS= read -r cfg; do
        [[ $first -eq 1 ]] && { result="${cfg}"; first=0; } || result="${result}!${cfg}"
    done < <(get_configs)
    echo "${result}"
}

run_in_xterm() {
    local window_title="$1" cmd="$2"
    local pos_x=$(( (SCR_W - 810) / 2 ))
    local pos_y=$(( (SCR_H - 630) / 2 ))
    [[ $pos_x -lt 0 ]] && pos_x=0
    [[ $pos_y -lt 0 ]] && pos_y=0

    local main_wid=""
    command -v xdotool >/dev/null 2>&1 && \
        main_wid=$(xdotool search --name "${TITLE}" 2>/dev/null | head -1) || true
    [[ -n "${main_wid}" ]] && xdotool windowunmap "${main_wid}" 2>/dev/null || true

    xterm \
        -title "${window_title}" \
        -bg "#1e1e2e" -fg "#cdd6f4" \
        -fa "Monospace" -fs 10 \
        -geometry "100x35+${pos_x}+${pos_y}" \
        -e bash -c "${cmd}; echo; printf '  ${T_PRESS_ENTER}'; read -r _"

    [[ -n "${main_wid}" ]] && xdotool windowmap "${main_wid}" 2>/dev/null || true
    [[ -n "${main_wid}" ]] && xdotool windowactivate --sync "${main_wid}" 2>/dev/null || true
}

main_menu() {
    do_install() {
        if [[ "$(id -u)" -ne 0 ]]; then
            bash "${BASH_SOURCE[0]}" --action=install
        else
            action_install_deps
        fi
    }

    local SELF
    SELF="$(readlink -f "${BASH_SOURCE[0]}")"

    yad \
        --form \
        --title="${TITLE}" \
        ${WIN_ICON_OPT} \
        --image="${ICON}" \
        --image-on-top \
        --width=640 \
        --borders=16 \
        --columns=1 \
        --align=fill \
        --center \
        --text="<b><span foreground='#89b4fa' font='16'>${T_HEADER_PLAIN}</span></b>\n\n<small><span foreground='#77960A'>Author: josejp2424  ·  License: GPL-3.0  ·\nversion 0.1.2</span></small>\n" \
        --field="📦  ${T_ACT_INSTALL}!!${T_DESC_INSTALL}:FBTN" \
            "bash '${SELF}' --action=install" \
        --field="🔍  ${T_ACT_CHECK}!!${T_DESC_CHECK}:FBTN" \
            "bash '${SELF}' --action=check" \
        --field="🔨  ${T_ACT_BUILD}!!${T_DESC_BUILD}:FBTN" \
            "bash '${SELF}' --action=build" \
        --field="🗑   ${T_ACT_CLEAN}!!${T_DESC_CLEAN}:FBTN" \
            "bash '${SELF}' --action=clean" \
        --button="${T_BTN_EXIT}":0 \
        2>/dev/null

    exit 0
}

action_install_deps() {
    if [[ "$(id -u)" -ne 0 ]]; then
        yad --question \
            --title="EssoraKB" \
            ${WIN_ICON_OPT} \
            --image=dialog-question \
            --text="${T_CONFIRM_INSTALL}" \
            --width=400 --center \
            --button="${T_BTN_CANCEL}":1 \
            --button="${T_BTN_INSTALL}":0 \
            2>/dev/null || exit 0
        run_in_xterm "EssoraKB — ${T_ACT_INSTALL}" \
            "sudo bash '${ESSORAKB_DIR}/install-deps.sh'"
    else
        run_in_xterm "EssoraKB — ${T_ACT_INSTALL}" \
            "bash '${ESSORAKB_DIR}/install-deps.sh'"
    fi
}

action_check_deps() {
    run_in_xterm "EssoraKB — ${T_ACT_CHECK}" \
        "bash '${ESSORAKB_DIR}/install-deps.sh' --check"
}

action_build() {
    local COMBO
    COMBO="$(build_combo)"
    if [[ -z "${COMBO}" ]]; then
        yad --error --title="EssoraKB" ${WIN_ICON_OPT} \
            --text="${T_NO_CONFIGS}" \
            --width=400 --center \
            --button="OK":0 2>/dev/null
        return 0
    fi

    local result
    result=$(yad \
        --form \
        --title="${T_BUILD_TITLE}" \
        ${WIN_ICON_OPT} \
        --width=440 --center \
        --text="${T_BUILD_TEXT}" \
        --field="${T_FIELD_CONFIG}:CB"  "${COMBO}" \
        --field="${T_FIELD_JOBS}:NUM"   "0" \
        --field="${T_FIELD_AUTO}:CHK"   "FALSE" \
        --field="${T_FIELD_FORCE}:CHK"  "FALSE" \
        --button="${T_BTN_CANCEL}":1 \
        --button="${T_BTN_BUILD}":0 \
        2>/dev/null) || return 0

    IFS='|' read -r cfg_chosen jobs_val auto_mode force_dl <<< "${result}"

    local args=()
    [[ -n "${cfg_chosen}" ]]             && args+=("--config" "${cfg_chosen}")
    [[ "${jobs_val}" =~ ^[1-9][0-9]*$ ]] && args+=("--jobs" "${jobs_val}")
    [[ "${auto_mode}" == "TRUE" ]]        && args+=("--auto")
    [[ "${force_dl}"  == "TRUE" ]]        && args+=("--force")

    local cmd_str
    if [[ "$(id -u)" -ne 0 ]]; then
        cmd_str="sudo bash '${ESSORAKB_DIR}/build.sh' ${args[*]:-}"
    else
        cmd_str="bash '${ESSORAKB_DIR}/build.sh' ${args[*]:-}"
    fi

    run_in_xterm "EssoraKB — ${T_ACT_BUILD} [${cfg_chosen}]" "${cmd_str}"
}

action_clean() {
    yad --question \
        --title="EssoraKB" \
        ${WIN_ICON_OPT} \
        --image=dialog-warning \
        --text="${T_CONFIRM_CLEAN}" \
        --width=400 --center \
        --button="${T_BTN_CANCEL}":1 \
        --button="${T_BTN_CLEAN}":0 \
        2>/dev/null || return 0
    run_in_xterm "EssoraKB — ${T_ACT_CLEAN}" \
        "bash '${ESSORAKB_DIR}/build.sh' clean"
}

dispatch_action() {
    local action="$1"
    if [[ "$(id -u)" -ne 0 ]]; then
        ask_password --action="${action}"
        return
    fi
    case "${action}" in
        install) action_install_deps ;;
        check)   action_check_deps   ;;
        build)   action_build        ;;
        clean)   action_clean        ;;
    esac
}

ask_password() {
    local passwd

    passwd=$(yad \
        --entry \
        --entry-label="${T_AUTH_PASS}" \
        --hide-text \
        --image=dialog-password \
        ${WIN_ICON_OPT} \
        --width=380 \
        --center \
        --text="${T_AUTH_TEXT}" \
        --title="${T_AUTH_TITLE}" \
        ${T_AUTH_CANCEL} ${T_AUTH_OK} \
        2>/dev/null) || exit 0

    [[ -z "${passwd}" ]] && exit 0

    if echo "${passwd}" | sudo -S true 2>/dev/null; then
        exec sudo -S bash "${BASH_SOURCE[0]}" "$@" <<< "${passwd}"
    else
        passwd=$(yad \
            --entry \
            --entry-label="${T_AUTH_PASS}" \
            --hide-text \
            --image=dialog-error \
            ${WIN_ICON_OPT} \
            --width=380 \
            --center \
            --text="${T_AUTH_WRONG}" \
            --title="${T_AUTH_TITLE}" \
            ${T_AUTH_CANCEL} ${T_AUTH_OK} \
            2>/dev/null) || exit 0

        [[ -z "${passwd}" ]] && exit 0
        exec sudo -S bash "${BASH_SOURCE[0]}" "$@" <<< "${passwd}"
    fi
}

if [[ ! -d "${ESSORAKB_DIR}" ]]; then
    yad --error --title="EssoraKB" --center ${WIN_ICON_OPT} \
        --text="${T_NOT_FOUND}:\n<b>${ESSORAKB_DIR}</b>\n\n${T_INSTALL_PKG}" \
        --button="OK":0 2>/dev/null
    exit 1
fi

ACTION=""
for arg in "$@"; do
    case "${arg}" in
        --action=*) ACTION="${arg#--action=}" ;;
    esac
done

if [[ -n "${ACTION}" ]]; then
    if [[ "$(id -u)" -ne 0 ]]; then
        ask_password --action="${ACTION}"
    fi
    case "${ACTION}" in
        install) action_install_deps ;;
        check)   action_check_deps   ;;
        build)   action_build        ;;
        clean)   action_clean        ;;
    esac
    exit 0
fi

if [[ "$(id -u)" -ne 0 ]]; then
    ask_password "$@"
fi

main_menu
