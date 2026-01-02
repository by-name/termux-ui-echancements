#!/data/data/com.termux/files/usr/bin/bash

# MIT License 版本7.0 保留所有权利 版权2026到2028
set -e
echo 本脚本仅用于美化Termux，请勿用于非法用途，by:Github by-name
echo -e "  TTTTT  EEEEE  RRRRR  M   M  U   U  X   X\n\
    T    E      R   R  MM MM  U   U  X X\n\
    T    EEEE   RRRR   M M M  U   U   X\n\
    T    E      R  R   M   M  U   U  X X\n\
    T    EEEEE  R   R  M   M  UUUUU  X   X"
echo     Termux Ultimate Edidtion
echo     手机最佳开发环境部署器
echo         作者:by-name
echo 3
sleep 1
echo 2
sleep 1
echo 1
sleep 1
echo Start!
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="$HOME/termux_setup_$(date +%Y%m%d_%H%M%S).log"

log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

backup_file() {
    if [ -f "$1" ]; then
        backup="$1.bak_$(date +%Y%m%d_%H%M%S)"
        cp "$1" "$backup"
        log_info "已备份 $1 到 $backup"
    fi
}

setup_termux_environment() {
    log_info "设置Termux环境..."
    
    if [ ! -d ~/storage ]; then
        log_info "请授予存储权限..."
        termux-setup-storage
        sleep 2
    fi
    
    mkdir -p ~/{bin,Projects,.local/bin,.config,tmp,scripts,backup,downloads}
    
    echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
    
    log_success "环境设置完成"
}

setup_sources() {
    log_info "配置软件源..."
    
    backup_file "$PREFIX/etc/apt/sources.list"
    backup_file "$PREFIX/etc/apt/sources.list.d/*" 2>/dev/null || true
    
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
# 清华源
deb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main
# 中科大源
deb https://mirrors.ustc.edu.cn/termux/termux-packages-24 stable main
# 阿里云源
deb https://mirrors.aliyun.com/termux/termux-packages-24 stable main
EOF
    
    log_info "更新软件包列表..."
    pkg update -y
    log_info "升级已安装的软件包..."
    pkg upgrade -y --allow-downgrades
    
    pkg autoclean
    pkg clean
    
    log_success "软件源配置完成"
}

install_base_tools() {
    log_info "安装基础工具..."
    
    pkg install -y \
        neofetch wget curl git tar unzip zip \
        nano vim neovim bat exa fd ripgrep fzf \
        htop proot-distro openssh tmux ranger \
        man ncdu tree jq yq python nodejs ruby
    
    if ! pkg show git | grep -q "Version: 2."; then
        log_info "安装最新版Git..."
        pkg install -y git
    fi
    
    touch ~/.hushlogin
    
    log_success "基础工具安装完成"
}

install_development_tools() {
    log_info "安装开发工具..."
    
    pkg install -y \
        clang cmake make gdb binutils \
        ninja pkg-config
    
    pip install --upgrade pip
    pkg install -y \
        python-numpy python-pandas python-scipy \
        python-matplotlib jupyter-notebook
    
    pkg install -y nodejs-lts
    
    pkg install -y openjdk-17
    
    pkg install -y golang
    
    pkg install -y rust
    
    pkg install -y sqlite mariadb
    
    pkg install -y net-tools dnsutils nmap httpie
    
    log_success "开发工具安装完成"
}

setup_fish_shell() {
    log_info "配置 Fish Shell..."
    
    pkg install -y fish
    
    if [ "$SHELL" != "$PREFIX/bin/fish" ]; then
        chsh -s "$PREFIX/bin/fish"
    fi
    
    mkdir -p ~/.config/fish/{conf.d,functions,completions}
    
    cat > ~/.config/fish/config.fish << 'EOF'
set -g fish_greeting ""

set -g fish_color_normal normal
set -g fish_color_command blue
set -g fish_color_param cyan
set -g fish_color_redirection brblue
set -g fish_color_comment red
set -g fish_color_error brred
set -g fish_color_escape bryellow
set -g fish_color_operator brcyan
set -g fish_color_end brmagenta
set -g fish_color_quote yellow
set -g fish_color_autosuggestion 555
set -g fish_color_user brgreen
set -g fish_color_host normal
set -g fish_color_valid_path --underline
set -g fish_color_match --background=brblue
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_cwd green
set -g fish_color_cwd_root red

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx MANPAGER "less -R"

set -gx PATH $HOME/bin $HOME/.local/bin $PATH

alias ls "exa --icons"
alias ll "exa -lh --icons"
alias la "exa -lha --icons"
alias lt "exa --tree --icons"
alias cat "bat"
alias grep "grep --color=auto"
alias fgrep "fgrep --color=auto"
alias egrep "egrep --color=auto"
alias vim "nvim"
alias vi "nvim"
alias g "git"
alias ga "git add"
alias gc "git commit"
alias gs "git status"
alias gl "git log --oneline --graph"
alias gd "git diff"
alias gp "git push"
alias gpl "git pull"
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias tree "tree -C"
alias df "df -h"
alias du "du -h"
alias free "free -h"

function fish_user_key_bindings
    bind \cr 'fzf-history-widget'
    bind \cv 'fzf-file-widget'
end

if type -q oh-my-posh
    oh-my-posh init fish --config ~/.config/oh-my-posh/themes/catppuccin_mocha.omp.json | source
end

if type -q starship
    starship init fish | source
end

set -q __fish_cd_direction_history; or set -g __fish_cd_direction_history
function __cdh_add_history
    set -l dir (pwd)
    if test "$dir" != "$__fish_cd_direction_history[1]"
        set -g __fish_cd_direction_history $dir $__fish_cd_direction_history
    end
end
functions --copy cd fish_cd
function cd
    fish_cd $argv
    __cdh_add_history
end
__cdh_add_history
EOF
    
    if [ ! -f ~/.config/fish/functions/fisher.fish ]; then
        log_info "安装Fisher插件管理器..."
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fi
    
    if command_exists fisher; then
        log_info "安装Fish插件..."
        fisher install \
            jorgebucaran/nvm.fish \
            jethrokuan/z \
            jorgebucaran/autopair.fish \
            PatrickF1/fzf.fish \
            edc/bass
    fi
    
    log_success "Fish Shell配置完成"
}

