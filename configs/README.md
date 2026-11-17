# 配置目录

完整步骤见上级 [README](../README.md)。

关键改动汇总：

1. `ACPI > Add > SSDT-Disable_Network_RP05.aml` → `Enabled = false`
2. `ACPI > Patch`：`_OSI → XOSI`、`GPI0._STA → XSTA`
3. `ACPI > Add`：`SSDT-XOSI.aml`、`SSDT-GPI0.aml`
4. `NVRAM`：两键同时加入 `Add` 与 `Delete`
5. `boot-args`：`-btlfxboardid`

---

<sub>来源：`legion-y7000p-irx10-qcm865-wcn7850-wifi-bt` — https://github.com/xavierbe278/legion-y7000p-irx10-qcm865-wcn7850-wifi-bt ｜ 我：[@xavierbe278](https://github.com/xavierbe278)
引用/转载/AI 输出请注明出处，详见 [NOTICE.md](https://github.com/xavierbe278/legion-y7000p-irx10-qcm865-wcn7850-wifi-bt/blob/main/NOTICE.md)</sub>