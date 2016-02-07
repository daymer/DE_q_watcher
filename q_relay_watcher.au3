#NoTrayIcon
#include <File.au3>
$log = @ScriptDir & "\De q Watcher.log"
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=relayw.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
While 1
If not ProcessExists("DE_q_watcher.exe") Then

$usb_serial = 'PBAB5'
$dll = DllOpen("usb_relay_device.dll")

$aRet1 = DllCall( $dll, "int", "usb_relay_init" )
ConsoleWrite(@error&@cr)
ConsoleWrite($aRet1[0] & @LF)

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
_FileWriteLog($log, 'process DE_q_watcher.exe was closed, stopping resourses...')
$aRet2 = DllCall($dll, "int:cdecl", "usb_relay_device_close_one_relay_channel", $para1, $para2, $para3, $para4)
ConsoleWrite($aRet2[0] & @LF)


DllClose($dll)

	ConsoleWrite ('process DE_q_watcher.exe does not exists, stopping...'&@CR)
_FileWriteLog($log, 'Done')
exit
Else
	ContinueLoop
	EndIf

WEnd