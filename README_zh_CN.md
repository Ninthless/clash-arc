# Clash Arc

[English](README.md)

[![License](https://img.shields.io/github/license/Ninthless/clash-arc?style=flat-square)](LICENSE)

Clash Arc 是使用 Flutter 构建的社区维护型跨平台 Mihomo 客户端。本项目基于
[FlClash](https://github.com/chen08209/FlClash)，已经重命名并进行了大量修改。

## 功能

- 支持 Android、Windows、macOS 和 Linux
- Material 3 自适应界面
- Mihomo 配置、代理、连接、请求、日志与资源管理
- TUN 与系统代理集成
- WebDAV 备份与恢复
- 内置固定版本的
  [Aethersailor Custom OpenClash Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) 订阅转换模板
- 支持多订阅源，并读取流量与有效期信息

## 项目状态

Clash Arc 是独立分支项目，与 FlClash、Mihomo、OpenClash 或 Aethersailor 的维护者不存在隶属、背书或官方支持关系。

仓库目前处于活跃开发阶段。替换现有客户端配置前，请先审查变更并备份数据。

## 开发

环境要求：

- 发布构建以 Flutter 3.44.4 为准
- Dart SDK `>=3.8.0 <4.0.0`
- 用于 Mihomo 包装层的 Go 工具链
- 对应目标操作系统的平台工具链

初始化子模块与依赖：

```bash
git submodule update --init --recursive
flutter pub get
```

运行应用：

```bash
flutter run
```

验证项目：

```bash
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

通过项目脚本构建安装包：

```bash
dart setup.dart windows
dart setup.dart macos
dart setup.dart linux
dart setup.dart android
```

Linux 开发依赖：

```bash
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3-dev
```

## 订阅转换隐私

订阅地址通常包含访问令牌。使用公共转换服务时，转换服务会收到源订阅地址和转换参数。重视隐私或稳定性时，请使用可信的自建
SubConverter 兼容服务。

Clash Arc 内置的订阅转换流程仅接受 HTTPS 转换服务和 HTTPS 源订阅。

## 许可证与署名

Clash Arc 遵循上游 FlClash 的许可证，以 [GNU General Public License v3.0](LICENSE) 发布。

本仓库保留上游版权和许可证声明。所有修改均以 Clash Arc 名义发布，并可通过本仓库的 Git 历史查阅。

第三方组件及下载资源仍分别遵循其各自许可证。
