# MIT License 版本4.0 保留所有权利 版权2026到2028
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

echo "正在设置背景图片..."
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
    1)
        SELECTED_URL="${BACKGROUND_URLS[0]}"
        BACKGROUND_NAME="mountain.jpg"
        ;;
    2)
        SELECTED_URL="${BACKGROUND_URLS[1]}"
        BACKGROUND_NAME="stars.jpg"
        ;;
    3)
        SELECTED_URL="${BACKGROUND_URLS[2]}"
        BACKGROUND_NAME="forest.jpg"
        ;;
    *)
        echo "无效选择，使用默认背景"
        SELECTED_URL="${BACKGROUND_URLS[0]}"
        BACKGROUND_NAME="mountain.jpg"
        ;;
esac

echo "正在下载背景图片..."
if wget -q "$SELECTED_URL" -O ~/backgrounds/$BACKGROUND_NAME; then
    echo "背景图片下载成功：$BACKGROUND_NAME"
    
    cat > ~/set_background.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
am broadcast --user 0 -a com.termux.app.SET_BACKGROUND --es path "$(pwd)/backgrounds/$BACKGROUND_NAME" com.termux > /dev/null 2>&1
EOF
    
    chmod +x ~/set_background.sh
    
    if ~/set_background.sh; then
        echo "✅ 背景图片已自动设置！"
    else
        echo "⚠️  自动设置失败，请手动设置："
        echo "1. 安装 Termux:Styling 插件"
        echo "2. 运行命令: bash ~/set_background.sh"
        echo "或者手动在Termux设置中选择背景图片"
    fi
else
    echo "❌ 背景图片下载失败，请检查网络连接"
    echo "您也可以稍后手动设置背景："
    echo "1. 安装 Termux:Styling 插件"
    echo "2. 在设置中选择背景图片"
fi

pkg install vim
pkg install clang make cmake python nodejs npm git curl unzip tar -y
echo "alias la='ls -a'" >> .bashrc
exit