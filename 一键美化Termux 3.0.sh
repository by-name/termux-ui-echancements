# MIT License 版本3.0 保留所有权利 版权2026到2028
cp $PREFIX/etc/apt/source.list $PREFIX/etc/apt/source.list.dat
echo "deb https://mirrors.ustc.edu.cn/termux/termux-packages-24 stable main" > $PREFIX/etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main" >> $PREFIX/etc/apt/sources.list
echo USTC源版本可能滞后，现在获取存储权限，在弹出的窗口中选择允许
termux-setup-storage
pkg update -y
pkg upgrade -y
touch .hushlogin
pkg install neofetch -y
mkdir oh-my-posh
cd oh-my-posh
mkdir themes
cd ..
cd ..
pkg install wget -y
touch .bashrc
echo "neofetch" >> .bashrc
pkg install fish -y
echo "exec fish" >> .bashrc
wget https://ohmyposh.dev/install.sh
chmod +x install.sh
./install.sh
mv .cache/oh-my-posh/* oh-my-posh/themes
cd .config/fish
find .cache/oh-my-posh -mindepth 1 -delete
echo "set -g fish_greeting """ >> config.fish
echo "oh-my-posh init fish --config ~/oh-my-posh/themes/montys.omp.json | source" >> config.fish
pkg install vim
pkg install clang make cmake python nodejs npm git curl unzip tar -y
pkg install fzf bat ripgrep fd exa -y
pkg install openssh htop tree jq fzf bat ripgrep fd -y
npm install -g yarn pnpm typescript ts-node nodemon
# 我还不会换背景，所以跳过
echo "alias la='ls -a'" >> .bashrc
exit