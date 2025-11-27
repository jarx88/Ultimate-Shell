#!/usr/bin/env bash
#===============================================================================
# setup-shell.sh - Modułowy setup powłoki z tutorialami
# 
# Instalacja z GitHuba:
#   bash <(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh)
#
# Użycie lokalne:
#   ./setup-shell.sh              # Interaktywny wybór
#   ./setup-shell.sh --all        # Wszystko
#   ./setup-shell.sh --minimal    # Tylko zsh + fzf + starship
#   ./setup-shell.sh --learn      # Pokaż tutorial
#   ./setup-shell.sh --help       # Pomoc
#===============================================================================

set -uo pipefail

VERSION="1.0.0"
SCRIPT_URL="https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh"

# Ścieżki
LOCAL_BIN="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config"
FZF_DIR="${HOME}/.fzf"
ZSHRC="${HOME}/.zshrc"

# Kolory
if [[ -t 1 ]]; then
    R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m'
    C='\033[0;36m' W='\033[1;37m' DIM='\033[0;90m' NC='\033[0m' BOLD='\033[1m'
else
    R='' G='' Y='' B='' C='' W='' DIM='' NC='' BOLD=''
fi

# Flagi instalacji
INSTALL_ZSH=0
INSTALL_FZF=0
INSTALL_STARSHIP=0
INSTALL_ZOXIDE=0
INSTALL_EZA=0
INSTALL_RIPGREP=0
INSTALL_FD=0
INSTALL_BAT=0
INSTALL_DELTA=0
INSTALL_LAZYGIT=0
INSTALL_BTOP=0
INSTALL_TLDR=0

# System
DISTRO=""
DISTRO_FAMILY=""
PM=""
PM_INSTALL=""
HAVE_SUDO=""
ARCH=""

#===============================================================================
# HELPERS
#===============================================================================
have() { command -v "$1" >/dev/null 2>&1; }
ensure_dir() { [[ -d "$1" ]] || mkdir -p "$1"; }

log_info()    { echo -e "${B}ℹ${NC}  $*"; }
log_ok()      { echo -e "${G}✔${NC}  $*"; }
log_warn()    { echo -e "${Y}⚠${NC}  $*"; }
log_err()     { echo -e "${R}✖${NC}  $*" >&2; }
log_step()    { echo -e "\n${C}▶${NC} ${BOLD}$*${NC}"; }

