# Clash Arc

[简体中文](README_zh_CN.md)

[![License](https://img.shields.io/github/license/Ninthless/clash-arc?style=flat-square)](LICENSE)

Clash Arc is a community-maintained, cross-platform Mihomo client built with Flutter. It is based on
[FlClash](https://github.com/chen08209/FlClash) and has been renamed and substantially modified.

## Features

- Android, Windows, macOS, and Linux support
- Material 3 adaptive interface
- Mihomo profiles, proxies, connections, requests, logs, and resources
- TUN and system proxy integration
- WebDAV backup and restore
- Subscription conversion with version-pinned
  [Aethersailor Custom OpenClash Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) templates
- Multiple subscription sources with traffic and expiration metadata

## Project status

Clash Arc is an independent fork and is not affiliated with, endorsed by, or supported by the FlClash maintainers,
Mihomo maintainers, OpenClash, or Aethersailor.

The repository currently tracks active development. Review changes and create a backup before replacing an existing
client configuration.

## Development

Requirements:

- Flutter 3.44.4 for release parity
- Dart SDK `>=3.8.0 <4.0.0`
- Go toolchain for the Mihomo wrapper
- Platform toolchains for the target operating system

Initialize submodules and dependencies:

```bash
git submodule update --init --recursive
flutter pub get
```

Run the application:

```bash
flutter run
```

Verify the project:

```bash
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

Build packages through the project setup script:

```bash
dart setup.dart windows
dart setup.dart macos
dart setup.dart linux
dart setup.dart android
```

Linux development requires:

```bash
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3-dev
```

## Subscription conversion privacy

Subscription URLs commonly contain access tokens. When a public conversion backend is selected, the backend receives
the source URLs and conversion parameters. Use a trusted self-hosted SubConverter-compatible backend when privacy or
availability is important.

Clash Arc only accepts HTTPS conversion backends and HTTPS source subscriptions in its built-in conversion flow.

## Licensing and attribution

Clash Arc is distributed under the [GNU General Public License v3.0](LICENSE), following the license of the upstream
FlClash project.

This repository preserves upstream copyright and license notices. Modifications are published as Clash Arc and can be
reviewed through this repository's Git history.

Third-party components and downloaded resources remain subject to their respective licenses.
