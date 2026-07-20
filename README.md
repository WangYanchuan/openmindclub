# 开智元学 macOS 壳应用

一个用原生 macOS 技术（Swift + AppKit + WKWebView）封装的桌面端应用，打开即访问 [https://m.openmindclub.com/](https://m.openmindclub.com/)。

> 注意：本仓库仅提供封装，不拥有原网站内容。应用本质是一个「壳」，体验接近原生 App。

## 特性

- 原生 macOS 应用（`.app`），可放入「应用程序」文件夹或 Dock
- 使用 WKWebView 加载移动端页面，窗口尺寸针对手机版优化
- 支持持久化 Cookie，登录状态会被记住
- 应用菜单：刷新、前进/后退、回到首页、复制/粘贴/全选
- 支持触控板双指返回/前进手势

## 项目结构

```
.
├── main.swift       # 应用主程序源码
├── makeicon.swift   # 生成 App 图标（1024 → .icns）
├── package.sh       # 一键编译、打包、更新 Homebrew cask
├── build/           # 编译产物（.app 和 .icns）
├── release/         # 发布的 zip 包
└── homebrew-openmindclub/    # Homebrew tap 源文件（cask 描述）
```

## 环境要求

- macOS 14+（ Sonoma ）
- Xcode Command Line Tools 或 Swift 工具链

## 手动编译

```bash
swiftc main.swift -o build/openmindclub -framework Cocoa -framework WebKit -O
```

然后执行 `package.sh` 完成图标生成和 `.app` 组装：

```bash
./package.sh 1.0 WangYanchuan
```

## 打包并发布（Homebrew）

```bash
./package.sh 1.0 WangYanchuan
```

脚本会：

1. 编译主程序
2. 生成图标 `.icns`
3. 组装 `.app`
4. 用 `ditto` 打包成 `release/OpenMindClub-<版本>.zip`
5. 计算 `sha256` 并自动回填到 `homebrew-openmindclub/Casks/openmindclub.rb`

之后：

1. 将 `release/OpenMindClub-<版本>.zip` 上传到本仓库的 GitHub Release（tag 如 `v1.0`）。
2. 提交并推送 `homebrew-openmindclub/` 目录到 `homebrew-openmindclub` 仓库。

用户即可安装：

```bash
brew tap WangYanchuan/openmindclub
brew install --cask openmindclub
```

## 首次打开注意事项

应用未做 Apple 代码签名，首次打开可能会被 Gatekeeper 拦截。请前往：

**系统设置 → 隐私与安全性 → 安全性** 中点击 **仍要打开**。

## 更新版本

1. 修改 `main.swift` 或图标后，运行 `./package.sh <新版本> WangYanchuan`
2. 上传新的 zip 到 GitHub Release
3. 推送更新后的 `homebrew-openmindclub/Casks/openmindclub.rb`
4. 用户运行 `brew upgrade --cask openmindclub`