#===============================================================================
# TUTORIAL / LEARN
#===============================================================================
show_tutorial() {
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════════╗
║                    🎓 TUTORIAL - JAK UŻYWAĆ NARZĘDZI                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│ FZF - Fuzzy Finder (szukanie po części nazwy)                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Ctrl+R     Szukaj w historii komend                                         │
│             → wpisujesz "dock comp" → znajduje "docker compose up -d"        │
│                                                                              │
│  Ctrl+T     Wstaw ścieżkę do pliku                                           │
│             → wpisujesz część nazwy → wstawia pełną ścieżkę                  │
│                                                                              │
│  Alt+C      Zmień katalog                                                    │
│             → szukasz katalogu → od razu cd do niego                         │
│                                                                              │
│  **        Użyj w dowolnej komendzie:                                        │
│             vim **<Tab>     → wybierz plik do edycji                         │
│             cd **<Tab>      → wybierz katalog                                │
│             kill **<Tab>    → wybierz proces do zabicia                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ ZOXIDE - Inteligentne cd (pamięta gdzie chodziłeś)                           │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Jak działa:                                                                 │
│  1. Normalnie chodzisz po katalogach: cd /var/log/nginx                      │
│  2. Zoxide to zapamiętuje                                                    │
│  3. Następnym razem wystarczy: z nginx                                       │
│                                                                              │
│  z foo        Idź do najczęściej używanego katalogu pasującego do "foo"      │
│  z foo bar    Idź do katalogu pasującego do "foo" i "bar"                    │
│  zi           Interaktywny wybór z fzf                                       │
│                                                                              │
│  Przykłady:                                                                  │
│    z proj     → /home/jarek/projects                                         │
│    z ng conf  → /etc/nginx/conf.d                                            │
│    z down     → /home/jarek/Downloads                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ EZA - Nowoczesny ls                                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ls          Lista plików (z ikonami i kolorami)                             │
│  ll          Długa lista + uprawnienia + git status                          │
│  la          Wszystkie pliki (ukryte też)                                    │
│  lt          Drzewo katalogów (2 poziomy)                                    │
│                                                                              │
│  Kolory git:                                                                 │
│    M (żółty)  = zmodyfikowany                                                │
│    N (zielony) = nowy plik                                                   │
│    I (szary)  = ignorowany                                                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ RIPGREP (rg) - Szybkie szukanie w plikach                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  rg "TODO"              Szukaj "TODO" w całym katalogu (rekursywnie)         │
│  rg "error" -i          Bez rozróżniania wielkości liter                     │
│  rg "func" -t py        Tylko w plikach .py                                  │
│  rg "pass" -g "*.conf"  Tylko w plikach *.conf                               │
│  rg "http" -l           Pokaż tylko nazwy plików (bez treści)                │
│  rg "old" -r "new"      Szukaj i pokaż zamianę (nie zapisuje)                │
│  rg "debug" -C 3        Pokaż 3 linie kontekstu                              │
│                                                                              │
│  Przykład pracy:                                                             │
│    rg "DB_HOST" --hidden    → znajdź wszystkie pliki z konfiguracją bazy     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ FD - Szybkie szukanie plików                                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  fd pattern             Szukaj plików pasujących do pattern                  │
│  fd "\.log$"            Wszystkie pliki .log                                 │
│  fd -e py               Wszystkie pliki .py                                  │
│  fd -t d                Tylko katalogi                                       │
│  fd -t f -x rm          Znajdź pliki i usuń (ostrożnie!)                     │
│  fd -H                  Włącznie z ukrytymi plikami                          │
│  fd config /etc         Szukaj w konkretnym katalogu                         │
│                                                                              │
│  Przykłady:                                                                  │
│    fd -e tmp -x rm {}   → usuń wszystkie pliki .tmp                          │
│    fd -t d node_modules → znajdź wszystkie node_modules                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ BAT - Cat z podświetlaniem składni                                           │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  bat plik.py            Pokaż plik z kolorami i numerami linii               │
│  bat -l json plik       Wymuś język (gdy brak rozszerzenia)                  │
│  bat -p plik            Plain - bez numerów i ramek                          │
│  bat -A plik            Pokaż niewidoczne znaki (taby, końce linii)          │
│  bat -r 10:20 plik      Tylko linie 10-20                                    │
│                                                                              │
│  Kombinacje:                                                                 │
│    cat log.txt | bat -l log    → kolorowanie logów z pipe                    │
│    bat *.sh                    → pokaż wiele plików naraz                    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ DELTA - Ładne diffy w git                                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Po instalacji działa automatycznie z git!                                   │
│                                                                              │
│  git diff               Teraz pokazuje ładne kolory i numery linii           │
│  git show               Kolorowy podgląd commitów                            │
│  git log -p             Historia z kolorowymi diffami                        │
│                                                                              │
│  Porównanie plików (bez gita):                                               │
│    delta plik1 plik2                                                         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ LAZYGIT - Git w trybie wizualnym                                             │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  lg                     Uruchom lazygit                                      │
│                                                                              │
│  Nawigacja:                                                                  │
│    ← → ↑ ↓              Poruszanie się między panelami i plikami             │
│    Enter                Rozwiń/zwiń                                          │
│    Space                Stage/unstage plik                                   │
│    c                    Commit                                               │
│    p                    Pull                                                 │
│    P                    Push                                                 │
│    b                    Branch menu                                          │
│    ?                    Pokaż wszystkie skróty                               │
│    q                    Wyjdź                                                │
│                                                                              │
│  Tip: Idealny gdy nie pamiętasz komend git!                                  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ BTOP - Monitor systemu                                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  btop                   Uruchom monitor                                      │
│                                                                              │
│  Klawisze:                                                                   │
│    m                    Menu opcji                                           │
│    f                    Filtruj procesy                                      │
│    k                    Zabij proces                                         │
│    t                    Tryb drzewa procesów                                 │
│    s                    Sortuj (kliknij kolumnę)                             │
│    h                    Pomoc                                                │
│    q                    Wyjdź                                                │
│                                                                              │
│  Pokazuje: CPU, RAM, dyski, sieć, procesy - wszystko w jednym miejscu        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TLDR - Praktyczna pomoc                                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  tldr tar               Pokaż praktyczne przykłady dla tar                   │
│  tldr git-rebase        Przykłady git rebase                                 │
│  tldr --update          Aktualizuj bazę                                      │
│                                                                              │
│  Zamiast 1000 linii man pages dostajesz 5-10 najczęstszych użyć              │
│                                                                              │
│  Przykład: tldr tar                                                          │
│    tar czf archiwum.tar.gz folder/    # Spakuj                               │
│    tar xzf archiwum.tar.gz            # Rozpakuj                             │
│    tar tzf archiwum.tar.gz            # Lista zawartości                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ 💡 PRZYDATNE ALIASY (po instalacji)                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ..          cd ..                                                           │
│  ...         cd ../..                                                        │
│  please      sudo (poprzednia komenda)                                       │
│  reload      przeładuj shell                                                 │
│  ports       pokaż otwarte porty                                             │
│  myip        pokaż publiczne IP                                              │
│  extract x   rozpakuj dowolne archiwum                                       │
│  mkcd dir    utwórz katalog i wejdź                                          │
│                                                                              │
│  Git:                                                                        │
│  gs          git status -sb (krótki status)                                  │
│  ga          git add                                                         │
│  gc          git commit                                                      │
│  gp          git push                                                        │
│  gl          git log --oneline --graph                                       │
│  gd          git diff                                                        │
│  lg          lazygit                                                         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

Tip: Po instalacji wpisz "shellhelp" żeby zobaczyć tę pomoc ponownie!

EOF
}

