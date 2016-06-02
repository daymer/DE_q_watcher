#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.4.0
	Author:         FireFox

	Script Function:
	Example for Skype UDF functions
	Skype4COM library showed by a GUI

#ce ----------------------------------------------------------------------------
#AutoIt3Wrapper_UseX64=n

#include "..\Skype.au3"
#include "onEventFunc.au3"
#include "HotKey.au3"

#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <ScrollBarConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GuiScrollBars.au3>
#include <GUIEdit.au3>
#include <WinAPI.au3>

Opt("GUIOnEventMode", 1)

_Skype_Start() ;in case not running

#Region Loading
$GUI_LOADING = GUICreate("Skype4COM - Loading", 250, 100, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST)
GUISetBkColor(0xFFFFFF, $GUI_LOADING)

GUICtrlCreateAvi("big_snake.avi", 0, 30, 30, 32, 32)
GUICtrlSetState(-1, 1)

GUICtrlCreateLabel("Loading...", 100, 33, 100, 25)
GUICtrlSetColor(-1, 0x01AEEF)
GUICtrlSetFont(-1, 16)

GUISetState(@SW_SHOW, $GUI_LOADING)
_WinAPI_SetLayeredWindowAttributes($GUI_LOADING, 0xFFFFFF)
#EndRegion Loading

#Region Variables
Global $oChat, $blChat = False
Global $oCall, $blCall = False, $blCallHold = False
Global $sCurrUserHandle = _Skype_ProfileGetHandle()
Global $sDealUserHandle
#EndRegion Variables

#Region Skype_OnEvent
_Skype_OnEventAttachmentStatus("_AttachmentStatus")

_Skype_OnEventMessageStatus("_ChatMessage", $cCmsSent)
_Skype_OnEventMessageStatus("_ChatMessage", $cCmsReceived)

_Skype_OnEventCallStatus("_StatusCallOn", $cClsUnplaced)
_Skype_OnEventCallStatus("_StatusCallOn", $cClsRouting)
_Skype_OnEventCallStatus("_StatusCallOn", $cClsRinging)
_Skype_OnEventCallStatus("_StatusCallOn", $cClsInProgress)
_Skype_OnEventCallStatus("_StatusCallOff", $cClsFinished)
_Skype_OnEventCallStatus("_StatusCallOff", $cClsFailed)
_Skype_OnEventCallStatus("_StatusCallOff", $cClsRefused)
_Skype_OnEventCallStatus("_StatusCallOff", $cClsCancelled)
_Skype_OnEventCallStatus("_StatusCallHold", $cClsLocalHold)
_Skype_OnEventCallStatus("_StatusCallHold", $cClsRemoteHold)

_Skype_OnEventOnlineStatus("_OnlineStatus")

_Skype_OnEventError("_Error")
#EndRegion Skype_OnEvent

#Region GUI
$GUI = GUICreate("Skype4COM - " & $sCurrUserHandle, 645, 400)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetBkColor(0xFFFFFF, $GUI)

GUICtrlCreatePic("background.jpg", 0, 0, 645, 400)
GUICtrlSetState(-1, $GUI_DISABLE)

$btn_OnlineStatus = GUICtrlCreateIcon("Icons\OnlineStatus\Online.ico", -1, 7, 8, 16, 16)
GUICtrlSetTip($btn_OnlineStatus, "Right click to change the online status")

$l_fullname = GUICtrlCreateLabel(_Skype_ProfileGetFullName(), 27, 7, 250, 17, 1)
GUICtrlSetFont($l_fullname, 10)
GUICtrlSetTip($l_fullname, "Profile fullname")

$l_moodtext = GUICtrlCreateLabel(_Skype_ProfileGetMoodText(), 9, 34, 290, 32)
GUICtrlSetTip($l_moodtext, "Profile mood")

$btn_edit = GUICtrlCreateButton("", 279, 6, 20, 20, $BS_ICON)
GUICtrlSetImage($btn_edit, "Icons\Profile\Edit.ico")
GUICtrlSetTip($btn_edit, "Edit profile")
GUICtrlSetOnEvent($btn_edit, "_ProfileShow")


;Right Side
$btn_call = GUICtrlCreateButton("", 307, 6, 20, 20, $BS_ICON)
GUICtrlSetImage($btn_call, "Icons\Call\call.ico")
GUICtrlSetOnEvent($btn_call, "_CallCreate")