install_oh_my_posh() {
    log_info "安装Oh My Posh..."
    
    if ! command_exists oh-my-posh; then
        log_info "从GitHub安装Oh My Posh..."
        wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -O ~/.local/bin/oh-my-posh
        chmod +x ~/.local/bin/oh-my-posh
    fi
    
    mkdir -p ~/.config/oh-my-posh/themes
    
    THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes"
    
    themes=(
        "catppuccin_mocha.omp.json"
        "powerlevel10k_rainbow.omp.json"
        "atomic.omp.json"
        "jv.omp.json"
        "space.omp.json"
    )
    
    for theme in "${themes[@]}"; do
        if [ ! -f ~/.config/oh-my-posh/themes/$theme ]; then
            wget -q $THEME_URL/$theme -O ~/.config/oh-my-posh/themes/$theme || log_warn "无法下载主题: $theme"
        fi
    done
    
    if [ ! -f ~/.config/oh-my-posh/themes/custom.omp.json ]; then
        cat > ~/.config/oh-my-posh/themes/custom.omp.json << 'EOF'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "final_space": true,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "session",
          "style": "diamond",
          "foreground": "#ffffff",
          "background": "#FFB347",
          "properties": {
            "prefix": " ",
            "display_host": false
          }
        },
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#000000",
          "background": "#9ECB87",
          "properties": {
            "prefix": "  ",
            "style": "folder"
          }
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#000000",
          "background": "#E4C9AF",
          "properties": {
            "display_stash_count": true,
            "display_status": true,
            "local_changes_color": "#FFB347",
            "ahead_and_behind_color": "#9ECB87"
          }
        },
        {
          "type": "node",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#000000",
          "background": "#6CA0DC",
          "properties": {
            "prefix": " "
          }
        }
      ]
    },
    {
      "type": "rprompt",
      "segments": [
        {
          "type": "time",
          "style": "plain",
          "foreground": "#BEBEBE",
          "properties": {
            "time_format": "15:04"
          }
        }
      ]
    }
  ]
}
EOF
    fi
    
    log_success "Oh My Posh安装完成"
}

install_nerd_fonts() {
    log_info "安装Nerd Fonts..."
    
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    
    fonts=(
        "FiraCode"
        "JetBrainsMono"
        "Meslo"
        "CascadiaCode"
        "Hack"
    )
    
    for font in "${fonts[@]}"; do
        font_file="${font}NerdFont-Regular.ttf"
        if [ ! -f "$font_file" ]; then
            log_info "下载字体: $font..."
            wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/$font.zip" && {
                unzip -q -o "$font.zip" "*.ttf" 2>/dev/null || true
                rm -f "$font.zip"
                log_info "字体 $font 下载完成"
            } || log_warn "字体 $font 下载失败"
        fi
    done
    
    fc-cache -fv
    
    if command_exists termux-font; then
        log_info "设置Termux字体..."
        cp "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ~/.termux/font.ttf 2>/dev/null || true
    fi
    
    log_success "Nerd Fonts安装完成"
}

setup_background_and_theming() {
    log_info "设置终端主题和背景..."
    
    mkdir -p ~/backgrounds
    
    backgrounds=(
        "https://images.unsplash.com/photo-1519681393784-d120267933ba"
        "https://images.unsplash.com/photo-1518837695005-2083093ee35b"
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4"
        "https://images.unsplash.com/photo-1501854140801-50d01698950b"
    )
    
    for i in "${!backgrounds[@]}"; do
        bg_url="${backgrounds[$i]}?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80"
        bg_name="background_$((i+1)).jpg"
        if [ ! -f "$HOME/backgrounds/$bg_name" ]; then
            wget -q "$bg_url" -O "$HOME/backgrounds/$bg_name" && \
            log_info "下载背景: $bg_name" || \
            log_warn "背景下载失败: $bg_name"
        fi
    done
    
    cat > ~/scripts/setup_termux_theme.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}设置 Termux 主题${NC}"

if ! pm list packages | grep -q com.termux.styling; then
    echo -e "${YELLOW}请先安装 Termux:Styling 插件${NC}"
    echo "可以通过 F-Droid 或 GitHub 安装:"
    echo "https://github.com/termux/termux-styling"
    exit 1
fi

if [ -f "$HOME/.local/share/fonts/FiraCodeNerdFont-Regular.ttf" ]; then
    echo -e "${BLUE}设置字体为 Fira Code Nerd Font...${NC}"
    cp "$HOME/.local/share/fonts/FiraCodeNerdFont-Regular.ttf" ~/.termux/font.ttf
fi

echo -e "${BLUE}设置颜色方案...${NC}"
cat > ~/.termux/colors.properties << 'COLORSCHEME'
# Catppuccin Mocha
background=#1e1e2e
foreground=#cdd6f4
cursor=#f5e0dc
color0=#45475a
color8=#585b70
color1=#f38ba8
color9=#f38ba8
color2=#a6e3a1
color10=#a6e3a1
color3=#f9e2af
color11=#f9e2af
color4=#89b4fa
color12=#89b4fa
color5=#f5c2e7
color13=#f5c2e7
color6=#94e2d5
color14=#94e2d5
color7=#bac2de
color15=#a6adc8
COLORSCHEME

