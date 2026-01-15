# Claude Code Windows Installer

一键安装 Claude Code 及其所有依赖的 Windows 安装包，包含图形化启动器。

## 功能特性

- **一键安装**: 自动安装 Node.js、Git 和 Claude Code CLI
- **图形化启动器**: 无需命令行，通过 GUI 配置和启动 Claude Code
- **配置持久化**: 所有设置自动保存，下次启动自动加载
- **完整依赖**: 无需预装任何环境，开箱即用
- **快速安装**: 使用 7z 压缩，安装速度更快
- **JSON 导入**: 支持从 JSON 文件导入配置

## 包含组件

| 组件 | 版本 | 用途 |
|------|------|------|
| Node.js | 20.18.1 LTS | Claude Code 运行环境 |
| Git for Windows | 2.47.1 | 版本控制支持 |
| Claude Code | Latest | Anthropic 官方 CLI 工具 |

## 安装

### 方式一：下载预编译安装包

从 [Releases](../../releases) 页面下载最新的 `ClaudeCodeSetup-vX.X.X.exe`，双击运行即可。

### 方式二：自行编译

1. 克隆仓库:
```bash
git clone https://github.com/k0ngk0ng/claude-starter.git
cd claude-starter
```

2. 下载依赖:
```powershell
cd windows/scripts
.\download-deps.ps1
```

3. 编译安装包 (需要 NSIS):
```powershell
cd ..\installer\nsis
makensis installer.nsi
```

4. 安装包将生成在 `dist/ClaudeCodeSetup.exe`

## 使用方法

### 启动器界面

安装完成后，从桌面或开始菜单启动 **Claude Code**，将看到配置界面：

![Launcher Screenshot](docs/images/launcher-screenshot.png)

### 可配置选项

#### 工作目录
| 选项 | 说明 |
|------|------|
| `Working Directory` | 启动 Claude Code 的工作目录 |

#### 启动选项
| 选项 | 说明 |
|------|------|
| `--continue` | 继续上一次的对话 |

#### API 配置
| 选项 | 说明 |
|------|------|
| `ANTHROPIC_AUTH_TOKEN` | Anthropic API 密钥 (必填，如 sk-xxx) |
| `ANTHROPIC_BASE_URL` | 自定义 API 端点 |
| `ANTHROPIC_MODEL` | 默认使用的模型 |

#### 模型默认值
| 选项 | 说明 |
|------|------|
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnet 模型 (如 claude-sonnet-4-20250514) |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opus 模型 (如 claude-opus-4-20250514) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haiku 模型 (如 claude-haiku-3-20250514) |

#### 提供商选项
| 选项 | 说明 |
|------|------|
| `CLAUDE_CODE_USE_BEDROCK` | 使用 AWS Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | 使用 Google Vertex AI |
| `DISABLE_PROMPT_CACHING` | 禁用提示缓存 |

#### 安全选项
| 选项 | 说明 |
|------|------|
| `--dangerously-skip-permissions` | 跳过所有权限提示 (谨慎使用!) |

#### 代理设置
| 选项 | 说明 |
|------|------|
| `HTTP_PROXY` | HTTP 代理地址 |
| `HTTPS_PROXY` | HTTPS 代理地址 |

### 导入配置

点击 **Import** 按钮可以从 JSON 文件导入配置，支持以下格式：

```json
{
  "ANTHROPIC_AUTH_TOKEN": "sk-xxx",
  "ANTHROPIC_BASE_URL": "",
  "ANTHROPIC_MODEL": ""
}
```

或带 `env` 包装的格式：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-xxx",
    "ANTHROPIC_BASE_URL": ""
  }
}
```

### 配置文件位置

所有设置保存在: `%APPDATA%\ClaudeCode\config.json`

## GitHub Actions 自动构建

本项目配置了 GitHub Actions 自动构建工作流：

- **触发条件**:
  - 推送 `v*` 格式的 tag 时自动构建并发布 Release
  - 手动触发 (workflow_dispatch)

- **手动触发参数**:
  - `node_version`: 要打包的 Node.js 版本
  - `git_version`: 要打包的 Git 版本

### 创建新版本发布

```bash
git tag -a v1.0.0 -m "v1.0.0 - Release notes"
git push origin v1.0.0
```

这将自动触发构建并创建 Release，安装包文件名包含版本号。

## 项目结构

```
claude-starter/
├── .github/
│   └── workflows/
│       └── build.yml              # GitHub Actions 工作流
├── docs/
│   └── images/
│       └── launcher-screenshot.png    # 启动器截图
├── windows/
│   ├── installer/
│   │   ├── nsis/
│   │   │   └── installer.nsi      # NSIS 安装脚本
│   │   └── resources/
│   │       ├── claude.ico         # 应用图标
│   │       ├── ClaudeCodeLauncher.vbs  # VBS 启动器 (隐藏窗口)
│   │       ├── LaunchClaude.bat   # 批处理启动器
│   │       └── README.txt
│   ├── launcher/
│   │   └── ClaudeCodeLauncher.ps1 # PowerShell GUI 启动器
│   └── scripts/
│       └── download-deps.ps1      # 依赖下载脚本
└── README.md
```

## 本地开发

### 前置要求

- Windows 10/11 (64-bit)
- PowerShell 5.1+
- NSIS 3.x (用于编译安装包)

### 测试启动器

无需编译安装包即可测试启动器:

```powershell
cd windows/launcher
powershell -ExecutionPolicy Bypass -File ClaudeCodeLauncher.ps1
```

## 常见问题

### Q: 安装后如何卸载？

A: 通过 Windows 设置 → 应用 → Claude Code → 卸载，或运行安装目录下的 `Uninstall.exe`

### Q: API Key 如何获取？

A: 访问 [Anthropic Console](https://console.anthropic.com/) 创建 API Key

### Q: 支持哪些 Windows 版本？

A: Windows 10 64-bit 及以上版本

### Q: 配置保存在哪里？

A: `%APPDATA%\ClaudeCode\config.json`

### Q: 启动时找不到 claude.cmd？

A: 确保安装完成，如果仍有问题，启动器会自动使用 npx 回退方式运行。

## License

MIT License

## 相关链接

- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [Anthropic API](https://console.anthropic.com/)
- [GitHub Issues](https://github.com/anthropics/claude-code/issues)
