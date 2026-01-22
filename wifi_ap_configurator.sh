#!/bin/bash

# =============================================================================
# Wi-Fi AP/クライアント自動切り替え設定ツール
# =============================================================================

CONFIG_FILE="/etc/wifi_ap_switch.conf"
SWITCH_SCRIPT="/usr/local/bin/wifi_ap_switch.sh"
SERVICE_FILE="/etc/systemd/system/wifi_ap_switch.service"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# ユーティリティ関数
# =============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# =============================================================================
# 既存接続の取得
# =============================================================================

get_existing_connections() {
    nmcli -t -f NAME,TYPE connection show | grep "802-11-wireless"
}

list_wifi_connections() {
    echo -e "\n${BLUE}既存のWi-Fi接続:${NC}"
    local i=1
    while IFS=: read -r name type; do
        echo "  $i) $name"
        ((i++))
    done < <(get_existing_connections)
}

# =============================================================================
# AP設定
# =============================================================================

configure_ap() {
    print_header "アクセスポイント(AP)設定"
    
    echo -e "\n既存のAP接続を使用しますか？"
    list_wifi_connections
    echo "  0) 新規作成"
    read -p "選択 [0]: " ap_choice
    ap_choice=${ap_choice:-0}
    
    if [ "$ap_choice" = "0" ]; then
        # 新規AP作成
        read -p "AP接続名 [PiAP]: " AP_CONN_NAME
        AP_CONN_NAME=${AP_CONN_NAME:-PiAP}
        
        read -p "APのSSID [RaspberryPi-AP]: " AP_SSID
        AP_SSID=${AP_SSID:-RaspberryPi-AP}
        
        echo -e "\nパスワード保護:"
        echo "  1) パスワードあり (WPA2)"
        echo "  2) オープン (パスワードなし)"
        read -p "選択 [1]: " pass_choice
        pass_choice=${pass_choice:-1}
        
        if [ "$pass_choice" = "1" ]; then
            while true; do
                read -sp "APパスワード (8文字以上): " AP_PASSWORD
                echo
                if [ ${#AP_PASSWORD} -ge 8 ]; then
                    break
                else
                    print_error "パスワードは8文字以上必要です"
                fi
            done
            AP_PASSWORD_CMD="wifi-sec.key-mgmt wpa-psk wifi-sec.psk \"$AP_PASSWORD\""
        else
            AP_PASSWORD_CMD=""
        fi
        
        read -p "Wi-Fiデバイス名 [wlan0]: " WIFI_DEV
        WIFI_DEV=${WIFI_DEV:-wlan0}
        
        # AP接続を作成
        print_warning "AP接続を作成中..."
        if [ -n "$AP_PASSWORD_CMD" ]; then
            sudo nmcli connection add type wifi ifname "$WIFI_DEV" \
                con-name "$AP_CONN_NAME" autoconnect no ssid "$AP_SSID" \
                mode ap 802-11-wireless.band bg ipv4.method shared \
                $AP_PASSWORD_CMD
        else
            sudo nmcli connection add type wifi ifname "$WIFI_DEV" \
                con-name "$AP_CONN_NAME" autoconnect no ssid "$AP_SSID" \
                mode ap 802-11-wireless.band bg ipv4.method shared
        fi
        
        if [ $? -eq 0 ]; then
            print_success "AP接続 '$AP_CONN_NAME' を作成しました"
        else
            print_error "AP接続の作成に失敗しました"
            exit 1
        fi
    else
        # 既存接続を選択
        local i=1
        while IFS=: read -r name type; do
            if [ "$i" = "$ap_choice" ]; then
                AP_CONN_NAME="$name"
                break
            fi
            ((i++))
        done < <(get_existing_connections)
        
        if [ -z "$AP_CONN_NAME" ]; then
            print_error "無効な選択です"
            exit 1
        fi
        
        read -p "Wi-Fiデバイス名 [wlan0]: " WIFI_DEV
        WIFI_DEV=${WIFI_DEV:-wlan0}
        
        print_success "既存のAP接続 '$AP_CONN_NAME' を使用します"
    fi
}

# =============================================================================
# Wi-Fiクライアント設定
# =============================================================================

configure_wifi_client() {
    print_header "Wi-Fiクライアント設定"
    
    echo -e "\n既存のWi-Fi接続を使用しますか？"
    list_wifi_connections
    echo "  0) 新規作成"
    read -p "選択 [0]: " sta_choice
    sta_choice=${sta_choice:-0}
    
    if [ "$sta_choice" = "0" ]; then
        # 新規クライアント接続作成
        read -p "クライアント接続名 [HomeWiFi]: " STA_CONN_NAME
        STA_CONN_NAME=${STA_CONN_NAME:-HomeWiFi}
        
        read -p "接続先SSID: " STA_SSID
        if [ -z "$STA_SSID" ]; then
            print_error "SSIDは必須です"
            exit 1
        fi
        
        read -sp "Wi-Fiパスワード: " STA_PASSWORD
        echo
        
        # クライアント接続を作成
        print_warning "Wi-Fiクライアント接続を作成中..."
        sudo nmcli connection add type wifi ifname "$WIFI_DEV" \
            con-name "$STA_CONN_NAME" autoconnect yes ssid "$STA_SSID" \
            wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$STA_PASSWORD"
        
        if [ $? -eq 0 ]; then
            print_success "Wi-Fiクライアント接続 '$STA_CONN_NAME' を作成しました"
        else
            print_error "Wi-Fiクライアント接続の作成に失敗しました"
            exit 1
        fi
    else
        # 既存接続を選択
        local i=1
        while IFS=: read -r name type; do
            if [ "$i" = "$sta_choice" ]; then
                STA_CONN_NAME="$name"
                break
            fi
            ((i++))
        done < <(get_existing_connections)
        
        if [ -z "$STA_CONN_NAME" ]; then
            print_error "無効な選択です"
            exit 1
        fi
        
        print_success "既存のWi-Fiクライアント接続 '$STA_CONN_NAME' を使用します"
    fi
}

# =============================================================================
# 切り替えモード設定
# =============================================================================

configure_switch_mode() {
    print_header "自動切り替えモード設定"
    
    echo -e "\n切り替えモードを選択してください:"
    echo "  1) イーサネット接続ベース (Ethernet接続時→AP、切断時→Wi-Fiクライアント)"
    echo "  2) 既知Wi-Fi検出ベース (既知Wi-Fi圏外→AP、圏内→Wi-Fiクライアント)"
    echo "  3) 機能オフ (自動切り替えを無効化)"
    read -p "選択 [1]: " mode_choice
    mode_choice=${mode_choice:-1}
    
    case $mode_choice in
        1)
            SWITCH_MODE="ethernet"
            read -p "イーサネットデバイス名 [eth0]: " ETH_IF
            ETH_IF=${ETH_IF:-eth0}
            print_success "イーサネット接続ベースモードを選択しました"
            ;;
        2)
            SWITCH_MODE="wifi_detect"
            print_success "既知Wi-Fi検出ベースモードを選択しました"
            ;;
        3)
            SWITCH_MODE="disabled"
            print_success "自動切り替えを無効化します"
            ;;
        *)
            print_error "無効な選択です"
            exit 1
            ;;
    esac
}

