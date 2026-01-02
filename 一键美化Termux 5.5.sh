#!/data/data/com.termux/files/usr/bin/bash
# MIT License 版本5.5 保留所有权利 版权2026到2028
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="$HOME/termux_setup.log"

log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak_$(date +%Y%m%d_%H%M%S)"
        log_info "已备份 $1"
    fi
}

setup_sources() {
    log_info "配置软件源..."
    backup_file "$PREFIX/etc/apt/sources.list"
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main" > "$PREFIX/etc/apt/sources.list"
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main" >> $PREFIX/etc/apt/sources.list
    pkg update -y && pkg upgrade -y
    log_success "软件源配置完成"
}

install_base_tools() {
    log_info "安装基础工具..."
    pkg install -y neofetch wget git curl unzip tar fish vim clang make cmake python nodejs npm bat exa fd ripgrep
    touch ~/.hushlogin
    log_success "基础工具安装完成"
}

setup_fish_shell() {
    log_info "配置 Fish Shell..."
    echo "exec fish" >> ~/.bashrc
    mkdir -p ~/.config/fish
    cat >> ~/.config/fish/config.fish << 'EOF'
set -g fish_greeting ""
if type -q oh-my-posh
    oh-my-posh init fish --config ~/oh-my-posh/themes/montys.omp.json | source
end
EOF
    log_success "Fish Shell 配置完成"
}

install_oh_my_posh() {
    if ! command_exists oh-my-posh; then
        log_info "安装 Oh My Posh..."
        wget -q https://ohmyposh.dev/install.sh -O install.sh
        chmod +x install.sh
        ./install.sh
        rm install.sh
    fi
    mkdir -p ~/oh-my-posh/themes
    mkdir -p ~/.cache/oh-my-posh 2>/dev/null || true
    if [ -d ~/.cache/oh-my-posh ]; then
        mv ~/.cache/oh-my-posh/* ~/oh-my-posh/themes/ 2>/dev/null || true
        rm -rf ~/.cache/oh-my-posh
    fi
    log_success "Oh My Posh 安装完成"
}

install_nerd_fonts() {
    log_info "安装 Nerd Font (FiraCode)..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    if [ ! -f "FiraCodeNerdFont-Regular.ttf" ]; then
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip && {
            unzip -q FiraCode.zip
            rm FiraCode.zip
        }
    fi
    fc-cache -fv
    log_success "Nerd Font 安装完成"
}

setup_background() {
    log_info "设置背景图片..."
    mkdir -p ~/backgrounds
    BACKGROUND_URL="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80"
    BACKGROUND_NAME="mountain.jpg"
    if wget -q "$BACKGROUND_URL" -O "$HOME/backgrounds/$BACKGROUND_NAME"; then
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
        log_info "运行 'bash ~/set_background.sh' 设置背景"
    else
        log_error "背景下载失败"
    fi
}

install_node_enhanced() {
    log_info "安装 Node.js 增强环境..."
    if [ ! -d "$HOME/.nvm" ]; then
        wget -q https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh -O install_nvm.sh
        bash install_nvm.sh
        rm install_nvm.sh
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    npm install -g yarn pnpm nodemon eslint typescript ts-node
    log_success "Node.js 增强环境安装完成"
}

install_python_enhanced() {
    log_info "安装 Python 增强环境..."
    pkg install -y python-pip
    pip install pipx
    pipx ensurepath
    pipx install httpie poetry black pylint
    log_success "Python 增强环境安装完成"
}

setup_proot_ubuntu() {
    log_info "安装 Ubuntu proot..."
    pkg install -y proot-distro
    if ! proot-distro list | grep -q ubuntu; then
        proot-distro install ubuntu
    fi
    log_success "Ubuntu proot 安装完成"
}

configure_git() {
    log_info "配置 Git..."
    git_user="User"
    git_email="user@example.com"
    git config --global user.name "$git_user"
    git config --global user.email "$git_email"
    log_success "Git 配置完成"
    git clone https://github.com/sqlsec/termux-install-linux
    unzip termux-install-linux.zip
}
git clone https://github.com/sqlsec/termux-install-linux
install_termux_plugins_tip() {
    log_info "建议安装的 Termux 插件："
    echo "pkg install termux-api termux-styling termux-boot"
}

show_summary() {
    log_success "安装完成！"
    echo -e "\n${GREEN}安装状态：${NC}"
    echo "✓ 包管理器已配置"
    echo "✓ Shell 已设置为 fish"
    echo "✓ 开发工具已安装"
    echo "✓ 字体已安装"
    echo "✓ 背景设置脚本已准备"
    echo "✓ Git 已配置"
    echo "✓ Ubuntu 环境已准备"
    echo "✓ Node.js/Yarn/pnpm 已安装"
    echo "✓ Python/pipx 已安装"
}

main() {
    echo "初始化..." | tee "$LOG_FILE"
    termux-setup-storage
    backup_file "$HOME/.bashrc"
    setup_sources
    install_base_tools
    setup_fish_shell
    install_oh_my_posh
    install_nerd_fonts
    setup_background
    install_node_enhanced
    install_python_enhanced
    setup_proot_ubuntu
    configure_git
    install_termux_plugins_tip
    show_summary
}

main