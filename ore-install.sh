#!/bin/bash

echo "请选择操作："
echo "1) 安装 Rust 和 Cargo"
echo "2) 安装 Solana CLI 并生成密钥对"
echo "3) 安装 Ore CLI"
echo "4) 安装 nvm、Node.js 和全局安装 pm2"
echo "5) 用 pm2 运行 Ore 矿工"
echo "6) 查看奖励数量"
echo "7) 用pm2 运行 Ore 提取奖励"
read -p "请输入选项 [1-7]: " choice

default_rpc="https://api.mainnet-beta.solana.com"
default_threads=4

case $choice in
    1)
        echo "正在安装 Rust 和 Cargo..."
        curl https://sh.rustup.rs -sSf | sh
        source ~/.bashrc
        ;;
    2)
        echo "正在安装 Solana CLI..."
        sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
        echo "正在生成 Solana 密钥对..."
        export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
        solana-keygen new
        ;;
    3)
        echo "正在安装 Ore CLI..."
        cargo install ore-cli
        ;;
    4)
        echo "正在安装 nvm、Node.js 和全局安装 pm2..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        nvm install node # 安装最新版本的 Node.js 和 npm
        npm install pm2@latest -g
        ;;
    5)
        echo "创建 Ore 矿工运行脚本..."
        read -p "请输入 Ore RPC 地址 [直接回车则默认: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        read -p "请输入矿工进程数 [直接回车则默认: ${default_threads}]: " threads
        threads=${threads:-$default_threads}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 mine --threads ${threads}" >> ore_miner.sh
        chmod +x ore_miner.sh
        echo "使用 pm2 启动 Ore 矿工运行脚本..."
        pm2 start ore_miner.sh --name ore-miner
        echo "Ore 矿工运行脚本已经通过 pm2 在后台启动。"
        ;;
    6)
        ore --rpc https://api.mainnet-beta.solana.com --keypair ~/.config/solana/id.json rewards
        ;;
    7)
        echo "创建 Ore 提取运行脚本..."
        read -p "请输入 Ore RPC 地址 [默认: ${default_rpc}]: " rpc
        rpc=${rpc:-$default_rpc}
        echo "#!/bin/bash" > ore_miner.sh
        echo "ore --rpc ${rpc} --keypair ~/.config/solana/id.json --priority-fee 500000 claim" >> ore_claimer.sh
        chmod +x ore_claimer.sh
        echo "使用 pm2 启动 Ore 矿工运行脚本..."
        pm2 start ore_claimer.sh --name ore-claimer
        echo "Ore 矿工运行脚本已经通过 pm2 在后台启动。"
        ;;
    *)
        echo "选择了无效的选项。退出。"
        exit 1
      ;;
esac

echo "操作完成。"