# =============================================================================
# 設定ファイル生成
# =============================================================================

generate_config() {
    print_warning "設定ファイルを生成中..."
    
    sudo tee "$CONFIG_FILE" > /dev/null << EOF
# Wi-Fi AP/クライアント自動切り替え設定
# 生成日時: $(date)

# 切り替えモード: ethernet / wifi_detect / disabled
SWITCH_MODE="$SWITCH_MODE"

# AP接続名
AP_CONN="$AP_CONN_NAME"

# Wi-Fiクライアント接続名
STA_CONN="$STA_CONN_NAME"

# Wi-Fiデバイス名
WIFI_DEV="$WIFI_DEV"

# イーサネットデバイス名 (ethernetモード使用時)
ETH_IF="${ETH_IF:-eth0}"

# チェック間隔（秒）
CHECK_INTERVAL=2
EOF
    
    print_success "設定ファイルを作成しました: $CONFIG_FILE"
}

# =============================================================================
# 切り替えスクリプト生成
# =============================================================================

generate_switch_script() {
    print_warning "切り替えスクリプトを生成中..."
    
    sudo tee "$SWITCH_SCRIPT" > /dev/null << 'SCRIPT_EOF'
#!/bin/bash

# 設定ファイル読み込み
CONFIG_FILE="/etc/wifi_ap_switch.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "設定ファイルが見つかりません: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# ログ関数
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1"
}