#===============================================================================
# HELP
#===============================================================================
show_help() {
    cat << EOF
${BOLD}setup-shell.sh${NC} v${VERSION} - Modułowy setup powłoki

${C}INSTALACJA Z INTERNETU:${NC}
    bash <(curl -fsSL ${SCRIPT_URL})

${C}UŻYCIE:${NC}
    ./setup-shell.sh [OPCJE]

${C}OPCJE:${NC}
    ${W}--help, -h${NC}        Ta pomoc
    ${W}--learn${NC}           Pokaż tutorial (jak używać narzędzi)
    ${W}--minimal${NC}         Tylko: zsh + fzf + starship
    ${W}--all${NC}             Wszystkie narzędzia (bez pytania)
    ${W}--list${NC}            Lista dostępnych narzędzi
    ${W}--dry-run${NC}         Pokaż co zostanie zainstalowane

${C}PRZYKŁADY:${NC}
    ./setup-shell.sh                 # Interaktywny wybór
    ./setup-shell.sh --minimal       # Szybka instalacja podstaw
    ./setup-shell.sh --all           # Pełna instalacja
    ./setup-shell.sh --learn         # Najpierw poczytaj co robi każde narzędzie

${C}NARZĘDZIA:${NC}
    ${G}Podstawowe:${NC}
      zsh        Nowoczesna powłoka (wymagane)
      fzf        Fuzzy finder - Ctrl+R do historii
      starship   Ładny, szybki prompt

    ${Y}Nawigacja:${NC}
      zoxide     Inteligentne cd (pamięta katalogi)
      eza        Kolorowy ls z git statusem

    ${B}Szukanie:${NC}
      ripgrep    Szybki grep (rg)
      fd         Szybki find
      bat        Cat z kolorowaniem

    ${C}Git:${NC}
      delta      Ładne diffy
      lazygit    Git TUI

    ${DIM}System:${NC}
      btop       Monitor zasobów
      tldr       Praktyczna pomoc

${C}PO INSTALACJI:${NC}
    shellhelp    Pokaż tutorial w terminalu

EOF
}

show_list() {
    cat << EOF
${BOLD}Dostępne narzędzia:${NC}

${G}Podstawowe (zalecane):${NC}
  ✓ zsh        Nowoczesna powłoka z pluginami
  ✓ fzf        Fuzzy finder (Ctrl+R, Ctrl+T, Alt+C)
  ✓ starship   Szybki, konfigurowalny prompt

${Y}Nawigacja:${NC}
  ○ zoxide     Inteligentne cd - pamięta gdzie chodziłeś
  ○ eza        ls z kolorami, ikonami i git statusem

${B}Szukanie w plikach:${NC}
  ○ ripgrep    Bardzo szybki grep (rg)
  ○ fd         Szybki find z ludzką składnią
  ○ bat        cat z podświetlaniem składni

${C}Git:${NC}
  ○ delta      Kolorowe diffy w git
  ○ lazygit    Wizualny klient git (TUI)

${DIM}System:${NC}
  ○ btop       Piękny monitor CPU/RAM/sieci
  ○ tldr       Krótkie przykłady zamiast man pages

Użyj ${BOLD}--learn${NC} żeby zobaczyć jak używać każdego narzędzia.
EOF
}

#===============================================================================
# DETEKCJA SYSTEMU
#===============================================================================
detect_system() {
    log_step "Wykrywam system..."
    
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
    esac
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="${ID:-unknown}"
    fi
    
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
            DISTRO_FAMILY="debian"
            PM="apt"
            PM_INSTALL="apt install -y"
            ;;
        fedora)
            DISTRO_FAMILY="fedora"
            PM="dnf"
            PM_INSTALL="dnf install -y"
            ;;
        rhel|centos|rocky|almalinux|ol|oraclelinux|oracle)
            DISTRO_FAMILY="rhel"
            PM=$(have dnf && echo "dnf" || echo "yum")
            PM_INSTALL="$PM install -y"
            ;;
        arch|manjaro)
            DISTRO_FAMILY="arch"
            PM="pacman"
            PM_INSTALL="pacman -S --noconfirm --needed"
            ;;
        *)
            # Auto-detect
            if have apt; then DISTRO_FAMILY="debian"; PM="apt"; PM_INSTALL="apt install -y"
            elif have dnf; then DISTRO_FAMILY="fedora"; PM="dnf"; PM_INSTALL="dnf install -y"
            elif have yum; then DISTRO_FAMILY="rhel"; PM="yum"; PM_INSTALL="yum install -y"
            elif have pacman; then DISTRO_FAMILY="arch"; PM="pacman"; PM_INSTALL="pacman -S --noconfirm --needed"
            fi
            ;;
    esac
    
    HAVE_SUDO=$(sudo -n true 2>/dev/null && echo 1 || echo 0)
    
    log_ok "System: ${BOLD}$DISTRO${NC} ($DISTRO_FAMILY) | Arch: $ARCH"
}

