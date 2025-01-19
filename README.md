```bash
 █████╗ ██╗      ██████╗██╗  ██╗███████╗███╗   ███╗██╗   ██╗███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔══██╗██║     ██╔════╝██║  ██║██╔════╝████╗ ████║╚██╗ ██╔╝██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████║██║     ██║     ███████║█████╗  ██╔████╔██║ ╚████╔╝ █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
██╔══██║██║     ██║     ██╔══██║██╔══╝  ██║╚██╔╝██║  ╚██╔╝  ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
██║  ██║███████╗╚██████╗██║  ██║███████╗██║ ╚═╝ ██║   ██║   ██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
```
- 油管频道：https://www.youtube.com/@alchemyfinance/
- 法师社群：https://t.me/ytalchemy/

# HyperSpace 节点一键脚本
- 官网：https://hyper.space/
- 节点：https://node.hyper.space/

## 配置要求

最低配置：4GB 内存 - 2 vCPU
推荐配置：8GB 内存 - 4 vCPU

```bash
# 查看配置
curl -o info.sh https://raw.githubusercontent.com/btcalchemyfinance/Tools/refs/heads/main/info.sh && chmod +x info.sh && ./info.sh
```

## VPS
- 使用 DigitalOcean，新用户可获得 **60 天 $200** 的试用额度

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=9de664fa6fad&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

## Docker 一键安装
- 先从网页端获取私钥：https://node.hyper.space/
- ⬇️⬇️⬇️ 然后复制下方代码到终端输入 ⬇️⬇️⬇️
```bash
curl -O https://raw.githubusercontent.com/btcalchemyfinance/aios_sh/refs/heads/main/aios.sh && chmod +x aios.sh && ./aios.sh
```

- 根据提示输入私钥

- 等待终端输出以下内容
```bash
Artificial Intelligence (AI) is a branch of computer science that focuses on building machines capable of performing tasks that would normally require human intelligence, such as understanding natural language, recognizing patterns, and making decisions. AI technology aims to create intelligent agents or systems that can work autonomously or with minimal human intervention, to improve efficiency, automate processes, and enhance the overall performance of various industries. At its core, AI involves developing algorithms and computational models inspired by the structure and function of the human brain, to enable machines to learn, reason, perceive, and interact with the world around them in a way that resembles human cognition.
```

## 检查是否成功上线
- 使用 tmux 新建会话窗口
```bash
tmux new -s <aios>                          # <aios> 可自定义
```

- 进入窗口后使用该命令查看日志
```bash
docker logs -f aios-container
docker logs -f --tail=<n> aios-container    # 查看最近 n 条日志
```

- 直到终端输出以下内容则表示成功上线
```bash
[2025-01-19 17:24:55] INFO [aios_kernel::logger] Pinging hive...
[2025-01-19 17:24:55] INFO [aios_kernel::logger] Ping sent successfully
[2025-01-19 17:24:55] INFO [aios_kernel::logger] 🙂👍
[2025-01-19 17:24:55] INFO [aios_kernel::logger] Received pong
```

- 其它 tmux 指令
tmux 会话窗口中使用 `ctrl + b` 进入快捷键模式，再按 `d` 即可退出当前会话窗口
如果需要再次进入会话窗口则使用指令`tmux a -t <aios>`

## 各类路径
- 建议私钥导出到本地存档好
```bash
/root/script_progress.log                   # 报错了就查看该日志
/root/key.pem                               # 私钥位置
```

## 其它指令
- 查看积分
```bash
docker exec -it aios-container /app/aios-cli hive points
```

- 查看公钥与私钥
```bash
docker exec -it aios-container /app/aios-cli hive whoami
```

- 停止
```bash
docker stop aios-container
```

- 删除
```bash
docker rm aios-container
```

- 删除镜像
```bash
docker rmi kartikhyper/aios
```

- 更多指令可以查看[官方库](https://github.com/hyperspaceai/aios-cli?tab=readme-ov-file#commands)
- 如果需要在终端中使用对应指令需要在官方指令前面加入以下内容
```bash
docker exec -it aios-container /app/

# eg. 原指令 aios-cli help
docker exec -it aios-container /app/aios-cli help
```
