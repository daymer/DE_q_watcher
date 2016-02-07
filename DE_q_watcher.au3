#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=relay.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Date.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <GUIListBox.au3>
#include <GuiStatusBar.au3>
#include <GuiToolbar.au3>
#include <ToolbarConstants.au3>
#include <StaticConstants.au3>
#include <GuiButton.au3>
#include <ColorConstants.au3>
#include <IE.au3>
#include <EditConstants.au3>
#include <Crypt.au3>
;AutoItSetOption("MustDeclareVars", 1)

$log = @ScriptDir & "\De q Watcher.log"


;~ #Region start vars
;~ If $CmdLine[0] = "" Then
;~     MsgBox(64, "Warning", "Started without needful arguments.", 10)
;~    Exit
;~ EndIf
;~ For $i=1 to 3
;~ $t=$i*2-1
;~ ;-----------------------------------------------------
;~ If $CmdLine[$t] = "-timeout" Then
;~    $timeout = $CmdLine[$t+1]
;~ EndIf
;~ ;-----------------------------------------------------
;~ If $CmdLine[$t] = "-usb_serial" Then
;~    $usb_serial = $CmdLine[$t+1]
;~ EndIf
;~ ;-----------------------------------------------------
;~ If $CmdLine[$t] = "-time_to_react" Then
;~    $time_to_react = $CmdLine[$t+1]
;~ EndIf
;~ Next
;~ #EndRegion
#Region default start vars
$timeout=10000
$usb_serial = 'PBAB5'
$time_to_react = 30
#EndRegion
$time_to_react = Number($time_to_react)
_FileWriteLog($log, "=======================================================================================================")
_FileWriteLog($log, "Starting the program with attributes:")
_FileWriteLog($log, "Timeout: "&$timeout)
_FileWriteLog($log, "USB serial: "&$usb_serial)
_FileWriteLog($log, "Time_to_react: "&$time_to_react)
Run('cmd.exe /c "' & @ScriptDir&"\q_relay_watcher.exe" & '"', '', @SW_HIDE, 6)
$usb_serial = 'PBAB5'
$dll = DllOpen("usb_relay_device.dll")
ConsoleWrite(@error&@cr)
$aRet1 = DllCall( $dll, "int", "usb_relay_init" )
ConsoleWrite(@error&@cr)
$aRet = DllCall( $dll, "int:cdecl", "usb_relay_device_open_with_serial_number", "str", $usb_serial, "uint", 5 )
If @error Then
  ConsoleWrite( "Errorcode: " & @error & @CRLF )
Else
  ConsoleWrite( "Handle: " & $aRet[0] & @CRLF )
EndIf
$para1 = "int"
$para2 = $aRet[0]
$para3 = "int"
$para4 = 1

If Not IsAdmin() Then
    MsgBox($MB_SYSTEMMODAL, "Warning","Admin rights are not detected."& @CR& 'You need to be admin to run this tool')
	Exit
EndIf
Func _RunInCMD($sPath)
    Local $eMsg, $stdout
    Local $pid = Run('cmd.exe /c "' & $sPath & '"', '', @SW_HIDE, 6)
    If Not $pid Then Return SetError(-1, 0, 'Failed to run')
    ;
    While 1
        $eMsg &= StderrRead($pid, 0, 0)
        If @error Then ExitLoop
        Sleep(10)
    WEnd
    If $eMsg Then Return SetError(-2, 0, $eMsg)
    ;
    While 1
        $stdout &= StdoutRead($pid, 0, 0)
        If @error Then ExitLoop
        Sleep(10)
    WEnd
    ;
    If Not $stdout Then Return SetError(-3, 0, 'Nothing to read')
    Return SetError(0, 0, $stdout)
EndFunc
Func _Clear2($type = 10, $visible = 1)
    ; #############################################################################
    ; Типы очистки:
    ; 1 = Очистить Журнал
    ; 2 = Очистить файлы "Cookie"
    ; 8 = Очистить временные файлы Интернета
    ; 16 = Очистить данные веб-форм
    ; 32 = Очистить пароли
    ; 255 = Удалить все
    ; 4351 = Удалить все, включая данные и файлы созданные дополнениями (аддонами)
    ; #############################################################################

    If $visible = 1 Then
        RunWait('RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess ' & $type)
    Else
        RunWait('RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess ' & $type, '', @SW_HIDE)
    EndIf

    DirRemove(@UserProfileDir & '\Application Data\Macromedia\Flash Player', 1)
    DirRemove(@UserProfileDir & '\Application Data\Adobe\Flash Player', 1)