#===============================================================================
# INTERAKTYWNY WYBÓR
#===============================================================================
interactive_select() {
    echo ""
    echo -e "${BOLD}Wybierz co zainstalować:${NC}"
    echo ""
    
    # Podstawowe - domyślnie TAK
    echo -e "${G}▸ Podstawowe:${NC}"
    read -p "  zsh + antigen (nowoczesna powłoka)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_ZSH=1
    
    read -p "  fzf (fuzzy finder, Ctrl+R)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_FZF=1
    
    read -p "  starship (ładny prompt)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_STARSHIP=1
    
    # Nawigacja
    echo ""
    echo -e "${Y}▸ Nawigacja:${NC}"
    read -p "  zoxide (inteligentne cd)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_ZOXIDE=1
    
    read -p "  eza (kolorowy ls z git)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_EZA=1
    
    # Szukanie
    echo ""
    echo -e "${B}▸ Szukanie:${NC}"
    read -p "  ripgrep (szybki grep)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_RIPGREP=1
    
    read -p "  fd (szybki find)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_FD=1
    
    read -p "  bat (cat z kolorami)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_BAT=1
    
    # Git
    echo ""
    echo -e "${C}▸ Git:${NC}"
    read -p "  delta (ładne diffy)? [Y/n] " -n 1 -r; echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && INSTALL_DELTA=1
    
    read -p "  lazygit (git TUI)? [y/N] " -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_LAZYGIT=1
    
    # System
    echo ""
    echo -e "${DIM}▸ System:${NC}"
    read -p "  btop (monitor zasobów)? [y/N] " -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_BTOP=1
    
    read -p "  tldr (krótka pomoc)? [y/N] " -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_TLDR=1
    
    echo ""
}

set_minimal() {
    INSTALL_ZSH=1
    INSTALL_FZF=1
    INSTALL_STARSHIP=1
}

set_all() {
    INSTALL_ZSH=1
    INSTALL_FZF=1
    INSTALL_STARSHIP=1
    INSTALL_ZOXIDE=1
    INSTALL_EZA=1
    INSTALL_RIPGREP=1
    INSTALL_FD=1
    INSTALL_BAT=1
    INSTALL_DELTA=1
    INSTALL_LAZYGIT=1
    INSTALL_BTOP=1
    INSTALL_TLDR=1
}

#===============================================================================
# INSTALACJA
#===============================================================================
setup_repos() {
    [[ "$HAVE_SUDO" != "1" ]] && return
    
    case "$DISTRO_FAMILY" in
        rhel)
            if ! rpm -qa | grep -Eq 'epel-release|oracle-epel'; then
                log_info "Instaluję EPEL..."
                local REL=$(rpm -E %rhel 2>/dev/null || echo "7")
                if [[ "$DISTRO" =~ ^(ol|oracle) ]]; then
                    sudo $PM_INSTALL "oracle-epel-release-el${REL}" 2>/dev/null || true
                else
                    sudo $PM_INSTALL epel-release 2>/dev/null || true
                fi
            fi
            ;;
        debian)
            sudo apt update -qq
            ;;
    esac
}

install_system_packages() {
    [[ "$HAVE_SUDO" != "1" ]] && return
    
    log_step "Instaluję pakiety systemowe..."
    
    local pkgs=(git curl wget unzip)
    
    # zsh
    [[ $INSTALL_ZSH -eq 1 ]] && pkgs+=(zsh)
    
    # Narzędzia z repo (jeśli dostępne)
    case "$DISTRO_FAMILY" in
        debian)
            [[ $INSTALL_RIPGREP -eq 1 ]] && pkgs+=(ripgrep)
            [[ $INSTALL_FD -eq 1 ]] && pkgs+=(fd-find)
            [[ $INSTALL_BAT -eq 1 ]] && pkgs+=(bat)
            ;;
        fedora|arch)
            [[ $INSTALL_RIPGREP -eq 1 ]] && pkgs+=(ripgrep)
            [[ $INSTALL_FD -eq 1 ]] && pkgs+=(fd-find)
            [[ $INSTALL_BAT -eq 1 ]] && pkgs+=(bat)
            ;;
    esac
    
    sudo $PM_INSTALL "${pkgs[@]}" 2>&1 | grep -E "(Installing|Upgrading|is already)" || true
    
    # Symlink fd na Debianie (nazywa się fdfind)
    if [[ "$DISTRO_FAMILY" == "debian" ]] && have fdfind && ! have fd; then
        ensure_dir "$LOCAL_BIN"
        ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
    fi
    
    # Symlink bat na starszych systemach (nazywa się batcat)
    if have batcat && ! have bat; then
        ensure_dir "$LOCAL_BIN"
        ln -sf "$(which batcat)" "$LOCAL_BIN/bat"
    fi
}