$cm_call = GUICtrlCreateContextMenu($btn_call)
$mi_hold = GUICtrlCreateMenuItem("Place Call on Hold", $cm_call)
GUICtrlSetOnEvent($mi_hold, "_CallHold")

$l_speakwith = GUICtrlCreateLabel("", 330, 7, 305, 17, 1)
GUICtrlSetFont($l_speakwith, 10)

$tb_history = GUICtrlCreateEdit("", 306, 32, 334, 286, $ES_MULTILINE + $ES_WANTRETURN + $ES_READONLY)
GUICtrlSetBkColor($tb_history, 0xFFFFFF)
GUICtrlSetLimit($tb_history, 947512)

GUICtrlCreateButton("", 307, 324, 20, 20, $BS_ICON)
GUICtrlSetImage(-1, "Icons\File.ico")
GUICtrlSetTip(-1, "Send file")
GUICtrlSetOnEvent(-1, "_SendFile")

GUICtrlCreateButton("", 332, 324, 35, 20, $BS_ICON)
GUICtrlSetImage(-1, "Icons\Error.ico")
GUICtrlSetTip(-1, "Test the event of errors")
GUICtrlSetOnEvent(-1, "_CreateError")

$tb_msg = GUICtrlCreateEdit("", 306, 350, 287, 45, $ES_MULTILINE)

$btn_send = GUICtrlCreateButton("", 599, 350, 41, 45, $BS_ICON)
GUICtrlSetImage(-1, "Icons\Chat.ico")
GUICtrlSetTip($btn_send, "Send Message")
GUICtrlSetOnEvent($btn_send, "_ChatSend")
#EndRegion GUI

#Region GUI_CONTACTS
$GUI_CONTACTS = GUICreate("Contact List", 295, 323, 5, 72, $WS_POPUP, $WS_EX_MDICHILD, $GUI)
GUIRegisterMsg($WM_VSCROLL, "WM_VSCROLL")
GUISetBkColor(0xFFFFFF, $GUI_CONTACTS)

_GUIScrollBars_Init($GUI_CONTACTS)
_GUIScrollBars_ShowScrollBar($GUI_CONTACTS, $SB_HORZ, False)
#EndRegion GUI_CONTACTS

#Region Initialize
_GetContactList()
_GetOnlineStatus()
_GetActiveChat()
_GetActiveCall()

_HotKeyAssign(0x0D, "_ChatSend", BitOR($HK_FLAG_NOBLOCKHOTKEY, $HK_FLAG_NOREPEAT))

GUIDelete($GUI_LOADING)
GUISetState(@SW_SHOW, $GUI)
GUISetState(@SW_SHOW, $GUI_CONTACTS)
#EndRegion Initialize

#Region GUI_PROFILE
$GUI_PROFILE = GUICreate("Skype4COM - Profile", 350, 313)
GUISetOnEvent($GUI_EVENT_CLOSE, "_ProfileHide")

