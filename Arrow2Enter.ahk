; 可用于87键的键盘按键替换 Pause Script
A_TrayMenu.Delete("&Pause Script")  ; 删除暂停菜单


iniFile:= "Arrow2Enter.ini"
secName:= "Arrow2Enter"
secKey:= "HoldCapsLock"
global holdCapsLockFlag
holdCapsLockFlag := IniRead(iniFile, secName , secKey ,1)
If(holdCapsLockFlag) {
	A_TrayMenu.Add("CapsLock Hold", MenuHandler)  ; 默认需要按住大写键生效
	;A_TrayMenu.Rename("CapsLock Hold","When CapsLock")
} Else {
	A_TrayMenu.Add("When CapsLock", MenuHandler)  ; 默认需要按住大写键生效
	;A_TrayMenu.Rename("When CapsLock","CapsLock Hold")
}
MenuHandler(*) {
    global holdCapsLockFlag
	if(holdCapsLockFlag)
	{
		hint := "Hold"
		hint2 := "When"
	}else
	{
		hint := "When"
		hint2 := "Hold"
	}
	msg := format("Numpad is enabled by [{1}] CapsLock, will change to [{2}] and reload?",hint,hint2)
	Result := MsgBox(msg,,"YesNo")
	if(Result = "No"){
		return
	}
    holdCapsLockFlag := !holdCapsLockFlag
	IniWrite holdCapsLockFlag, iniFile, secName , secKey
	Reload
}

; 用键盘右下方的 方向下+方向右 = 回车 
Down & Right::Enter     ; 先按Down，后按Right触发Enter
; ~Down & Right::Enter  ;  将不阻止Down的触发会导致多次执行Down
$Down::Send "{Down}"    ; 发送模拟按键 Down。
; 发送各种快捷键组合 Down 模拟特殊快捷键
^Down::Send "^{Down}"
+Down::Send "+{Down}"
!Down::Send "!{Down}"
!+Down::Send "!+{Down}"
^+Down::Send "^+{Down}"
^!Down::Send "^!{Down}"
^!+Down::Send "^!+{Down}"
#Down::Send "#{Down}"
#!+Down::Send "#!+{Down}"
#^+Down::Send "#^+{Down}"
#^!Down::Send "#^!{Down}"
#^!+Down::Send "#^!+{Down}"

; 替换右侧上方控制键为数字键，0 为方向键左 ，小数点为方向键上
; 以下可以通过按住大写切换键盘实现，代码如下,也可通过 Hotkey 函数动态实现，比较麻烦
#HotIf holdCapsLockFlag
CapsLock & Left::Numpad0
CapsLock & Up::NumpadDot
CapsLock & Del::Numpad1
CapsLock & End::Numpad2
CapsLock & PgDn::Numpad3
CapsLock & Ins::Numpad4
CapsLock & Home::Numpad5
CapsLock & PgUp::Numpad6
CapsLock & PrintScreen::Numpad7
CapsLock & ScrollLock::Numpad8
CapsLock & Pause::Numpad9
; 当大写开关开着时，改变按键含义
#HotIf !holdCapsLockFlag and GetKeyState("CapsLock", "T")
Left::Numpad0
Up::NumpadDot
Del::Numpad1
End::Numpad2
PgDn::Numpad3
Ins::Numpad4
Home::Numpad5
PgUp::Numpad6
PrintScreen::Numpad7
ScrollLock::Numpad8
Pause::Numpad9
#HotIf