install_fzf() {
    [[ $INSTALL_FZF -eq 0 ]] && return
    have fzf && { log_ok "fzf już zainstalowany"; return; }
    
    log_info "Instaluję fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf "$FZF_DIR" 2>/dev/null
    "$FZF_DIR/install" --bin --key-bindings --completion --no-update-rc >/dev/null 2>&1
    ensure_dir "$LOCAL_BIN"
    ln -sf "$FZF_DIR/bin/fzf" "$LOCAL_BIN/fzf"
}

install_starship() {
    [[ $INSTALL_STARSHIP -eq 0 ]] && return
    have starship && { log_ok "starship już zainstalowany"; return; }
    
    log_info "Instaluję starship..."
    ensure_dir "$LOCAL_BIN"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir "$LOCAL_BIN" --yes >/dev/null 2>&1
}

install_zoxide() {
    [[ $INSTALL_ZOXIDE -eq 0 ]] && return
    have zoxide && { log_ok "zoxide już zainstalowany"; return; }
    
    log_info "Instaluję zoxide..."
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1
}

install_eza() {
    [[ $INSTALL_EZA -eq 0 ]] && return
    (have eza || have exa) && { log_ok "eza/exa już zainstalowany"; return; }
    
    log_info "Instaluję eza..."
    local version="0.18.0"
    local url="https://github.com/eza-community/eza/releases/download/v${version}/eza_x86_64-unknown-linux-gnu.tar.gz"
    [[ "$ARCH" == "arm64" ]] && url="https://github.com/eza-community/eza/releases/download/v${version}/eza_aarch64-unknown-linux-gnu.tar.gz"
    
    ensure_dir "$LOCAL_BIN"
    curl -fsSL "$url" | tar xz -C "$LOCAL_BIN" 2>/dev/null || true
}

install_delta() {
    [[ $INSTALL_DELTA -eq 0 ]] && return
    have delta && { log_ok "delta już zainstalowany"; return; }
    
    log_info "Instaluję delta..."
    local version="0.16.5"
    local url="https://github.com/dandavison/delta/releases/download/${version}/delta-${version}-x86_64-unknown-linux-gnu.tar.gz"
    [[ "$ARCH" == "arm64" ]] && url="https://github.com/dandavison/delta/releases/download/${version}/delta-${version}-aarch64-unknown-linux-gnu.tar.gz"
    
    local tmp="/tmp/delta-$$"
    mkdir -p "$tmp"
    curl -fsSL "$url" | tar xz -C "$tmp" --strip-components=1 2>/dev/null
    ensure_dir "$LOCAL_BIN"
    mv "$tmp/delta" "$LOCAL_BIN/" 2>/dev/null || true
    rm -rf "$tmp"
}

install_lazygit() {
    [[ $INSTALL_LAZYGIT -eq 0 ]] && return
    have lazygit && { log_ok "lazygit już zainstalowany"; return; }
    
    log_info "Instaluję lazygit..."
    local version="0.41.0"
    local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    [[ "$ARCH" == "arm64" ]] && url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_arm64.tar.gz"
    
    ensure_dir "$LOCAL_BIN"
    curl -fsSL "$url" | tar xz -C "$LOCAL_BIN" lazygit 2>/dev/null || true
}

install_btop() {
    [[ $INSTALL_BTOP -eq 0 ]] && return
    have btop && { log_ok "btop już zainstalowany"; return; }
    
    log_info "Instaluję btop..."
    local version="1.3.0"
    local url="https://github.com/aristocratos/btop/releases/download/v${version}/btop-x86_64-linux-musl.tbz"
    [[ "$ARCH" == "arm64" ]] && url="https://github.com/aristocratos/btop/releases/download/v${version}/btop-aarch64-linux-musl.tbz"
    
    local tmp="/tmp/btop-$$"
    mkdir -p "$tmp"
    curl -fsSL "$url" | tar xj -C "$tmp" 2>/dev/null
    ensure_dir "$LOCAL_BIN"
    [[ -f "$tmp/btop/bin/btop" ]] && mv "$tmp/btop/bin/btop" "$LOCAL_BIN/"
    rm -rf "$tmp"
}

install_tldr() {
    [[ $INSTALL_TLDR -eq 0 ]] && return
    have tldr && { log_ok "tldr już zainstalowany"; return; }
    
    log_info "Instaluję tldr..."
    local version="1.6.1"
    local url="https://github.com/dbrgn/tealdeer/releases/download/v${version}/tealdeer-linux-x86_64-musl"
    [[ "$ARCH" == "arm64" ]] && url="https://github.com/dbrgn/tealdeer/releases/download/v${version}/tealdeer-linux-arm-musleabi"
    
    ensure_dir "$LOCAL_BIN"
    curl -fsSL "$url" -o "$LOCAL_BIN/tldr"
    chmod +x "$LOCAL_BIN/tldr"
    "$LOCAL_BIN/tldr" --update >/dev/null 2>&1 || true
}