# =============================================================================
# イーサネット接続ベースモード
# =============================================================================

mode_ethernet() {
    local PREV_ETH_STATE="unknown"
    
    log_msg "イーサネット接続ベースモード開始"
    
    while true; do
        if [ ! -e "/sys/class/net/$ETH_IF" ]; then
            log_msg "警告: デバイス $ETH_IF が見つかりません"
            sleep $CHECK_INTERVAL
            continue
        fi
        
        ETH_STATE=$(cat /sys/class/net/$ETH_IF/operstate 2>/dev/null)
        
        if [ "$ETH_STATE" != "$PREV_ETH_STATE" ]; then
            if [ "$ETH_STATE" = "up" ]; then
                log_msg "Ethernet接続検出 → APモード有効化"
                nmcli connection down "$STA_CONN" 2>/dev/null
                nmcli radio wifi on
                sleep 1
                nmcli connection up "$AP_CONN"
            else
                log_msg "Ethernet切断検出 → Wi-Fiクライアントモード"
                nmcli connection down "$AP_CONN" 2>/dev/null
                nmcli radio wifi off
                sleep 1
                nmcli radio wifi on
                sleep 2
                nmcli connection up "$STA_CONN"
            fi
            PREV_ETH_STATE=$ETH_STATE
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# =============================================================================
# 既知Wi-Fi検出ベースモード
# =============================================================================

mode_wifi_detect() {
    local PREV_MODE="unknown"
    
    log_msg "既知Wi-Fi検出ベースモード開始"
    
    while true; do
        # 既知のWi-Fiが利用可能かチェック
        KNOWN_WIFI_AVAILABLE=$(nmcli -t -f NAME,DEVICE connection show --active | grep "^$STA_CONN:")
        
        if [ -n "$KNOWN_WIFI_AVAILABLE" ]; then
            # 既知Wi-Fiに接続中
            if [ "$PREV_MODE" != "client" ]; then
                log_msg "既知Wi-Fi接続中 → Wi-Fiクライアントモード維持"
                PREV_MODE="client"
            fi
        else
            # 既知Wi-Fiが見つからない
            SSID=$(nmcli -t -f SSID device wifi list ifname "$WIFI_DEV" 2>/dev/null | grep -F "$(nmcli -t -f 802-11-wireless.ssid connection show "$STA_CONN" | cut -d: -f2)")
            
            if [ -z "$SSID" ]; then
                # 既知Wi-Fiが圏外 → APモード
                if [ "$PREV_MODE" != "ap" ]; then
                    log_msg "既知Wi-Fi圏外 → APモード有効化"
                    nmcli connection down "$STA_CONN" 2>/dev/null
                    nmcli radio wifi on
                    sleep 1
                    nmcli connection up "$AP_CONN"
                    PREV_MODE="ap"
                fi
            else
                # 既知Wi-Fiが圏内 → クライアントモードに切り替え
                if [ "$PREV_MODE" != "client" ]; then
                    log_msg "既知Wi-Fi検出 → Wi-Fiクライアントモード"
                    nmcli connection down "$AP_CONN" 2>/dev/null
                    nmcli radio wifi off
                    sleep 1
                    nmcli radio wifi on
                    sleep 2
                    nmcli connection up "$STA_CONN"
                    PREV_MODE="client"
                fi
            fi
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# =============================================================================
# メイン処理
# =============================================================================

case "$SWITCH_MODE" in
    ethernet)
        mode_ethernet
        ;;
    wifi_detect)
        mode_wifi_detect
        ;;
    disabled)
        log_msg "自動切り替えは無効化されています"
        exit 0
        ;;
    *)
        log_msg "エラー: 不明な切り替えモード '$SWITCH_MODE'"
        exit 1
        ;;
