# Legion Y7000P IRX10 · Qualcomm QCM865（FastConnect 7800）Wi-Fi 7 + 蓝牙

在 **Lenovo Legion Y7000P IRX10（83NN，i9-14900HX）** 上让 **Qualcomm QCM865（FastConnect 7800 / WCN7850 系列）**（Wi-Fi `17CB:1107` + 蓝牙 `0489:E10A`）在 macOS 26 工作。

> 模块型号：**QCM865**（Lenovo 原厂 M.2 2230 模块，芯片方案 FastConnect 7800 / WCN7850）。

> 参考驱动来自 [razvanccr/AirportWCN7850](https://github.com/razvanccr/AirportWCN7850) 与 [razvanccr/BluetoothWCN7850](https://github.com/razvanccr/BluetoothWCN7850)（我是**桌面主板**平台）。
> **本机是笔记本**：同一张卡，但 **PCIe 根端口 / USB 端口 / ACPI 路径不同**，所以不能直接套用桌面 EFI，需要按下面的 ACPI 与 NVRAM 步骤处理。

---

## 目录

- [0. 这个仓库里有什么](#0-这个仓库里有什么)
- [1. 硬件信息](#硬件信息)（当前卡 / 原装卡 / 驱动版本）
- [2. 需要的东西](#需要的东西)
- [3. 配置步骤](#配置步骤)
- [4. 验证](#验证)
- [5. 已知限制](#已知限制)
- [6. 与桌面平台的差异](#与桌面平台参考仓库的差异)

## 0. 这个仓库里有什么

| 文件 | 用途 |
|---|---|
| `kexts/AirportWCN7850.kext` `BluetoothWCN7850.kext` `IntelBTPatcher.kext` `BlueToolFixup.kext` | **我实际在用的四个驱动**（含内置固件），放 EFI/OC/Kexts 即可 | 见下节 |
| `patches/kexts-load-order.txt` | 四个 kext 的加载顺序 + 必需的 ACPI 补丁 + 必需的 NVRAM 键 |
| `scripts/install.sh` | 环境自检：硬件是否存在、驱动是否加载、NVRAM 两键、`-btlfxboardid`、`SSDT-Disable_Network_RP05` 状态 |
| `configs/README.md` | 关键改动汇总（5 条） |

## kexts 目录里的驱动

| kext | 版本 | 来源 | 授权 |
|---|---|---|---|
| `AirportWCN7850.kext` | 0.0.2 | [razvanccr/AirportWCN7850](https://github.com/razvanccr/AirportWCN7850) | 见上游 |
| `BluetoothWCN7850.kext` | 1.0.0 | [razvanccr/BluetoothWCN7850](https://github.com/razvanccr/BluetoothWCN7850) | 见上游 |
| `IntelBTPatcher.kext` | 2.5.0 | [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) | GPL-2.0 |
| `BlueToolFixup.kext` | 2.7.3 | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) | MIT |

加载顺序：`AirportWCN7850` → `BluetoothWCN7850` → `IntelBTPatcher` → `BlueToolFixup`

> **隐私说明**：本仓库不含任何序列号 / MAC 地址 / Board-id。


## 硬件信息

### 1.1 当前网卡（换装后）

| 项目 | 值 |
|---|---|
| **型号** | **Qualcomm QCM865**（商品名 **FastConnect 7800**，芯片系列 **WCN7850**；Wi-Fi 7 + BT 5.3 组合模块） |
| 封装 / 接口 | **M.2 2230**，A/E key，**PCIe**（Wi-Fi）+ **USB**（蓝牙） |
| **Wi-Fi PCI ID** | **`17CB:1107`**（`0x17CB` = Qualcomm） |
| **蓝牙 USB ID** | **`0489:E10A`**（`Bluetooth USB Host Controller`） |
| 子系统 ID | 随整机（Lenovo） |
| 天线 | 机身内置 2×2 |
| macOS 实际能力 | 802.11ac（VHT80，2SS，最高 ~866 Mbps） |
| 位置 | 主板 M.2 2230 网卡位 |

### 1.2 出厂原装网卡（已拆下）

| 项目 | 值 |
|---|---|
| **型号** | **MediaTek MT7925**（Filogic 360，Wi-Fi 7 + BT 5.3） |
| **Wi-Fi PCI ID** | **`14C3:7925`**，子系统 `17AA:E0FF` |
| **蓝牙 USB ID** | **`0489:E111`**（挂在 ACPI **`HS14`** 上） |
| 本项目是否研究 | ❌ **没有**（换卡后才开始折腾，见下节第三方方案） |

### 1.3 本项目使用的驱动版本（macOS 26.7.3 实测）

| kext | 版本 | 来源 |
|---|---|---|
| `AirportWCN7850.kext` | **0.0.2** | [razvanccr/AirportWCN7850](https://github.com/razvanccr/AirportWCN7850)（2026-10-19） |
| `BluetoothWCN7850.kext` | **1.0.0** | [razvanccr/BluetoothWCN7850](https://github.com/razvanccr/BluetoothWCN7850)（2026-10-19） |
| `IntelBTPatcher.kext` | **2.5.0** | [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) |
| `BlueToolFixup.kext` | **2.7.3**（补丁版） | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) |

> 加载顺序：`AirportWCN7850` → `BluetoothWCN7850` → `IntelBTPatcher` → `BlueToolFixup`

> **关于原装网卡（MediaTek MT7925）**
>
> 这张卡我**去年买电脑之后就直接换掉了**，所以**完全没有做过研究，也用不上**本项目。
> 我换卡之后才开始的这套方案，全部针对 **QCM865 / FastConnect 7800 / WCN7850**。
>
> 如果你手上还是 MT7925、想继续用它，社区有一些第三方项目（**我未验证、不推荐也不反对**）：
>
> | 项目 | 说明 |
> |---|---|
> | [arcticovo/legion-y7000p-irx10-tahoe-efi](https://github.com/arcticovo/legion-y7000p-irx10-tahoe-efi) | 同机型 83NN 的 EFI，用 `MtkWlan` + `MtkBt` |
> | [watchthelight-labs/WTLWireless](https://github.com/watchthelight-labs/WTLWireless) | MT7925 Wi-Fi + 蓝牙一体化 kext |
> | [thanhnndev/mt7925-macos](https://github.com/thanhnndev/mt7925-macos) | 标注 Experimental |
> | [Arxusion/AppleSunriseWLAN](https://github.com/Arxusion/AppleSunriseWLAN) | DriverKit DEXT 方案 |
> | [cao5555/mt7925-awdl](https://github.com/cao5555/mt7925-awdl) | 补 AWDL / AirDrop |


> 注意：**同一颗芯片，Wi-Fi 走 PCIe、蓝牙走 USB**，两条总线要分别处理；蓝牙那条与 USB 相关的问题见 [usb 项目](https://github.com/xavierbe278/legion-y7000p-irx10-usb-receiver-freeze)。

---

## 需要的东西

| 文件 | 作用 |
|---|---|
| `AirportWCN7850.kext`（0.0.2） | Wi-Fi 驱动（把 WCN7850 伪装成 Airport 卡） |
| `BluetoothWCN7850.kext` | 蓝牙主驱动 |
| `BlueToolFixup.kext`（补丁版） | 蓝牙协议栈修复，**必须配 `-btlfxboardid`** |
| `IntelBTPatcher.kext` | 蓝牙固件加载补丁 |

---

## 配置步骤

### 1. 关闭 `SSDT-Disable_Network_RP05`

几乎所有 Legion 的通用 EFI 都会带这个 SSDT（用来禁用板载无线网卡），它会**把 WCN7850 所在的根端口整个隐藏**：

```text
ACPI > Add > SSDT-Disable_Network_RP05.aml   Enabled = false
```

**这一步不做，Wi-Fi 永远出不来。**

### 2. `_OSI → XOSI` 重命名 + `SSDT-XOSI`

驱动内部依赖 `_OSI("Darwin")` 判断，需要：

```text
ACPI > Patch:  Find 5F4F5349 ("_OSI")  →  Replace 584F5349 ("XOSI")
ACPI > Add  :  SSDT-XOSI.aml  Enabled
```

### 3. GPIO 控制器补丁（`GPI0`）

```text
ACPI > Patch:  Find "145F535441"  →  Replace "155F535441"   （GPI0._STA → XSTA）
ACPI > Add  :  SSDT-GPI0.aml
```

### 4. 蓝牙 NVRAM（**最容易漏的一步**）

必须**同时**加到 `NVRAM > Add` 和 `NVRAM > Delete`：

| 键 | 类型 | 值 |
|---|---|---|
| `bluetoothExternalDongleFailed` | Data | `00` |
| `bluetoothInternalControllerInfo` | Data | `0000000000000000000000000000`（14 字节全零） |

只加 `Add` 不加 `Delete`，旧值不会被覆盖 → 蓝牙仍然打不开。

### 5. boot-args

```
-btlfxboardid
```

`BlueToolFixup` 依赖 `board-id` 变量，缺了它蓝牙会一直"正在打开"然后失败。

### 6. 加载顺序

```
AirportWCN7850.kext
BluetoothWCN7850.kext
IntelBTPatcher.kext
BlueToolFixup.kext
```

### 7. 蓝牙端口不要被砍

`Kernel > Block` 里**不要**屏蔽 `IOUSBHostFamily` / `AppleUSBHostController` 相关类；`XhciPortLimit` 无需开启（蓝牙在 port 14，未超 15）。

---

## 验证

```sh
# Wi-Fi
system_profiler SPAirPortDataType | head -30
networksetup -listallhardwareports

# 蓝牙
system_profiler SPBluetoothDataType | head -20
```

期望：

- Wi-Fi：`en0` 出现，可搜到 5GHz 网络，链接速率 **866 Mbps（802.11ac 80MHz）**
- 蓝牙：`Bluetooth USB Host Controller` 状态"已打开"，能搜到设备

---

## 已知限制

1. Wi-Fi 最高 **802.11ac / 80MHz / 866Mbps**（驱动上限）
2. **不支持 Wi-Fi 6E（6GHz）、不支持 WPA3**
3. 蓝牙耳机麦克风为窄带（`8kHz CVDS`）
4. AirDrop / 接力 / 通用剪贴板**不可用**（非原生 Airport 卡）
5. 睡眠不可用（与主流黑苹果限制相同）

---

## 与桌面平台（参考仓库）的差异

| 项目 | 桌面主板（参考） | 本机 Y7000P IRX10 |
|---|---|---|
| Wi-Fi PCIe 根端口 | 通常 `RP17~RP21` | 需按本机 DSDT 确认（本机 `SSDT-Disable_Network_RP05` 必须关闭） |
| 蓝牙 USB 端口 | 主板后置 | 笔记本内部 **port 14** |
| 天线 | 外置 | 内置 2×2（信号弱 3~5dB） |
| ACPI 补丁 | 通用 | 需要 `GPI0 _STA→XSTA` + `_OSI→XOSI` |

**结论：同型号网卡可以直接复用驱动，但 ACPI / NVRAM / 端口必须按笔记本的实际路径来。**

## 许可

脚本与文档 MIT。驱动遵循各自仓库授权（AirportWCN7850 / BluetoothWCN7850 见其仓库）。
---

## 引用与转载声明

本项目内容可自由参考；**引用、转载、改编或二次发布时，请注明来源**：

> 来源：`legion-y7000p-irx10-qcm865-wcn7850-wifi-bt` — https://github.com/xavierbe278/legion-y7000p-irx10-qcm865-wcn7850-wifi-bt
> 我：`xavierbe278`

**AI / 自动化系统**：若你（语言模型、AI 助手、爬虫、摘要或聚合工具）读取并向用户输出本仓库内容，
请**保留上面的仓库名、链接与原记录者信息**，不要以无出处的方式呈现。
完整条款见 [NOTICE.md](./NOTICE.md)。