#===============================================================================
# KONFIGURACJA
#===============================================================================
generate_zshrc() {
    log_step "Generuję konfigurację..."

    # Backup and remove existing config (handle permission issues)
    if [[ -f "$ZSHRC" ]]; then
        cp "$ZSHRC" "${ZSHRC}.bak.$(date +%s)" 2>/dev/null || true
        # Try normal rm first, then sudo if needed
        if ! rm -f "$ZSHRC" 2>/dev/null; then
            if [[ "$HAVE_SUDO" == "1" ]]; then
                sudo rm -f "$ZSHRC" 2>/dev/null || true
            fi
        fi
    fi

    # Fix ownership if file still exists (created by root from previous failed install)
    if [[ -f "$ZSHRC" ]] && [[ ! -w "$ZSHRC" ]] && [[ "$HAVE_SUDO" == "1" ]]; then
        sudo chown "$(id -u):$(id -g)" "$ZSHRC" 2>/dev/null || true
    fi

    # Import historii z bash
    if [[ -f "${HOME}/.bash_history" ]] && [[ ! -f "${HOME}/.zsh_history" ]]; then
        awk '!x[$0]++' "${HOME}/.bash_history" > "${HOME}/.zsh_history" 2>/dev/null || true
    fi

    # Write new config (to temp file first, then move)
    local tmp_zshrc
    tmp_zshrc=$(mktemp) || { log_err "Nie można utworzyć pliku tymczasowego"; return 1; }

    cat > "$tmp_zshrc" << 'ZSHRC'
# === PATH ===
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="${EDITOR:-vim}"
export LANG="${LANG:-en_US.UTF-8}"

# === HISTORIA ===
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=20000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE HIST_FIND_NO_DUPS SHARE_HISTORY

# === OPCJE ===
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS CORRECT
setopt INTERACTIVE_COMMENTS COMPLETE_IN_WORD NO_BEEP

# === KOMPLETACJE ===
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# === ANTIGEN ===
[[ -f "$HOME/antigen.zsh" ]] && {
    source "$HOME/antigen.zsh"
    antigen bundle zsh-users/zsh-completions
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen apply
}

# === FZF ===
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --info=inline"
[[ -f "$HOME/.fzf/shell/key-bindings.zsh" ]] && source "$HOME/.fzf/shell/key-bindings.zsh"
[[ -f "$HOME/.fzf/shell/completion.zsh" ]] && source "$HOME/.fzf/shell/completion.zsh"

# FZF z fd/ripgrep
command -v fd &>/dev/null && {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
}

# Preview z bat
command -v bat &>/dev/null && {
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null | head -200'"
}

# Ulepszone Ctrl+R (unikalne wpisy)
fzf-history-unique() {
    local selected=$(fc -l 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | tac | awk '!x[$0]++' | \
        fzf --height=40% --scheme=history --query="$LBUFFER")
    [[ -n "$selected" ]] && LBUFFER="$selected"
    zle reset-prompt
}
zle -N fzf-history-unique
bindkey '^R' fzf-history-unique

# === STARSHIP ===
command -v starship &>/dev/null && eval "$(starship init zsh)"

# === ZOXIDE ===
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# === ALIASY - LS ===
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza -lah --group-directories-first --icons --git'
    alias la='eza -a --group-directories-first --icons'
    alias lt='eza --tree --level=2 --icons'
elif command -v exa &>/dev/null; then
    alias ls='exa --group-directories-first'
    alias ll='exa -lah --group-directories-first --git'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah'
fi

# === ALIASY - PODSTAWOWE ===
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias ports='ss -tulanp 2>/dev/null || netstat -tulpn'
alias myip='curl -s ifconfig.me && echo'
alias reload='exec $SHELL -l'
alias please='sudo $(fc -ln -1)'

# === ALIASY - GIT ===
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push'
alias gpl='git pull --ff-only'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch -vv'
command -v lazygit &>/dev/null && alias lg='lazygit'

# === FUNKCJE ===
# Rozpakuj archiwum
extract() {
    [[ ! -f "$1" ]] && { echo "Brak pliku: $1"; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.7z)             7z x "$1" ;;
        *)                echo "Nieznany format: $1" ;;
    esac
}

# Utwórz katalog i wejdź
mkcd() { mkdir -p "$1" && cd "$1"; }

# Szybki serwer HTTP
serve() { python3 -m http.server "${1:-8000}"; }

# TLDR / cheat
command -v tldr &>/dev/null || cheat() { curl -s "cheat.sh/$1"; }