esac
SCRIPT_EOF
    
    sudo chmod +x "$SWITCH_SCRIPT"
    print_success "切り替えスクリプトを作成しました: $SWITCH_SCRIPT"
}

# =============================================================================
# systemdサービス生成
# =============================================================================

generate_service() {
    print_warning "systemdサービスを生成中..."
    
    sudo tee "$SERVICE_FILE" > /dev/null << 'EOF'
[Unit]
Description=Wi-Fi AP/Client Auto Switcher
After=network.target NetworkManager.service
Wants=NetworkManager.service

[Service]
Type=simple
ExecStart=/usr/local/bin/wifi_ap_switch.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "systemdサービスを作成しました: $SERVICE_FILE"
}

# =============================================================================
# サービス制御
# =============================================================================

control_service() {
    if [ "$SWITCH_MODE" = "disabled" ]; then
        print_warning "サービスを停止・無効化中..."
        sudo systemctl stop wifi_ap_switch.service 2>/dev/null
        sudo systemctl disable wifi_ap_switch.service 2>/dev/null
        print_success "サービスを無効化しました"
    else
        print_warning "サービスを有効化・起動中..."
        sudo systemctl daemon-reload
        sudo systemctl enable wifi_ap_switch.service
        sudo systemctl restart wifi_ap_switch.service
        
        sleep 2
        if sudo systemctl is-active --quiet wifi_ap_switch.service; then
            print_success "サービスが正常に起動しました"
        else
            print_error "サービスの起動に失敗しました"
            echo -e "\nログを確認してください:"
            echo "  sudo journalctl -u wifi_ap_switch.service -n 20"
            exit 1
        fi
    fi
}

# =============================================================================
# 設定サマリー表示
# =============================================================================

show_summary() {
    print_header "設定完了"
    
    echo -e "\n${GREEN}設定内容:${NC}"
    echo "  AP接続名: $AP_CONN_NAME"
    echo "  Wi-Fiクライアント接続名: $STA_CONN_NAME"
    echo "  Wi-Fiデバイス: $WIFI_DEV"
    
    case "$SWITCH_MODE" in
        ethernet)
            echo "  切り替えモード: イーサネット接続ベース"
            echo "  イーサネットデバイス: $ETH_IF"
            ;;
        wifi_detect)
            echo "  切り替えモード: 既知Wi-Fi検出ベース"
            ;;
        disabled)
            echo "  切り替えモード: 無効"
            ;;
    esac
    
    echo -e "\n${YELLOW}便利なコマンド:${NC}"
    echo "  サービス状態確認: sudo systemctl status wifi_ap_switch.service"
    echo "  ログ確認: sudo journalctl -u wifi_ap_switch.service -f"
    echo "  サービス停止: sudo systemctl stop wifi_ap_switch.service"
    echo "  サービス開始: sudo systemctl start wifi_ap_switch.service"
    echo "  再設定: sudo $0"
}

# =============================================================================
# メイン処理
# =============================================================================

main() {
    # root権限チェック
    if [ "$EUID" -ne 0 ]; then
        print_error "このスクリプトはroot権限で実行してください"
        echo "実行方法: sudo $0"
        exit 1
    fi
    
    print_header "Wi-Fi AP/クライアント自動切り替え設定"
    
    # 既存設定の確認
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "\n${YELLOW}既存の設定が見つかりました${NC}"
        read -p "再設定しますか？ [y/N]: " reconfigure
        if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
            echo "設定をキャンセルしました"
            exit 0
        fi
    fi
    
    # 設定手順
    configure_ap
    configure_wifi_client
    configure_switch_mode
    
    # ファイル生成
    generate_config
    generate_switch_script
    generate_service
    
    # サービス制御
    control_service
    
    # サマリー表示
    show_summary
    
    echo -e "\n${GREEN}すべての設定が完了しました！${NC}"
}

# スクリプト実行
main
