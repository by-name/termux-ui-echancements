#!/data/data/com.termux/files/usr/bin/bash
# MIT License 版本4.5 保留所有权利 版权2026到2028
echo 4.5重构更新
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak"
    fi
}
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
echo "初始化"
backup_file "$PREFIX/etc/apt/sources.list"
backup_file "$HOME/.bashrc"
cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.dat"
echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main" > "$PREFIX/etc/apt/sources.list"
echo "deb https://mirrors.ustc.edu.cn/termux/termux-packages-24 stable main" >> $PREFIX/etc/apt/
echo "现在获取存储权限"
termux-setup-storage
pkg update -y && pkg upgrade -y
touch ~/.hushlogin
pkg install neofetch wget git curl unzip tar -y
pkg install fish -y
echo "exec fish" >> ~/.bashrc
mkdir -p ~/oh-my-posh/themes
if ! command_exists oh-my-posh; then
    wget -q https://ohmyposh.dev/install.sh -O install.sh
    chmod +x install.sh
    ./install.sh
    rm install.sh
fi
mkdir -p ~/.cache/oh-my-posh 2>/dev/null || true
if [ -d ~/.cache/oh-my-posh ]; then
    mv ~/.cache/oh-my-posh/* ~/oh-my-posh/themes/ 2>/dev/null || true
    rm -rf ~/.cache/oh-my-posh
fi
mkdir -p ~/.config/fish
cat >> ~/.config/fish/config.fish << 'EOF'
set -g fish_greeting ""
if type -q oh-my-posh
    oh-my-posh init fish --config ~/oh-my-posh/themes/montys.omp.json | source
end
EOF
print_info "安装 Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
FONT_SUCCESS=0
if [ ! -f "FiraCodeNerdFont-Regular.ttf" ]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip && {
        unzip -q FiraCode.zip
        rm FiraCode.zip
        FONT_SUCCESS=1
    } || true
fi
if [ $FONT_SUCCESS -eq 0 ]; then
    if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip && {
            unzip -q JetBrainsMono.zip
            rm JetBrainsMono.zip
        }
    fi
fi

fc-cache -fv
print_info "设置背景图片..."
mkdir -p ~/backgrounds
BACKGROUND_URLS=(
    "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80"
    "https://images.unsplash.com/photo-1519681393784-d120267933ba?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80"
    "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80"
)
echo "请选择背景图片（输入数字）："
echo "1. 山脉风景"
echo "2. 星空夜景"
echo "3. 森林景观"
read -p "请输入选择 (1-3): " choice
case $choice in
    1) SELECTED_URL="${BACKGROUND_URLS[0]}"; BACKGROUND_NAME="mountain.jpg" ;;
    2) SELECTED_URL="${BACKGROUND_URLS[1]}"; BACKGROUND_NAME="stars.jpg" ;;
    3) SELECTED_URL="${BACKGROUND_URLS[2]}"; BACKGROUND_NAME="forest.jpg" ;;
    *) SELECTED_URL="${BACKGROUND_URLS[0]}"; BACKGROUND_NAME="mountain.jpg" ;;
esac
if wget -q "$SELECTED_URL" -O "$HOME/backgrounds/$BACKGROUND_NAME"; then
    cat > ~/set_background.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
if pm list packages | grep -q com.termux.styling; then
    am startservice -n com.termux.styling/.TermuxStyleService \
        -a com.termux.styling.BACKGROUND \
        --es path "$HOME/backgrounds/$BACKGROUND_NAME" > /dev/null 2>&1
    echo "背景已设置"
else
    echo "请先安装 Termux:Styling 插件来设置背景"
fi
EOF
    chmod +x ~/set_background.sh
    print_info "运行以下命令设置背景: bash ~/set_background.sh"
else
    print_info "背景下载失败，请检查网络连接"
fi
pkg install vim clang make cmake python -y
pkg install nodejs npm -y
pkg install bat exa fd ripgrep -y
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O install_ohmyzsh.sh
    RUNZSH=no CHSH=no sh install_ohmyzsh.sh
    rm install_ohmyzsh.sh
fi
if type -q fish; then
    fish -c "
    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end
    "
fi
if [ ! -d "$HOME/.nvm" ]; then
    wget -q https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh -O install_nvm.sh
    bash install_nvm.sh
    rm install_nvm.sh
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
if command_exists nvm; then
    nvm install --lts
    nvm use --lts
fi
read -p "请输入 Git 用户名 (默认: User): " git_user
git_user=${git_user:-User}
read -p "请输入 Git 邮箱 (默认: user@example.com): " git_email  
git_email=${git_email:-user@example.com}
git config --global user.name "$git_user"
git config --global user.email "$git_email"
pkg install proot-distro -y
if ! proot-distro list | grep -q ubuntu; then
    proot-distro install ubuntu
fi
cat >> ~/.bashrc << 'EOF'
alias la='ls -a'
alias ll='ls -l'
alias cat='bat'
alias ls='exa'
if [ -t 1 ] && [ -z "$FISH_VERSION" ]; then
    exec fish
fi
EOF
alias la='ls -a'
alias ll='ls -l'
alias cat='bat'
alias ls='exa'
print_info "安装完成！建议执行以下操作："
echo "1. 安装 Termux 插件："
echo "   - Termux:API (访问设备功能)"
echo "   - Termux:Styling (主题和背景)"  
echo "   - Termux:Boot (开机自启)"
echo "2. 重新启动 Termux 以应用所有更改"
echo "3. 运行 'source ~/.bashrc' 或新开终端来使用 fish shell"
echo -e "\n${GREEN}安装状态：${NC}"
echo "✓ 包管理器已配置"
echo "✓ Shell 已设置为 fish"
echo "✓ 开发工具已安装"
echo "✓ 字体已安装"
echo "✓ 背景设置脚本已准备"
echo "✓ Git 已配置"
echo "✓ Ubuntu 环境已准备"
exit 0