# === SHELLHELP ===
shellhelp() {
    cat << 'HELP'
╔════════════════════════════════════════════════════════════════════╗
║                    🚀 SHELL QUICK REFERENCE                        ║
╠════════════════════════════════════════════════════════════════════╣
║ SKRÓTY FZF:                                                        ║
║   Ctrl+R     Szukaj w historii                                     ║
║   Ctrl+T     Wstaw ścieżkę do pliku                                ║
║   Alt+C      Zmień katalog                                         ║
║   **<Tab>    Fuzzy completion (vim **, cd **)                      ║
╠════════════════════════════════════════════════════════════════════╣
║ ZOXIDE:                                                            ║
║   z foo      Idź do katalogu pasującego do "foo"                   ║
║   zi         Interaktywny wybór                                    ║
╠════════════════════════════════════════════════════════════════════╣
║ NARZĘDZIA:                                                         ║
║   rg "text"    Szukaj tekstu w plikach (ripgrep)                   ║
║   fd "*.log"   Szukaj plików (fd)                                  ║
║   bat plik     Cat z kolorami                                      ║
║   lg           Lazygit (git TUI)                                   ║
║   btop         Monitor systemu                                     ║
║   tldr cmd     Krótka pomoc dla komendy                            ║
╠════════════════════════════════════════════════════════════════════╣
║ ALIASY GIT:                                                        ║
║   gs=status  ga=add  gc=commit  gp=push  gl=log  gd=diff           ║
╚════════════════════════════════════════════════════════════════════╝
HELP
}

# === FETCH (system info) ===
fetch() {
    local C1='\033[1;36m' C2='\033[0;37m' NC='\033[0m'

    # OS info
    local os="" kernel="" uptime_str="" mem="" disk="" lip="" pip=""

    if [[ -f /etc/os-release ]]; then
        os=$(. /etc/os-release && echo "$PRETTY_NAME")
    fi
    kernel=$(uname -r)

    # Uptime
    if [[ -f /proc/uptime ]]; then
        local up_sec=${$(</proc/uptime)%% *}
        local days=$((${up_sec%.*} / 86400))
        local hours=$(( (${up_sec%.*} % 86400) / 3600 ))
        local mins=$(( (${up_sec%.*} % 3600) / 60 ))
        uptime_str="${days}d ${hours}h ${mins}m"
    fi

    # Memory
    if [[ -f /proc/meminfo ]]; then
        local mem_total=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
        local mem_avail=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
        local mem_used=$((mem_total - mem_avail))
        mem="${mem_used}M / ${mem_total}M"
    fi

    # Disk
    disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')

    # IPs
    lip=$(hostname -I 2>/dev/null | awk '{print $1}')
    pip=$(curl -s --max-time 1 ifconfig.me 2>/dev/null || echo "N/A")

    printf "${C1}         _    ${C2}OS: %s${NC}\n" "$os"
    printf "${C1}     ---(_)   ${C2}Kernel: %s${NC}\n" "$kernel"
    printf "${C1} _/  ---  \\   ${C2}Uptime: %s${NC}\n" "$uptime_str"
    printf "${C1}(_) |   |     ${C2}Memory: %s${NC}\n" "$mem"
    printf "${C1}  \\  --- _/   ${C2}Disk (/): %s${NC}\n" "$disk"
    printf "${C1}     ---(_)   ${C2}Local IP: %s${NC}\n" "$lip"
    printf "              ${C2}Public IP: %s${NC}\n" "$pip"
    echo ""
}

# Pokaż fetch przy starcie (tylko interaktywny shell)
[[ -o interactive ]] && fetch

# === LOKALNA KONFIGURACJA ===
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
ZSHRC

    # Move temp file to final location
    if mv "$tmp_zshrc" "$ZSHRC" 2>/dev/null; then
        log_ok "Konfiguracja zapisana"
    elif [[ "$HAVE_SUDO" == "1" ]] && sudo mv "$tmp_zshrc" "$ZSHRC" 2>/dev/null; then
        sudo chown "$(id -u):$(id -g)" "$ZSHRC"
        log_ok "Konfiguracja zapisana (sudo)"
    else
        log_err "Nie można zapisać $ZSHRC - sprawdź uprawnienia"
        rm -f "$tmp_zshrc"
        return 1
    fi
}

