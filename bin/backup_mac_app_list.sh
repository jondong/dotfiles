#!/usr/bin/env bash

sync_path="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/backup/app-lists"
total_apps_file="total_apps.conf"
mas_apps_file="mas_apps.conf"
brew_apps_file="brew_apps.conf"
brew_cask_apps_file="brew_cask_apps.conf"

# Backup app list.
if [ -d "$sync_path" ]; then
  pushd "$sync_path"
else
  echo "$sync_path does not exist, create it first."
  exit 1
fi

ls /Applications | sed 's/\.app//g' > "$total_apps_file"
/usr/local/bin/mas list > "$mas_apps_file"
/usr/local/bin/brew list --formula> "$brew_apps_file"
/usr/local/bin/brew list --cask> "$brew_cask_apps_file"

# Generate app installation script.
install_script="app_installer.sh"
echo -e "#!/usr/bin/env bash\n" > "$install_script"
cat "$mas_apps_file" | sed "s/(.*)//g" | sed -Ee 's/([0-9]+) (.+)/mas install \1 #\2/g' >> "$install_script"
echo -e "\nbrew install $(cat $brew_apps_file | tr '\n' ' ')" >> "$install_script"
echo -e "\nbrew install $(cat $brew_cask_apps_file | tr '\n' ' ')" >> "$install_script"
chmod +x "$install_script"

# Execute it.
popd
