# 🚀 Shell Setup

Modułowy skrypt do konfiguracji nowoczesnej powłoki na serwerach Linux.  
Jeden skrypt → profesjonalne środowisko pracy.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jarx88/dotfiles/main/setup-shell.sh)
```

![Zsh + Starship + FZF](https://img.shields.io/badge/shell-zsh-green?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

---

## ✨ Co dostajesz?

| Narzędzie | Opis | Skrót |
|-----------|------|-------|
| **zsh** | Nowoczesna powłoka z pluginami | - |
| **fzf** | Fuzzy finder - szukaj wpisując część nazwy | `Ctrl+R` |
| **starship** | Szybki, ładny prompt | - |
| **zoxide** | Inteligentne `cd` - pamięta gdzie chodziłeś | `z nazwa` |
| **eza** | Kolorowy `ls` z git statusem | `ll` |
| **ripgrep** | Szybki grep | `rg "text"` |
| **fd** | Szybki find | `fd "*.log"` |
| **bat** | Cat z kolorowaniem składni | `bat plik` |
| **delta** | Ładne diffy w git | automatyczne |
| **lazygit** | Git w trybie wizualnym | `lg` |
| **btop** | Monitor systemu | `btop` |
| **tldr** | Krótka pomoc zamiast man | `tldr tar` |

---

## 📦 Instalacja

### Szybka (interaktywna)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh)
```

Skrypt zapyta co chcesz zainstalować.

### Minimalna

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh) --minimal
```

Instaluje tylko: zsh + fzf + starship

### Pełna

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh) --all
```

Instaluje wszystkie narzędzia.

### Bezpieczna (najpierw podgląd)

```bash
curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh | less
```

---

## 🎓 Nauka

Nie wiesz jak używać tych narzędzi? Skrypt ma wbudowany tutorial:

```bash
./setup-shell.sh --learn
```

Po instalacji w terminalu:

```bash
shellhelp
```

---

## 🖥️ Wspierane systemy

- ✅ Ubuntu / Debian / Linux Mint / Pop!_OS
- ✅ Fedora
- ✅ RHEL / CentOS / Rocky / AlmaLinux / Oracle Linux
- ✅ Arch / Manjaro

---

## ⌨️ Skróty klawiszowe

Po instalacji masz dostęp do:

| Skrót | Działanie |
|-------|-----------|
| `Ctrl+R` | Szukaj w historii komend (fzf) |
| `Ctrl+T` | Wstaw ścieżkę do pliku |
| `Alt+C` | Zmień katalog |
| `**<Tab>` | Fuzzy completion (`vim **<Tab>`, `cd **<Tab>`) |

---

## 📝 Przydatne aliasy

```bash
# Nawigacja
..          # cd ..
...         # cd ../..

# Pliki
ll          # Szczegółowa lista z git statusem
lt          # Drzewo katalogów

# Git
gs          # git status -sb
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline --graph
lg          # lazygit (TUI)

# System
ports       # Pokaż otwarte porty
myip        # Twoje publiczne IP
please      # sudo (poprzednia komenda)
reload      # Przeładuj shell
```

---

## 🛠️ Funkcje pomocnicze

```bash
extract plik.tar.gz    # Rozpakuj dowolne archiwum
mkcd nowy-katalog      # Utwórz katalog i wejdź
serve                  # Szybki serwer HTTP (port 8000)
z nazwa                # Inteligentne cd (zoxide)
```

---

## 🔧 Konfiguracja

Skrypt tworzy/modyfikuje:

```
~/.zshrc                    # Główna konfiguracja zsh
~/.config/starship.toml     # Konfiguracja prompta
~/.zshrc.local              # Twoje lokalne zmiany (nie nadpisywane)
```

### Własne modyfikacje

Dodaj swoje aliasy i ustawienia do `~/.zshrc.local`:

```bash
# ~/.zshrc.local
alias projects='cd ~/projekty'
export EDITOR=nano
```

---

## 📖 Jak używać narzędzi?

### FZF - Fuzzy Finder

```bash
# Historia komend
Ctrl+R → wpisz "dock" → znajdzie "docker compose up -d"

# Szukaj plików
Ctrl+T → wpisz część nazwy → wstawi pełną ścieżkę

# Completion
vim **<Tab>     # Wybierz plik do edycji
cd **<Tab>      # Wybierz katalog
kill **<Tab>    # Wybierz proces
```

### Zoxide - Inteligentne cd

```bash
# Normalnie chodzisz po katalogach
cd /var/log/nginx
cd /home/jarek/projekty/api

# Zoxide to zapamiętuje, potem wystarczy:
z nginx         # → /var/log/nginx
z api           # → /home/jarek/projekty/api
z proj api      # → dokładniejsze dopasowanie
zi              # → interaktywny wybór z fzf
```

### Ripgrep - Szybki grep

```bash
rg "TODO"                 # Szukaj w całym katalogu
rg "error" -i             # Bez wielkości liter
rg "func" -t py           # Tylko w plikach .py
rg "config" -g "*.yaml"   # Tylko w *.yaml
rg "password" -l          # Tylko nazwy plików
```

### Lazygit - Git TUI

```bash
lg    # Uruchom

# Nawigacja:
# ← → ↑ ↓  Poruszanie
# Space    Stage/unstage
# c        Commit
# p        Pull
# P        Push
# ?        Pomoc
# q        Wyjdź
```

---

## ❓ FAQ

### Jak wrócić do bash?

```bash
chsh -s /bin/bash
```

### Jak zaktualizować narzędzia?

```bash
# Uruchom skrypt ponownie
bash <(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/setup-shell.sh) --all
```

### Coś nie działa

1. Wyloguj się i zaloguj ponownie
2. Sprawdź czy `~/.local/bin` jest w PATH: `echo $PATH`
3. Sprawdź wersję zsh: `zsh --version` (wymaga 5.8+)

### Jak odinstalować?

```bash
# Przywróć bash
chsh -s /bin/bash

# Usuń konfiguracje
rm -rf ~/.zshrc ~/.config/starship.toml ~/.fzf ~/.local/bin/{starship,fzf,eza,fd,rg,bat,delta,lazygit,btop,tldr,zoxide}
```

---

## 📄 Licencja

MIT

---

## 🙏 Inspiracje

- [Oh My Zsh](https://ohmyz.sh/)
- [Starship](https://starship.rs/)
- [Modern Unix](https://github.com/ibraheemdev/modern-unix)
