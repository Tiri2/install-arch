HISTFILE=~/.histfile
HISTSIZE=10000

export system_dir="/var/system"
export tools_dir="$system_dir/tools"

# colors
export black='\033[0;30m'        # Black
export red='\033[0;31m'          # Red
export green='\033[0;32m'        # Green
export yellow='\033[0;33m'       # Yellow
export blue='\033[0;34m'         # Blue
export purple='\033[0;35m'       # Purple
export cyan='\033[0;36m'         # Cyan
export white='\033[0;37m'        # White


# Zinit Path
ZINIT_HOME="${tools_dir}/zinit/zinit.git"

# Download zinit if not installed
if [ ! -d "$ZINIT_HOME" ]; then
  echo -e "installing zinit"
	mkdir -p "$(dirname "$ZINIT_HOME")"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# ============================================
#
#
# 	            LOAD PLUGINS
#
#
# ============================================

# load zinit
source "$ZINIT_HOME/zinit.zsh"

# zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zstyle ':completion:*' matcher-list 'm:{a-z}={S-Za-z}'
zstyle ':completion:*' list-colors "§{(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview "ls --color $realpath"

# load prompt (theme)
autoload -Uz promptinit
promptinit

PROMPT='(%B%F{green}%n@%m%f%b) %F{blue}%~%f%b $ '

# ============================================
#
#
# 	            INIT PLUGINS
#
#
# ============================================

# load completions
autoload -U compinit && compinit

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search


# ============================================
#
#
# 	            KEY BINDINGS
#
#
# ============================================

bindkey -- "^[[H"         beginning-of-line                         # pos 1
bindkey -- "^[[F"         end-of-line                               # end
bindkey -- "^[[3~"        delete-char                               # delete
bindkey -- "^[[2~"        overwrite-mode                            #
bindkey -- "^H"           backward-delete-char                      # backspace
bindkey -- "^[[A"         up-line-or-beginning-search               # up
bindkey -- "^[[B"         down-line-or-beginning-search             # down
bindkey -- "^[[5~"        beginning-of-buffer-or-history            # Page down
bindkey -- "^[[6~"        end-of-buffer-or-history                  # Page up


# ============================================
#
#
# 	            ALIASES
#
#
# ============================================

alias ll="lsd -al --icon=never --color=auto"
alias ls="lsd --icon=never --color=auto"
alias cd="z"
alias fzf="fzf --preview='cat {}'"
alias shutdown="systemctl shutdown"
alias reboot="systemctl reboot"
alias ..="cd .."
alias ...="cd ../.."
alias cls="clear"
alias ss="ss -tuln"
alias ftop='htop -p $(pidof java | sed -e "s/ /,/g")'
alias flextop='htop -p $(pidof java | sed -e "s/ /,/g")'


# ============================================
#
#
# 	            BANNER
#
#
# ============================================

USER=$(whoami)
UPTIME=$(uptime -p)

# Berechnung der Größe von /srv/smb/ in Prozent
get_smb_usage() {
  local smb_path="/srv/smb"
  local partition=$(df "$smb_path" --output=source | tail -1) # Partition für das Verzeichnis
  local total_size=$(df "$partition" --output=size | tail -1) # Gesamtgröße der Partition (1K-Blöcke)
  local used_size=$(du -s "$smb_path" | awk '{print $1}')     # Verwendeter Platz von /srv/smb in 1K-Blöcken

  if [[ -n $total_size && -n $used_size ]]; then
    local percentage=$(awk "BEGIN {printf \"%.2f\", ($used_size/$total_size)*100}")
    echo "Verzeichnis /srv/smb nutzt $percentage% der Partition $partition"
  else
    echo "Fehler bei der Berechnung der Größe von /srv/smb"
  fi
}



echo "${yellow}===================="
echo " "
echo "${green} "
echo "   _____         ____     __     __  _             _____      __   __ __"
echo "  / _/ /____ __ / __/__  / /_ __/ /_(_)__  ___    / ___/_ _  / /  / // /"
echo " / _/ / -_) \ /_\ \/ _ \/ / // / __/ / _ \/ _ \  / (_ /  '\' / _ \/ _  / "
echo "/_//_/\__/_\_\/___/\___/_/\_,_/\__/_/\___/_//_/  \___/_/_/_/_.__/_//_/  "
echo "                                                                        "
echo " "
echo " "
echo "${blue}Willkommen, ${white}${USER}!"
echo " "
echo "${white}Uptime is ${yellow}$UPTIME"
# Anzeige der Nutzung bei jedem neuen Terminal
get_smb_usage

echo " "

if [ "$USER" = "root" ]; then
  echo "⚠️    ${red}Du bist als root Nutzer angemeldet!"
  echo " "
fi

echo "${yellow}===================="

# Extra space because of the prompt
echo " "