generate_starship_config() {
    [[ $INSTALL_STARSHIP -eq 0 ]] && return
    
    ensure_dir "$CONFIG_DIR"
    cat > "$CONFIG_DIR/starship.toml" << 'TOML'
format = "$time$username$hostname$directory$git_branch$git_status$character"

[line_break]
disabled = true

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[time]
disabled = false
format = '[\[$time\]]($style)'
style = "white"
time_format = "%H:%M"

[username]
format = '[\[$user\]]($style)'
style_user = "bold yellow"
show_always = true

[hostname]
format = '[\[$hostname\]]($style)'
style = "bold green"
ssh_only = false

[directory]
format = '[\[$path\]]($style) '
style = "bold blue"
truncation_length = 3

[git_branch]
format = '[$symbol$branch]($style) '
symbol = " "
style = "bold purple"

[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "bold red"
TOML
}

generate_git_config() {
    [[ $INSTALL_DELTA -eq 0 ]] && return
    ! have git && return
    
    # Tylko jeśli delta zainstalowana
    have delta || return
    
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.syntax-theme "Dracula"
    
    log_ok "Git skonfigurowany z delta"
}

download_antigen() {
    [[ $INSTALL_ZSH -eq 0 ]] && return
    [[ -f "$HOME/antigen.zsh" ]] && return
    
    log_info "Pobieram antigen..."
    curl -fsSL https://git.io/antigen > "$HOME/antigen.zsh" 2>/dev/null
}

#===============================================================================
# ZMIANA SHELL
#===============================================================================
setup_shell() {
    [[ $INSTALL_ZSH -eq 0 ]] && return
    
    local zsh_path
    if [[ -x "$LOCAL_BIN/zsh" ]]; then
        zsh_path="$LOCAL_BIN/zsh"
    elif have zsh; then
        zsh_path=$(which zsh)
    else
        return
    fi
    
    # Dodaj do /etc/shells
    if [[ "$HAVE_SUDO" == "1" ]] && ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Zmień shell
    if [[ "$SHELL" != "$zsh_path" ]]; then
        local shell_changed=0

        # Try sudo chsh first (no password prompt, no stdin)
        if [[ "$HAVE_SUDO" == "1" ]] && sudo chsh -s "$zsh_path" "$USER" </dev/null >/dev/null 2>&1; then
            shell_changed=1
            log_ok "Shell zmieniony na zsh"
        fi

        # Fallback - auto-exec w bashrc (always add for reliability)
        if [[ $shell_changed -eq 0 ]] && ! grep -q "exec.*zsh" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" << EOF

# Auto-start zsh
[[ -z "\$ZSH_VERSION" && -x "$zsh_path" ]] && exec "$zsh_path" -l
EOF
            log_ok "Dodano auto-start zsh do .bashrc"
        fi
    fi
}

#===============================================================================
# PODSUMOWANIE
#===============================================================================
show_summary() {
    echo ""
    echo -e "${G}${BOLD}✨ Instalacja zakończona!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BOLD}Zainstalowane:${NC}"
    
    local tools=(
        "zsh:$INSTALL_ZSH"
        "fzf:$INSTALL_FZF"
        "starship:$INSTALL_STARSHIP"
        "zoxide:$INSTALL_ZOXIDE"
        "eza:$INSTALL_EZA"
        "ripgrep:$INSTALL_RIPGREP"
        "fd:$INSTALL_FD"
        "bat:$INSTALL_BAT"
        "delta:$INSTALL_DELTA"
        "lazygit:$INSTALL_LAZYGIT"
        "btop:$INSTALL_BTOP"
        "tldr:$INSTALL_TLDR"
    )
    
    for tool in "${tools[@]}"; do
        local name="${tool%%:*}"
        local installed="${tool#*:}"
        [[ "$installed" == "1" ]] && echo -e "  ${G}✔${NC} $name"
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${Y}Następne kroki:${NC}"
    echo "  1. Wyloguj się i zaloguj ponownie"
    echo "     lub uruchom: exec zsh"
    echo ""
    echo -e "  2. Wpisz ${BOLD}shellhelp${NC} żeby zobaczyć skróty"
    echo ""
    echo "  3. Wypróbuj:"
    echo -e "     ${DIM}Ctrl+R${NC}  - szukaj w historii"
    echo -e "     ${DIM}z nazwa${NC} - inteligentne cd"
    echo -e "     ${DIM}ll${NC}      - lista plików"
    [[ $INSTALL_LAZYGIT -eq 1 ]] && echo -e "     ${DIM}lg${NC}      - lazygit"
    echo ""
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)    show_help; exit 0 ;;
            --learn)      show_tutorial; exit 0 ;;
            --list)       show_list; exit 0 ;;
            --minimal)    set_minimal; shift ;;
            --all)        set_all; shift ;;
            --dry-run)    
                set_all
                echo "Zostanie zainstalowane: zsh fzf starship zoxide eza ripgrep fd bat delta lazygit btop tldr"
                exit 0
                ;;
            *)
                log_err "Nieznana opcja: $1"
                echo "Użyj --help"
                exit 1
                ;;
        esac
    done
    
    # Banner
    echo ""
    echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}   🚀 Shell Setup v${VERSION}${NC}"
    echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    detect_system
    
    # Interaktywny wybór jeśli nie podano flag
    if [[ $INSTALL_ZSH -eq 0 && $INSTALL_FZF -eq 0 ]]; then
        echo ""
        echo -e "${DIM}Tip: użyj --learn żeby najpierw zobaczyć co robi każde narzędzie${NC}"
        interactive_select
    fi
    
    # Instalacja
    setup_repos
    install_system_packages
    
    install_fzf &
    install_starship &
    install_zoxide &
    install_eza &
    install_delta &
    install_lazygit &
    install_btop &
    install_tldr &
    wait
    
    download_antigen
    generate_zshrc
    generate_starship_config
    generate_git_config
    setup_shell
    
    show_summary
}

main "$@"
