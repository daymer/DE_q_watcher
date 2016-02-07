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

$aRet2 = DllCall($dll, "int:cdecl", "usb_relay_device_open_one_relay_channel", $para1, $para2, $para3, $para4)
ConsoleWrite($aRet2[0] & @LF)

Sleep(1000)


$aRet2 = DllCall($dll, "int:cdecl", "usb_relay_device_close_one_relay_channel", $para1, $para2, $para3, $para4)
ConsoleWrite($aRet2[0] & @LF)


DllClose($dll)