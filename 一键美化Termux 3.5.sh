# MIT License 版本3.5 保留所有权利 版权2026到2028
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
pkg install fontconfig -y
mkdir share
cd share
mkdir fouts
cd ~//share/fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip
if [ $? -eq 0 ]; then
    echo "Fira Code Nerd Font下载成功"
    unzip -q FiraCode.zip
    rm FiraCode.zip
else
    echo "Fira Code下载失败，尝试其他字体..."
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
    if [ $? -eq 0 ]; then
        echo "JetBrains Mono Nerd Font下载成功"
        unzip -q JetBrainsMono.zip
        rm JetBrainsMono.zip
    else
        echo "字体下载失败，请手动安装Nerd字体"
    fi
fi
fc-cache -fv
echo "字体安装完成！请在Termux设置中手动选择已安装的Nerd字体："
echo "- Fira Code Nerd Font"
echo "- JetBrains Mono Nerd Font"
echo "设置路径：Termux → 更多 → 设置 → 外观 → 字体"
pkg install vim
pkg install clang make cmake python nodejs npm git curl unzip tar -y
pkg install fzf bat ripgrep fd exa -y
pkg install openssh htop tree jq fzf bat ripgrep fd -y
npm install -g yarn pnpm typescript ts-node nodemon
# 我还不会换背景，所以跳过
echo "alias la='ls -a'" >> .bashrc
exit
