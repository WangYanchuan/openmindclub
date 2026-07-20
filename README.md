# 开智元学 for macOS

给 [开智元学学习系统](https://m.openmindclub.com/) 做的原生 macOS 壳应用（Swift + WKWebView）。
独立窗口、自定义图标、记住登录状态。

> 非官方项目，仅为方便自己在 Mac 上快速打开该网站。

## 从源码构建

需要 Xcode 命令行工具（`swiftc` / `iconutil` / `sips`）。

```bash
./package.sh <版本号> <你的GitHub用户名>
# 例：./package.sh 1.0 wangyanchuan
```

脚本会：编译主程序 → 生成图标 → 组装 `开智元学.app` → 打包 zip → 计算 sha256。
产物在 `build/`（app）和 `release/`（zip）。

## 通过 Homebrew 安装

见 tap 仓库：`homebrew-tap`。

```bash
brew tap <你的GitHub用户名>/tap
brew install --cask openmindclub
```

## 说明

- 应用未做 Apple 签名，首次打开需在「系统设置 → 隐私与安全性 → 仍要打开」放行。
- 本质是网站的 WebView 封装，网站改版或不可访问时应用同样受影响。
