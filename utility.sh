#!/bin/bash

# Display usage information
usage() {
    cat <<EOF
Usage:
    $0 <option>

Options:
EOF
    # Loop through all options and their descriptions
    for opt in "${options[@]}"; do
        name=$(echo "$opt" | cut -d':' -f1)
        description=$(echo "$opt" | cut -d':' -f2)
        # Print name and description with aligned columns
        printf "    %-20s - %s\n" "$name" "$description"
    done
    exit 1
}

# Define options array with names and descriptions
options=(
    "music:Play music playlist"
    "kill-music:Kill music player"
    "restart-media:Restart media services"
    "media-debug:Debug media issues"
    "files:Open file manager"
    "term:Open terminal"
    "temp:Monitor temperature"
    "fish:Edit Fish config"
    "edit:Edit utility script"
    "input-debug:Debug input events"
    "mvup:Move files up"
    "backup:Create system backup"
    "st:Run speed test"
    "ipa:Show IP addresses"
    "update:Update system"
    "sync:Sync system"
    "clean-root:Clean system (sudo)"
    "clean:Clean system"
    "sy:Sync OneDrive"
    "cisco:Connect to Cisco switch"
    "fish-reload:Reload Fish config"
    "gdm:Restart GDM"
    "keybind-set:Set custom keybindings"
    "generate-fish:Generate Fish config"
    "audio-flicker:Bluetooth on/of headset"
)

option=$1

# Variables
a="sudo"
term="gnome-terminal -- bash -c"
editor="nano"
location="/home/ghost/Documents/Code/Bash/utility.sh"


musicScript(){
    if ! command -v mpv &> /dev/null
    then
        $term "$a dnf install -y mpv mpv-mpris"
    fi
    mpv --playlist=/home/ghost/Music/ --no-video --speed=1.5 --shuffle
}

kill-musicScript(){
    pkill mpv
    
}

restart-mediaScript(){
    systemctl --user restart wireplumber pipewire pipewire-pulse
}

media-debugScript(){
    $term "killall -3 gnome-shell"
}

filesScript(){
    nautilus
}

terminalScript(){
    gnome-terminal
}

tempScript(){
    $term "
        while true; do
            for i in / - \\ \|; do
                 echo -ne \"Processing \$i \$(sensors | awk '/temp1:/ {print \$2}') \\r\";
                 sleep 0.1;
            done;
        done
    "
}

fishsScript(){
    $term "$editor /home/ghost/.config/fish/config.fish"
    
}

utilEditScript(){
    $term "$editor /home/ghost/Documents/Code/Bash/utility.sh"
    
}

mvupScript(){
    find . -mindepth 2 -type f -print -exec mv {} . \;
}

backupScript(){
    $a timeshift --create
    
}

speedTestScript(){
    speedtest-cli
}

ipColorScript(){
    ip -c a
}

updateScript(){
    # update pc
    $term "$a timeshift --create
        $a dnf update --refresh
        $a dnf autoremove
        flatpak update
        flatpak remove --unused
    "
}

distroSyncScript(){
    $term "$a dnf distro-sync"
}

bleachRootScript(){
    $term "$a bleachbit --clean --preset"
}

bleachScript(){
    $term "bleachbit --clean --preset"
}

onedriveSyncScript(){
    onedrive --synchronize
}

comSwitchScript(){
    $a screen /dev/ttyUSB0
}

fishReloadScript(){
    fish -c "source ~/.config/fish/config.fish"
}

gnomeRestartScript(){
    $a systemctl restart gdm
}

keybindScript(){
    
    # Function to add a new custom keybinding
    add_keybinding() {
        local index="$1"
        local name="$2"
        local command="$3"
        local binding="$4"
        
        # Add the new custom keybinding
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"$index"/ name "$name"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"$index"/ command "$command"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"$index"/ binding "$binding"
    }
    
    # Add Super+E to open Nautilus
    add_keybinding 0 "Open Nautilus" "nautilus" "<Super>e"
    
    # Add Super+T to open terminal
    add_keybinding 1 "Open Terminal" "gnome-terminal" "<Super>t"
    
    # Add Super+Shift+M for music player
    add_keybinding 2 "Music Player" "$location music" "<Super><Shift>m"
    
    # Add Super+Shift+K to kill music player
    add_keybinding 3 "Kill Music Player" "$location kill-music" "<Super><Shift>k"
    
    # Add Super+Shift+K to kill music player
    add_keybinding 4 "Bluetooth on/of headset" "$location audio-flicker" "<Super><Shift>b"
    
    # Define the list of custom keybindings
    custom_keybindings="["
    for ((i=0; i<=4; i++)); do
        custom_keybindings+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/',"
    done
    custom_keybindings="${custom_keybindings%,}]"
    
    # Update the list of custom keybindings
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$custom_keybindings"
}