if [ -d "$HOME/backgrounds" ]; then
    bg_files=("$HOME"/backgrounds/*.jpg "$HOME"/backgrounds/*.png)
    if [ ${#bg_files[@]} -gt 0 ] && [ -e "${bg_files[0]}" ]; then
        selected_bg="${bg_files[0]}"
        echo -e "${BLUE}设置背景图片: $(basename "$selected_bg")${NC}"
        am startservice -n com.termux.styling/.TermuxStyleService \
            -a com.termux.styling.BACKGROUND \
            --es path "$selected_bg" > /dev/null 2>&1 || true
    fi
fi

termux-reload-settings

echo -e "${GREEN}主题设置完成！${NC}"
echo -e "${YELLOW}可能需要重启Termux应用才能看到所有更改${NC}"
EOF
    
    chmod +x ~/scripts/setup_termux_theme.sh
    
    cat > ~/scripts/random_background.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

BG_DIR="$HOME/backgrounds"
if [ -d "$BG_DIR" ]; then
    bg_files=("$BG_DIR"/*.jpg "$BG_DIR"/*.png)
    if [ ${#bg_files[@]} -gt 0 ] && [ -e "${bg_files[0]}" ]; then
        random_bg="${bg_files[RANDOM % ${#bg_files[@]}]}"
        if pm list packages | grep -q com.termux.styling; then
            am startservice -n com.termux.styling/.TermuxStyleService \
                -a com.termux.styling.BACKGROUND \
                --es path "$random_bg" > /dev/null 2>&1
            echo "已切换背景: $(basename "$random_bg")"
        else
            echo "请先安装 Termux:Styling 插件"
        fi
    else
        echo "背景文件夹为空"
    fi
else
    echo "背景文件夹不存在: $BG_DIR"
fi
EOF
    
    chmod +x ~/scripts/random_background.sh
    
    log_success "主题和背景设置完成"
    echo -e "${YELLOW}运行 ~/scripts/setup_termux_theme.sh 来应用主题${NC}"
}

install_node_enhanced() {
    log_info "安装Node.js增强环境..."
    
    if [ ! -d "$HOME/.nvm" ]; then
        log_info "安装nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
        
        cat >> ~/.bashrc << 'NVM_CONFIG'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
NVM_CONFIG
        
        cat >> ~/.config/fish/config.fish << 'FISH_NVM'
if test -d "$HOME/.nvm"
    set -gx NVM_DIR "$HOME/.nvm"
    bass source "$NVM_DIR/nvm.sh" ';' nvm >/dev/null
end
FISH_NVM
        
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    if command_exists nvm; then
        log_info "安装Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'
    fi
    
    if command_exists npm; then
        log_info "安装全局npm包..."
        
        npm install -g \
            yarn \
            pnpm \
            typescript \
            ts-node \
            nodemon \
            eslint \
            prettier \
            @nestjs/cli \
            create-react-app \
            vue-cli \
            nx \
            webpack \
            webpack-cli \
            parcel \
            jest \
            mocha \
            npm-check-updates
        
        npm install -g \
            tldr \
            live-server \
            http-server \
            json-server \
            nodemon \
            concurrently
        
        if command_exists yarn; then
            log_info "Yarn版本: $(yarn --version)"
        fi
        if command_exists pnpm; then
            log_info "PNPM版本: $(pnpm --version)"
        fi
    fi
    
    log_success "Node.js环境安装完成"
}

install_python_enhanced() {
    log_info "安装Python增强环境..."
    
    pip install --upgrade pip setuptools wheel
    
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    
    pipx install httpie
    pipx install poetry
    pipx install black
    pipx install pylint
    pipx install flake8
    pipx install mypy
    pipx install pyright
    pipx install cookiecutter
    pipx install pre-commit
    
    pip install --user \
        numpy \
        pandas \
        matplotlib \
        seaborn \
        scipy \
        scikit-learn \
        jupyter \
        ipython \
        requests \
        beautifulsoup4 \
        fastapi \
        sqlalchemy \
        django \
        flask \
        tornado \
        pyyaml \
        python-dotenv \
        pytest \
        hypothesis \
        tqdm \
        rich \
        typer
    
    python3 -m venv ~/venv/python_env
    
    log_success "Python环境安装完成"
}

setup_proot_distros() {
    log_info "设置PRoot发行版..."
    
    pkg install -y proot-distro
    
    distros=("ubuntu" "debian" "fedora" "alpine" "archlinux")
    
    echo -e "${CYAN}可用的PRoot发行版:${NC}"
    for i in "${!distros[@]}"; do
        echo "  $((i+1)). ${distros[$i]}"
    done
    
    read -p "请选择要安装的发行版编号 (1-${#distros[@]}, 默认1): " choice
    choice=${choice:-1}
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#distros[@]}" ]; then
        selected_distro="${distros[$((choice-1))]}"
        
        if ! proot-distro list | grep -q "^$selected_distro\$"; then
            log_info "安装 $selected_distro..."
            proot-distro install "$selected_distro"
            
            cat > ~/start_${selected_distro}.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
echo "启动 $selected_distro..."
proot-distro login $selected_distro
EOF
            chmod +x ~/start_${selected_distro}.sh
            
            if [ "$selected_distro" = "ubuntu" ]; then
                cat > ~/start_ubuntu_gui.sh << 'UBUNTU_GUI'
#!/data/data/com.termux/files/usr/bin/bash

echo "安装图形环境..."
proot-distro login ubuntu -- bash -c "
apt update && apt install -y xfce4 xfce4-goodies tightvncserver
"

echo "创建VNC配置..."
cat > ~/.vnc/xstartup << 'VNCSTART'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
VNCSTART
chmod +x ~/.vnc/xstartup

echo "设置VNC密码..."
vncpasswd

echo "启动VNC服务器..."
vncserver :1 -geometry 1280x720 -depth 24

echo "VNC服务器已启动"
echo "使用VNC客户端连接 localhost:5901"
UBUNTU_GUI
                chmod +x ~/start_ubuntu_gui.sh
            fi
        else
            log_info "$selected_distro 已安装"
        fi
    fi
    
    cat > ~/scripts/manage_proot.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

case "$1" in
    list)
        echo -e "${BLUE}已安装的PRoot发行版:${NC}"
        proot-distro list
        ;;
    install)
        if [ -z "$2" ]; then
            echo -e "${YELLOW}用法: $0 install <distro>${NC}"
            echo "可用发行版: ubuntu debian fedora alpine archlinux"
            exit 1
        fi
        proot-distro install "$2"
        ;;
    remove)
        if [ -z "$2" ]; then
            echo -e "${YELLOW}用法: $0 remove <distro>${NC}"
            exit 1
        fi
        proot-distro remove "$2"
        ;;
    backup)
        if [ -z "$2" ]; then
            distro="ubuntu"
        else
            distro="$2"
        fi
        backup_file="$HOME/backup/${distro}_$(date +%Y%m%d_%H%M%S).tar.gz"
        echo -e "${BLUE}备份 $distro 到 $backup_file${NC}"
        mkdir -p ~/backup
        proot-distro backup "$distro" | gzip > "$backup_file"
        echo -e "${GREEN}备份完成${NC}"
        ;;
    restore)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo -e "${YELLOW}用法: $0 restore <distro> <backup_file>${NC}"
            exit 1
        fi
        echo -e "${BLUE}从 $3 恢复 $distro${NC}"
        gunzip -c "$3" | proot-distro restore "$2"
        echo -e "${GREEN}恢复完成${NC}"
        ;;
    *)
        echo -e "${BLUE}PRoot 发行版管理工具${NC}"
        echo "命令:"
        echo "  list                   列出已安装的发行版"
        echo "  install <distro>       安装发行版"
        echo "  remove <distro>        删除发行版"
        echo "  backup [distro]        备份发行版"
        echo "  restore <distro> <file> 恢复发行版"
        ;;
esac
EOF
    
    chmod +x ~/scripts/manage_proot.sh
    
    log_success "PRoot环境设置完成"
}

configure_git() {
    log_info "配置Git..."
    
    echo -e "${CYAN}配置Git用户信息${NC}"
    
    read -p "请输入Git用户名 (默认: $(whoami)): " git_user
    git_user=${git_user:-$(whoami)}
    
    read -p "请输入Git邮箱 (默认: $(whoami)@localhost): " git_email
    git_email=${git_email:-"$(whoami)@localhost"}
    
    read -p "请输入默认编辑器 (默认: nvim): " git_editor
    git_editor=${git_editor:-nvim}
    
    git config --global user.name "$git_user"
    git config --global user.email "$git_email"
    git config --global core.editor "$git_editor"
    git config --global init.defaultBranch main
    git config --global color.ui auto
    git config --global pull.rebase false
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "${CYAN}生成SSH密钥...${NC}"
        read -p "为SSH密钥添加注释 (可选): " ssh_comment
        ssh-keygen -t ed25519 -C "${ssh_comment:-$git_email}" -f ~/.ssh/id_ed25519 -N ""
        
        echo -e "${GREEN}SSH公钥:${NC}"
        echo "----------------------------------------"
        cat ~/.ssh/id_ed25519.pub
        echo "----------------------------------------"
        echo -e "${YELLOW}请将上述公钥添加到你的Git托管服务 (GitHub, GitLab等)${NC}"
    fi
    
    log_info "克隆有用的Git仓库..."
    mkdir -p ~/Projects
    cd ~/Projects
    
    repos=(
        "https://github.com/sqlsec/termux-install-linux"
        "https://github.com/termux/termux-packages"
        "https://github.com/oh-my-fish/oh-my-fish"
        "https://github.com/junegunn/fzf"
    )
    
    for repo in "${repos[@]}"; do
        repo_name=$(basename "$repo")
        if [ ! -d "$repo_name" ]; then
            git clone --depth=1 "$repo" || log_warn "克隆失败: $repo"
        fi
    done
    
    log_success "Git配置完成"
}

install_termux_plugins() {
    log_info "安装Termux插件和相关工具..."
    
    echo -e "${CYAN}建议安装的Termux插件:${NC}"
    echo "1. Termux:API - 访问Android API"
    echo "2. Termux:Styling - 终端主题和字体"
    echo "3. Termux:Widget - 桌面小工具"
    echo "4. Termux:Boot - 开机自启动"
    echo "5. Termux:Float - 悬浮窗口"
    
    echo -e "\n${YELLOW}这些插件需要从F-Droid或GitHub安装:${NC}"
    echo "F-Droid: https://f-droid.org/packages/com.termux.api/"
    echo "GitHub: https://github.com/termux/termux-api"
    
    cat > ~/scripts/termux_plugins_info.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;36mTermux 插件安装指南\033[0m"
echo "="*50

echo -e "\n\033[1;32m必装插件:\033[0m"
echo "1. \033[1;34mTermux:API\033[0m"
echo "   功能: 访问Android API (联系人、短信、通知等)"
echo "   安装: https://f-droid.org/packages/com.termux.api/"
echo ""
echo "2. \033[1;34mTermux:Styling\033[0m"
echo "   功能: 自定义终端颜色、字体、背景"
echo "   安装: https://f-droid.org/packages/com.termux.styling/"
echo ""
echo "3. \033[1;34mTermux:Widget\033[0m"
echo "   功能: 桌面小工具，快速运行命令"
echo "   安装: https://f-droid.org/packages/com.termux.widget/"
echo ""
echo "4. \033[1;34mTermux:Boot\033[0m"
echo "   功能: 开机自启动脚本"
echo "   安装: https://f-droid.org/packages/com.termux.boot/"
echo ""
echo "5. \033[1;34mTermux:Float\033[0m"
echo "   功能: 浮动窗口模式"
echo "   安装: https://f-droid.org/packages/com.termux.float/"

echo -e "\n\033[1;33m安装方法:\033[0m"
echo "1. 安装F-Droid: https://f-droid.org"
echo "2. 在F-Droid中搜索 'Termux'"
echo "3. 安装上述插件"
echo "4. 授予必要的权限"

echo -e "\n\033[1;33m常用API命令:\033[0m"
echo "termux-vibrate          # 震动"
echo "termux-notification     # 发送通知"
echo "termux-toast            # 显示Toast消息"
echo "termux-telephony-call   # 拨打电话"
echo "termux-sms-send         # 发送短信"
echo "termux-clipboard-get    # 获取剪贴板"
echo "termux-clipboard-set    # 设置剪贴板"
echo "termux-camera-photo     # 拍照"
echo "termux-location         # 获取位置"

echo -e "\n\033[1;33m开机自启动配置:\033[0m"
echo "1. 创建 ~/.termux/boot/ 目录"
echo "2. 将启动脚本放在该目录"
echo "3. 脚本必须有执行权限"
echo "4. 重启后自动运行"

echo -e "\n\033[1;33m小工具配置:\033[0m"
echo "1. 创建 ~/.shortcuts/ 目录"
echo "2. 将脚本放在该目录"
echo "3. 脚本必须有执行权限"
echo "4. 在桌面添加Termux小工具"
echo "5. 选择要运行的脚本"

echo -e "\n\033[1;32m已安装的插件:\033[0m"
for pkg in api styling widget boot float; do
    if pm list packages | grep -q "com.termux.$pkg"; then
        echo -e "✓ Termux:${pkg^}"
    fi
done
EOF
    
    chmod +x ~/scripts/termux_plugins_info.sh
    
    mkdir -p ~/.termux/boot ~/.shortcuts/tasks
    
    cat > ~/.termux/boot/start_ssh.sh << 'BOOT_SSH'
#!/data/data/com.termux/files/usr/bin/bash

sleep 5
if ! pgrep -x "sshd" > /dev/null; then
    sshd
    echo "SSH服务器已启动" | termux-notification --title "Termux Boot"
fi
BOOT_SSH
    
    cat > ~/.shortcuts/tasks/backup_home.sh << 'SHORTCUT_BACKUP'
#!/data/data/com.termux/files/usr/bin/bash

BACKUP_DIR="$HOME/storage/shared/TermuxBackups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"

echo "开始备份..."
cd ~
tar -czf "$BACKUP_FILE" \
    --exclude='storage' \
    --exclude='.cache' \
    --exclude='tmp' \
    .

echo "备份完成: $BACKUP_FILE"
termux-toast -g top "备份完成: $(basename "$BACKUP_FILE")"
SHORTCUT_BACKUP
    
    chmod +x ~/.termux/boot/*.sh ~/.shortcuts/tasks/*.sh
    
    log_success "插件配置完成"
}

install_additional_tools() {
    log_info "安装额外工具..."
    
    pkg install -y \
        btop \
        nethogs \
        iftop \
        speedtest-go \
        neofetch \
        htop
    
    pkg install -y \
        mtr \
        tcpdump \
        netcat-openbsd \
        socat \
        sshuttle \
        aria2
    
    pkg install -y \
        rename \
        jq \
        yq \
        csvkit \
        xmlstarlet \
        htmlq \
        pup
    
    pkg install -y \
        cmatrix \
        sl \
        fortune \
        cowsay \
        lolcat \
        figlet \
        toilet
    
    pkg install -y \
        mc \
        ranger \
        fzf \
        fd \
        ripgrep \
        bat \
        exa \
        duf \
        ncdu
    
    pkg install -y \
        gcc \
        g++ \
        clang \
        make \
        cmake \
        ninja \
        automake \
        autoconf \
        libtool
    
    pkg install -y \
        ffmpeg \
        imagemagick \
        mpv \
        sox \
        pulseaudio
    
    pkg install -y \
        nmap \
        hydra \
        sqlmap \
        nikto \
        netcat \
        wireshark
    
    pkg install -y \
        python \
        nodejs \
        ruby \
        perl \
        php \
        lua
    
    pkg install -y \
        git \
        git-lfs \
        tig \
        hub
    
    pkg install -y \
        tmux \
        screen \
        zsh \
        fish \
        bash-completion
    
    pkg install -y \
        tree \
        rsync \
        wget \
        curl \
        unzip \
        zip \
        p7zip \
        rclone \
        taskwarrior \
        timewarrior
        wget -O install-nethunter-termux.sh https://offs.ec/2MceZWr
        chmod +x install-nethunter-termux.sh
        ./install-nethunter-termux.sh
    
    log_success "额外工具安装完成"
}

setup_security() {
    log_info "设置安全配置..."
    
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    if [ ! -f ~/.ssh/config ]; then
        cat > ~/.ssh/config << 'SSHCONFIG'
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/controlmasters/%r@%h:%p
    ControlPersist 10m
    
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
SSHCONFIG
        chmod 600 ~/.ssh/config
    fi
    
    echo "umask 022" >> ~/.bashrc
    echo "umask 022" >> ~/.config/fish/config.fish
    
    echo "export HISTCONTROL=ignorespace" >> ~/.bashrc
    echo "set -gx HISTCONTROL ignorespace" >> ~/.config/fish/config.fish
    
    cat > ~/scripts/security_check.sh << 'SECURITY'
#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;36mTermux 安全检查\033[0m"
echo "="*50

echo -e "\n\033[1;33mSSH密钥权限检查:\033[0m"
for key in ~/.ssh/*; do
    if [ -f "$key" ]; then
        perm=$(stat -c "%a" "$key")
        if [[ "$perm" == "600" ]] || [[ "$perm" == "400" ]]; then
            echo -e "✓ $(basename "$key"): $perm"
        else
            echo -e "✗ $(basename "$key"): $perm (应该为600或400)"
        fi
    fi
done

echo -e "\n\033[1;33mSSH目录权限:\033[0m"
ssh_dir_perm=$(stat -c "%a" ~/.ssh)
if [[ "$ssh_dir_perm" == "700" ]]; then
    echo -e "✓ ~/.ssh: $ssh_dir_perm"
else
    echo -e "✗ ~/.ssh: $ssh_dir_perm (应该为700)"
fi

echo -e "\n\033[1;33mumask检查:\033[0m"
current_umask=$(umask)
if [[ "$current_umask" == "0022" ]] || [[ "$current_umask" == "022" ]]; then
    echo -e "✓ umask: $current_umask"
else
    echo -e "✗ umask: $current_umask (应该为022)"
fi

echo -e "\n\033[1;33m最近登录:\033[0m"
last 2>/dev/null | head -5 || echo "无法获取登录历史"

echo -e "\n\033[1;33m网络连接:\033[0m"
netstat -tulpn 2>/dev/null | grep LISTEN || echo "无法获取网络连接"

echo -e "\n\033[1;33m可疑进程:\033[0m"
ps aux 2>/dev/null | grep -E "(miner|crypto|backdoor)" | grep -v grep || echo "未发现可疑进程"

echo -e "\n\033[1;33m系统文件检查:\033[0m"
important_files=(
    "$PREFIX/bin/bash"
    "$PREFIX/bin/sh"
    "$PREFIX/bin/login"
)
for file in "${important_files[@]}"; do
    if [ -f "$file" ]; then
        if [[ $(stat -c "%a" "$file") == "755" ]]; then
            echo -e "✓ $file"
        else
            echo -e "✗ $file: 权限异常"
        fi
    fi
done

echo -e "\n\033[1;32m安全检查完成\033[0m"
SECURITY
    
    chmod +x ~/scripts/security_check.sh
    
    cat > ~/scripts/backup_termux.sh << 'BACKUP'
#!/data/data/com.termux/files/usr/bin/bash

BACKUP_DIR="$HOME/storage/shared/TermuxBackups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/termux_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

echo "开始备份Termux..."
echo "备份文件: $BACKUP_FILE"

cat > /tmp/exclude_list.txt << 'EXCLUDE'
storage
.cache
tmp
.thumbnails
.Trash
node_modules
__pycache__
*.log
*.tmp
*.temp
EXCLUDE

cd ~
tar -czf "$BACKUP_FILE" \
    --exclude-from=/tmp/exclude_list.txt \
    .

backup_size=$(du -h "$BACKUP_FILE" | cut -f1)

echo "备份完成!"
echo "备份文件: $BACKUP_FILE"
echo "备份大小: $backup_size"

echo -e "\n备份列表:"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -5

find "$BACKUP_DIR" -name "termux_backup_*.tar.gz" -mtime +7 -delete
echo "已清理7天前的备份"
BACKUP
    
    chmod +x ~/scripts/backup_termux.sh
    
    cat > ~/scripts/restore_termux.sh << 'RESTORE'
#!/data/data/com.termux/files/usr/bin/bash

BACKUP_DIR="$HOME/storage/shared/TermuxBackups"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "备份目录不存在: $BACKUP_DIR"
    exit 1
fi

echo "可用的备份文件:"
echo "="*50
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | nl -w3 -s') '
echo "="*50

read -p "请选择要恢复的备份编号 (q退出): " choice

if [ "$choice" = "q" ]; then
    echo "已取消"
    exit 0
fi

backup_files=("$BACKUP_DIR"/*.tar.gz)
if [ -z "${backup_files[$choice]}" ]; then
    echo "无效的选择"
    exit 1
fi

selected_backup="${backup_files[$((choice-1))]}"

echo -e "\n警告: 这将恢复备份: $(basename "$selected_backup")"
echo "当前数据将被覆盖!"
read -p "确定要恢复吗? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "已取消"
    exit 0
fi

echo "正在恢复备份..."
cd ~
tar -xzf "$selected_backup"

echo "恢复完成!"
echo "建议重新启动Termux"
RESTORE
    
    chmod +x ~/scripts/restore_termux.sh
    
    log_success "安全配置完成"
}

setup_aliases_and_functions() {
    log_info "设置别名和函数..."
    
    cat > ~/.bash_aliases << 'ALIASES'
alias ll='ls -lh'
alias la='ls -lha'
alias l='ls -CF'
alias ltr='ls -ltr'
alias lt='ls -lt'
alias lr='ls -lR'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

alias myip='curl ifconfig.me'
alias ports='netstat -tulpn'
alias ping='ping -c 5'
alias trace='traceroute'
alias http='python3 -m http.server'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gst='git stash'
alias gm='git merge'

alias df='df -h'
alias du='du -h'
alias free='free -h'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias cpuinfo='lscpu'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

alias termux-reload='termux-reload-settings'
alias termux-clipboard-get='termux-clipboard-get'
alias termux-clipboard-set='termux-clipboard-set'
alias termux-notification='termux-notification'
alias termux-toast='termux-toast'
alias termux-vibrate='termux-vibrate'
alias termux-open='termux-open'
alias termux-share='termux-share'

alias py='python3'
alias ipy='ipython'
alias pserver='python3 -m http.server 8000'
alias nj='node --inspect'
alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

mkcd() { mkdir -p "$1" && cd "$1"; }
gif() { git add . && git commit -m "$1"; }
backup() { cp "$1" "$1.bak"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
weather() { curl wttr.in/"${1:-Beijing}"; }
qrcode() { echo "$1" | curl -d @- https://qrcode.show; }
cheat() { curl "cheat.sh/$1"; }
ALIASES
    
    echo '[ -f ~/.bash_aliases ] && source ~/.bash_aliases' >> ~/.bashrc
    
    cat > ~/.config/fish/conf.d/aliases.fish << 'FISH_ALIASES'
alias ll "ls -lh"
alias la "ls -lha"
alias l "ls -CF"
alias ltr "ls -ltr"
alias lt "ls -lt"
alias lr "ls -lR"

alias rm "rm -i"
alias cp "cp -i"
alias mv "mv -i"
alias ln "ln -i"

alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gpl "git pull"
alias gco "git checkout"
alias gb "git branch"
alias gl "git log --oneline --graph --all"
alias gd "git diff"
alias gst "git stash"
alias gm "git merge"

function mkcd
    mkdir -p $argv[1]
    and cd $argv[1]
end

function gif
    git add .
    and git commit -m "$argv"
end

function backup
    cp $argv[1] "$argv[1].bak"
end

function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

function weather
    curl "wttr.in/$argv[1]"
end

function qrcode
    echo $argv[1] | curl -d @- https://qrcode.show
end

function cheat
    curl "cheat.sh/$argv[1]"
end
FISH_ALIASES
    
    cat > ~/scripts/welcome.sh << 'WELCOME'
#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << 'EOF'
  _______                       __
 |__   __|                     / _|
    | | ___ _ __ _ __ ___  ___| |_ _   _
    | |/ _ \ '__| '_ ` _ \/ __|  _| | | |
    | |  __/ |  | | | | | \__ \ | | |_| |
    |_|\___|_|  |_| |_| |_|___/_|  \__, |
                                    __/ |
                                   |___/
EOF
echo -e "${NC}"

echo -e "${YELLOW}欢迎使用 Termux!${NC}"
echo -e "${BLUE}系统信息:${NC}"
echo "----------------------------------------"
neofetch 2>/dev/null || echo "安装 neofetch 来显示系统信息"
echo "----------------------------------------"

echo -e "${GREEN}可用命令:${NC}"
echo "  ${CYAN}welcome${NC}        - 显示此欢迎信息"
echo "  ${CYAN}backup-termux${NC}  - 备份Termux"
echo "  ${CYAN}restore-termux${NC} - 恢复Termux"
echo "  ${CYAN}security-check${NC} - 安全检查"
echo "  ${CYAN}setup-theme${NC}    - 设置主题"
echo "  ${CYAN}random-bg${NC}      - 随机切换背景"
echo "  ${CYAN}manage-proot${NC}   - 管理PRoot发行版"
echo "  ${CYAN}plugins-info${NC}   - Termux插件信息"

echo -e "${GREEN}快捷方式:${NC}"
echo "  ${CYAN}~/.shortcuts/tasks/${NC} - 小工具脚本"
echo "  ${CYAN}~/.termux/boot/${NC}     - 开机启动脚本"
echo "  ${CYAN}~/scripts/${NC}          - 实用脚本"

echo -e "${YELLOW}提示:${NC}"
echo "  • 使用 ${CYAN}fish${NC} 作为默认shell"
echo "  • 已安装 ${CYAN}Oh My Posh${NC} 提示符"
echo "  • 支持 ${CYAN}PRoot${NC} Linux发行版"
echo "  • 安装 ${CYAN}Termux:Styling${NC} 来自定义主题"

echo -e "${PURPLE}开始你的Termux之旅吧! 🚀${NC}"
WELCOME
    
    chmod +x ~/scripts/welcome.sh
    
    cat >> ~/.config/fish/config.fish << 'FISH_WELCOME'
if status is-interactive
    and not set -q TMUX
    ~/scripts/welcome.sh
end
FISH_WELCOME
    
    echo '[ -n "$PS1" ] && ~/scripts/welcome.sh' >> ~/.bashrc
    
    log_success "别名和函数设置完成"
}

cleanup_and_finalize() {
    log_info "清理和最终配置..."
    
    pkg autoclean
    pkg clean
    
    if command_exists mandb; then
        mandb -q
    fi
    
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
    
    chmod 700 ~/.ssh 2>/dev/null || true
    chmod 600 ~/.ssh/* 2>/dev/null || true
    chmod 755 ~/scripts/*.sh 2>/dev/null || true
    
    date > ~/.termux_setup_complete
    
    log_success "清理完成"
}

show_summary() {
    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    Termux 配置完成！                    ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}📦 已安装的软件包:${NC}"
    echo "  ✓ 基础工具 (git, curl, wget, vim, neovim)"
    echo "  ✓ 开发工具 (Python, Node.js, Go, Rust, Java)"
    echo "  ✓ 系统工具 (htop, tmux, ranger, fzf)"
    echo "  ✓ 网络工具 (nmap, httpie, ssh)"
    echo "  ✓ 文本处理 (bat, exa, fd, ripgrep)"
    
    echo -e "\n${CYAN}🎨 主题和外观:${NC}"
    echo "  ✓ Fish Shell 配置"
    echo "  ✓ Oh My Posh 提示符"
    echo "  ✓ Nerd Fonts 字体"
    echo "  ✓ 终端背景图片"
    echo "  ✓ 颜色方案 (Catppuccin Mocha)"
    
    echo -e "\n${CYAN}🐧 虚拟化环境:${NC}"
    echo "  ✓ PRoot 发行版支持"
    echo "  ✓ Ubuntu/Debian/Fedora/Alpine/Arch"
    echo "  ✓ 启动脚本"
    
    echo -e "\n${CYAN}🛠️ 开发环境:${NC}"
    echo "  ✓ Node.js 和 npm/yarn/pnpm"
    echo "  ✓ Python 和 pip/pipx/poetry"
    echo "  ✓ Git 配置和SSH密钥"
    echo "  ✓ 多版本管理器 (nvm)"
    
    echo -e "\n${CYAN}📁 目录结构:${NC}"
    echo "  ~/bin/              - 用户脚本"
    echo "  ~/scripts/          - 实用脚本"
    echo "  ~/Projects/         - 项目目录"
    echo "  ~/backgrounds/     - 背景图片"
    echo "  ~/.shortcuts/       - 小工具脚本"
    echo "  ~/.termux/boot/     - 开机启动脚本"
    
    echo -e "\n${CYAN}🚀 可用脚本:${NC}"
    echo "  ${YELLOW}welcome${NC}           - 显示欢迎信息"
    echo "  ${YELLOW}setup_termux_theme${NC} - 设置终端主题"
    echo "  ${YELLOW}random_background${NC}  - 随机切换背景"
    echo "  ${YELLOW}backup_termux${NC}      - 备份Termux"
    echo "  ${YELLOW}restore_termux${NC}     - 恢复Termux"
    echo "  ${YELLOW}security_check${NC}     - 安全检查"
    echo "  ${YELLOW}manage_proot${NC}       - 管理PRoot发行版"
    echo "  ${YELLOW}termux_plugins_info${NC} - Termux插件信息"
    
    echo -e "\n${CYAN}🔧 配置完成:${NC}"
    echo "  ✓ Shell: Fish 和 Bash"
    echo "  ✓ 编辑器: Neovim"
    echo "  ✓ 包管理器: pkg, pip, npm, yarn"
    echo "  ✓ 终端增强: fzf, exa, bat, ripgrep"
    echo "  ✓ 系统监控: htop, btop, neofetch"
    
    echo -e "\n${CYAN}🔌 Termux插件建议:${NC}"
    echo "  1. Termux:API     - Android API访问"
    echo "  2. Termux:Styling - 主题和字体"
    echo "  3. Termux:Widget  - 桌面小工具"
    echo "  4. Termux:Boot    - 开机自启动"
    echo "  5. Termux:Float   - 悬浮窗口"
    echo "  (从F-Droid或GitHub安装)"
    
    echo -e "\n${CYAN}🐚 默认Shell:${NC}"
    echo "  Fish Shell 已设置为默认shell"
    echo "  重启Termux或运行 'exec fish' 生效"
    
    echo -e "\n${CYAN}📊 磁盘使用:${NC}"
    df -h $PREFIX 2>/dev/null || echo "  无法获取磁盘使用情况"
    
    echo -e "\n${CYAN}📋 下一步建议:${NC}"
    echo "  1. 重启Termux应用"
    echo "  2. 运行 'welcome' 查看欢迎信息"
    echo "  3. 运行 'setup_termux_theme' 设置主题"
    echo "  4. 安装Termux插件 (从F-Droid)"
    echo "  5. 配置Git用户名和邮箱"
    
    echo -e "\n${GREEN}🎉 安装完成！享受你的Termux之旅！${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}系统信息:${NC}"
    echo "主机名: $(hostname)"
    echo "内核: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "存储: $(df -h $HOME | awk 'NR==2 {print $4}') 可用"
    
    echo -e "\n${YELLOW}安装日志: $LOG_FILE${NC}"
    
    cat > ~/first_run.sh << 'FIRSTRUN'
#!/data/data/com.termux/files/usr/bin/bash

echo "首次启动配置..."
echo "1. 设置Git用户信息..."
read -p "请输入Git用户名: " git_name
read -p "请输入Git邮箱: " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"

echo "2. 生成SSH密钥..."
ssh-keygen -t ed25519 -C "$git_email"

echo "3. 显示SSH公钥..."
echo "========================================"
cat ~/.ssh/id_ed25519.pub
echo "========================================"
echo "请将上述公钥添加到你的Git托管服务"

echo "4. 设置完成！"
FIRSTRUN
    
    chmod +x ~/first_run.sh
    echo -e "\n${YELLOW}运行 ~/first_run.sh 完成首次设置${NC}"
}

main() {
    echo -e "${GREEN}开始Termux配置...${NC}"
    echo -e "日志文件: $LOG_FILE"
    echo -e "开始时间: $(date)\n"
    
    START_TIME=$(date +%s)
    
    setup_termux_environment
    setup_sources
    install_base_tools
    install_development_tools
    install_additional_tools
    setup_fish_shell
    install_oh_my_posh
    install_nerd_fonts
    setup_background_and_theming
    install_node_enhanced
    install_python_enhanced
    setup_proot_distros
    configure_git
    install_termux_plugins
    setup_security
    setup_aliases_and_functions
    cleanup_and_finalize
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}安装完成！耗时: $((DURATION / 60))分$((DURATION % 60))秒${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    show_summary
    
    echo -e "${YELLOW}⚠️  重要提示:${NC}"
    echo "1. 可能需要重启Termux应用才能应用所有更改"
    echo "2. 某些功能需要Termux插件支持"
    echo "3. 确保设备有足够的存储空间"
    echo "4. 定期备份重要数据"
    echo "5. 查看 ~/scripts/ 目录下的实用脚本"
    
    echo -e "\n${CYAN}🔄 重启Termux:${NC}"
    echo "  1. 完全退出Termux应用"
    echo "  2. 从最近任务中清除"
    echo "  3. 重新打开Termux"
    echo "  4. 运行 'welcome' 查看欢迎信息"
    
    echo -e "\n${GREEN}🎯 安装完成！${NC}"
    echo "作者B站:https://b23.tv/yXJsNoJ"
    echo "作者Github:https://github.com/by-name"
}

trap 'log_error "脚本在 $BASH_COMMAND 处出错，退出状态: $?"' ERR

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
