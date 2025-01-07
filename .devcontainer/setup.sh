#!/usr/bin/zsh
sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install --no-install-recommends libvips libvips-dev libvips-tools libpq-dev python3-pygments
sudo mkdir /root/.config
cd /root/.config
git config --global init.defaultBranch main
current_dir=$(pwd)
if [ "$current_dir" = "/root/.config" ]; then 
    git init .
    git remote add origin https://github.com/Greenwood-Cultural-Center/dotfiles.git
    git pull origin main
    mv /root/.config/.zshrc /root/.zshrc
    mv /root/.config/.p10k.zsh /root/.p10k.zsh
else 
    echo "Not in /root/.config: skipping dotfiles setup for root: Please manually clone the dotfiles repo, https://github.com/Greenwood-Cultural-Center/dotfiles.git, to /root/.config"
fi
cd /workspaces/greenwood-kiosk
brew install fzf
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k
bundle install
yarn install