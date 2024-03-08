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
    "audio-flicker:Bluetooth on/off headset"
    "repolist:List repositories"
    "reporemove:Clean repositories"
    "extract:Extract compressed files"
    "dnfregenerate:Regenerate DNF configuration"
    "gui:Use a graphical uer interface"
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
    $term "speedtest-cli"
}

ipColorScript(){
    ip -c a | awk '/^[0-9]+: / {print $2} /^[[:space:]]+inet / {print $2}'
}

updateScript(){
    # update pc
    $term "
        $a timeshift --create
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
    
    # Add Super+Shift+G to start util gui
    add_keybinding 5 "util gui" "$location gui" "<Super><Shift>g"
    
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

repoListScript() {
    for file in /etc/yum.repos.d/*; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            while IFS= read -r line; do
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
    files=$(find . -maxdepth 1 -type f ! -name 'extract.sh')
    for file in $files; do
        mimetype=$(file -b --mime-type "$file")
        case $mimetype in
            application/zip)
                echo "Extracting $file ..."
                unzip -q "$file"
            ;;
            application/x-rar-compressed | application/x-rar)
                echo "Extracting $file ..."
                unrar x "$file"
            ;;
            application/x-7z-compressed)
                echo "Extracting $file ..."
                7z x "$file" -o"${file%%.*}"
            ;;
            *)
                echo "Skipping $file - not a compressed file."
            ;;
        esac
    done
}

dnfRemakeScript() {
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
}

zenityScript() {
    # Define options array with names and descriptions for Zenity UI
    options=(
        "Play Music Playlist:Play music playlist"
        "Kill Music Player:Kill music player"
        "Restart Media Services:Restart media services"
        "Media Debug:Debug media issues"
        "Open File Manager:Open file manager"
        "Open Terminal:Open terminal"
        "Monitor Temperature:Monitor temperature"
        "Edit Fish Config:Edit Fish config"
        "Edit Utility Script:Edit utility script"
        "Create System Backup:Create system backup"
        "Run Network Speed Test:Run Network speed test"
        "Show IP Addresses:Show IP addresses"
        "Update System:Update system"
        "Sync System:Sync system"
        "Clean System (sudo):Clean system (sudo)"
        "Clean System:Clean system"
        "Sync OneDrive:Sync OneDrive"
        "Connect to Cisco Switch:Connect to Cisco switch"
        "Reload Fish Config:Reload Fish config"
        "Restart GDM:Restart GDM"
        "Set Custom Keybindings:Set custom keybindings"
        "Generate Fish Config:Generate Fish config"
        "Bluetooth On/Off Headset:Bluetooth on/off headset"
        "Repo List:List repositories"
        "Repo Clean:Clean repositories"
        "Extract Compressed Files:Extract compressed files"
        "Regenerate DNF Configuration:Regenerate DNF configuration"
    )
    
    # Extract options and descriptions for Zenity UI
    actions=()
    descriptions=()
    for opt in "${options[@]}"; do
        name=$(echo "$opt" | cut -d':' -f1)
        description=$(echo "$opt" | cut -d':' -f2)
        actions+=("$name")
        descriptions+=("$description")
    done
    
    # Show the Zenity list dialog with default size
    choice=$(zenity --list \
        --title="Utility Script" \
        --text="Select an action:" \
        --column="Action" "${actions[@]}" \
        --width=500 \
        --height=500 \
    --cancel-label="Cancel")
    
    # Check the selected action and execute the corresponding function
    case "$choice" in
        "Play Music Playlist")
        musicScript;;
        "Kill Music Player")
        kill-musicScript;;
        "Restart Media Services")
        restart-mediaScript;;
        "Media Debug")
        media-debugScript;;
        "Open File Manager")
        filesScript;;
        "Open Terminal")
        terminalScript;;
        "Monitor Temperature")
        tempScript;;
        "Edit Fish Config")
        fishsScript;;
        "Edit Utility Script")
        utilEditScript;;
        "Create System Backup")
        backupScript;;
        "Run Speed Test")
        speedTestScript;;
        "Show IP Addresses")
        ipColorScript;;
        "Update System")
        updateScript;;
        "Clean System (sudo)")
        bleachRootScript;;
        "Clean System")
        bleachScript;;
        "Reload Fish Config")
        fishReloadScript;;
        "Restart GDM")
        gnomeRestartScript;;
        "Set Custom Keybindings")
        keybindScript;;
        "Generate Fish Config")
        fishRemakeScript;;
        "Bluetooth On/Off Headset")
        bluetoothAudioReconnectScript;;
        "Regenerate DNF Configuration")
        dnfRemakeScript;;
        
    esac
}

# Execute chosen option
case $option in
    'help' )
    usage;;
    'music' )
    musicScript;;
    'kill-music' )
    kill-musicScript;;
    'restart-media' )
    restart-mediaScript;;
    'media-debug')
    media-debugScript;;
    'files')
    filesScript;;
    'term')
    terminalScript;;
    'temp')
    tempScript;;
    'fish')
    fishsScript;;
    'edit')
    utilEditScript;;
    'backup')
    backupScript;;
    'st')
    speedTestScript;;
    'ipa')
    ipColorScript;;
    'update')
    updateScript;;
    'sync')
    distroSyncScript;;
    'clean-root')
    bleachRootScript;;
    'clean')
    bleachScript;;
    'sy')
    onedriveSyncScript;;
    'cisco')
    comSwitchScript;;
    'fish-reload')
    fishReloadScript;;
    'gdm')
    gnomeRestartScript;;
    'keybind-set')
    keybindScript;;
    'generate-fish')
    fishRemakeScript;;
    'audio-flicker')
    bluetoothAudioReconnectScript;;
    'repolist')
    repoListScript;;
    'reporemove')
    repocleanScript;;
    'extract')
    extractScript;;
    'dnfregenerate')
    dnfRemakeScript;;
    'gui')
    zenityScript;;
    *)
    usage;;
esac