GUICtrlCreateLabel("Fullname", 10, 13, 80, 17, $SS_RIGHT)
$tb_fullname = GUICtrlCreateEdit("", 100, 10, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(10, "_ProfileSetFullName")
_ProfileCreateCancelBtn(10, "_ProfileGetFullName")

GUICtrlCreateLabel("Picture", 10, 50, 80, 17, $SS_RIGHT)
$pic_avatar = GUICtrlCreatePic(@DesktopDir & "\logo.gif", 100, 40, 50, 50)
GUICtrlSetOnEvent($pic_avatar, "_SaveAvatar")

GUICtrlCreateLabel("Choose picture from file", 170, 50, 117, 15)
GUICtrlSetOnEvent(-1, "_ChangeAvatar")
GUICtrlSetCursor(-1, 0)

GUICtrlCreateLabel("Mood", 10, 115, 80, 17, $SS_RIGHT)
$tb_mood = GUICtrlCreateEdit("", 100, 107, 190, 45, $ES_MULTILINE + $ES_WANTRETURN)
_ProfileCreateApplyBtn(107, "_ProfileSetMoodText")
_ProfileCreateCancelBtn(107, "_ProfileGetMoodText")

GUICtrlCreateLabel("Mobile phone", 10, 170, 80, 17, $SS_RIGHT)
$tb_mobilephone = GUICtrlCreateEdit("", 100, 167, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(167, "_ProfileSetMobilePhone")
_ProfileCreateCancelBtn(167, "_ProfileGetMobilePhone")

GUICtrlCreateLabel("Home phone", 10, 200, 80, 17, $SS_RIGHT)
$tb_homephone = GUICtrlCreateEdit("", 100, 197, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(197, "_ProfileSetHomePhone")
_ProfileCreateCancelBtn(197, "_ProfileGetHomePhone")

GUICtrlCreateLabel("Country/Region", 10, 230, 80, 17, $SS_RIGHT)
$tb_country = GUICtrlCreateEdit("", 100, 227, 190, 20, $ES_AUTOHSCROLL + $ES_READONLY)

GUICtrlCreateLabel("State/Province", 10, 260, 80, 17, $SS_RIGHT)
$tb_state = GUICtrlCreateEdit("", 100, 257, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(257, "_ProfileSetProvince")
_ProfileCreateCancelBtn(257, "_ProfileGetProvince")

GUICtrlCreateLabel("City", 10, 290, 80, 17, $SS_RIGHT)
$tb_city = GUICtrlCreateEdit("", 100, 287, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(287, "_ProfileSetCity")
_ProfileCreateCancelBtn(287, "_ProfileGetCity")

GUICtrlCreateLabel("Website", 10, 320, 80, 17, $SS_RIGHT)
$tb_homepage = GUICtrlCreateEdit("", 100, 317, 190, 20, $ES_AUTOHSCROLL)
_ProfileCreateApplyBtn(317, "_ProfileSetHomePage")
_ProfileCreateCancelBtn(317, "_ProfileGetHomePage")

GUICtrlCreateLabel("About me", 10, 353, 80, 17, $SS_RIGHT)
$tb_about = GUICtrlCreateEdit("", 100, 347, 190, 45, $ES_AUTOHSCROLL + $ES_WANTRETURN)
_ProfileCreateApplyBtn(347, "_ProfileSetAbout")
_ProfileCreateCancelBtn(347, "_ProfileGetAbout")

_GUIScrollBars_Init($GUI_PROFILE)
_GUIScrollBars_ShowScrollBar($GUI_PROFILE, $SB_HORZ, False)

_GUIScrollBars_SetScrollInfoMax($GUI_PROFILE, $SB_VERT, 23)
#EndRegion GUI_PROFILE

While 1
	Sleep(1000)
	;As you can see there's nothing in this loop thanks to skype onevent functions !
WEnd

Func _AttachmentStatus($TAttachmentStatus)
	;the Skype UDF will automatically attach to skype when this one will be available
EndFunc

Func _GetContactList()
	Local $aContacts = _Skype_ProfileGetContacts()
	Local $aLabelContacts[$aContacts[0]], $aIconContacts[$aContacts[0]]

	For $i = 1 To $aContacts[0] - 1
		Local $sUserHandle = $aContacts[$i]
		Local $sUserFullName = _Skype_UserGetFullName($sUserHandle)

		$aLabelContacts[$i] = GUICtrlCreateLabel($sUserFullName, 30, ($i * 20) - 15)
		GUICtrlSetTip($aLabelContacts[$i], _Skype_UserGetMoodText($sUserHandle))
		SetOnEventA($aLabelContacts[$i], "_ChatCreate", $PARAMBYVAL, $sUserHandle, $PARAMBYVAL, $sUserFullName)

		Local $sOnlineStatus = _Skype_UserGetOnlineStatus($sUserHandle)

		Select
			Case $sOnlineStatus = $cCusOffline
				$aIconContacts[$i] = GUICtrlCreateIcon("Icons\OnlineStatus\Offline.ico", -1, 5, ($i * 20) - 16, 16, 16)
			Case $sOnlineStatus = $cCusOnline
				$aIconContacts[$i] = GUICtrlCreateIcon("Icons\OnlineStatus\Online.ico", -1, 5, ($i * 20) - 16, 16, 16)
			Case $sOnlineStatus = $cCusAway
				$aIconContacts[$i] = GUICtrlCreateIcon("Icons\OnlineStatus\Away.ico", -1, 5, ($i * 20) - 16, 16, 16)
			Case $sOnlineStatus = $cCusNotAvailable
				$aIconContacts[$i] = GUICtrlCreateIcon("Icons\OnlineStatus\Away.ico", -1, 5, ($i * 20) - 16, 16, 16)
			Case $sOnlineStatus = $cCusDoNotDisturb
				$aIconContacts[$i] = GUICtrlCreateIcon("Icons\OnlineStatus\DoNotDisturb.ico", -1, 5, ($i * 20) - 16, 16, 16)
		EndSelect
	Next

	_GUIScrollBars_SetScrollInfoMax($GUI_CONTACTS, $SB_VERT, Int($aContacts[0] * 1.14))
EndFunc   ;==>_GetContactList

Func _ChatCreate($sUserHandle, $sUserFullName)
	$sDealUserHandle = $sUserHandle
	If _Skype_UserGetOnlineStatus($sUserHandle) = $cCusOffline Then Return ;For testing it's useless to interact with an offline user

	GUICtrlSetTip($tb_msg, "Type a message to " & $sUserFullName & " here")
	$oChat = _Skype_ChatCreateWith($sUserHandle)
	$blChat = True

	GUICtrlSetData($l_speakwith, $sUserFullName)
EndFunc   ;==>_ChatCreate

Func _ChatSend()
	If $blChat = False Then Return ;No active chat

	Local $sMsg = GUICtrlRead($tb_msg)

	If $sMsg <> "" Then
		_Skype_ChatSendMessage($oChat, $sMsg)
		GUICtrlSetData($tb_msg, "")
	EndIf
EndFunc   ;==>_ChatSend

Func _ChatMessage($oMsg)
	Local $sMsgFromHandle = _Skype_ChatMessageGetFromHandle($oMsg)
	Local $sMsgBody = _Skype_ChatMessageGetBody($oMsg)

	If GUICtrlRead($tb_history) = "" Then
		_GUICtrlEdit_AppendText($tb_history, "[" & @HOUR & ":" & @MIN & "] " _
				 & _Skype_UserGetFullName($sMsgFromHandle) & " :" & @CRLF & $sMsgBody)
	Else
		_GUICtrlEdit_AppendText($tb_history, @CRLF & @CRLF & "[" & @HOUR & ":" & @MIN & "] " _
				 & _Skype_UserGetFullName($sMsgFromHandle) & " :" & @CRLF & $sMsgBody)
	EndIf

	If Not WinActive($GUI) And $sMsgFromHandle <> $sCurrUserHandle Then _WinAPI_FlashWindow($GUI)
EndFunc   ;==>_ChatMessage

Func _GetOnlineStatus()
	Local $TOnlineStatus = _Skype_ProfileGetOnlineStatus()

	_OnlineStatus($sCurrUserHandle, $TOnlineStatus)

	Local $cm_OnlineStatus = GUICtrlCreateContextMenu($btn_OnlineStatus)
	Local $mi_Online = GUICtrlCreateMenuItem("Online", $cm_OnlineStatus)
	SetOnEventA($mi_Online, "_ChangeOnlineStatus", $PARAMBYVAL, $cCusOnline)

	Local $mi_Offline = GUICtrlCreateMenuItem("Offline", $cm_OnlineStatus)
	SetOnEventA($mi_Offline, "_ChangeOnlineStatus", $PARAMBYVAL, $cCusOffline)

	Local $mi_Away = GUICtrlCreateMenuItem("Away", $cm_OnlineStatus)
	SetOnEventA($mi_Away, "_ChangeOnlineStatus", $PARAMBYVAL, $cCusAway)

	Local $mi_DoNotDisturb = GUICtrlCreateMenuItem("DoNotDisturb", $cm_OnlineStatus)
	SetOnEventA($mi_DoNotDisturb, "_ChangeOnlineStatus", $PARAMBYVAL, $cCusDoNotDisturb)

	Local $mi_Invisible = GUICtrlCreateMenuItem("Invisible", $cm_OnlineStatus)
	SetOnEventA($mi_Invisible, "_ChangeOnlineStatus", $PARAMBYVAL, $cCusInvisible)
EndFunc   ;==>_GetOnlineStatus

Func _ChangeOnlineStatus($TUserStatus)
	_Skype_ProfileSetOnlineStatus($TUserStatus)
	_OnlineStatus($sCurrUserHandle, $TUserStatus)
EndFunc   ;==>_ChangeOnlineStatus

Func _GetActiveCall()
	Local $aMembers = _Skype_CallActiveGetMembers()
	If Not ($aMembers[0] - 1) Then Return ;No active calls

	$blCall = True
	GUICtrlSetImage($btn_call, "Icons\Call\ring-off.ico")

	Local $sUsersFullNames
	For $i = 1 To $aMembers[0] - 1
		$sUsersFullNames &= _Skype_UserGetFullName($aMembers[$i]) & ", "
	Next

	GUICtrlSetData($l_speakwith, StringTrimRight($sUsersFullNames, 1))

	Local $aCall = _Skype_CallGetActive()
	$oCall = $aCall[0]
EndFunc   ;==>_GetActiveCall

Func _GetActiveChat()
	Local $oActiveChats = _Skype_ChatGetAllActive()

	If IsArray($oActiveChats) Then
		$oChat = $oActiveChats[0]
		$blChat = True

		Local $aMembers = _Skype_ChatGetMembers($oChat)

		Local $sUsersFullNames
		For $i = 2 To $aMembers[0] - 1
			$sUsersFullNames &= _Skype_UserGetFullName($aMembers[$i]) & ", "
		Next

		$sDealUserHandle = $aMembers[2]
		GUICtrlSetData($l_speakwith, StringTrimRight($sUsersFullNames, 2))
		GUICtrlSetTip($tb_msg, "Type a message to " & StringTrimRight($sUsersFullNames, 2) & " here")
	EndIf
EndFunc   ;==>_GetActiveChat

Func _CallCreate()
	If Not $blChat Then Return ;

	If Not $blCall Then
		$oCall = _Skype_CallCreate($sDealUserHandle)
	Else
		If Not $blCallHold Then
			If Not _Skype_CallFinish($oCall) Then ;Case call started by Skype
				Local $aCall = _Skype_CallGetActive()
				_Skype_CallFinish($aCall[0])
			EndIf
		Else
			_Skype_CallResume($oCall)
		EndIf
	EndIf
EndFunc   ;==>_CallCreate

Func _StatusCallOn($oCall)
	GUICtrlSetImage($btn_call, "Icons\Call\ring-off.ico")
	GUICtrlSetTip($btn_call, _Skype_ConvertCallStatus(_Skype_CallGetStatus($oCall), True))
	$blCall = True
EndFunc   ;==>_StatusCallOn

Func _StatusCallHold($oCall)
	GUICtrlSetImage($btn_call, "Icons\Call\resume.ico")
	GUICtrlSetTip($btn_call, _Skype_ConvertCallStatus(_Skype_CallGetStatus($oCall), True))
	$blCallHold = True
EndFunc   ;==>_StatusCallHold

Func _StatusCallOff($oCall)
	GUICtrlSetImage($btn_call, "Icons\Call\call.ico")
	GUICtrlSetTip($btn_call, _Skype_ConvertCallStatus(_Skype_CallGetStatus($oCall), True))
	$blCall = False
EndFunc   ;==>_StatusCallOff

Func _CallHold()
	If $blCall Then _Skype_CallHold($oCall)
EndFunc   ;==>_CallHold

Func _OnlineStatus($sUserHandle, $TOnlineStatus)
	If $sUserHandle = $sCurrUserHandle Then
		Select
			Case $TOnlineStatus = $cCusOffline
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\Offline.ico")
				TraySetIcon("Icons\OnlineStatus\Offline.ico")
			Case $TOnlineStatus = $cCusOnline
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\Online.ico")
				TraySetIcon("Icons\OnlineStatus\Online.ico")
			Case $TOnlineStatus = $cCusAway
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\Away.ico")
				TraySetIcon("Icons\OnlineStatus\Away.ico")
			Case $TOnlineStatus = $cCusNotAvailable
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\Away.ico")
				TraySetIcon("Icons\OnlineStatus\Away.ico")
			Case $TOnlineStatus = $cCusDoNotDisturb
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\DoNotDisturb.ico")
				TraySetIcon("Icons\OnlineStatus\DoNotDisturb.ico")
			Case $TOnlineStatus = $cCusUnknown
				GUICtrlSetImage($btn_OnlineStatus, "Icons\OnlineStatus\Offline.ico")
				TraySetIcon("Icons\OnlineStatus\Offline.ico")
		EndSelect
	Else
		Local $aContacts = _Skype_ProfileGetContacts()
		Local $aLabelContacts[$aContacts[0]], $aIconContacts[$aContacts[0]]

		For $i = 1 To $aContacts[0] - 1
			If $aContacts[$i] = $sUserHandle Then
				Select
					Case $TOnlineStatus = $cCusOffline
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Offline.ico")
					Case $TOnlineStatus = $cCusOnline
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Online.ico")
					Case $TOnlineStatus = $cCusAway
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Away.ico")
					Case $TOnlineStatus = $cCusNotAvailable
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Away.ico")
					Case $TOnlineStatus = $cCusDoNotDisturb
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\DoNotDisturb.ico")
					Case $TOnlineStatus = $cCusUnknown
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Offline.ico")
					Case $TOnlineStatus = $cCusInvisible
						GUICtrlSetImage($aIconContacts[$i], "Icons\OnlineStatus\Offline.ico")
				EndSelect
			EndIf
		Next
	EndIf
EndFunc   ;==>_OnlineStatus

Func _SendFile()
	If Not $blChat Then Return ;No active chat
	_Skype_OpenFileTransfer($sDealUserHandle, @ScriptDir)
EndFunc   ;==>_SendFile

Func _ProfileShow()
	_ProfileGetFullName()
	_ProfileGetAvatar()
	_ProfileGetMoodText()
	_ProfileGetMobilePhone()
	_ProfileGetHomePhone()
	_ProfileGetProvince()
	_ProfileGetCity()
	_ProfileGetHomePage()
	_ProfileGetAbout()

	GUISetState(@SW_SHOW, $GUI_PROFILE)
EndFunc   ;==>_ProfileShow

Func _ProfileHide()
	GUISetState(@SW_HIDE, $GUI_PROFILE)
EndFunc   ;==>_ProfileHide

Func _ProfileGetFullName()
	GUICtrlSetData($tb_fullname, _Skype_ProfileGetFullName())
EndFunc   ;==>_ProfileGetFullName

Func _ProfileSetFullName()
	_Skype_ProfileSetFullName(GUICtrlRead($tb_fullname))
EndFunc   ;==>_ProfileSetFullName

Func _ChangeAvatar()
	Local $sAvatarPath = FileOpenDialog("Choose your picture", @MyDocumentsDir, "(*.jpg;*.jpeg;*.bmp;*.png;*.skype)")
	If @error Then Return ;Invalid avatar

	_Skype_ProfileLoadAvatarFromFile($sAvatarPath)
	_ProfileGetAvatar() ;in case avatar's format is png or skype
EndFunc   ;==>_ChangeAvatar

Func _ProfileGetAvatar()
	_Skype_ProfileSaveAvatarToFile(@TempDir & "\avatar.bmp")
	GUICtrlSetImage($pic_avatar, @TempDir & "\avatar.bmp")
	FileDelete(@TempDir & "\avatar.bmp")
EndFunc   ;==>_ProfileGetAvatar

Func _SaveAvatar()
	Local $sAvatarPath = FileSaveDialog("Choose where you want to save the picture", @MyDocumentsDir, "(*.jpg;*.jpeg;*.bmp;*.png;*.skype)")
	If @error Then Return ;Invalid path

	_Skype_ProfileSaveAvatarToFile($sAvatarPath)
EndFunc   ;==>_SaveAvatar

Func _ProfileGetMoodText()
	GUICtrlSetData($tb_mood, _Skype_ProfileGetMoodText())
EndFunc   ;==>_ProfileGetMoodText

Func _ProfileSetMoodText()
;~ 	_Skype_ProfileSetRichMoodText("test")
	_Skype_ProfileSetMoodText(GUICtrlRead($tb_mood))
EndFunc   ;==>_ProfileSetMoodText

Func _ProfileGetMobilePhone()
	GUICtrlSetData($tb_mobilephone, _Skype_ProfileGetPhoneMobile())
EndFunc   ;==>_ProfileGetMobilePhone

Func _ProfileSetMobilePhone()
	_Skype_ProfileSetPhoneMobile(GUICtrlRead($tb_mobilephone))
EndFunc   ;==>_ProfileSetMobilePhone

Func _ProfileGetHomePhone()
	GUICtrlSetData($tb_homephone, _Skype_ProfileGetPhoneHome())
EndFunc   ;==>_ProfileGetHomePhone

Func _ProfileSetHomePhone()
	_Skype_ProfileSetPhoneHome(GUICtrlRead($tb_homephone))
EndFunc   ;==>_ProfileSetHomePhone

Func _ProfileGetProvince()
	GUICtrlSetData($tb_state, _Skype_ProfileGetProvince())
EndFunc   ;==>_ProfileGetProvince

Func _ProfileSetProvince()
	_Skype_ProfileSetProvince(GUICtrlRead($tb_state))
EndFunc   ;==>_ProfileSetProvince

Func _ProfileGetCity()
	GUICtrlSetData($tb_city, _Skype_ProfileGetCity())
EndFunc   ;==>_ProfileGetCity

Func _ProfileSetCity()
	_Skype_ProfileSetCity(GUICtrlRead($tb_city))
EndFunc   ;==>_ProfileSetCity

Func _ProfileGetHomePage()
	GUICtrlSetData($tb_homepage, _Skype_ProfileGetHomepage())
EndFunc   ;==>_ProfileGetHomePage

Func _ProfileSetHomePage()
	_Skype_ProfileSetHomepage(GUICtrlRead($tb_homepage))
EndFunc   ;==>_ProfileSetHomePage

Func _ProfileGetAbout()
	GUICtrlSetData($tb_about, _Skype_ProfileGetAbout())
EndFunc   ;==>_ProfileGetAbout

Func _ProfileSetAbout()
	_Skype_ProfileSetAbout(GUICtrlRead($tb_about))
EndFunc   ;==>_ProfileSetAbout

Func _ProfileCreateApplyBtn($iTop, $sFunc)
	GUICtrlCreateButton("", 297, $iTop-1, 22, 22, $BS_ICON)
	GUICtrlSetImage(-1, "Icons\Profile\Apply.ico")
	GUICtrlSetTip(-1, "Apply changes")
	GUICtrlSetOnEvent(-1, $sFunc)
EndFunc   ;==>_ProfileCreateApplyBtn

Func _ProfileCreateCancelBtn($iTop, $sFunc)
	GUICtrlCreateButton("", 322, $iTop-1, 22, 22, $BS_ICON)
	GUICtrlSetImage(-1, "Icons\Profile\Cancel.ico")
	GUICtrlSetTip(-1, "Cancel changes")
	GUICtrlSetOnEvent(-1, $sFunc)
EndFunc   ;==>_ProfileCreateCancelBtn

Func _Error($iError, $sError)
	MsgBox(16, $iError, $sError)
EndFunc

Func _CreateError()
	__Skype_SendCommand("Skype UDF by FireFox :)") ;this command does not exists so it will make an error
EndFunc

Func WM_VSCROLL($hWnd, $Msg, $wParam, $lParam)
	#forceref $Msg, $wParam, $lParam
	Local $nScrollCode = BitAND($wParam, 0x0000FFFF)
	Local $index = -1, $yChar, $yPos
	Local $Min, $Max, $Page, $Pos, $TrackPos

	For $x = 0 To UBound($aSB_WindowInfo) - 1
		If $aSB_WindowInfo[$x][0] = $hWnd Then
			$index = $x
			$yChar = $aSB_WindowInfo[$index][3]
			ExitLoop
		EndIf
	Next
	If $index = -1 Then Return 0


	; Get all the vertial scroll bar information
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_VERT)
	$Min = DllStructGetData($tSCROLLINFO, "nMin")
	$Max = DllStructGetData($tSCROLLINFO, "nMax")
	$Page = DllStructGetData($tSCROLLINFO, "nPage")
;~     WinSetTitle($hChild, "", $Page)
	; Save the position for comparison later on
	$yPos = DllStructGetData($tSCROLLINFO, "nPos")
	$Pos = $yPos
	$TrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")

	Switch $nScrollCode
		Case $SB_TOP ; user clicked the HOME keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $Min)

		Case $SB_BOTTOM ; user clicked the END keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $Max)

		Case $SB_LINEUP ; user clicked the top arrow
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - 1)

		Case $SB_LINEDOWN ; user clicked the bottom arrow
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + 1)

		Case $SB_PAGEUP ; user clicked the scroll bar shaft above the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - $Page)

		Case $SB_PAGEDOWN ; user clicked the scroll bar shaft below the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + $Page)

		Case $SB_THUMBTRACK ; user dragged the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $TrackPos)
	EndSwitch

;~    // Set the position and then retrieve it.  Due to adjustments
;~    //   by Windows it may not be the same as the value set.

	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
	_GUIScrollBars_GetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
	;// If the position has changed, scroll the window and update it
	$Pos = DllStructGetData($tSCROLLINFO, "nPos")

	If ($Pos <> $yPos) Then
		_GUIScrollBars_ScrollWindow($hWnd, 0, $yChar * ($yPos - $Pos))
		$yPos = $Pos
	EndIf
EndFunc   ;==>WM_VSCROLL

Func _Exit()
	Exit
EndFunc   ;==>_Exit
