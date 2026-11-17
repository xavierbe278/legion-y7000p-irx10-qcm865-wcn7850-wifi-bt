#!/bin/bash
# Wi-Fi / 蓝牙（Qualcomm WCN7850）配置检查与安装
# 用法: sudo bash install.sh
set -u
[ "$(id -u)" = 0 ] || { echo "请用 sudo 运行"; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "══════════════════════════════════════════════"
echo "  WCN7850 Wi-Fi / 蓝牙 检查"
echo "══════════════════════════════════════════════"

echo
echo "1. 硬件是否存在"
ioreg -l -w0 -p IOService 2>/dev/null | tr -d '\000' | grep -iE "17cb|1107" | head -3 | sed 's/^/   /' || echo "   未发现 17CB:1107（Wi-Fi PCIe）"
ioreg -p IOUSB -l -w0 2>/dev/null | tr -d '\000' | grep -iE "0489|e10a|Bluetooth" | head -3 | sed 's/^/   /' || true

echo
echo "2. 驱动是否加载"
for k in AirportWCN7850 BluetoothWCN7850 IntelBTPatcher BlueToolFixup; do
  if kextstat 2>/dev/null | grep -qi "$k"; then echo "   ✅ $k"; else echo "   ❌ $k 未加载"; fi
done

echo
echo "3. NVRAM 蓝牙键"
for key in bluetoothExternalDongleFailed bluetoothInternalControllerInfo; do
  v=$(nvram -p 2>/dev/null | grep -m1 "^$key" | cut -f2)
  [ -n "$v" ] && echo "   ✅ $key = $v" || echo "   ❌ $key 缺失（Add 和 Delete 都要有！）"
done

echo
echo "4. boot-args 是否含 -btlfxboardid"
nvram -p 2>/dev/null | grep -m1 boot-args | grep -q -- '-btlfxboardid' \
  && echo "   ✅ 已包含" || echo "   ❌ 缺失（蓝牙会一直打不开）"

echo
echo "5. SSDT-Disable_Network_RP05 必须关闭"
find_esp(){
  PHYS=$(/usr/sbin/diskutil info / 2>/dev/null | sed -n 's/^ *APFS Physical Store: *//p' | head -1)
  DISK=${PHYS%s*}; ESPDEV=$(/usr/sbin/diskutil list "${DISK}" 2>/dev/null | awk '/ EFI /{print $NF}' | head -1)
  /usr/sbin/diskutil mount "${ESPDEV}" >/dev/null 2>&1
  EFS=$(/usr/sbin/diskutil info "${ESPDEV}" 2>/dev/null | sed -n 's/^ *Mount Point: *//p')
  [ -d "${EFS}/EFI/OC" ]
}
if find_esp; then
  /usr/libexec/PlistBuddy -c 'Print :ACPI:Add' "${EFS}/EFI/OC/config.plist" 2>/dev/null | grep -A2 -i "Disable_Network" | sed 's/^/   /'
  echo "   （确认其中 Enabled = false）"
  /sbin/diskutil unmount "${EFS}" >/dev/null 2>&1
fi