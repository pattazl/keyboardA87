; 可用于87键的键盘按键替换 Pause Script
A_TrayMenu.Delete("&Pause Script")  ; 删除暂停菜单


iniFile:= "Arrow2Enter.ini"
secName:= "Arrow2Enter"
secKey := "HoldCapsLock"
global holdCapsLockFlag
holdCapsLockFlag := IniRead(iniFile, secName , secKey ,1)
repeatMaxMs := IniRead(iniFile, secName , "repeatMaxMs" ,500) ; 重复最大 1000/2
repeatMinMs := IniRead(iniFile, secName , "repeatMinMs" ,30)  ; 重复最小 1000/30
delayMaxMs := IniRead(iniFile, secName , "delayMaxMs" ,1000) ; 延时最大 1000
delayMinMs := IniRead(iniFile, secName , "delayMinMs" ,250)  ; 延时最小 250
; 获取系统按键延时和重复速度
keyDelay:= RegRead( "HKEY_CURRENT_USER\Control Panel\Keyboard", "KeyboardDelay")
keySpeed:= RegRead( "HKEY_CURRENT_USER\Control Panel\Keyboard", "KeyboardSpeed")
; 系统按键延时范围为0-3 ; 一般默认1，为500ms
waitDownMS := delayMinMs + (delayMaxMs - delayMinMs)/3*keyDelay
; 系统按键速度范围为0-31
repeatCurrent:= repeatMaxMs + (repeatMinMs-repeatMaxMs)/31*keySpeed

If(holdCapsLockFlag) {
	A_TrayMenu.Add("Caps&Lock Hold", MenuHandler)  ; 默认需要按住大写键生效
	;A_TrayMenu.Rename("CapsLock Hold","When CapsLock")
} Else {
	A_TrayMenu.Add("When Caps&Lock", MenuHandler)  ; 默认需要按住大写键生效
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
downState := 0  ; 按下锁定标记
timeout:=0
$Down::
{
	global downState
	global timeout
	StartTime := A_TickCount
	;OutputDebug "autohotkey 1 downState " downState " ,timeout " timeout
	IsDown:= GetKeyState("Down","P")
	;OutputDebug "autohotkey 1 downState " downState ",IsDown:" IsDown
	; 第一次按住状态，需要锁定
	if(IsDown ==1 && downState == 0)
	{
		;OutputDebug "autohotkey True"
		BlockInput True
		downState := 1
		timeout := 0
	}
	sendEnter:=0
	Loop 
	{
		if( downState == 1 && (A_TickCount - StartTime)< waitDownMS ) 
		{
			IsRight:= GetKeyState("Right","P")
			if(IsRight)
			{
				sendEnter:=1
			}
		}else{
			timeout := 1
		}
		IsDown:= GetKeyState("Down","P")
		;OutputDebug "autohotkey 2 downState:" downState ", timeout: " timeout " IsDown: " IsDown
		; 释放按钮
		if(IsDown==0){
			downState := 0
		}
		; 解除开始超时
		if(IsDown==0 || timeout ==1 || sendEnter==1 ){
			BlockInput False
			;OutputDebug "autohotkey False"
			if(sendEnter==0){
				Send "{Down}"
				;OutputDebug "autohotkey send Down 3"
			}else{
				Send "{Enter}"
				;OutputDebug "autohotkey send Enter 4"
			}
		}
		if(downState==0||sendEnter==1)
		{
			timeout:=0
			downState:=0
			break
		}
		; 按内置的 按键延时来响应
		Sleep(repeatCurrent) ; 暂不用 A_KeyDelay
	}
}

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
CapsLock & Down::NumpadSub
CapsLock & Right::NumpadAdd
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
Down::NumpadSub
Right::NumpadAdd
#HotIf