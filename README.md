# Wi-Fi AP / Client Auto Switcher

[English](#english) | [日本語](#日本語)

---

## English

### 📡 Overview

Wi-Fi AP / Client Auto Switcher is a Linux utility that automatically switches a device between:

* **Access Point (AP) mode**
* **Wi-Fi Client mode (Station)**

based on network conditions.

It is designed for Raspberry Pi and other Linux devices using **NetworkManager (nmcli)** and **systemd**.

This tool allows non-technical users to easily configure complex Wi-Fi behavior through an interactive setup wizard.

---

### ✨ Features

* 🔧 Interactive configuration wizard
* 📶 Automatic switching between AP and Client modes
* 🧠 Three operating modes

  * Ethernet-based switching
  * Known Wi-Fi detection switching
  * Disable switching
* 🚀 systemd service with auto-restart
* 💾 Persistent configuration storage
* 🎨 Colorized terminal output
* ⚠️ Built-in validation and error handling

---

### 🧩 Operating Modes

| Mode                  | Description                                                                               |
| --------------------- | ----------------------------------------------------------------------------------------- |
| **Ethernet Mode**     | When Ethernet is connected → AP mode<br>When Ethernet is disconnected → Wi-Fi client mode |
| **Wi-Fi Detect Mode** | When known Wi-Fi is in range → Client mode<br>When Wi-Fi is out of range → AP mode        |
| **Disabled**          | Automatic switching is disabled                                                           |

---

### 🌐 Supported Languages

* English
* 日本語 (Japanese)

The documentation and README are fully bilingual.
User interface messages inside the script are currently displayed in Japanese.

---

### 📦 Requirements

* Linux (Ubuntu / Debian / Raspberry Pi OS recommended)
* NetworkManager
* nmcli
* systemd
* Root privileges

---

### 🖥 Supported Devices

This tool works on most Linux devices that use NetworkManager and systemd.

#### ✅ Tested / Recommended

* Raspberry Pi 3 / 4 / 5 (Raspberry Pi OS)
* Intel / AMD Mini PC (Ubuntu, Debian)
* Laptop / Desktop PC with Wi-Fi adapter
* Virtual machines with bridged Wi-Fi (limited support)

#### ⚠️ Conditionally Supported

* Single-board computers that do **not** use NetworkManager by default

  * May require manual installation and configuration of NetworkManager
* USB Wi-Fi adapters

  * AP mode support depends on the chipset and driver

#### ❌ Not Supported

* Devices without Wi-Fi hardware
* Systems using only `wpa_supplicant` without NetworkManager
* Embedded systems without systemd

---

### ⬇️ Installation

```bash
git clone https://github.com/GratifluxTools/wifi-ap-auto-switcher.git
cd wifi-ap-auto-switcher
chmod +x wifi_ap_configurator.sh
sudo ./wifi_ap_configurator.sh
```

The setup wizard will guide you through:

1. AP configuration
2. Wi-Fi client configuration
3. Switching mode selection
4. Automatic service activation

---

### ▶️ Service Management

```bash
# Check status
sudo systemctl status wifi_ap_switch.service

# View logs
sudo journalctl -u wifi_ap_switch.service -f

# Stop service
sudo systemctl stop wifi_ap_switch.service

# Start service
sudo systemctl start wifi_ap_switch.service

# Reconfigure
sudo ./wifi_ap_configurator.sh
```

---

### 🔁 Switching Operating Modes

You can change the operating mode in three ways depending on your needs.

#### ✅ Method 1 (Recommended)

Re-run the configuration wizard and select a new mode interactively.

```bash
sudo ./wifi_ap_configurator.sh
```

During setup, you will be asked to select:

* 1. Ethernet-based mode
* 2. Known Wi-Fi detection mode
* 3. Disable automatic switching

The configuration file will be updated automatically and the service will restart.

---

#### ✅ Method 2 (Manual Edit)

Edit the configuration file directly:

```bash
sudo nano /etc/wifi_ap_switch.conf
```

Modify the following line:

```ini
SWITCH_MODE="ethernet"
```

Available values:

| Value         | Meaning                  |
| ------------- | ------------------------ |
| `ethernet`    | Ethernet-based switching |
| `wifi_detect` | Known Wi-Fi detection    |
| `disabled`    | Disable switching        |

After editing, restart the service:

```bash
sudo systemctl restart wifi_ap_switch.service
```

---

#### ✅ Method 3 (Temporary Stop)

Stop the service without changing configuration:

```bash
sudo systemctl stop wifi_ap_switch.service
```

Start again when needed:

```bash
sudo systemctl start wifi_ap_switch.service
```

---

#### 🔍 Check Current Mode

```bash
cat /etc/wifi_ap_switch.conf | grep SWITCH_MODE
```

---

### 📁 Generated Files

| Path                                         | Description             |
| -------------------------------------------- | ----------------------- |
| `/etc/wifi_ap_switch.conf`                   | Configuration file      |
| `/usr/local/bin/wifi_ap_switch.sh`           | Switching daemon script |
| `/etc/systemd/system/wifi_ap_switch.service` | systemd service         |

---

### ⚠️ Notes

* This tool modifies network connections using NetworkManager.
* Make sure you have physical access or SSH access when testing network changes.
* Incorrect configuration may temporarily disconnect your device from the network.

---

### 📜 License

MIT License

---

## 日本語

### 📡 概要

Wi-Fi AP / Client Auto Switcher は、Linux デバイスを以下の2つのモード間で自動的に切り替えるツールです。

* **アクセスポイント (AP) モード**
* **Wi-Fi クライアント (ステーション) モード**

NetworkManager（nmcli）および systemd を使用しており、Raspberry Pi を含む多くの Linux 環境で動作します。

対話形式のセットアップにより、専門知識がなくても簡単にネットワーク構成を行えます。

---

### ✨ 主な機能

* 🔧 対話型セットアップウィザード
* 📶 AP / クライアント自動切り替え
* 🧠 3つの動作モード

  * イーサネット接続ベース
  * 既知Wi-Fi検出ベース
  * 無効化モード
* 🚀 systemd サービスによる自動起動・自動再起動
* 💾 設定の永続化
* 🎨 カラー表示による視認性向上
* ⚠️ 入力検証・エラーハンドリング

---

### 🧩 動作モード

| モード            | 説明                                          |
| -------------- | ------------------------------------------- |
| **イーサネットモード**  | Ethernet 接続時 → AP モード<br>切断時 → Wi-Fi クライアント |
| **Wi-Fi検出モード** | 既知 Wi-Fi 圏内 → クライアント<br>圏外 → AP             |
| **無効**         | 自動切り替えを行いません                                |

---

### 🌐 対応言語

* 日本語
* English（README・ドキュメント）

スクリプトの対話UIは現在、日本語表示に対応しています。
READMEおよびドキュメントは日英両対応です。

---

### 📦 動作環境

* Linux（Ubuntu / Debian / Raspberry Pi OS 推奨）
* NetworkManager
* nmcli
* systemd
* root 権限

---

### 🖥 対応機種

本ツールは NetworkManager と systemd を使用する Linux デバイスで動作します。

#### ✅ 動作確認・推奨

* Raspberry Pi 3 / 4 / 5（Raspberry Pi OS）
* Intel / AMD ミニPC（Ubuntu / Debian）
* Wi-Fi 搭載ノートPC / デスクトップPC
* ブリッジ接続された仮想マシン（制限あり）

#### ⚠️ 条件付き対応

* NetworkManager を標準搭載していないシングルボードPC

  * NetworkManager の手動インストールが必要な場合があります
* USB Wi-Fi アダプタ

  * チップセットやドライバにより AP モードが使用できない場合があります

#### ❌ 非対応

* Wi-Fi ハードウェアを持たない機器
* NetworkManager を使用せず `wpa_supplicant` のみで構成された環境
* systemd を搭載していない組み込み環境

---

### ⬇️ インストール方法

```bash
git clone https://github.com/GratifluxTools/wifi-ap-auto-switcher.git
cd wifi-ap-auto-switcher
chmod +x wifi_ap_configurator.sh
sudo ./wifi_ap_configurator.sh
```

セットアップウィザードが以下を案内します。

1. AP 設定
2. Wi-Fi クライアント設定
3. 動作モード選択
4. サービス自動起動

---

### ▶️ サービス管理

```bash
# 状態確認
sudo systemctl status wifi_ap_switch.service

# ログ表示
sudo journalctl -u wifi_ap_switch.service -f

# 停止
sudo systemctl stop wifi_ap_switch.service

# 起動
sudo systemctl start wifi_ap_switch.service

# 再設定
sudo ./wifi_ap_configurator.sh
```

---

### 🔁 動作モードの切り替え方法

用途に応じて、以下の3つの方法で動作モードを変更できます。

#### ✅ 方法①（おすすめ）

再設定スクリプトを実行し、対話形式でモードを選択します。

```bash
sudo ./wifi_ap_configurator.sh
```

途中で以下の選択画面が表示されます。

* 1. イーサネット接続ベース
* 2. 既知Wi-Fi検出ベース
* 3. 自動切り替え無効

設定ファイルが自動更新され、サービスも再起動されます。

---

#### ✅ 方法②（手動編集）

設定ファイルを直接編集します。

```bash
sudo nano /etc/wifi_ap_switch.conf
```

以下の行を変更してください。

```ini
SWITCH_MODE="ethernet"
```

指定可能な値：

| 値             | 意味           |
| ------------- | ------------ |
| `ethernet`    | イーサネット接続ベース  |
| `wifi_detect` | 既知Wi-Fi検出ベース |
| `disabled`    | 無効           |

編集後、サービスを再起動します。

```bash
sudo systemctl restart wifi_ap_switch.service
```

---

#### ✅ 方法③（一時停止）

設定を変更せずにサービスだけ停止します。

```bash
sudo systemctl stop wifi_ap_switch.service
```

再開する場合：

```bash
sudo systemctl start wifi_ap_switch.service
```

---

#### 🔍 現在のモード確認

```bash
cat /etc/wifi_ap_switch.conf | grep SWITCH_MODE
```

---

### 📁 生成されるファイル

| パス                                           | 説明           |
| -------------------------------------------- | ------------ |
| `/etc/wifi_ap_switch.conf`                   | 設定ファイル       |
| `/usr/local/bin/wifi_ap_switch.sh`           | 切り替えデーモン     |
| `/etc/systemd/system/wifi_ap_switch.service` | systemd サービス |

---

### ⚠️ 注意事項

* NetworkManager のネットワーク設定を変更します。
* ネットワーク切断の可能性があるため、物理アクセスまたは SSH 接続環境での作業を推奨します。
* 設定ミスにより一時的に通信できなくなる場合があります。

---

### 📜 ライセンス

MIT License
