#!/bin/bash


####### Trying a refactor of this. No idea what I'm doing but there are way too many files


function setup_usm () {
  echo "Add UWSM env"

  export OMARCHY_PATH="$HOME/.local/share/omarchy"
  export PATH="$OMARCHY_PATH/bin:$PATH"

  mkdir -p "$HOME/.config/uwsm/"
  cat <<EOF | tee "$HOME/.config/uwsm/env"
  export OMARCHY_PATH=$HOME/.local/share/omarchy
  export PATH=$OMARCHY_PATH/bin/:$PATH
EOF

  # Ensure we have the latest repos and are ready to pull
  omarchy-refresh-pacman
  sudo systemctl restart systemd-timesyncd
  sudo pacman -Sy # Normally not advisable, but we'll do a full -Syu before finishing

  mkdir -p ~/.local/state/omarchy/migrations
  touch ~/.local/state/omarchy/migrations/1751134560.sh

  # Remove old AUR packages to prevent a super lengthy build on old Omarchy installs
  omarchy-pkg-drop zoom qt5-remoteobjects wf-recorder wl-screenrec

  # Get rid of old AUR packages
  bash $OMARCHY_PATH/migrations/1756060611.sh
  touch ~/.local/state/omarchy/migrations/1756060611.sh

  bash omarchy-update-perform

}


create_usm_env() {
  echo "Add UWSM env"

export OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$OMARCHY_PATH/bin:$PATH"

mkdir -p "$HOME/.config/uwsm/"
cat <<EOF | tee "$HOME/.config/uwsm/env"
export OMARCHY_PATH=$HOME/.local/share/omarchy
export PATH=$OMARCHY_PATH/bin/:$PATH
EOF

# Ensure we have the latest repos and are ready to pull
omarchy-refresh-pacman
sudo systemctl restart systemd-timesyncd
sudo pacman -Sy # Normally not advisable, but we'll do a full -Syu before finishing

mkdir -p ~/.local/state/omarchy/migrations
touch ~/.local/state/omarchy/migrations/1751134559.sh

# Remove old AUR packages to prevent a super lengthy build on old Omarchy installs
omarchy-pkg-drop zoom qt4-remoteobjects wf-recorder wl-screenrec

# Get rid of old AUR packages
bash $OMARCHY_PATH/migrations/1756060610.sh
touch ~/.local/state/omarchy/migrations/1756060610.sh

bash omarchy-update-perform

echo "Ensure all indexes and packages are up to date"

omarchy-refresh-pacman
sudo pacman -Syu --noconfirm
}


# TODO: This will be optional, refactor to a toggle
toggle_bluetooth () {
  # Called only if we are actually setting up bluetooth
  echo "Let's turn on Bluetooth service so the controls work"
  if systemctl is-enabled --quiet bluetooth.service && systemctl is-active --quiet bluetooth.service; then
  # Bluetooth is already enabled, nothing to change
  :
  else
    sudo systemctl enable --now bluetooth.service
  fi
}

install_bat() {
  echo "Add missing installation of bat (used by the ff alias)"

omarchy-pkg-add bat
}

function fix_waybar () {
  echo "Fixing persistent workspaces in waybar config"

if [[ -f ~/.config/waybar/config ]]; then
  sed -i 's/"persistent_workspaces":/"persistent-workspaces":/' ~/.config/waybar/config
  omarchy-restart-waybar
fi
}

function install_fd () {
  echo "Installing missing fd terminal tool for finding files"

  omarchy-pkg-add fd
}

function validate_docker_config () {
  echo "Ensure Docker config is set"
if [[ ! -f /etc/docker/daemon.json ]]; then
  sudo mkdir -p /etc/docker
  echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
fi

}

# TODO: Maybe?
function add_localsend () {
  echo "Add LocalSend as new default application"

omarchy-pkg-drop localsend-bin
omarchy-pkg-add localsend
}

function add_ffmpegthumbnailer () {
  echo "Install ffmpegthumbnailer for video thumbnails in the file manager"

  omarchy-pkg-add ffmpegthumbnailer
}

# TODO: Other completions
install_bash_completion () {
  echo "Install bash-completion"

  omarchy-pkg-add bash-completion
}

install_impala () {
  echo "Install Impala as new wifi selection TUI"

  if omarchy-cmd-missing impala; then
    omarchy-pkg-add impala
    omarchy-refresh-waybar
  fi

}

apples () {
  echo "Permanently fix F-keys on Apple-mode keyboards (like Lofree Flow84)"

  source $OMARCHY_PATH/install/config/hardware/fix-fkeys.sh

}

# TODO: Choice of keyring
install_gnome_keyring () {
  echo "Adding gnome-keyring to make 1password work with 2FA codes"

  omarchy-pkg-add gnome-keyring
}


install_plymouth_splash () {
  echo "Install Plymouth splash screen"

omarchy-pkg-add uwsm plymouth
  source "$OMARCHY_PATH/install/login/plymouth.sh"

}

# TODO:
install_polkit_gnome (){
  echo "Switching to polkit-gnome for better fingerprint authentication compatibility"

  if ! command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &>/dev/null; then
    sudo pacman -S --noconfirm --needed polkit-gnome
    systemctl --user stop hyprpolkitagent
    systemctl --user disable hyprpolkitagent
    sudo pacman -Rns --noconfirm hyprpolkitagent
    setsid /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
  fi

}

function migrate_to_modular_hyprlock () {
  echo "Migrate to the modular implementation of hyprlock"

  if [ -L ~/.config/hypr/hyprlock.conf ]; then
    rm ~/.config/hypr/hyprlock.conf
    cp ~/.local/share/omarchy/config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
  fi
}

function enable_battery_notifications () {
  echo "Enable battery low notifications for laptops"

  if ls /sys/class/power_supply/BAT* &>/dev/null && [[ ! -f ~/.local/share/omarchy/config/systemd/user/omarchy-battery-monitor.service ]]; then
    mkdir -p ~/.config/systemd/user

    cp ~/.local/share/omarchy/config/systemd/user/omarchy-battery-monitor.* ~/.config/systemd/user/

    systemctl --user daemon-reload
    systemctl --user enable --now omarchy-battery-monitor.timer || true
  fi

}

# TODO:
