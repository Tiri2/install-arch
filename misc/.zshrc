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

# Other important settings
setopt autocd

USER=$(whoami)

# Download zinit if not installed
ZINIT_HOME="${tools_dir}/zinit/zinit.git"
LOAD_PLUGINS="yes"
if [ ! -d "$ZINIT_HOME" ]; then
  echo -e "installing zinit"

  if [[ $USER != "root" ]]; then
    echo "${red}Bitte als Root ausführen!"
    LOAD_PLUGINS="no"
  else
    mkdir -p "$(dirname "$ZINIT_HOME")"
	  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  fi
fi

# ============================================
#
#
# 	            COMMAND HISTORY
#
#
# ============================================

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=10000

setopt APPEND_HISTORY             # Befehle werden an die Datei angehängt, nicht überschrieben
setopt SHARE_HISTORY              # History wird zwischen laufenden Zsh-Sessions geteilt
setopt INC_APPEND_HISTORY         # Befehle sofort in die History-Datei schreiben
setopt HIST_IGNORE_DUPS           # Duplikate in der History ignorieren
setopt HIST_IGNORE_ALL_DUPS       # Alle Duplikate entfernen
setopt HIST_IGNORE_SPACE          # Befehle, die mit einem Leerzeichen beginnen, ignorieren
setopt HIST_FIND_NO_DUPS          # Keine Duplikate bei der History-Suche
setopt HIST_REDUCE_BLANKS         # Überflüssige Leerzeichen aus Befehlen entfernen
setopt HIST_VERIFY                # Befehl vor der Ausführung im Editor bestätigen
setopt EXTENDED_HISTORY           # Befehle mit Zeitstempeln speichern

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
if [[ $LOAD_PLUGINS == "yes"]]; then
  zinit ice wait"1" # Lazy Loading
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  #zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*' matcher-list 'm:{a-z}={S-Za-z}'
  zstyle ':completion:*' list-colors "§{(s.:.)LS_COLORS}"
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:complete:cd:*' fzf-preview "ls --color $realpath"
fi

# load prompt (theme)
autoload -Uz promptinit
promptinit

# User based prompt
if [[ $USER == "root" ]]; then
  PROMPT='(%B%F{red}%n@%m%f%b) %F{blue}%~%f%b $ '
else
  PROMPT='(%B%F{green}%n@%m%f%b) %F{blue}%~%f%b $ '
fi


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
bindkey -- "^[[D"         backward-char                             # left
bindkey -- "^[[C"         forward-char                              # right



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
alias shutdown="sudo systemctl shutdown"
alias reboot="sudo systemctl reboot"
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

UPTIME=$(uptime -p)

# Berechnung der Größe von /srv/smb/ in Prozent
function print_smb_usage() {
  local smb_path="/srv/smb"
  local partition=$(df "$smb_path" --output=source | tail -1) # Partition für das Verzeichnis
  local total_size=$(df "$partition" --output=size | tail -1) # Gesamtgröße der Partition (1K-Blöcke)
  local used_size=$(du -s "$smb_path" | awk '{print $1}')     # Verwendeter Platz von /srv/smb in 1K-Blöcken

  if [[ -n $total_size && -n $used_size ]]; then
    local percentage=$(awk "BEGIN {printf \"%.2f\", ($used_size/$total_size)*100}")
    echo -e "${white}/srv/smb verbaucht ${cyan}$percentage% ${white}Speicher"
  fi
}

function list_nics_and_ips() {
    # Iterate through all network interfaces
    for nic in $(ls /sys/class/net/); do
        # Check if the NIC exists and is up
        if [ -d "/sys/class/net/$nic" ] && ip link show "$nic" > /dev/null 2>&1; then
            echo "${cyan}$nic:"  # Print the NIC name

            # Get all IP addresses for the NIC
            ips=$(ip -4 -o addr show dev "$nic" | awk '{print $4}')

            if [ -n "$ips" ]; then
                # Get the gateway (if any) for the NIC
                gateway=$(ip route | grep "default via" | grep "$nic" | awk '{print $3}')

                for ip in $ips; do
                    if [ -n "$gateway" ]; then
                        echo "   - ${yellow}$ip ${white}via ${yellow}$gateway"
                    else
                        echo "   - ${yellow}$ip"
                    fi
                done
            else
                echo "   - No IPs assigned"
            fi
        fi
    done
}


echo " "
echo "      flexSolution GmbH"
echo " "
echo "${purple}========================"
echo " "
echo "${blue}Willkommen, ${white}${USER}@$(cat /etc/hostname)!"
echo "${white}Uptime is ${yellow}$UPTIME"
echo " "
list_nics_and_ips
echo " "
print_smb_usage
echo " "

if [ "$USER" = "root" ]; then
  echo "${red}Du bist als root Nutzer angemeldet!"
  echo " "
fi

echo "${purple}========================"

# Extra space because of the prompt
echo " "