fishRemakeScript() {
    cat <<EOF >> ~/.config/fish/config.fish
    if status is-interactive

    # Fish greeter
    set fish_greeting ""

    alias util="/home/ghost/Documents/Code/Bash/utility.sh"

    # Basic dnf commands
    alias up="sudo dnf5 update"
    alias in="sudo dnf5 install"
    alias are="sudo dnf5 autoremove"
    alias re="sudo dnf5 remove"
    alias dls="sudo dnf5 list"
    alias apt="dnf"

    # Basic Flatpak commands
    alias fup="flatpak update"
    alias fin="flatpak install"
    alias fare="flatpak remove --unused"
    alias fre="flatpak remove"

    # Basic Fisher commands
    alias fishup="fisher update"

    # System actions
    alias rb="reboot"
    alias sdn="shutdown now"

    # Utils

    ## Networking
    alias ipa="ip -c a"
    alias st="speedtest-cli"
    alias sy="util sy"
    alias cisco="util cisco"

    # Random
    alias nf="neofetch"
    alias cls="clear"
    alias pipe="echo '|'"
    alias sudo="sudo -sE"
    alias backup="util backup"

    # File operations
    alias ur="unrar x"
    alias mvup="util mvup"
    alias reload="util fish-reload"

    # Media
    alias aure="util restart-media"

    end
EOF
}

bluetoothAudioReconnectScript(){
    bluetoothctl disconnect
    bluetoothctl connect 28:6F:40:13:59:98
}

repoListScript(){
    
    # Iterate over each file in /etc/yum.repos.d/ directory
    for file in /etc/yum.repos.d/*; do
        
        # Check if the file exists and is readable
        if [ -f "$file" ] && [ -r "$file" ]; then
            # Read each line in the file
            while IFS= read -r line; do
                # Check if the line contains braces
                if [[ $line == *"["* || $line == *"]"* ]]; then
                    echo "$line"
                fi
            done < "$file"
        else
            echo "Cannot read $file"
        fi
        
    done
    
}

repocleanScript(){
    echo"dnf repository-packages REPO_NAME_HERE list --installed"
}

extractScript() {
    # Extract all compressed files in the current directory
    
    # List all files except directories and the script itself
    files=$(find . -maxdepth 1 -type f ! -name 'extract.sh')
    
    # Loop through each file
    for file in $files; do
        # Check if the file is compressed
        mimetype=$(file -b --mime-type "$file")
        case $mimetype in
            application/zip)
                echo "Extracting $file ..."
                unzip -q "$file"
            ;;
            application/x-rar-compressed)
                echo "Extracting $file ..."
                unrar x "$file"
            ;;
            application/x-rar)
                echo "Extracting $file ..."
                unrar x "$file"
            ;;
            application/x-7z-compressed)
                echo "Extracting $file ..."
                7z x "$file" -o"${file%%.*}"
            ;;
            *)
                echo "Skipping $file - not a compressed file."
                continue
            ;;
        esac
    done
}

dnfRemakeScript() {
   $a bash <<EOF
cat <<CONF > /etc/dnf/dnf.conf
[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
max_parallel_downloads=6
zchunk=False
max_parallel_downloads=5
fastestmirror=True
defaultyes=True
CONF
EOF
}




# Execute chosen option
case $option in
    
    'help' )
        usage
    ;;
    'music' )
        musicScript
    ;;
    'kill-music' )
        kill-musicScript
    ;;
    'restart-media' )
        restart-mediaScript
    ;;
    'media-debug')
        media-debugScript
    ;;
    'files')
        filesScript
    ;;
    'term')
        terminalScript
    ;;
    'temp')
        tempScript
    ;;
    'fish')
        fishsScript
    ;;
    'edit')
        utilEditScript
    ;;
    'mvup')
        mvupScript
    ;;
    'backup')
        backupScript
    ;;
    'st')
        speedTestScript
    ;;
    'ipa')
        ipColorScript
    ;;
    'update')
        updateScript
    ;;
    'sync')
        distroSyncScript
    ;;
    'clean-root')
        bleachRootScript
    ;;
    'clean')
        bleachScript
    ;;
    'sy')
        onedriveSyncScript
    ;;
    'cisco')
        comSwitchScript
    ;;
    'fish-reload')
        fishReloadScript
    ;;
    'gdm')
        gnomeRestartScript
    ;;
    'keybind-set')
        keybindScript
    ;;
    'generate-fish')
        fishRemakeScript
    ;;
    'audio-flicker')
        bluetoothAudioReconnectScript
    ;;
    'repolist')
        repoListScript
    ;;
    'reporemove')
        repocleanScript
    ;;
    'extract')
        extractScript
    ;;
    'dnfregenerate')
        dnfRemakeScript
    ;;
    * )
        usage
    ;;
esac

