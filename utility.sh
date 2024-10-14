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
    "restart-media:Restart media services"
    "music:Play music playlist"
    "kill-music:Kill music player"
    "edit:Edit utility script"
    "mvup:Move files up"
    "ip:Show IP addresses in color"
    "fish:Edit Fish config"
    "rpg:Install RPG MV game cheat menu"
    "st:Run network speed test"
    "backup:Create system backup using timeshift"
    "vpn:Work VPN"
    "reconnect:Bluetooth headset on/off"
    "temp:Monitor temperature"
    "update:Update system"
    "clean:Clean system"
    "hotkey:Set custom keybindings"
    "fish-gen:Generate Fish config"
    "extract:Extract compressed files"
    "setup:Install basic needed packages"
    "sideload:Sideload sidestore to iPhone"
    "led:Ledvance smart home stuff"
    "slash:convert backslash to slash"
    "fish-reload:Source fish config file"
    
)
option=$1

# Variables
a="sudo"
term="gnome-terminal -- bash -c"
editor="vim"
location="/home/ghost/Documents/Code/Bash/utility.sh"
sideloadUser=""
sideloadPassword=""
vpnUser=""
vpnAddress=""
vpnGroup=""

btDevice="28:6F:40:13:59:98"

# Function Definitions
mediaRestart(){ systemctl --user restart wireplumber pipewire pipewire-pulse;}
musicStart(){ mpv --no-video --speed=1.5 --shuffle ~/Music/*;}
musicEnd(){ pkill mpv;}
utilEdit(){ $term "$editor $location";}
fileMvUp(){ find . -mindepth 2 -type f -print -exec mv {} . \;;}
ipList(){ ip -c a | awk '/^[0-9]+: / {print $2} /^[[:space:]]+inet / {print $2}';}
fishEdit(){ $term "$editor /home/ghost/.config/fish/config.fish";fishReloadScript;}
rpgmCheats(){ git clone https://github.com/Gren-95/RPGM_Cheat_Menu.git && cp RPGM_Cheat_Menu/MVPluginPatcher.exe RPGM_Cheat_Menu/plugins_patch.txt  RPGM_Cheat_Menu/www/ . -r && wine MVPluginPatcher.exe;}
ooklaSpeedTest(){ $term "speedtest-cli";}
timeshiftBackup(){ $a timeshift --create; }
fishReloadScript(){ fish -c "source ~/.config/fish/config.fish";}
jeldwenVpnConnect(){ $term "$a openconnect --user=$vpnUser $vpnAddress --authgroup=$vpnGroup";}
headphoneReconnect(){ bluetoothctl disconnect $btDevice;bluetoothctl connect $btDevice;}
systemUpdate(){ $term " $a timeshift --create && $a dnf update --refresh && $a dnf autoremove && flatpak update && flatpak remove --unused";}
systemClean(){ echo "run bleachbit from gui first" && $a bleachbit --clean --preset && bleachbit --clean --preset; }

slashReplace() {
    read -p "Enter the Linux path: " linux_path
    windows_path="Z:${linux_path//\//\\}"
    echo "Converted Windows path: $windows_path"
    echo -n "$windows_path" | wl-copy
    echo "Path copied to clipboard."
}




liveTemperature(){
    $term "
        while true; do
            for i in / - \\ \|; do
                 echo -ne \"Processing \$i \$(sensors | awk '/temp1:/ {print \$2}') \\r\";
                 sleep 0.1;
            done;
        done
    "
}

systemKeybind(){
    # Function to add a new custom keybinding
    add_keybinding() {
        local index="$1"
        local name="$2"
        local command="$3"
        local binding="$4"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/']"
        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/" name "$name"
        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/" command "$command"
        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/" binding "$binding"
    }
    
    add_keybinding 0 "Open Nautilus" "nautilus" "<Super>e"
    add_keybinding 1 "Open Terminal" "gnome-terminal" "<Super>t"
    add_keybinding 2 "Music Player" "$location music" "<Super><Shift>m"
    add_keybinding 3 "Kill Music Player" "$location kill-music" "<Super><Shift>k"
    add_keybinding 4 "Bluetooth on/of headset" "$location reconnect" "<Super><Shift>b"
    
    # Define the list of custom keybindings
    custom_keybindings="["
    for ((i=0; i<=4; i++)); do
        custom_keybindings+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/',"
    done
    custom_keybindings="${custom_keybindings%,}]"
    
    # Update the list of custom keybindings
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$custom_keybindings"
}

fishRegenerate() {
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
    fishReloadScript
}

archiveExtract(){
    for f in *.{zip,tar.gz,tar.bz2,rar,7z}; do
        case "$f" in
            *.zip) unzip -o "$f" ;;
            *.tar.gz) tar -xzf "$f" ;;
            *.tar.bz2) tar -xjf "$f" ;;
            *.rar) unrar x -o+ "$f" ;;
            *.7z) 7z x -o./ "$f" ;;
        esac
    done
}

logfile="$HOME/system_setup.log"

log_and_exit() {
    echo "$1" | tee -a "$logfile"
    exit 1
}

systemSetup() {
    set -e
    
    echo 'Updating system' | tee -a "$logfile"
    $a dnf update -y || log_and_exit "Failed to update system"
    
    echo 'Enabling mpv-mpris repo' | tee -a "$logfile"
    $a dnf copr enable cyrinux/misc -y || log_and_exit "Failed to enable mpv-mpris repo"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || log_and_exit "Failed to add Flathub remote"
    
    echo 'Removing bloat' | tee -a "$logfile"
    $a dnf remove -y virtualbox-guest-additions gnome-classic-session gnome-font-viewer gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list gnome-clocks gnome-weather gnome-photos fedora-bookmarks fedora-chromium-config fedora-chromium-config-gnome gnome-contacts gnome-tour rhythmbox gnome-calendar gnome-connections gnome-maps gnome-user-docs gnome-video-effects gnome-video-effects gnome-user-docs desktop-backgrounds-gnome gnome-boxes anaconda* mediawriter fedora-flathub-remote yelp* qemu* libreoffice* dotnet* fedora-workstation-backgrounds || log_and_exit "Failed to remove bloat"
    
    echo 'Installing needed packages' | tee -a "$logfile"
    $a dnf install -y ranger fish mpv gamescope fzf bleachbit neofetch gnome-tweaks cabextract unrar vim timeshift tmux piper make wine winetricks mpv-mpris dxvk-native game-music-emu expect protontricks cmatrix lolcat speedtest-cli btop screen util-linux-user cronie cronie-anacron crontabs alsa-lib-devel ncurses-devel fftw3-devel pulseaudio-libs-devel libtool openssl adobe-source-code-pro-fonts git unzip p7zip-plugins gzip sssd tlp tlp-rdw xorg-x11-drv-amdgpu gnome-backgrounds wl-clipboard steam pipx || log_and_exit "Failed to install needed packages"
    
    echo 'Adding Flathub remote' | tee -a "$logfile"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || log_and_exit "Failed to add Flathub remote"
    
    flatpak_packages=(
        com.visualstudio.code org.localsend.localsend_app org.nickvision.tubeconverter org.remmina.Remmina xyz.xclicker.xclicker org.gimp.GIMP
        io.github.kukuruzka165.materialgram com.mattjakeman.ExtensionManager com.github.tchx84.Flatseal com.vysp3r.ProtonPlus
        org.filezillaproject.Filezilla org.gnome.Aisleriot org.gnome.Logs org.gnome.Mahjongg org.mozilla.firefox page.codeberg.libre_menu_editor.LibreMenuEditor
        io.github.milkshiift.GoofCord org.gtk.Gtk3theme.Adwaita-dark com.adobe.Flash-Player-Projector de.haeckerfelix.Fragments org.prismlauncher.PrismLauncher
    )
    
    echo 'Installing Flatpak packages' | tee -a "$logfile"
    for package in "${flatpak_packages[@]}"; do
        flatpak install -y "$package" || log_and_exit "Failed to install Flatpak package: $package"
    done
    
    echo 'Setting Flatpak override for GTK theme' | tee -a "$logfile"
    $a flatpak override --env=GTK_THEME=Adwaita-dark || log_and_exit "Failed to set Flatpak override for GTK theme"
    
    if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/bin/fish" ]; then
        echo 'Changing default shell to fish' | tee -a "$logfile"
        chsh -s /bin/fish || log_and_exit "Failed to change default shell to fish"
        echo 'Please run these commands to configure Fish shell' | tee -a "$logfile"
        echo 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' | tee -a "$logfile"
        echo 'fisher install decors/fish-colored-man jorgebucaran/hydro jethrokuan/z Gren-95/esc2pipe patrickf1/fzf.fish' | tee -a "$logfile"
    else
        echo "Shell is already fish. Skipping..." | tee -a "$logfile"
    fi
    
    if ! command -v tailscale &> /dev/null; then
        echo 'Installing Tailscale' | tee -a "$logfile"
        curl -fsSL https://tailscale.com/install.sh | sh || log_and_exit "Failed to install Tailscale"
        $a tailscale up || log_and_exit "Failed to start Tailscale"
        $a tailscale set --operator="$USER" || log_and_exit "Failed to set Tailscale operator"
    else
        echo "Tailscale is already installed. Skipping..." | tee -a "$logfile"
    fi
    
    
    pipx install gnome-extensions-cli --system-site-packages
    fishReloadScript || log_and_exit "Failed to reload Fish script"
    
    
    echo 'Installing GNOME extensions' | tee -a "$logfile"
    gnome_extensions=(
        appindicatorsupport@rgcjonas.gmail.com
        clipboard-history@alexsaveau.dev
        dash-to-panel@jderose9.github.com
        tailscale@joaophi.github.com
        hass-gshell@geoph9-on-github
    )
    
    #gnome-extensions-cli search dash to panel
    
    for url in "${gnome_extensions[@]}"
    do
        gnome-extensions-cli install "$url"
        gnome-extensions-cli enable "$url"
        
    done

    echo "Please import the config file in your home directory"
    gnome-extensions-cli preferences dash-to-panel@jderose9.github.com
    sleep 10
    
    echo 'Downloading dash to panel config' | tee -a "$logfile"
    wget https://raw.githubusercontent.com/Gren-95/linux-config/main/dashtopanel > /dev/null 2>&1 || log_and_exit "Failed to download dash to panel config"
    
    echo 'Enabling fstrim.timer' | tee -a "$logfile"
    $a systemctl enable fstrim.timer || log_and_exit "Failed to enable fstrim.timer"
    
    echo 'Setting hostname' | tee -a "$logfile"
    $a hostnamectl set-hostname "hp-envy-x360" || log_and_exit "Failed to set hostname"
    
    echo 'Updating grub config' | tee -a "$logfile"
    $a grubby --update-kernel=ALL --args="mitigations=off" || log_and_exit "Failed to update grub config"
    
    echo 'Updating dnf.conf' | tee -a "$logfile"
    $a tee /etc/dnf/dnf.conf <<EOF
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
EOF
    
    fishReloadScript || log_and_exit "Failed to reload Fish script"
    gnome_settings || log_and_exit "Failed to apply GNOME settings"
    systemKeybind || log_and_exit "Failed to set system keybinds"
    git config --global user.name "Gren-95"
    git config --global user.email fossfrog@protonmail.com
    
    echo 'System setup completed successfully' | tee -a "$logfile"
}
sideload(){
    expect -c "
        spawn /home/ghost/Documents/Phone/iPhone/sideloader-cli-linux-x86_64/sideloader-cli-linux-x86_64 install /home/ghost/Documents/Phone/iPhone/SideStore.ipa -i
        expect \"Apple ID:\"
        send \"$sideloadUser\r\"
        expect \"Password:\"
        send \"$sideloadPassword\r\"
        interact
    "
}

led(){
    expect -c "
       spawn python /home/ghost/Documents/ledvance/print-local-keys.py
        expect \"Please put your Tuya/Ledvance username:\"
        send \"enginguldere@gmail.com\r\"
        expect \"Please put your Tuya/Ledvance password:\"
        send \"a25011996A@\r\"
        interact
    "
}

gnome_settings() {
    gnome_settings=(
        "org.gnome.desktop.wm.preferences button-layout :minimize,maximize,close"
        "org.gtk.Settings.FileChooser sort-directories-first true"
        "org.gnome.desktop.interface show-battery-percentage true"
        "org.gnome.desktop.interface color-scheme 'prefer-dark'"
        "org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
        "org.gnome.desktop.interface text-scaling-factor 1"
        "org.gnome.desktop.interface scaling-factor 1"
        "org.gnome.desktop.interface clock-format '24h'"
        "org.gnome.desktop.interface clock-show-seconds false"
        "org.gnome.desktop.interface clock-show-weekday true"
        "org.gnome.desktop.interface enable-hot-corners false"
        "org.gnome.desktop.interface font-antialiasing 'rgba'"
        "org.gnome.desktop.interface font-hinting 'slight'"
        "org.gnome.desktop.interface font-rgba-order 'rgb'"
        "org.gnome.nautilus.preferences default-sort-in-reverse-order false"
        "org.gnome.nautilus.preferences show-directory-item-counts 'local-only'"
        "org.gnome.nautilus.preferences show-image-thumbnails 'local-only'"
        "org.gnome.nautilus.preferences default-folder-viewer 'icon-view'"
        "org.gnome.nautilus.preferences show-hidden-files true"
        "org.gnome.nautilus.preferences show-create-link true"
        "org.gnome.gnome-system-monitor cpu-stacked-area-chart true"
        "org.gnome.gnome-system-monitor graph-update-interval 50"
        "org.gnome.gnome-system-monitor logarithmic-scale false"
        "org.gnome.gnome-system-monitor current-tab 'processes'"
        "org.gnome.gnome-system-monitor cpu-smooth-graph true"
        "org.gnome.gnome-system-monitor network-in-bits true"
        "org.gnome.gnome-system-monitor network-total-in-bits true"
        "org.gnome.gnome-system-monitor process-memory-in-iec false"
        "org.gnome.gnome-system-monitor resources-memory-in-iec true"
        "org.gnome.gnome-system-monitor show-whose-processes 'user'"
        "org.gnome.gnome-system-monitor.disktreenew col-0-visible true"
        "org.gnome.gnome-system-monitor.disktreenew col-1-visible true"
        "org.gnome.gnome-system-monitor.disktreenew col-2-visible true"
        "org.gnome.gnome-system-monitor.disktreenew col-3-visible true"
        "org.gnome.gnome-system-monitor.disktreenew col-4-visible false"
        "org.gnome.gnome-system-monitor.disktreenew col-5-visible true"
        "org.gnome.gnome-system-monitor.disktreenew col-6-visible true"
        "org.gnome.gnome-system-monitor.proctree col-0-visible true"
        "org.gnome.gnome-system-monitor.proctree col-1-visible false"
        "org.gnome.gnome-system-monitor.proctree col-10-visible false"
        "org.gnome.gnome-system-monitor.proctree col-11-visible false"
        "org.gnome.gnome-system-monitor.proctree col-12-visible false"
        "org.gnome.gnome-system-monitor.proctree col-13-visible false"
        "org.gnome.gnome-system-monitor.proctree col-14-visible true"
        "org.gnome.gnome-system-monitor.proctree col-15-visible true"
        "org.gnome.gnome-system-monitor.proctree col-16-visible false"
        "org.gnome.gnome-system-monitor.proctree col-17-visible false"
        "org.gnome.gnome-system-monitor.proctree col-18-visible false"
        "org.gnome.gnome-system-monitor.proctree col-19-visible false"
        "org.gnome.gnome-system-monitor.proctree col-2-visible false"
        "org.gnome.gnome-system-monitor.proctree col-20-visible false"
        "org.gnome.gnome-system-monitor.proctree col-21-visible false"
        "org.gnome.gnome-system-monitor.proctree col-22-visible false"
        "org.gnome.gnome-system-monitor.proctree col-23-visible false"
        "org.gnome.gnome-system-monitor.proctree col-24-visible false"
        "org.gnome.gnome-system-monitor.proctree col-25-visible false"
        "org.gnome.gnome-system-monitor.proctree col-26-visible false"
        "org.gnome.gnome-system-monitor.proctree col-3-visible false"
        "org.gnome.gnome-system-monitor.proctree col-4-visible false"
        "org.gnome.gnome-system-monitor.proctree col-5-visible false"
        "org.gnome.gnome-system-monitor.proctree col-6-visible false"
        "org.gnome.gnome-system-monitor.proctree col-7-visible false"
        "org.gnome.gnome-system-monitor.proctree col-8-visible true"
        "org.gnome.gnome-system-monitor.proctree col-9-visible false"
    )
    
    for setting in "${gnome_settings[@]}"; do
        gsettings set $setting
        echo "Setting: $setting is now active"
    done
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ee+nodeadkeys')]"
}




# Execute chosen option
case $option in
    'help' ) usage ;;
    'restart-media' ) mediaRestart ;;
    'music' ) musicStart ;;
    'kill-music' ) musicEnd ;;
    'edit') utilEdit ;;
    'mvup') fileMvUp ;;
    'ip') ipList ;;
    'fish') fishEdit ;;
    'rpg') rpgmCheats ;;
    'st') ooklaSpeedTest ;;
    'backup') timeshiftBackup ;;
    'vpn') jeldwenVpnConnect ;;
    'reconnect') headphoneReconnect ;;
    'temp') liveTemperature ;;
    'update') systemUpdate ;;
    'clean') systemClean ;;
    'hotkey') systemKeybind ;;
    'fish-gen') fishRegenerate ;;
    'extract') archiveExtract ;;
    'setup') systemSetup ;;
    'sideload') sideload;;
    'led') led;;
    'g') gnome_settings;;
    'slash') slashReplace;;
    'fish-reload') fishReloadScript;;
    *) usage ;;
esac