EndFunc   ;==>_Clear
;--------------------------------------------------------------------------------------------------------------------------
$UserSID=_RunInCMD("wmic useraccount where name='%username%' get sid")
$UserSID=StringReplace($UserSID, 'SID', '')
$UserSID=StringReplace($UserSID, @cr, '')
$UserSID=StringReplace($UserSID, @LF, '')
$UserSID=StringStripWS($UserSID,8)
;ConsoleWrite($UserSID)
$username = RegRead ("HKEY_USERS\"&$UserSID&'\Software\Microsoft\Windows\CurrentVersion\Internet Settings', "sfu" )
$password = RegRead ("HKEY_USERS\"&$UserSID&'\Software\Microsoft\Windows\CurrentVersion\Internet Settings', "sfp" )
;ConsoleWrite($username&' '&$password&@cr)
if $username = '' or $password = '' Then
	$IsFirstStart = True
Else
	$IsFirstStart = False
EndIf
ConsoleWrite('$IsFirstStart '&$IsFirstStart&@cr)
#Region $IsFirstStart = True
if $IsFirstStart = True Then

$gui = GUICreate("First start", 234, 150, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_POPUP,$WS_EX_TOPMOST)

$username_input = GUICtrlCreateInput("username", 8, 40, 217, 21)

$password_input = GUICtrlCreateInput("password", 8, 65, 217, 21,$ES_PASSWORD)

$message = GUICtrlCreateLabel("At the first run of the software you need to specify the salesforce user credentials", 8, 8, 200, 30)

$ok=GUICtrlCreateButton("OK",8,100,217,30)

GUISetState()

While 1

$nMsg = GUIGetMsg()

Switch $nMsg

Case $GUI_EVENT_CLOSE

Exit
	Case $ok
		$username = GUICtrlRead($username_input)
		$password = GUICtrlRead($password_input)
				if $username = 'username' or $password = 'password' Then
				MsgBox($MB_SYSTEMMODAL, "Warning","User or password is not correct."& @CR& 'You need to be a salesforce user to run this tool')
				ContinueLoop
				EndIf
			GUIDelete($gui)
		ExitLoop
EndSwitch

WEnd
$username_encrypted = _Crypt_EncryptData($username, 'krestomansi', $CALG_AES_256)
$password_encrypted = _Crypt_EncryptData($password, 'krestomansi', $CALG_AES_256)
;ConsoleWrite($username_encrypted&' '&$password_encrypted&@cr)
;ConsoleWrite("HKEY_USERS\"&$UserSID&'\Software\Microsoft\Windows\CurrentVersion\Internet Settings'&@CR)
RegWrite("HKEY_USERS\"&$UserSID&'\Software\Microsoft\Windows\CurrentVersion\Internet Settings', "sfu",  "REG_BINARY", $username_encrypted)
RegWrite("HKEY_USERS\"&$UserSID&'\Software\Microsoft\Windows\CurrentVersion\Internet Settings', "sfp",  "REG_BINARY", $password_encrypted)
EndIf
#EndRegion
#Region $IsFirstStart = False
$username_decrypted=BinaryToString(_Crypt_DecryptData($username, 'krestomansi', $CALG_AES_256))
$password_decrypted=BinaryToString(_Crypt_DecryptData($password, 'krestomansi', $CALG_AES_256))
#EndRegion
;_Clear2(4351, 0)

While 1
If ProcessExists("iexplore.exe") Then
   	Sleep(2000)
	ConsoleWrite ('process iexplore.exe exists, stopping...'&@CR)
ProcessClose("iexplore.exe")
Else
	ExitLoop
EndIf
WEnd

local $oIE = _IECreate("https://na26.salesforce.com/500/x?fcf=00B60000005luyE&rolodexIndex=-1&page=1&isdtp=nv", 0, 0, 1, 0 )
_IELoadWait ($oIE)
Sleep(1000)
$oForm = _IEFormGetCollection ($oIE, 0)
$username_form = _IEFormElementGetObjByName ($oForm, 'username')
$password_form = _IEFormElementGetObjByName ($oForm, 'password')
;this one
_IEFormElementSetValue($username_form, $username)
_IEFormElementSetValue($password_form, $password)
;needs a fix
Sleep(5000)
Local $oSubmit = _IEGetObjByID($oIE, "Login")
_IEAction($oSubmit, "click")
$AlarmMode = False
Sleep(5000)
_IELoadWait ($oIE)
While 1
_IEAction($oIE, "refresh")
_IELoadWait ($oIE)
$content = _IEDocReadHTML($oIE)
local $FTRs = StringRegExp($content, 'cellCol5 numericalColumn">(.*?)</td>', 3)

local $FTRs_numm = UBound($FTRs, $UBOUND_ROWS) -1
For $i = 0 To $FTRs_numm step +1
	if $FTRs[$i]*2=0 Then ContinueLoop
	$FTRs[$i] = StringReplace($FTRs[$i], ",", "")
		If $FTRs[$i] <$time_to_react or $FTRs[$i] = $time_to_react Then
			ConsoleWrite('found '&$FTRs[$i]&@CR)
						if $AlarmMode = False Then

ConsoleWrite('Found a case with FTR ='&$FTRs[$i]&' - reacting...'&@CR)
$aRet2 = DllCall($dll, "int:cdecl", "usb_relay_device_open_one_relay_channel", $para1, $para2, $para3, $para4)
ConsoleWrite($aRet2[0] & @LF)
			_FileWriteLog($log, 'found a case with FTR ='&$FTRs[$i]&' - reacting...')
			$AlarmMode = True
		EndIf
		$AlarmMode = True
			ExitLoop
	EndIf
		If $i = $FTRs_numm Then
			$AlarmMode = False
$aRet2 = DllCall($dll, "int:cdecl", "usb_relay_device_close_one_relay_channel", $para1, $para2, $para3, $para4)
ConsoleWrite($aRet2[0] & @LF)
ConsoleWrite('no cases found - relay will be dowm'&@CR)
;~ _ArrayDisplay($FTRs)
_FileWriteLog($log, 'No cases found - relay will be dowm')
		EndIf

Next
ConsoleWrite('sleeping...'&@CR)
	Sleep($timeout)
WEnd
DllClose($dll)