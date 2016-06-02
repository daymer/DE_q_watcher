#include-once

; #INDEX# =======================================================================================================================
; Title .........: Skype
; UDF Version ...: 1.2
; AutoIt Version : 3.3.4.0+
; Description ...: Automates Skype™ (http://www.skype.com/)
; Author(s) .....: FireFox (aka d3mon, d3monCorp)
; Dll ...........: Skype4COM.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $oSkype = ObjCreate("Skype4COM.Skype")
Global $oUsers = ObjCreate("Skype4COM.UserCollection")

Global Const $oSkypeEvent = ObjEvent($oSkype, "Skype_")
If ObjEvent("AutoIt.Error") = "" Then Global Const $oError = ObjEvent("AutoIt.Error", "Skype_Error")

Global $sOutCmd = "", $_iTimeout = 2000 ;Command timeout (2 sec)

Global $sOnAppConnecting = "", $sOnAsyncSearchUsersFinished = "", $sOnAttachmentStatus = "", $sOnAutoAway = "", _
		$sOnCallHistory = "", $sOnCallInputStatusChanged = "", $sOnCallSeenStatusChanged = "", _
		$sOnCallTransferStatusChanged = "", $sOnCallTransferStatusChanged = "", $sOnCallVideoSendStatusChanged = "", _
		$sOnCallVideoReceiveStatusChanged = "", $sOnCallVideoStatusChanged = "", $sOnChatMembersChanged = "", _
		$sOnConnectionStatus = "", $sOnContactsFocused = "", $sOnCallDtmfReceived = "", $sOnError = "", _
		$sOnFileTransferStatusChanged = "", $sOnGroupDeleted = "", $sOnGroupExpanded = "", $sOnGroupUsers = "", _
		$sOnGroupVisible = "", $sOnMessageHistory = "", $sOnMute, $sOnOnlineStatus = "", $sOnPluginEventClicked = "", _
		$sOnPluginMenuItemClicked = "", $sOnSilentModeStatusChanged = "", $sOnSmsMessageStatusChanged = "", _
		$sOnSmsTargetStatusChanged = "", $sOnUILanguageChanged = "", $sOnUserAuthRequestReceived = "", $sOnUserMood = "", _
		$sOnUserStatus = "", $sOnVoiceMailStatus = "", $sOnWallpaperChanged = "", $aOnCallStatus[24], $aOnMessageStatus[5]
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
;TAttachmentStatus
Global Const $cAttachUnknown = -1, _
		$cAttachSuccess = 0, _
		$cAttachPendingAuthorization = 1, _
		$cAttachRefused = 2, _
		$cAttachNotAvailable = 3, _
		$cAttachAvailable = 4

;TConnectionStatus
Global Const $cConUnknown = -1, _
		$cConOffline = 0, _
		$cConConnecting = 1, _
		$cConPausing = 2, _
		$cConOnline = 3

;TUserStatus
Global Const $cCusUnknown = -1, _
		$cCusOffline = 0, _
		$cCusOnline = 1, _
		$cCusAway = 2, _
		$cCusNotAvailable = 3, _
		$cCusDoNotDisturb = 4, _
		$cCusInvisible = 5, _
		$cCusLoggedOut = 6, _
		$cCusSkypeMe = 7

;TCallFailureReason
Global Const $cCfrUnknown = -1, _
		$cCfrMiscError = 0, _
		$cCfrUserDoesNotExist = 1, _
		$cCfrUserIsOffline = 2, _
		$cCfrNoProxyFound = 3, _
		$cCfrSessionTerminated = 4, _
		$cCfrNoCommonCodec = 5, _
		$cCfrSoundIOError = 6, _
		$cCfrRemoteDeviceError = 7, _
		$cCfrBlockedByRecipient = 8, _
		$cCfrRecipientNotFriend = 9, _
		$cCfrNotAuthorizedByRecipient = 10, _
		$cCfrSoundRecordingError = 11

;TCallStatus
Global Const $cClsUnknown = -1, _
		$cClsUnplaced = 0, _
		$cClsRouting = 1, _
		$cClsEarlyMedia = 2, _
		$cClsFailed = 3, _
		$cClsRinging = 4, _
		$cClsInProgress = 5, _
		$cClsOnHold = 6, _
		$cClsFinished = 7, _
		$cClsMissed = 8, _
		$cClsRefused = 9, _
		$cClsBusy = 10, _
		$cClsCancelled = 11, _
		$cClsLocalHold = 12, _
		$cClsRemoteHold = 13, _
		$cClsVoicemailBufferingGreeting = 14, _
		$cClsVoicemailPlayingGreeting = 15, _
		$cClsVoicemailRecording = 16, _
		$cClsVoicemailUploading = 17, _
		$cClsVoicemailSent = 18, _
		$cClsVoicemailCancelled = 19, _
		$cClsVoicemailFailed = 20, _
		$cClsTransferring = 21, _
		$cClsTransferred = 22

;TCallType
Global Const $cCltUnknown = -1, _
		$cCltIncomingPSTN = 0, _
		$cCltOutgoingPSTN = 1, _
		$cCltIncomingP2P = 2, _
		$cCltOutgoingP2P = 3

;TCallHistory
Global Const $cChsAllCalls = 0, _
		$cChsMissedCalls = 1, _
		$cChsIncomingCalls = 2, _
		$cChsOutgoingCalls = 3

;TCallVideoStatus
Global Const $cCvsUnknown = -1, _
		$cCvsNone = 0, _
		$cCvsSendEnabled = 1, _
		$cCvsReceiveEnabled = 2, _
		$cCvsBothEnabled = 3

;TCallVideoSendStatus
Global Const $cVssUnknown = -1, _
		$cVssNotAvailable = 0, _
		$cVssAvailable = 1, _
		$cVssStarting = 2, _
		$cVssRejected = 3, _
		$cVssRunning = 4, _
		$cVssStopping = 5, _
		$cVssPaused = 6

;TCallIoDeviceType
Global Const $cCallIoDeviceTypeUnknown = -1, _
		$cCallIoDeviceTypeSoundcard = 0, _
		$cCallIoDeviceTypePort = 1, _
		$cCallIoDeviceTypeFile = 2

;TChatMessageType
Global Const $cCmeUnknown = -1, _
		$cCmeCreatedChatWith = 0, _
		$cCmeSawMembers = 1, _
		$cCmeAddedMembers = 2, _
		$cCmeSetTopic = 3, _
		$cCmeSaid = 4, _
		$cCmeLeft = 5, _
		$cCmeEmoted = 6, _
		$cCmePostedContacts = 7, _
		$cCmeGapInChat = 8, _
		$cCmeSetRole = 9, _
		$cCmeKicked = 10, _
		$cCmeSetOptions = 11, _
		$cCmeKickBanned = 12, _
		$cCcmeJoinedAsApplicant = 13, _
		$cCmeSetPicture = 14, _
		$cCmeSetGuidelines = 15

;TChatMessageStatus
Global Const $cCmsUnknown = -1, _
		$cCmsSending = 0, _
		$cCmsSent = 1, _
		$cCmsReceived = 2, _
		$cCmsRead = 3

;TChatMemberRole
Global Const $cChatMemberRoleUnknown = -1, _
		$cChatMemberRoleCreator = 0, _
		$cChatMemberRoleMaster = 1, _
		$cChatMemberRoleHelper = 2, _
		$cChatMemberRoleUser = 3, _
		$cChatMemberRoleListener = 4, _
		$cChatMemberRoleApplicant = 5

;TUserSex
Global Const $cUsexUnknown = -1, _
		$cUsexMale = 0, _
		$cUsexFemale = 1

;TBuddyStatus
Global Const $cBudUnknown = -1, _
		$cBudNeverBeenFriend = 0, _
		$cBbudDeletedFriend = 1, _
		$cBudPendingAuthorization = 2, _
		$cBudFriend = 3

;TOnlineStatus
Global Const $cOlsUnknown = -1, _
		$cOlsOffline = 0, _
		$cOlsOnline = 1, _
		$cOlsAway = 2, _
		$cOlsNotAvailable = 3, _
		$cOlsDoNotDisturb = 4, _
		$cOlsSkypeOut = 5, _
		$cOlsSkypeMe = 6

;TChatLeaveReason
Global Const $cLeaUnknown = -1, _
		$cLeaUserNotFound = 0, _
		$cLeaUserIncapable = 1, _
		$cLeaAdderNotFriend = 2, _
		$cLeaAddedNotAuthorized = 3, _
		$cLeaAddDeclined = 4, _
		$cLeaUnsubscribe = 5

;TChatStatus
Global Const $cChsUnknown = -1, _
		$cChsLegacyDialog = 0, _
		$cChsDialog = 1, _
		$cChsMultiNeedAccept = 2, _
		$cChsMultiSubscribed = 3, _
		$cChsUnsubscribed = 4

;TChatType
Global Const $cChatTypeUnknown = -1, _
		$cChatTypeDialog = 0, _
		$cChatTypeLegacyDialog = 1, _
		$cChatTypeLegacyUnsubscribed = 2, _
		$cChatTypeMultiChat = 3, _
		$cChatTypeSharedGroup = 4

;TChatMyStatus
Global Const $cChatStatusUnknown = -1, _
		$cChatStatusConnecting = 0, _
		$cChatStatusWaitingRemoteAccept = 1, _
		$cChatStatusAcceptRequired = 2, _
		$cChatStatusPasswordRequired = 3, _
		$cChatStatusSubscribed = 4, _
		$cChatStatusUnsubscribed = 5, _
		$cChatStatusDisbanded = 6, _
		$cChatStatusQueuedBecauseChatIsFull = 7, _
		$cChatStatusApplicationDenied = 8, _
		$cChatStatusKicked = 9, _
		$cChatStatusBanned = 10, _
		$cChatStatusRetryConnecting = 11

;TChatOptions
Global Const $cChatOptionJoiningEnabled = 1, _
		$cChatOptionJoinersBecomeApplicants = 2, _
		$cChatOptionJoinersBecomeListeners = 4, _
		$cChatOptionHistoryDisclosed = 8, _
		$cChatOptionUsersAreListeners = 16, _
		$cChatOptionTopicAndPictureLockedForUsers = 32

;TVoicemailType
Global Const $cVmtUnknown = -1, _
		$cVmtIncoming = 0, _
		$cVmtDefaultGreeting = 1, _
		$cVmtCustomGreeting = 2, _
		$cVmtOutgoing = 3

;TVoicemailStatus
Global Const $cVmsUnknown = -1, _
		$cVmsNotDownloaded = 0, _
		$cVmsDownloading = 1, _
		$cVmsUnplayed = 2, _
		$cVmsBuffering = 3, _
		$cVmsPlaying = 4, _
		$cVmsPlayed = 5, _
		$cVmsBlank = 6, _
		$cVmsRecording = 7, _
		$cVmsRecorded = 8, _
		$cVmsUploading = 9, _
		$cVmsUploaded = 10, _
		$cVmsDeleting = 11, _
		$cVmsFailed = 12

;TVoicemailFailureReason
Global Const $cVmrUnknown = -1, _
		$cVmrNoError = 0, _
		$cVmrMiscError = 1, _
		$cVmrConnectError = 2, _
		$cVmrNoPrivilege = 3, _
		$cVmrNoVoicemail = 4, _
		$cVmrFileReadError = 5, _
		$cVmrFileWriteError = 6, _
		$cVmrRecordingError = 7, _
		$cVmrPlaybackError = 8

;TGroupType
Global Const $cGrpUnknown = -1, _
		$cGrpCustomGroup = 0, _
		$cGrpAllUsers = 1, _
		$cGrpAllFriends = 2, _
		$cGrpSkypeFriends = 3, _
		$cGrpSkypeOutFriends = 4, _
		$cGrpOnlineFriends = 5, _
		$cGrpPendingAuthorizationFriends = 6, _
		$cGrpRecentlyContactedUsers = 7, _
		$cGrpUsersWaitingMyAuthorization = 8, _
		$cGrpUsersAuthorizedByMe = 9, _
		$cGrpUsersBlockedByMe = 10, _
		$cGrpUngroupedFriends = 11, _
		$cGrpSharedGroup = 12, _
		$cGrpProposedSharedGroup = 13

;TCallChannelType
Global Const $cCctUnknown = -1, _
		$cCctDatagram = 0, _
		$cCctReliable = 1

;TApiSecurityContext
Global Const $cApiContextUnknown = 0x0000, _
		$cApiContextVoice = 0x0001, _
		$cApiContextMessaging = 0x0002, _
		$cApiContextAccount = 0x0004, _
		$cApiContextContacts = 0x0008

;TSmsMessageType
Global Const $sSmsMessageTypeUnknown = -1, _
		$sSmsMessageTypeIncoming = 0, _
		$sSmsMessageTypeOutgoing = 1, _
		$sSmsMessageTypeCCRequest = 2, _
		$sSmsMessageTypeCCSubmit = 3

;TSmsMessageStatus
Global Const $sSmsMessageStatusUnknown = -1, _
		$sSmsMessageStatusReceived = 0, _
		$sSmsMessageStatusRead = 1, _
		$sSmsMessageStatusComposing = 2, _
		$sSmsMessageStatusSendingToServer = 3, _
		$sSmsMessageStatusSentToServer = 4, _
		$sSmsMessageStatusDelivered = 5, _
		$sSmsMessageStatusSomeTargetsFailed = 6, _
		$sSmsMessageStatusFailed = 7

;TSmsFailureReason
Global Const $sSmsFailureReasonUnknown = -1, _
		$sSmsFailureReasonMiscError = 0, _
		$sSmsFailureReasonServerConnectFailed = 1, _
		$sSmsFailureReasonNoSmsCapability = 2, _
		$sSmsFailureReasonInsufficientFunds = 3, _
		$sSmsFailureReasonInvalidConfirmationCode = 4, _
		$sSmsFailureReasonUserBlocked = 5, _
		$sSmsFailureReasonIPBlocked = 6, _
		$sSmsFailureReasonNodeBlocked = 7

;TSmsTargetStatus
Global Const $sSmsTargetStatusUnknown = -1, _
		$sSmsTargetStatusUndefined = 0, _
		$sSmsTargetStatusAnalyzing = 1, _
		$sSmsTargetStatusAcceptable = 2, _
		$sSmsTargetStatusNotRoutable = 3, _
		$sSmsTargetStatusDeliveryPending = 4, _
		$sSmsTargetStatusDeliverySuccessful = 5, _
		$sSmsTargetStatusDeliveryFailed = 6

;TPluginContext
Global Const $cPluginContextUnknown = -1, _
		$cPluginContextChat = 0, _
		$cPluginContextCall = 1, _
		$cPluginContextContact = 2, _
		$cPluginContextMyself = 3, _
		$cPluginContextTools = 4

;TPluginContactType
Global Const $cPluginContactTypeUnknown = -1, _
		$cPluginContactTypeAll = 0, _
		$cPluginContactTypeSkype = 1, _
		$cPluginContactTypeSkypeOut = 2

;TFileTransferType
Global Const $cFileTransferTypeIncoming = 0, _
		$cFileTransferTypeOutgoing = 1

;TFileTransferStatus
Global Const $cFileTransferStatusNew = 0, _
		$cFileTransferStatusConnecting = 1, _
		$cFileTransferStatusWaitingForAccept = 2, _
		$cFileTransferStatusTransferring = 3, _
		$cFileTransferStatusTransferringOverRelay = 4, _
		$cFileTransferStatusPaused = 5, _
		$cFileTransferStatusRemotelyPaused = 6, _
		$cFileTransferStatusCancelled = 7, _
		$cFileTransferStatusCompleted = 8, _
		$cFileTransferStatusFailed = 9

;TFileTransferFailureReason
Global Const $cFileTransferFailureReasonSenderNotAuthorized = 1, _
		$cFileTransferFailureReasonRemotelyCancelled = 2, _
		$cFileTransferFailureReasonFailedRead = 3, _
		$cFileTransferFailureReasonFailedRemoteRead = 4, _
		$cFileTransferFailureReasonFailedWrite = 5, _
		$cFileTransferFailureReasonFailedRemoteWrite = 6, _
		$cFileTransferFailureReasonRemoteDoesNotSupportFT = 7, _
		$cFileTransferFailureReasonRemoteOfflineTooLong = 8
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Skype_Start
; _Skype_Shutdown
; _Skype_IsRunning
; _Skype_SearchForUsers
; _Skype_GetAttachmentStatus
; _Skype_ConferenceCount
; _Skype_Focus
; _Skype_BtnPressed
; _Skype_BtnReleased
; _Skype_ConnectionStatus
; _Skype_ResetCache
; _Skype_ProfileSetOnlineStatus
; _Skype_Minimize
; _Skype_GetMute
; _Skype_SetMute
; _Skype_ResetIdleTimer
; _Skype_EnableApiSecurityContext

; _Skype_GetAudioOut
; _Skype_SetAudioOut
; _Skype_GetAudioIn
; _Skype_SetAudioIn
; _Skype_GetRinger
; _Skype_SetRinger
; _Skype_GetAutoAway
; _Skype_SetAutoAway
; _Skype_GetRingToneStatus
; _Skype_SetRingToneStatus
; _Skype_GetVideoIn
; _Skype_SetVideoIn
; _Skype_GetPCSpeaker
; _Skype_SetPCSpeaker
; _Skype_GetAGC
; _Skype_SetAGC
; _Skype_GetAEC
; _Skype_SetAEC
; _Skype_GetLanguage
; _Skype_SetLanguage
; _Skype_GetSkypeVersion
; _Skype_GetProtocol
; _Skype_SetProtocol
; _Skype_GetApiWrapperVersion
; _Skype_GetSilentMode
; _Skype_SetSilentMode
; _Skype_GetCache
; _Skype_SetCache
;
; _Skype_GroupCreate
; _Skype_GroupGetCount
; _Skype_GroupCustomGetCount
; _Skype_GroupHardwiredGetCount
; _Skype_GroupDelete
; _Skype_GroupRemoveUser
; _Skype_GroupAddUser
; _Skype_GroupCustomGetDetails
; _Skype_GroupHardwiredGetDetails
;
; _Skype_OpenContactsTab
; _Skype_OpenSearchDialog
; _Skype_OpenProfileDialog
; _Skype_OpenOptionsDialog
; _Skype_OpenUserInfoDialog
; _Skype_OpenMessageDialog
; _Skype_OpenFileTransfer
; _Skype_OpenLiveTab
; _Skype_OpenDialPadTab
; _Skype_OpenChat
; _Skype_OpenCallHistoryTab
; _Skype_OpenSendContactsDialog
; _Skype_OpenAuthorizationDialog
; _Skype_OpenBlockedUsersDialog
; _Skype_OpenImportContactsWizard
; _Skype_OpenGettingStartedWizard
; _Skype_OpenVideoTestDialog
; _Skype_OpenConferenceDialog
; _Skype_OpenAddAFriend
;
; _Skype_ChatCreate
; _Skype_ChatCreateWith
; _Skype_ChatAddMembers
; _Skype_ChatMessage
; _Skype_ChatAllGetMessagesDetails
; _Skype_ChatEnterPassword
; _Skype_ChatKickBan
; _Skype_ChatKick
; _Skype_ChatBookmark
; _Skype_ChatUnbookmark
; _Skype_ChatSetPassword
; _Skype_ChatGetTopic
; _Skype_ChatSetTopic
; _Skype_ChatOpenWindow
; _Skype_ChatSendMessage
; _Skype_ChatLeave
; _Skype_ChatAlterRemoveUsers
; _Skype_ChatAlterAddUsers
; _Skype_ChatAlterSetTopic
; _Skype_ChatAlterLeave
; _Skype_ChatAlterAddMembers
; _Skype_ChatCreateMultiple
; _Skype_ChatDisband
; _Skype_ChatAcceptAdd
; _Skype_ChatClearRecentMessages
; _Skype_ChatGetName
; _Skype_ChatGetMessages
; _Skype_ChatGetDate
; _Skype_ChatGetAdder
; _Skype_ChatGetStatus
; _Skype_ChatGetMembers
; _Skype_ChatGetMyStatus
; _Skype_ChatGetType
; _Skype_ChatSetAlertString
; _Skype_ChatGetDialogPartner
; _Skype_ChatPasswordHint
; _Skype_ChatGetActivityDate
; _Skype_ChatGetDescription
; _Skype_ChatSetDescription
; _Skype_ChatGetGuideLines
; _Skype_ChatSetGuideLines
; _Skype_ChatGetTopicXML
; _Skype_ChatSetTopicXML
; _Skype_ChatGetFriendlyName
; _Skype_ChatGetBlob
; _Skype_ChatMessageGetBody
; _Skype_ChatMessageGetId
; _Skype_ChatMessageGetFromHandle
; _Skype_ChatMessageGetDate
; _Skype_ChatMessageGetType
; _Skype_ChatGetAll
; _Skype_ChatGetAllActive
; _Skype_ChatGetMissed
; _Skype_ChatGetRecent
; _Skype_ChatGetBookmarked
; _Skype_ChatClearHistory
;
; _Skype_CallCreate
; _Skype_CallGetActiveCount
; _Skype_CallGetActive
; _Skype_CallActiveGetMembers
; _Skype_CallGetStatus
; _Skype_CallSetStatus
; _Skype_CallGetId
; _Skype_CallGetDate
; _Skype_CallGetConferenceId
; _Skype_CallGetType
; _Skype_CallGetFailureReason
; _Skype_CallGetSubject
; _Skype_CallGetPstnNumber
; _Skype_CallGetDuration
; _Skype_CallGetPstnStatus
; _Skype_CallGetSeen
; _Skype_CallSetSeen
; _Skype_CallSetDTMF
; _Skype_CallGetParticipantsCount
; _Skype_CallGetParticipants
; _Skype_CallGetVideoStatus
; _Skype_CallGetVideoSendStatus
; _Skype_CallGetVideoReceiveStatus
; _Skype_CallGetRate
; _Skype_CallGetRateCurrency
; _Skype_CallGetRatePrecision
; _Skype_CallGetInputDevice
; _Skype_CallSetInputDevice
; _Skype_CallGetOutputDevice
; _Skype_CallSetOutputDevice
; _Skype_CallGetCaptureMicDevice
; _Skype_CallSetCaptureMicDevice
; _Skype_CallGetInputStatus
; _Skype_CallGetForwardedBy
; _Skype_CallGetCanTransfer
; _Skype_CallGetTransferStatus
; _Skype_CallGetTransferActive
; _Skype_CallGetTransferredBy
; _Skype_CallGetTransferredTo
; _Skype_CallGetTargetIdentity
; _Skype_CallClearHistory
; _Skype_CallJoin
; _Skype_CallHold
; _Skype_CallResume
; _Skype_CallFinish
; _Skype_CallAnswer
; _Skype_CallStartVideoSend
; _Skype_CallStopVideoSend
; _Skype_CallStartVideoReceive
; _Skype_CallStopVideoReceive
; _Skype_CallForward
; _Skype_CallRedirectToVoicemail
;
; _Skype_ProfileGetHandle
; _Skype_ProfileGetContacts
; _Skype_ProfileSaveAvatarToFile
; _Skype_ProfileLoadAvatarFromFile
; _Skype_ProfileGetOnlineStatus
; _Skype_ProfileSetFullName
; _Skype_ProfileGetFullName
; _Skype_ProfileSetBirthday
; _Skype_ProfileGetBirthday
; _Skype_ProfileSetSex
; _Skype_ProfileGetSex
; _Skype_ProfileSetCountry
; _Skype_ProfileGetCountry
; _Skype_ProfileSetProvince
; _Skype_ProfileGetProvince
; _Skype_ProfileSetCity
; _Skype_ProfileGetCity
; _Skype_ProfileSetPhoneHome
; _Skype_ProfileGetPhoneHome
; _Skype_ProfileSetPhoneMobile
; _Skype_ProfileGetPhoneMobile
; _Skype_ProfileSetHomepage
; _Skype_ProfileGetHomepage
; _Skype_ProfileSetAbout
; _Skype_ProfileGetAbout
; _Skype_ProfileSetMoodText
; _Skype_ProfileGetMoodText
; _Skype_ProfileSetTimezone
; _Skype_ProfileGetTimezone
; _Skype_ProfileSetCallNoAnswerTimeout
; _Skype_ProfileGetCallNoAnswerTimeout
; _Skype_ProfileSetCallApplyCF
; _Skype_ProfileGetCallApplyCF
; _Skype_ProfileSetCallSendToVM
; _Skype_ProfileGetCallSendToVM
; _Skype_ProfileSetCallForwardRules
; _Skype_ProfileGetCallForwardRules
; _Skype_ProfileGetBalance
; _Skype_ProfileGetBalanceToText
; _Skype_ProfileGetIPCountry
; _Skype_ProfileGetValidatedSmsNumbers
; _Skype_ProfileSetRichMoodText
; _Skype_ProfileGetRichMoodText
; _Skype_ProfileGetLanguage
; _Skype_ProfileSetLanguage
;
; _Skype_OnEventError
; _Skype_OnEventAttachmentStatus
; _Skype_OnEventConnectionStatus
; _Skype_OnEventUserStatus
; _Skype_OnEventOnlineStatus
; _Skype_OnEventCallStatus
; _Skype_OnEventCallHistory
; _Skype_OnEventMute
; _Skype_OnEventMessageStatus
; _Skype_OnEventMessageHistory
; _Skype_OnEventAutoAway
; _Skype_OnEventCallDtmfReceived
; _Skype_OnEventVoicemailStatus
; _Skype_OnEventApplicationConnecting
; _Skype_OnEventContactsFocused
; _Skype_OnEventGroupVisible
; _Skype_OnEventGroupExpanded
; _Skype_OnEventGroupUsers
; _Skype_OnEventGroupDeleted
; _Skype_OnEventSmsMessageStatusChanged
; _Skype_OnEventSmsTargetStatusChanged
; _Skype_OnEventCallInputStatusChanged
; _Skype_OnEventAsyncSearchUsersFinished
; _Skype_OnEventCallSeenStatusChanged
; _Skype_OnEventPluginEventClicked
; _Skype_OnEventPluginMenuItemClicked
; _Skype_OnEventWallpaperChanged
; _Skype_OnEventFileTransferStatusChanged
; _Skype_OnEventCallTransferStatusChanged
; _Skype_OnEventChatMembersChanged
; _Skype_OnEventCallVideoStatusChanged
; _Skype_OnEventCallVideoSendStatusChanged
; _Skype_OnEventCallVideoReceiveStatusChanged
; _Skype_OnEventSilentModeStatusChanged
; _Skype_OnEventUILanguageChanged
; _Skype_OnEventUserAuthRequestReceived
;
; _Skype_UserGetFullName
; _Skype_UserSendMessage
; _Skype_UserGetBirthday
; _Skype_UserGetSex
; _Skype_UserGetCountry
; _Skype_UserGetProvince
; _Skype_UserGetCity
; _Skype_UserGetPhoneHome
; _Skype_UserGetPhoneMobile
; _Skype_UserGetHomepage
; _Skype_UserGetAbout
; _Skype_UserGetMoodText
; _Skype_UserGetTimezone
; _Skype_UserGetRichMoodText
; _Skype_UserGetBuddyStatus
; _Skype_UserSetBuddyStatus
; _Skype_UserGetAuthorized
; _Skype_UserSetAuthorized
; _Skype_UserGetIsBlocked
; _Skype_UserSetIsBlocked
; _Skype_UserGetDisplayName
; _Skype_UserSetDisplayName
; _Skype_UserGetOnlineStatus
; _Skype_UserGetLastOnline
; _Skype_UserGetReceivedAuthRequest
; _Skype_UserGetSpeedDial
; _Skype_UserSetSpeedDial
; _Skype_UserGetCanLeaveVoicemail
; _Skype_UserGetAliases
; _Skype_UserGetIsCallForwardActive
; _Skype_UserGetLanguage
; _Skype_UserGetLanguageCode
; _Skype_UserGetIsVideoCapable
; _Skype_UserGetIsSkypeOutContact
; _Skype_UserGetNumberOfAuthBuddies
; _Skype_UserGetIsVoicemailCapable
;
; _Skype_ConvertAttachmentStatus
; _Skype_ConvertConnectionStatus
; _Skype_ConvertUserStatus
; _Skype_ConvertCallFailureReason
; _Skype_ConvertCallStatus
; _Skype_ConvertCallType
; _Skype_ConvertCallHistory
; _Skype_ConvertCallVideoStatus
; _Skype_ConvertCallVideoSendStatus
; _Skype_ConvertCallIoDeviceType
; _Skype_ConvertChatMessageType
; _Skype_ConvertChatMemberRole
; _Skype_ConvertUserSex
; _Skype_ConvertBuddyStatus
; _Skype_ConvertOnlineStatus
; _Skype_ConvertChatLeaveReason
; _Skype_ConvertChatStatus
; _Skype_ConvertChatType
; _Skype_ConvertChatMyStatus
; _Skype_ConvertChatOptions
; _Skype_ConvertVoicemailType
; _Skype_ConvertVoicemailStatus
; _Skype_ConvertVoicemailFailureReason
; _Skype_ConvertGroupType
; _Skype_ConvertCallChannelType
; _Skype_ConvertApiSecurityContext
; _Skype_ConvertSmsMessageType
; _Skype_ConvertSmsMessageStatus
; _Skype_ConvertSmsFailureReason
; _Skype_ConvertSmsTargetStatus
; _Skype_ConvertPluginContext
; _Skype_ConvertPluginContactType
; _Skype_ConvertFileTransferType
; _Skype_ConvertFileTransferStatus
; _Skype_ConvertFileTransferFailureReason
;
; _Skype_FileTransfersGetDetails
; _Skype_FileTransfersGetActiveDetails
;
; _Skype_SMSSend
; _Skype_SMSGetDetails
; _Skype_SMSMessageDelete
;
; _Skype_ApplicationCreate
; _Skype_ApplicationDelete
;
; _Skype_CreateEvent
; _Skype_CreateMenuItem
;
; _Skype_PluginEventDelete
; _Skype_PluginMenuItemDelete
;
; _Skype_VoicemailClearHistory
; _Skype_VoicemailDelete
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __Skype_FTDetails
; __Skype_SendCommand
; __Skype_GetCommandReply
; __Skype_TimestampToDate
;
; Skype_Reply
; Skype_Error
; Skype_AttachmentStatus
; Skype_ConnectionStatus
; Skype_UserStatus
; Skype_OnlineStatus
; Skype_CallStatus
; Skype_CallHistory
; Skype_Mute
; Skype_MessageStatus
; Skype_MessageHistory
; Skype_AutoAway
; Skype_CallDtmfReceived
; Skype_VoicemailStatus
; Skype_ApplicationConnecting
; Skype_ApplicationStreams
; Skype_ApplicationDatagram
; Skype_ApplicationSending
; Skype_ApplicationReceiving
; Skype_ContactsFocused
; Skype_GroupVisible
; Skype_GroupExpanded
; Skype_GroupUsers
; Skype_GroupDeleted
; Skype_UserMood
; Skype_SmsMessageStatusChanged
; Skype_SmsTargetStatusChanged
; Skype_CallInputStatusChanged
; Skype_AsyncSearchUsersFinished
; Skype_CallSeenStatusChanged
; Skype_PluginEventClicked
; Skype_PluginMenuItemClicked
; Skype_WallpaperChanged
; Skype_FileTransferStatusChanged
; Skype_CallTransferStatusChanged
; Skype_ChatMembersChanged
; Skype_ChatMemberRoleChanged
; Skype_CallVideoStatusChanged
; Skype_CallVideoSendStatusChanged
; Skype_CallVideoReceiveStatusChanged
; Skype_SilentModeStatusChanged
; Skype_UILanguageChanged
; Skype_UserAuthorizationRequestReceived
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_Start
; Description ...: Starts the Client
; Syntax.........: _Skype_Start()
; Parameters ....: $blMinimized	- if True, Skype is minimized in the system tray
;				   $blNosplash 	- if True, Skype does not display a splash screen on start up
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_Shutdown
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_Start($blMinimized = False, $blNosplash = True)
	If Not $oSkype.Client.IsRunning Then $oSkype.Client.Start($blMinimized, $blNosplash)
EndFunc   ;==>_Skype_Start


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_Shutdown
; Description ...: Shutdowns the Client
; Syntax.........: _Skype_Shutdown()
; Parameters ....: None
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: It will shutdowns the client only if it was started
; Related .......: _Skype_Start
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_Shutdown()
	If $oSkype.Client.IsRunning Then $oSkype.Client.Shutdown()
EndFunc   ;==>_Skype_Shutdown


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_IsRunning
; Description ...: Queries if the skype client is running
; Syntax.........: _Skype_IsRunning()
; Parameters ....: None
; Return values .: Success      - Running status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_IsRunning()
	Return $oSkype.IsRunning
EndFunc   ;==>_Skype_IsRunning


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SearchForUsers
; Description ...: Search for users corresponding to a user handle
; Syntax.........: _Skype_SearchForUsers($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - Users handles (array)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SearchForUsers($sUserHandle)
	Local $oUsers2 = $oSkype.SearchForUsers($sUserHandle)
	If $oUsers2.Count = "" Then Return SetError(1, 0, 0)

	Local $aUserHandle[$oUsers2.Count], $i

	For $oUser In $oUsers2
		$aUserHandle[$i] = $oUser.Handle
		$i += 1
	Next

	Return $aUserHandle
EndFunc   ;==>_Skype_SearchForUsers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAttachmentStatus
; Description ...: Queries the attachment status of the Skype client
; Syntax.........: _Skype_GetAttachmentStatus()
; Parameters ....: None
; Return values .: Success      - TAttachmentStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAttachmentStatus()
	Return $oSkype.AttachmentStatus
EndFunc   ;==>_Skype_GetAttachmentStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConferenceCount
; Description ...: Queries the number of conferences
; Syntax.........: _Skype_ConferenceCount()
; Parameters ....: None
; Return values .: Success      - Number of conferences
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConferenceCount()
	Return $oSkype.Conferences.Count
EndFunc   ;==>_Skype_ConferenceCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_Focus
; Description ...: Sets the focus on Skype window
; Syntax.........: _Skype_Focus()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_Focus()
	$oSkype.Client.Focus

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_Focus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_BtnPressed
; Description ...: Presses the specified button
; Syntax.........: _Skype_BtnPressed($sBtn)
; Parameters ....: $sBtn		- Alphabetic or Numeric key
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_BtnReleased
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_BtnPressed($sBtn)
	$oSkype.Client.ButtonPressed($sBtn)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_BtnPressed


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_BtnReleased
; Description ...: Releases the specified button
; Syntax.........: _Skype_BtnReleased($sBtn)
; Parameters ....: $sBtn		- Alphabetic or Numeric key
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: You must call _Skype_BtnPressed before calling this function
; Related .......: _Skype_BtnPressed
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_BtnReleased($sBtn)
	$oSkype.Client.ButtonReleased($sBtn)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_BtnReleased


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConnectionStatus
; Description ...: Queries the connection status of the Skype client
; Syntax.........: _Skype_ConnectionStatus()
; Parameters ....: None
; Return values .: Success      - TConnectionStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConnectionStatus()
	Return $oSkype.ConnectionStatus
EndFunc   ;==>_Skype_ConnectionStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ResetCache
; Description ...: Deletes all cache entries
; Syntax.........: _Skype_ResetCache()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ResetCache()
	$oSkype.ResetCache

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ResetCache


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetOnlineStatus
; Description ...: Sets the online status of the current user
; Syntax.........: _Skype_ProfileSetOnlineStatus($TUserStatus)
; Parameters ....: $TUserStatus	- TUserStatus (const)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetOnlineStatus($TUserStatus)
	$oSkype.ChangeUserStatus = $TUserStatus

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetOnlineStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_Minimize
; Description ...: Minimizes Skype's window
; Syntax.........: _Skype_Minimize()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_Minimize()
	$oSkype.Client.Minimize

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_Minimize


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetMute
; Description ...: Queries the mute status of the Skype client
; Syntax.........: _Skype_GetMute()
; Parameters ....: None
; Return values .: Success      - Mute status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetMute
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetMute()
	Return $oSkype.Mute
EndFunc   ;==>_Skype_GetMute


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetMute
; Description ...: Sets the mute status of the Skype client
; Syntax.........: _Skype_SetMute()
; Parameters ....: $blMute		- Boolean value
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetMute
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetMute($blMute)
	$oSkype.Mute = $blMute

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetMute


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ResetIdleTimer
; Description ...: Resets Skype idle timer
; Syntax.........: _Skype_ResetIdleTimer()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ResetIdleTimer()
	$oSkype.Settings.ResetIdleTimer

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ResetIdleTimer


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_EnableApiSecurityContext
; Description ...: Enables an API security context for Internet Explorer scripts
; Syntax.........: _Skype_EnableApiSecurityContext($TApiSecurityContext)
; Parameters ....: $TApiSecurityContext	- TApiSecurityContext (const)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_EnableApiSecurityContext($TApiSecurityContext)
	$oSkype.EnableApiSecurityContext = $TApiSecurityContext

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_EnableApiSecurityContext


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAudioOut
; Description ...: Queries the name of an audio output device
; Syntax.........: _Skype_GetAudioOut()
; Parameters ....: None
; Return values .: Success      - Name of an audio output device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetAudioOut
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAudioOut()
	Return $oSkype.Settings.AudioOut
EndFunc   ;==>_Skype_GetAudioOut


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetAudioOut
; Description ...: Sets the name of an audio output device
; Syntax.........: _Skype_SetAudioOut($sAudioOut)
; Parameters ....: $sAudioOut	- Name of an audio output device
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetAudioOut
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetAudioOut($sAudioOut)
	$oSkype.Settings.AudioOut = $sAudioOut

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetAudioOut


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAudioIn
; Description ...: Queries the name of an audio input device
; Syntax.........: _Skype_GetAudioIn()
; Parameters ....: None
; Return values .: Success      - Name of an audio output device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetAudioIn
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAudioIn()
	Return $oSkype.Settings.AudioIn
EndFunc   ;==>_Skype_GetAudioIn


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetAudioIn
; Description ...: Sets the name of an audio input device
; Syntax.........: _Skype_SetAudioIn($sAudioIn)
; Parameters ....: $sAudioIn	- Name of an audio input device
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetAudioIn
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetAudioIn($sAudioIn)
	$oSkype.Settings.AudioIn = $sAudioIn

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetAudioIn


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetRinger
; Description ...: Queries the name of a ringer device
; Syntax.........: _Skype_GetRinger()
; Parameters ....: None
; Return values .: Success      - Name of a ringer device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetRinger
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetRinger()
	Return $oSkype.Settings.Ringer
EndFunc   ;==>_Skype_GetRinger


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetRinger
; Description ...: Sets the name of a ringer device
; Syntax.........: _Skype_SetRinger($sRinger)
; Parameters ....: $sRinger		- Name of a ringer device
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetRinger
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetRinger($sRinger)
	$oSkype.Settings.Ringer = $sRinger

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetRinger


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAutoAway
; Description ...: Queries the "Auto away" status
; Syntax.........: _Skype_GetAutoAway()
; Parameters ....: None
; Return values .: Success      - "Auto away" status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetAutoAway
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAutoAway()
	Return $oSkype.Settings.AutoAway
EndFunc   ;==>_Skype_GetAutoAway


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetAutoAway
; Description ...: Sets the "Auto away" status
; Syntax.........: _Skype_SetAutoAway($blAutoAway)
; Parameters ....: $blAutoAway	- "Auto away" status (bool)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetAutoAway
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetAutoAway($blAutoAway)
	$oSkype.Settings.AutoAway = $blAutoAway

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetAutoAway


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetRingToneStatus
; Description ...: Queries the ringtone status
; Syntax.........: _Skype_GetRingToneStatus()
; Parameters ....: None
; Return values .: Success      - RingTone status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetRingToneStatus
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetRingToneStatus()
	Return $oSkype.Settings.RingToneStatus
EndFunc   ;==>_Skype_GetRingToneStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetRingToneStatus
; Description ...: Sets the ringtone status
; Syntax.........: _Skype_SetRingToneStatus($blRingToneStatus)
; Parameters ....: $blRingToneStatus	- RingTone status (bool)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetRingToneStatus
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetRingToneStatus($blRingToneStatus)
	$oSkype.Settings.RingToneStatus = $blRingToneStatus

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetRingToneStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetVideoIn
; Description ...: Queries the name of a video input device
; Syntax.........: _Skype_GetVideoIn()
; Parameters ....: None
; Return values .: Success      - Name of a video input device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetVideoIn
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetVideoIn()
	Return $oSkype.Settings.VideoIn
EndFunc   ;==>_Skype_GetVideoIn


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetVideoIn
; Description ...: Sets the name of a video input device
; Syntax.........: _Skype_SetVideoIn($sVideoIn)
; Parameters ....: $sVideoIn	- Name of a video input device
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetVideoIn
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetVideoIn($sVideoIn)
	$oSkype.Settings.VideoIn = $sVideoIn

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetVideoIn


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetPCSpeaker
; Description ...: Queries the PC speaker status
; Syntax.........: _Skype_GetPCSpeaker()
; Parameters ....: None
; Return values .: Success      - PC speaker status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetPCSpeaker
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetPCSpeaker()
	Return $oSkype.Settings.PCSpeaker
EndFunc   ;==>_Skype_GetPCSpeaker


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetPCSpeaker
; Description ...: Sets the PC speaker status
; Syntax.........: _Skype_SetPCSpeaker($sPCSpeaker)
; Parameters ....: $sPCSpeaker	- PC speaker status (bool)
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetPCSpeaker
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetPCSpeaker($sPCSpeaker)
	$oSkype.Settings.PCSpeaker = $sPCSpeaker

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetPCSpeaker


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAGC
; Description ...: Queries the status of automatic gain control
; Syntax.........: _Skype_GetAGC()
; Parameters ....: None
; Return values .: Success      - The status of AGC (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetAGC
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAGC()
	Return $oSkype.Settings.AGC
EndFunc   ;==>_Skype_GetAGC


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetAGC
; Description ...: Queries the status of automatic gain control
; Syntax.........: _Skype_SetAGC($blAGC)
; Parameters ....: $blAGC		- The status of AGC (bool)
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetAGC
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetAGC($blAGC)
	$oSkype.Settings.AGC = $blAGC

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetAGC


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetAEC
; Description ...: Queries the status of automatic echo cancellation
; Syntax.........: _Skype_GetAEC()
; Parameters ....: None
; Return values .: Success      - The status of AEC
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetAEC
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetAEC()
	Return $oSkype.Settings.AEC
EndFunc   ;==>_Skype_GetAEC


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetAEC
; Description ...: Queries the status of automatic echo cancellation
; Syntax.........: _Skype_SetAEC($blAEC)
; Parameters ....: $blAEC		- The status of AEC (bool)
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetAEC
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetAEC($blAEC)
	$oSkype.Settings.AEC = $blAEC

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetAEC


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetLanguage
; Description ...: Queries the language of the Skype client
; Syntax.........: _Skype_GetLanguage()
; Parameters ....: None
; Return values .: Success      - The language of the Skype client
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetLanguage
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetLanguage()
	Return $oSkype.Settings.Language
EndFunc   ;==>_Skype_GetLanguage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetLanguage
; Description ...: Sets the language of the Skype client
; Syntax.........: _Skype_SetLanguage($sLanguage)
; Parameters ....: $sLanguage	- Language
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetLanguage
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetLanguage($sLanguage)
	$oSkype.Settings.Language = $sLanguage

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetLanguage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetSkypeVersion
; Description ...: Queries the application version of the Skype client
; Syntax.........: _Skype_GetSkypeVersion()
; Parameters ....: None
; Return values .: Success      - Skype version
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetSkypeVersion()
	Return $oSkype.Version
EndFunc   ;==>_Skype_GetSkypeVersion


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetProtocol
; Description ...: Queries the protocol version used by the Skype client
; Syntax.........: _Skype_GetProtocol()
; Parameters ....: None
; Return values .: Success      - Protocol version
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetProtocol
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetProtocol()
	Return $oSkype.Protocol
EndFunc   ;==>_Skype_GetProtocol


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetProtocol
; Description ...: Sets the protocol version used by the Skype client
; Syntax.........: _Skype_SetProtocol($iProtocol)
; Parameters ....: $iProtocol	- Protocol version
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetProtocol
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetProtocol($iProtocol)
	$oSkype.Protocol = $iProtocol

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetProtocol

; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetApiWrapperVersion
; Description ...: Returns API wrapper DLL version
; Syntax.........: _Skype_GetApiWrapperVersion()
; Parameters ....: None
; Return values .: Success      - API wrapper DLL version
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetApiWrapperVersion()
	Return $oSkype.ApiWrapperVersion
EndFunc   ;==>_Skype_GetApiWrapperVersion


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetSilentMode
; Description ...: Returns Skype silent mode status
; Syntax.........: _Skype_GetSilentMode($iProtocol)
; Parameters ....: None
; Return values .: Success      - Silent mode status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetSilentMode
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetSilentMode()
	Return $oSkype.SilentMode
EndFunc   ;==>_Skype_GetSilentMode


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetSilentMode
; Description ...: Returns Skype silent mode status
; Syntax.........: _Skype_GetSilentMode($iProtocol)
; Parameters ....: $blSilentMode	- Silent mode status
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetSilentMode
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetSilentMode($blSilentMode)
	$oSkype.SilentMode = $blSilentMode

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetSilentMode

; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GetCache
; Description ...: Returns the Skype's cache status
; Syntax.........: _Skype_GetCache()
; Parameters ....: None
; Return values .: Success      - Cache status (bool)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_SetCache
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GetCache()
	Return $oSkype.Cache
EndFunc   ;==>_Skype_GetCache

; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SetCache
; Description ...: Sets the Skype's cache status
; Syntax.........: _Skype_SetCache($blCacheStatus)
; Parameters ....: $blCacheStatus	- Cache status
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GetCache
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SetCache($blCacheStatus)
	$oSkype.Cache = $blCacheStatus

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SetCache

; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupCreate
; Description ...: Creates a contact group
; Syntax.........: _Skype_GroupCreate($sGroupName)
; Parameters ....: $sGroupName	- Name of the group
; Return values .: Success      - Group object
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GroupDelete
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupCreate($sGroupName)
	Local $oGroup = $oSkype.CreateGroup($sGroupName)
	If __Skype_GetCommandReply() = 0 Then Return 0

	Return $oGroup
EndFunc   ;==>_Skype_GroupCreate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupGetCount
; Description ...: Queries the group count
; Syntax.........: _Skype_GroupGetCount()
; Parameters ....: None
; Return values .: Success      - Number of groups
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupGetCount()
	Return $oSkype.Groups.Count
EndFunc   ;==>_Skype_GroupGetCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupCustomGetCount
; Description ...: Queries the custom group count
; Syntax.........: _Skype_GroupCustomGetCount()
; Parameters ....: None
; Return values .: Success      - Number of custom groups
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupCustomGetCount()
	Return $oSkype.CustomGroups.Count
EndFunc   ;==>_Skype_GroupCustomGetCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupHardwiredGetCount
; Description ...: Queries the hardwired group count
; Syntax.........: _Skype_GroupHardwiredGetCount()
; Parameters ....: None
; Return values .: Success      - Number of Hardwired groups
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupHardwiredGetCount()
	Return $oSkype.HardwiredGroups.Count
EndFunc   ;==>_Skype_GroupHardwiredGetCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupDelete
; Description ...: Deletes a contact group. Users in the contact group are moved to the All Contacts hardwired contact group
; Syntax.........: _Skype_GroupDelete($oGroup)
; Parameters ....: $oGroup		- object of a group
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GroupCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupDelete($oGroup)
	$oSkype.DeleteGroup($oGroup.Id)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_GroupDelete


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupRemoveUser
; Description ...: Removes a user to a group
; Syntax.........: _Skype_GroupRemoveUser($oGroup, $sUserHandle)
; Parameters ....: $oGroup		- object of a group
;				   $sUserHandle	- User handle to add
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GroupRemoveUser
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupRemoveUser($oGroup, $sUserHandle)
	$oGroup.RemoveUser($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_GroupRemoveUser


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupAddUser
; Description ...: Adds a user to a group
; Syntax.........: _Skype_GroupAddUser($oGroup, $sUserHandle)
; Parameters ....: $oGroup		- object of a group
;				   $sUserHandle	- User handle to add
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_GroupAddUser
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupAddUser($oGroup, $sUserHandle)
	$oGroup.AddUser($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_GroupAddUser


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupCustomGetDetails
; Description ...: Queries the custom groups details
; Syntax.........: _Skype_GroupCustomGetDetails()
; Parameters ....: None
; Return values .: Success      - Custom groups details (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: $aCustomGroups[$i][3] is an array
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupCustomGetDetails()
	Local Const $iCustomGroups = $oSkype.CustomGroups.Count
	If $iCustomGroups = 0 Then Return 0

	Local $aCustomGroups[$iCustomGroups][4]
	Local $sGroupUsers, $i = 0

	For $oGroup In $oSkype.CustomGroups
		$aCustomGroups[$i][0] = $oGroup.Id
		$aCustomGroups[$i][1] = $oGroup.DisplayName
		$aCustomGroups[$i][2] = $oGroup.Users.Count

		For $oUser In $oGroup.Users
			$sGroupUsers &= $oUser.Handle & "," & $oUser.FullName & Chr(0)
		Next
		$aCustomGroups[$i][3] = StringSplit($sGroupUsers, Chr(0))

		$i += 1
	Next

	Return $aCustomGroups
EndFunc   ;==>_Skype_GroupCustomGetDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_GroupHardwiredGetDetails
; Description ...: Queries the hardwired groups details
; Syntax.........: _Skype_GroupHardwiredGetDetails()
; Parameters ....: None
; Return values .: Success      - Hardwired groups details (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: $aHardwiredGroups[$i][3] is an array
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_GroupHardwiredGetDetails()
	Local Const $iHardwiredGroups = $oSkype.HardwiredGroups.Count
	If $iHardwiredGroups = 0 Then Return 0

	Local $aHardwiredGroups[$iHardwiredGroups][4]
	Local $sGroupUsers, $i = 0

	For $oGroup In $oSkype.HardwiredGroups
		$aHardwiredGroups[$i][0] = $oGroup.Id
		$aHardwiredGroups[$i][1] = $oGroup.Type
		$aHardwiredGroups[$i][2] = $oGroup.Users.Count

		For $oUser In $oGroup.Users
			$sGroupUsers &= $oUser.Handle & " (" & $oUser.FullName & ")" & Chr(0)
		Next
		$aHardwiredGroups[$i][3] = StringSplit($sGroupUsers, Chr(0))

		$i += 1
	Next

	Return $aHardwiredGroups
EndFunc   ;==>_Skype_GroupHardwiredGetDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenContactsTab
; Description ...: Brings the contacts tab into focus
; Syntax.........: _Skype_OpenContactsTab()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenContactsTab()
	$oSkype.Client.OpenContactsTab

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenContactsTab


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenSearchDialog
; Description ...: Opens the search contacts window
; Syntax.........: _Skype_OpenSearchDialog()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenSearchDialog()
	$oSkype.Client.OpenSearchDialog

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenSearchDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenProfileDialog
; Description ...: Opens the profile window for the current user
; Syntax.........: _Skype_OpenProfileDialog()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenProfileDialog()
	$oSkype.oSkype.Client.OpenProfileDialog

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenProfileDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenOptionsDialog
; Description ...: Opens the options window
; Syntax.........: _Skype_OpenOptionsDialog()
; Parameters ....: $sTab - Option tab to open
; Return values .: Success      - 0
;                  Failure      - 1 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The option tab must be one of the following:
;				   GENERAL; PRIVACY; NOTIFICATIONS; SOUNDALERTS; SOUNDDEVICES; HOTKEYS; CONNECTION; VOICEMAIL; CALLFORWARD;
;				   VIDEO; ADVANCED
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenOptionsDialog($sTab = "GENERAL")
	$oSkype.Client.OpenOptionsDialog($sTab)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenOptionsDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenUserInfoDialog
; Description ...: Opens a user's information window
; Syntax.........: _Skype_OpenUserInfoDialog($sUserHandle)
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenUserInfoDialog($sUserHandle)
	$oSkype.Client.OpenUserInfoDialog($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenUserInfoDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenMessageDialog
; Description ...: Opens an instant message window and writes a message
; Syntax.........: _Skype_OpenMessageDialog($sUserHandle, $sMessage)
; Parameters ....: $sUserHandle	- Name/handle of the user
;				   $sMessage	- Message to write
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenMessageDialog($sUserHandle, $sMessage)
	$oSkype.Client.OpenMessageDialog($sUserHandle, $sMessage)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenMessageDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenFileTransfer
; Description ...: Opens a filedialog to send a file to a user
; Syntax.........: _Skype_OpenFileTransfer($sUserHandle, $sInFolder = @MyDocumentsDir)
; Parameters ....: $sUserHandle	- Name/handle of the user
;				   $sInFolder	- Folder to open
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_OpenFileTransfer($sUserHandle, $sInFolder = @MyDocumentsDir)
	Return __Skype_SendCommand("OPEN FILETRANSFER " & $sUserHandle & " IN " & $sInFolder)
EndFunc   ;==>_Skype_OpenFileTransfer


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenLiveTab
; Description ...: Brings the Live tab into focus
; Syntax.........: _Skype_OpenLiveTab()
; Parameters ....: None
; Return values .: Success      - 0
;                  Failure      - 1 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenLiveTab()
	$oSkype.Client.OpenLiveTab

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenLiveTab


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenDialPadTab
; Description ...: Brings the dialpad tab into focus
; Syntax.........: _Skype_OpenDialPadTab()
; Parameters ....: None
; Return values .: Success      - 0
;                  Failure      - 1 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenDialPadTab()
	$oSkype.Client.OpenDialpadTab

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenDialPadTab


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenChat
; Description ...: Opens a user's chat
; Syntax.........: _Skype_OpenChat($sUserHandle)
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenChat($sUserHandle)
	Return __Skype_SendCommand("OPEN CHAT " & $sUserHandle)
EndFunc   ;==>_Skype_OpenChat


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenCallHistoryTab
; Description ...: Brings the call history tab into focus
; Syntax.........: _Skype_OpenCallHistoryTab()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenCallHistoryTab()
	$oSkype.Client.OpenCallHistoryTab

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenCallHistoryTab


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenSendContactsDialog
; Description ...: Opens the "SendContact" Dialog to send [a] contact(s) to a user
; Syntax.........: _Skype_OpenSendContactsDialog($sUserHandle)
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenSendContactsDialog($sUserHandle)
	$oSkype.Client.OpenSendContactsDialog($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenSendContactsDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenAuthorizationDialog
; Description ...: Opens the "Authorization" Dialog
; Syntax.........: _Skype_OpenSendContactsDialog($sUserHandle)
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenAuthorizationDialog($sUserHandle)
	$oSkype.Client.OpenAuthorizationDialog($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenAuthorizationDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenBlockedUsersDialog
; Description ...: Opens the "BlockedUsers" Dialog
; Syntax.........: _Skype_OpenBlockedUsersDialog()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenBlockedUsersDialog()
	$oSkype.Client.OpenBlockedUsersDialog

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenBlockedUsersDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenImportContactsWizard
; Description ...: Opens the "ImportContacts" Wizard
; Syntax.........: _Skype_OpenImportContactsWizard()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenImportContactsWizard()
	$oSkype.Client.OpenImportContactsWizard

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenImportContactsWizard


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenGettingStartedWizard
; Description ...: Opens the "GettingStarted" Wizard
; Syntax.........: _Skype_OpenGettingStartedWizard()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenGettingStartedWizard()
	$oSkype.Client.OpenGettingStartedWizard

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenGettingStartedWizard


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenVideoTestDialog
; Description ...: Opens the "VideoTest" Dialog
; Syntax.........: _Skype_OpenVideoTestDialog()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenVideoTestDialog()
	$oSkype.Client.OpenVideoTestDialog

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenVideoTestDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenConferenceDialog
; Description ...: Opens the "Conference" Dialog
; Syntax.........: _Skype_OpenConferenceDialog()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenConferenceDialog()
	$oSkype.Client.OpenConferenceDialog

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_OpenConferenceDialog


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OpenAddAFriend
; Description ...: Opens the "AddAFriend" Dialog to add a friend
; Syntax.........: _Skype_OpenAddAFriend()
; Parameters ....: $sUserHandle	- User handle to add
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OpenAddAFriend($sUserHandle = "")
	Return __Skype_SendCommand("OPEN ADDAFRIEND " & $sUserHandle)
EndFunc   ;==>_Skype_OpenAddAFriend


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatCreate
; Description ...: Creates a chat
; Syntax.........: _Skype_ChatCreate()
; Parameters ....: $sUserHandle	- User handle to create chat with
; Return values .: Success      - Chat id
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatCreate($sUserHandle)
	Local Const $aChatId = StringRegExp(__Skype_SendCommand("CHAT CREATE " & $sUserHandle), "#(.*?)\s", 1)
	If Not IsArray($aChatId) Then Return 0
	Return "#" & $aChatId[0]
EndFunc   ;==>_Skype_ChatCreate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatCreateWith
; Description ...: Creates a chat with a single user
; Syntax.........: _Skype_ChatCreateWith($sUserHandle)
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - Chat object
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateMultiple
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatCreateWith($sUserHandle)
	Return $oSkype.CreateChatWith($sUserHandle)
EndFunc   ;==>_Skype_ChatCreateWith


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAddMembers
; Description ...: Adds new members to a chat
; Syntax.........: _Skype_ChatAddMembers($sMembers)
; Parameters ....: $oChat		- Chat object
;				   $sMembers	- Member(s) to add [separated by "|"]
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAddMembers($oChat, $sMembers)
	Local Const $aMembers = StringSplit($sMembers, "|")

	If $aMembers[0] > 1 Then
		For $i = 1 To $aMembers[0]
			$oUsers.Add($oSkype.User($aMembers[$i]))
		Next
	Else
		$oUsers.Add($oSkype.User($sMembers))
	EndIf

	Local Const $sReturn = $oChat.AddMembers($oUsers)
	$oUsers.RemoveAll

	Return $sReturn
EndFunc   ;==>_Skype_ChatAddMembers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessage
; Description ...: Sends a message to a chat
; Syntax.........: _Skype_ChatMessage($iChatId, $sMessage)
; Parameters ....: $iChatId		- Chat id
;				   $sMessage	- Message to send
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatMessage($iChatId, $sMessage)
	Return __Skype_SendCommand("CHATMESSAGE " & $iChatId & " " & $sMessage)
EndFunc   ;==>_Skype_ChatMessage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAllGetMessagesDetails
; Description ...:	Gets all chats's messages datails of the user
; Syntax.........: _Skype_ChatAllGetMessagesDetails($sUserHandle = "all")
; Parameters ....: $sUserHandle	- Name/handle of the user
; Return values .: Success      - Messages and it's details (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: $aChatMessages[$i][0] returns an array
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAllGetMessagesDetails($sUserHandle = "all")
	Local Const $iChatCount = $oSkype.Chats.Count
	If $iChatCount = 0 Then Return 0

	Local $blGetMessages = False, $sTime = "", $sMsg = "", $sChatUsers = ""
	Local $aChatMessages[$iChatCount][4], $i = 0

	For $oChat In $oSkype.Chats
		For $oUser In $oChat.Members
			$sChatUsers &= $oUser.Handle & Chr(0)

			If ($oUser.Handle = $sUserHandle) Then $blGetMessages = True
		Next
		$aChatMessages[$i][0] = StringSplit($sChatUsers, Chr(0))

		If $blGetMessages Or ($sUserHandle = "all") Then
			For $oMsg In $oChat.Messages
				If ($oMsg.Body <> "") Then
					$aChatMessages[$i][1] = __Skype_TimestampToDate($oMsg.Timestamp)
					$aChatMessages[$i][2] = $oMsg.FromDisplayName
					$aChatMessages[$i][3] = $oMsg.Body
				EndIf
			Next
		EndIf

		$i += 1
	Next

	Return $aChatMessages
EndFunc   ;==>_Skype_ChatAllGetMessagesDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatEnterPassword
; Description ...: Enters chat password
; Syntax.........: _Skype_ChatEnterPassword($sPassword)
; Parameters ....: $oChat		- object of the chat
;				   $sPassword	- Password of the Chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetPassword, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatEnterPassword($oChat, $sPassword)
	$oChat.EnterPassword($sPassword)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatEnterPassword


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatKickBan
; Description ...: Kicks and ban member from chat
; Syntax.........: _Skype_ChatKickBan($oChat, $sUserHandle)
; Parameters ....: $oChat		- object of the chat
;				   $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatKick, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatKickBan($oChat, $sUserHandle)
	$oChat.KickBan($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatKickBan


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatKick
; Description ...: Kicks member from chat
; Syntax.........: _Skype_ChatKick($oChat, $sUserHandle)
; Parameters ....: $oChat		- object of the chat
;				   $sUserHandle	- Name/handle of the user
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatKickBan, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatKick($oChat, $sUserHandle)
	$oChat.Kick($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatKick


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatBookmark
; Description ...: Bookmarks a chat
; Syntax.........: _Skype_ChatBookmark($oChat)
; Parameters ....: $oChat		- object of the chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatUnbookmark, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatBookmark($oChat)
	$oChat.Bookmark

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatBookmark


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatUnbookmark
; Description ...: Removes the bookmark for a chat
; Syntax.........: _Skype_ChatUnbookmark($oChat)
; Parameters ....: $oChat		- object of the chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatBookmark, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatUnbookmark($oChat)
	$oChat.Unbookmark

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatUnbookmark


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSetPassword
; Description ...: Sets chat password
; Syntax.........: _Skype_ChatSetPassword($oChat, $sPassword)
; Parameters ....: $oChat		- object of the chat
;				   $sPassword	- Password of the Chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatEnterPassword, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetPassword($oChat, $sPassword)
	$oChat.SetPassword = $sPassword

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetPassword


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetTopic
; Description ...: Queries a chat topic
; Syntax.........: _Skype_ChatGetTopic($oChat)
; Parameters ....: $oChat		- object of the chat
; Return values .: Success      - Topic
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetTopic, _Skype_ChatAlterSetTopic, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetTopic($oChat)
	Return $oChat.Topic
EndFunc   ;==>_Skype_ChatGetTopic


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSetTopic
; Description ...: Sets a chat topic
; Syntax.........: _Skype_ChatSetTopic($oChat, $sTopic)
; Parameters ....: $oChat		- object of the chat
;				   $sTopic		- Topic
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatGetTopic, _Skype_ChatAlterSetTopic, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetTopic($oChat, $sTopic)
	$oChat.Topic = $sTopic

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetTopic


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatOpenWindow
; Description ...: Opens a chat window
; Syntax.........: _Skype_ChatOpenWindow($oChat)
; Parameters ....: $oChat		- object of the chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatOpenWindow($oChat)
	$oChat.OpenWindow

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatOpenWindow


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSendMessage
; Description ...: Sends a chat message
; Syntax.........: _Skype_ChatSendMessage($oChat, $sMessage)
; Parameters ....: $oChat		- object of the chat
;				   $sMessage	- Message to send
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatMessage, _Skype_ChatCreateWith
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatSendMessage($oChat, $sMessage)
	$oChat.SendMessage($sMessage)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSendMessage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatLeave
; Description ...: Leaves a chat
; Syntax.........: _Skype_ChatLeave($oChat)
; Parameters ....: $oChat		- object of the chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatAlterLeave, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatLeave($oChat)
	$oChat.Leave

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatLeave


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAlterRemoveUsers
; Description ...: Removes [a] user(s) from a chat
; Syntax.........: _Skype_ChatAlterRemoveUsers($iChatId, $sUserHandle)
; Parameters ....: $iChatId		- Id of the chat
;				   $sUserHandle	- User(s) to remove [separated by "|"]
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatAlterAddUsers, _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAlterRemoveUsers($iChatId, $sUserHandle)
	Local $aUsers = StringSplit($sUserHandle, "|")

	If $aUsers[0] > 1 Then
		For $i = 1 To $aUsers[0]
			If Not __Skype_SendCommand("ALTER GROUP " & $iChatId & " REMOVEUSER " & $aUsers[$i]) Then Return 0
		Next
	Else
		If Not __Skype_SendCommand("ALTER GROUP " & $iChatId & " REMOVEUSER " & $sUserHandle) Then Return 0
	EndIf

	Return 1
EndFunc   ;==>_Skype_ChatAlterRemoveUsers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAlterAddUsers
; Description ...: Add [a] user(s) from a chat
; Syntax.........: _Skype_ChatAlterAddUsers($iChatId, $sUserHandle)
; Parameters ....: $iChatId		- Id of the chat
;				   $sUserHandle	- User(s) to add [separated by "|"]
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatAlterRemoveUsers, _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAlterAddUsers($iChatId, $sUserHandle)
	Local $aUsers = StringSplit($sUserHandle, "|")

	If $aUsers[0] > 1 Then
		For $i = 1 To $aUsers[0]
			If Not __Skype_SendCommand("ALTER GROUP " & $iChatId & " ADDUSER " & $aUsers[$i]) Then Return 0
		Next
	Else
		If Not __Skype_SendCommand("ALTER GROUP " & $iChatId & " ADDUSER " & $sUserHandle) Then Return 0
	EndIf

	Return 1
EndFunc   ;==>_Skype_ChatAlterAddUsers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAlterSetTopic
; Description ...: Queries a chat topic
; Syntax.........: _Skype_ChatAlterSetTopic($iChatId, $sTopic)
; Parameters ....: $iChatId		- Id of the chat
;				   $sUserHandle	- Topic
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetTopic, _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAlterSetTopic($iChatId, $sTopic)
	Return __Skype_SendCommand("ALTER CHAT " & $iChatId & " SETTOPIC " & $sTopic)
EndFunc   ;==>_Skype_ChatAlterSetTopic


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAlterLeave
; Description ...: Leaves a chat
; Syntax.........: _Skype_ChatAlterLeave($iChatId)
; Parameters ....: $iChatId		- Id of the chat
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatLeave, _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAlterLeave($iChatId)
	Return __Skype_SendCommand("ALTER CHAT " & $iChatId & " LEAVE")
EndFunc   ;==>_Skype_ChatAlterLeave


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatAlterAddMembers
; Description ...: Adds member(s) to a chat
; Syntax.........: _Skype_ChatAlterAddMembers($iChatId, $sMembers)
; Parameters ....: $iChatId		- Id of the chat
;				   $sMembers	- Member(s) to add
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAlterAddMembers($iChatId, $sMembers)
	Local $aMembers = StringSplit($sMembers, "|")

	If $aMembers[0] > 1 Then
		For $i = 1 To $aMembers[0]
			If Not __Skype_SendCommand("ALTER CHAT " & $iChatId & " ADDMEMBERS " & $aMembers[$i]) Then Return 0
		Next
	Else
		If Not __Skype_SendCommand("ALTER CHAT " & $iChatId & " ADDMEMBERS " & $sMembers) Then Return 0
	EndIf
EndFunc   ;==>_Skype_ChatAlterAddMembers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatCreateMultiple
; Description ...: Creates a chat with [a] member(s)
; Syntax.........: _Skype_ChatCreateMultiple($sMembers)
; Parameters ....: $sMembers	- Member(s) to add
; Return values .: Success      - Chat object
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatCreateMultiple($sMembers)
	Local $aMembers = StringSplit($sMembers, "|")

	If $aMembers[0] > 1 Then
		For $i = 1 To $aMembers[0]
			$oUsers.Add($oSkype.User($aMembers[$i]))
		Next
	Else
		$oUsers.Add($oSkype.User($sMembers))
	EndIf

	Local $oChat = $oSkype.CreateChatMultiple($oUsers)
	If __Skype_GetCommandReply() = 0 Then Return 0
	$oUsers.RemoveAll

	Return $oChat
EndFunc   ;==>_Skype_ChatCreateMultiple


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatDisband
; Description ...: Ends a chat
; Syntax.........: _Skype_ChatDisband($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatDisband($oChat)
	$oChat.Disband

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatDisband


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatDisband
; Description ...: Accepts shared group add
; Syntax.........: _Skype_ChatAcceptAdd($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatAcceptAdd($oChat)
	$oChat.AcceptAdd

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatAcceptAdd


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatClearRecentMessages
; Description ...: Clears recent chat messages
; Syntax.........: _Skype_ChatClearRecentMessages($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatClearRecentMessages($oChat)
	$oChat.ClearRecentMessages

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatClearRecentMessages


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetName
; Description ...: Queries the chat name
; Syntax.........: _Skype_ChatGetName($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat name
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetName($oChat)
	Return $oChat.Name
EndFunc   ;==>_Skype_ChatGetName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetMessages
; Description ...: Queries chat messages
; Syntax.........: _Skype_ChatGetMessages($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat messages (array)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetMessages($oChat)
	Local $sChatMessages = "", $aChatMessages = 0

	For $oMsg In $oChat.Messages
		If ($oMsg.Body <> "") Then
			$sChatMessages &= $oMsg.Body & Chr(0)
		EndIf
	Next

	$aChatMessages = StringSplit($sChatMessages, Chr(0))
	If $aChatMessages[0] > 1 Then Return $aChatMessages

	Return 0
EndFunc   ;==>_Skype_ChatGetMessages


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetDate
; Description ...: Queries the chat date
; Syntax.........: _Skype_ChatGetDate($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat date
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetDate($oChat)
	Return __Skype_TimestampToDate($oChat.Timestamp)
EndFunc   ;==>_Skype_ChatGetDate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetAdder
; Description ...: Queries who added a user to a chat
; Syntax.........: _Skype_ChatGetAdder($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat adder
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetAdder($oChat)
	Return $oChat.Adder
EndFunc   ;==>_Skype_ChatGetAdder


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetStatus
; Description ...: Queries a chat status
; Syntax.........: _Skype_ChatGetStatus($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat status
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetStatus($oChat)
	Return $oChat.Status
EndFunc   ;==>_Skype_ChatGetStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetMembers
; Description ...: Queries the members of a chat
; Syntax.........: _Skype_ChatGetMembers($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat members
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatGetMembers($oChat)
	Local $sChatMembers = "", $aChatMembers = 0

	For $oUser In $oChat.Members
		If ($oUser.Handle <> "") Then
			$sChatMembers &= $oUser.Handle & Chr(0)
		EndIf
	Next

	$aChatMembers = StringSplit($sChatMembers, Chr(0))
	If $aChatMembers[0] > 1 Then Return $aChatMembers

	Return 0
EndFunc   ;==>_Skype_ChatGetMembers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetMyStatus
; Description ...: Queries my chat status
; Syntax.........: _Skype_ChatGetMyStatus($oChat)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - My chat status
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetMyStatus($oChat)
	Return $oChat.MyStatus
EndFunc   ;==>_Skype_ChatGetMyStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetType
; Description ...: Queries a chat type
; Syntax.........: _Skype_ChatGetType($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat type
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetType($oChat)
	Return $oChat.Type
EndFunc   ;==>_Skype_ChatGetType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSetAlertString
; Description ...: Sets chat alert string
; Syntax.........: _Skype_ChatSetAlertString($oCall)
; Parameters ....: $oChat		- Chat object
;				   $sAlert		- Alert
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetAlertString($oChat, $sAlert)
	$oChat.AlertString = $sAlert

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetAlertString


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetDialogPartner
; Description ...: Queries a chat dialog partner
; Syntax.........: _Skype_ChatGetDialogPartner($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat dialog partner
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetDialogPartner($oChat)
	Return $oChat.DialogPartner
EndFunc   ;==>_Skype_ChatGetDialogPartner


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatPasswordHint
; Description ...: Queries a chat password hint
; Syntax.........: _Skype_ChatPasswordHint($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat password hint
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatPasswordHint($oChat)
	Return $oChat.PasswordHint
EndFunc   ;==>_Skype_ChatPasswordHint


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetActivityDate
; Description ...: Queries a chat activity date
; Syntax.........: _Skype_ChatGetActivityDate($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat activity date
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetActivityDate($oChat)
	Return __Skype_TimestampToDate($oChat.ActivityTimestamp)
EndFunc   ;==>_Skype_ChatGetActivityDate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetDescription
; Description ...: Queries a chat description
; Syntax.........: _Skype_ChatGetDescription($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat description
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetDescription, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetDescription($oChat)
	Return $oChat.Description
EndFunc   ;==>_Skype_ChatGetDescription


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetDescription
; Description ...: Sets a chat description
; Syntax.........: _Skype_ChatSetDescription($oCall)
; Parameters ....: $oChat			- Chat object
;				   $sDescription	- Description
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatGetDescription, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetDescription($oChat, $sDescription)
	$oChat.Description = $sDescription

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetDescription


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetGuideLines
; Description ...: Queries a chat guidelines
; Syntax.........: _Skype_ChatGetGuideLines($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat guidelines
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetGuideLines, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetGuideLines($oChat)
	Return $oChat.GuideLines
EndFunc   ;==>_Skype_ChatGetGuideLines


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSetGuideLines
; Description ...: Sets a chat guidelines
; Syntax.........: _Skype_ChatSetGuideLines($oCall)
; Parameters ....: $oChat		- Chat object
;				   $sGuideLines	- Guidelines
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatGetGuideLines, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetGuideLines($oChat, $sGuideLines)
	$oChat.GuideLines = $sGuideLines

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetGuideLines


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetTopicXML
; Description ...: Queries chat topic in XML format
; Syntax.........: _Skype_ChatGetTopicXML($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat topic
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatSetTopicXML, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetTopicXML($oChat)
	Return $oChat.TopicXML
EndFunc   ;==>_Skype_ChatGetTopicXML


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatSetTopicXML
; Description ...: Sets chat topic in XML format
; Syntax.........: _Skype_ChatSetTopicXML($oCall, $sTopicXML)
; Parameters ....: $oChat		- Chat object
;				   $sTopicXML	- Topic
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatGetTopicXML, _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatSetTopicXML($oChat, $sTopicXML)
	$oChat.TopicXML = $sTopicXML

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatSetTopicXML


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetFriendlyName
; Description ...: Queries the "friendly" name of a chat
; Syntax.........: _Skype_ChatGetFriendlyName($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat FriendlyName
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetFriendlyName($oChat)
	Return $oChat.FriendlyName
EndFunc   ;==>_Skype_ChatGetFriendlyName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetBlob
; Description ...: Queries a chat blob
; Syntax.........: _Skype_ChatGetBlob($oCall)
; Parameters ....: $oChat		- Chat object
; Return values .: Success      - Chat blob
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ChatCreateWith
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetBlob($oChat)
	Return $oChat.Blob
EndFunc   ;==>_Skype_ChatGetBlob


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessageGetBody
; Description ...: Queries the message body
; Syntax.........: _Skype_ChatMessageGetBody($oMsg)
; Parameters ....: $oMsg		- Message object
; Return values .: Success      - Message body
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatMessageGetBody($oMsg)
	Return $oMsg.Body
EndFunc   ;==>_Skype_ChatMessageGetBody


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessageGetId
; Description ...: Queries the message Id
; Syntax.........: _Skype_ChatMessageGetId($oMsg)
; Parameters ....: $oMsg		- Message object
; Return values .: Success      - Message Id
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatMessageGetId($oMsg)
	Return $oMsg.Id
EndFunc   ;==>_Skype_ChatMessageGetId


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessageGetFromHandle
; Description ...: Queries the message from userhandle
; Syntax.........: _Skype_ChatMessageGetFromHandle($oMsg)
; Parameters ....: $oMsg		- Message object
; Return values .: Success      - Message from userhandle
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatMessageGetFromHandle($oMsg)
	Return $oMsg.FromHandle
EndFunc   ;==>_Skype_ChatMessageGetFromHandle


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessageGetDate
; Description ...: Queries the message date
; Syntax.........: _Skype_ChatMessageGetDate($oMsg)
; Parameters ....: $oMsg		- Message object
; Return values .: Success      - Message date
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatMessageGetDate($oMsg)
	Return __Skype_TimestampToDate($oMsg.Timestamp)
EndFunc   ;==>_Skype_ChatMessageGetDate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatMessageGetType
; Description ...: Queries the message type
; Syntax.........: _Skype_ChatMessageGetType($oMsg)
; Parameters ....: $oMsg		- Message object
; Return values .: Success      - Message type
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatMessageGetType($oMsg)
	Return $oMsg.Type
EndFunc   ;==>_Skype_ChatMessageGetType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetAll
; Description ...: Queries chats objects
; Syntax.........: _Skype_ChatGetAll()
; Parameters ....: None
; Return values .: Success      - Chats objects
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......: lionfaggot
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetAll()
	Local Const $iChatCount = $oSkype.Chats.Count
	If $iChatCount = 0 Then Return 0

	Local $aChats[$iChatCount], $i = 0

	For $oChat In $oSkype.Chats
		If $i > $aChats[0] Then ExitLoop

		$aChats[$i] = $oChat
		$i += 1
	Next

	Return $aChats
EndFunc   ;==>_Skype_ChatGetAll


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetAllActive
; Description ...: Queries all active chat objects
; Syntax.........: _Skype_ChatGetAllActive()
; Parameters ....: None
; Return values .: Success      - Active chat objects (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ChatGetAllActive()
	Local Const $iChatCount = $oSkype.ActiveChats.Count
	If $iChatCount = 0 Then Return 0

	Local $aChats[$iChatCount], $i = 0

	For $oChat In $oSkype.ActiveChats
		$aChats[$i] = $oChat
		$i += 1
	Next

	Return $aChats
EndFunc   ;==>_Skype_ChatGetAllActive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetMissed
; Description ...: Queries missed chats objects
; Syntax.........: _Skype_ChatGetMissed()
; Parameters ....: None
; Return values .: Success      - Missed chats objects
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetMissed()
	Local $iChatCount = $oSkype.MissedChats.Count
	If $iChatCount = 0 Then Return 0

	Local $aChats[$iChatCount], $i = 0

	For $oChat In $oSkype.MissedChats
		$aChats[$i] = $oChat
		$i += 1
	Next

	Return $aChats
EndFunc   ;==>_Skype_ChatGetMissed


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetRecent
; Description ...: Queries recent chats objects
; Syntax.........: _Skype_ChatGetRecent()
; Parameters ....: None
; Return values .: Success      - Recent chats objects
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetRecent()
	Local Const $iChatCount = $oSkype.RecentChats.Count
	If $iChatCount = 0 Then Return 0

	Local $aChats[$iChatCount], $i = 0

	For $oChat In $oSkype.RecentChats
		$aChats[$i] = $oChat
		$i += 1
	Next

	Return $aChats
EndFunc   ;==>_Skype_ChatGetRecent


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatGetBookmarked
; Description ...: Queries bookmarked chat objects
; Syntax.........: _Skype_ChatGetBookmarked()
; Parameters ....: None
; Return values .: Success      - Bookmarked chats objects
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatGetBookmarked()
	Local $iChatCount = $oSkype.BookmarkedChats.Count
	If $iChatCount = 0 Then Return 0

	Local $aChats[$iChatCount], $i = 0

	For $oChat In $oSkype.BookmarkedChats
		$aChats[$i] = $oChat
		$i += 1
	Next

	Return $aChats
EndFunc   ;==>_Skype_ChatGetBookmarked


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ChatClearHistory
; Description ...: Clears chat history
; Syntax.........: _Skype_ClearChatHistory()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ChatClearHistory()
	$oSkype.ClearChatHistory

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ChatClearHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallCreate
; Description ...: Places a call to a single user or creates a conference call
; Syntax.........: _Skype_CallCreate($sUserHandle1, $sUserHandle2, $sUserHandle3, $sUserHandle4)
; Parameters ....: $sUsersHandles	- Name/handle of the user
; Return values .: Success      - Call object
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: It will fail if the user is offline
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallCreate($sUserHandle1, $sUserHandle2 = "", $sUserHandle3 = "", $sUserHandle4 = "")
	Return $oSkype.PlaceCall($sUserHandle1, $sUserHandle2, $sUserHandle3, $sUserHandle4)
EndFunc   ;==>_Skype_CallCreate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetActiveCount
; Description ...: Queries the number of active calls
; Syntax.........: _Skype_CallGetActiveCount()
; Parameters ....: None
; Return values .: Success      - Number of active calls
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetActiveCount()
	Return $oSkype.ActiveCalls.Count
EndFunc   ;==>_Skype_CallGetActiveCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetActive
; Description ...: Queries the active call object
; Syntax.........: _Skype_CallActiveGetMembers()
; Parameters ....: None
; Return values .: Success      - Active call object
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetActive()
	Local Const $iCallCount = $oSkype.ActiveCalls.Count
	If $iCallCount = 0 Then Return 0

	Local $aCalls[$iCallCount], $i = 0

	For $oCall In $oSkype.ActiveCalls
		$aCalls[$i] = $oCall
		$i += 1
	Next

	Return $aCalls
EndFunc   ;==>_Skype_CallGetActive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallActiveGetMembers
; Description ...: Queries the members of the active call
; Syntax.........: _Skype_CallActiveGetMembers()
; Parameters ....: None
; Return values .: Success      - Members handles of the active call
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallActiveGetMembers()
	Local $sMembers = ""

	For $oCall In $oSkype.ActiveCalls
		$sMembers &= $oCall.PartnerHandle & Chr(0)
	Next

	Return StringSplit($sMembers, Chr(0))
EndFunc   ;==>_Skype_CallActiveGetMembers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetStatus
; Description ...: Queries a call status
; Syntax.........: _Skype_CallGetStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallGetStatus($oCall)
	Return $oCall.Status
EndFunc   ;==>_Skype_CallGetStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetStatus
; Description ...: Sets a call status
; Syntax.........: _Skype_CallSetStatus($oCall, $sStatus)
; Parameters ....: $oCall		- Call object
;				   $TCallStatus	- TCallStatus (const)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetStatus($oCall, $TCallStatus)
	$oCall.Status = $TCallStatus

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetId
; Description ...: Queries the call ID
; Syntax.........: _Skype_CallGetId($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call ID
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetId($oCall)
	Return $oCall.Id
EndFunc   ;==>_Skype_CallGetId


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetDate
; Description ...: Queries the call date
; Syntax.........: _Skype_CallGetDate($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call date
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetDate($oCall)
	Return __Skype_TimestampToDate($oCall.Timestamp)
EndFunc   ;==>_Skype_CallGetDate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetConferenceId
; Description ...: Queries a call conference ID
; Syntax.........: _Skype_CallGetConferenceId($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call conference Id
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetConferenceId($oCall)
	Return $oCall.ConferenceId
EndFunc   ;==>_Skype_CallGetConferenceId


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetType
; Description ...: Queries a call type
; Syntax.........: _Skype_CallGetType($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallType (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetType($oCall)
	Return $oCall.Type
EndFunc   ;==>_Skype_CallGetType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetFailureReason
; Description ...: Queries a call failure reason
; Syntax.........: _Skype_CallGetFailureReason($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallFailureReason (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetFailureReason($oCall)
	Return $oCall.FailureReason
EndFunc   ;==>_Skype_CallGetFailureReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetSubject
; Description ...: Queries the subject of a call
; Syntax.........: _Skype_CallGetSubject($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call subject
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetSubject($oCall)
	Return $oCall.Subject
EndFunc   ;==>_Skype_CallGetSubject


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetPstnNumber
; Description ...: Queries the PSTN number of a call
; Syntax.........: _Skype_CallGetPstnNumber($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call pstn number
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetPstnNumber($oCall)
	Return $oCall.PstnNumber
EndFunc   ;==>_Skype_CallGetPstnNumber


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetDuration
; Description ...: Queries the duration of a call
; Syntax.........: _Skype_CallGetDuration($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call duration
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetDuration($oCall)
	Return $oCall.Duration
EndFunc   ;==>_Skype_CallGetDuration


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetPstnStatus
; Description ...: Queries the call PSTN status
; Syntax.........: _Skype_CallGetPstnStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call pstn status
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetPstnStatus($oCall)
	Return $oCall.PstnStatus
EndFunc   ;==>_Skype_CallGetPstnStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetSeen
; Description ...: Queries the call to a status of seen
; Syntax.........: _Skype_CallGetSeen($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Status of seen (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetSeen($oCall)
	Return $oCall.Seen
EndFunc   ;==>_Skype_CallGetSeen


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetSeen
; Description ...: Sets the call to a status of seen
; Syntax.........: _Skype_CallSetSeen($oCall, $blSeen)
; Parameters ....: $oCall		- Call object
;				   $blSeen		- Seen status (bool)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetSeen($oCall, $blSeen)
	$oCall.Seen = $blSeen

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetSeen


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetDTMF
; Description ...: Sends a DTMF tone
; Syntax.........: _Skype_CallSetDTMF($oCall, $sDTMF)
; Parameters ....: $oCall		- Call object
;				   $sDTMF		- DTMF tone
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: DTMF tone must be one of the following:
;				   0; 1; 2; 3; 4; 5; 6; 7; 8; 9; #; *
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetDTMF($oCall, $sDTMF)
	$oCall.DTMF = $sDTMF

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetDTMF


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetParticipantsCount
; Description ...: Queries the number of participants in a conference call
; Syntax.........: _Skype_CallGetParticipantsCount($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Participants count
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetParticipantsCount($oCall)
	Return $oCall.Participants.Count
EndFunc   ;==>_Skype_CallGetParticipantsCount


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetParticipants
; Description ...: Queries the participants details in a conference call
; Syntax.........: _Skype_CallGetParticipants($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Participants handles (array)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetParticipants($oCall)
	Local $sUsersHandles = ""

	For $oParticipant In $oCall.Participants
		$sUsersHandles &= $oParticipant.Handle & Chr(0)
	Next

	Return StringSplit($sUsersHandles, Chr(0))
EndFunc   ;==>_Skype_CallGetParticipants


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetVideoStatus
; Description ...: Queries call video status
; Syntax.........: _Skype_CallGetVideoStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallVideoStatusToText (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetVideoStatus($oCall)
	Return $oCall.VideoStatus
EndFunc   ;==>_Skype_CallGetVideoStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetVideoSendStatus
; Description ...: Queries call video send status
; Syntax.........: _Skype_CallGetVideoSendStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallVideoSendStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetVideoSendStatus($oCall)
	Return $oCall.VideoStatus
EndFunc   ;==>_Skype_CallGetVideoSendStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetVideoReceiveStatus
; Description ...: Queries call video receive status
; Syntax.........: _Skype_CallGetVideoReceiveStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallVideoSendStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetVideoReceiveStatus($oCall)
	Return $oCall.VideoReceiveStatus
EndFunc   ;==>_Skype_CallGetVideoReceiveStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetRate
; Description ...: Queries the call rate, expressed in cents
; Syntax.........: _Skype_CallGetRate($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call rate
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetRate($oCall)
	Return $oCall.Rate
EndFunc   ;==>_Skype_CallGetRate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetRateCurrency
; Description ...: Queries currency code for the call rate
; Syntax.........: _Skype_CallGetRateCurrency($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call currency code
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetRateCurrency($oCall)
	Return $oCall.RateCurrency
EndFunc   ;==>_Skype_CallGetRateCurrency


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetRatePrecision
; Description ...: Queries the call rate precision
; Syntax.........: _Skype_CallGetRatePrecision($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call rate precision
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetRatePrecision($oCall)
	Return $oCall.RatePrecision
EndFunc   ;==>_Skype_CallGetRatePrecision


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetInputDevice
; Description ...: Queries the input sound device
; Syntax.........: _Skype_CallGetInputDevice($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Input sound device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetInputDevice($oCall)
	Return $oCall.InputDevice
EndFunc   ;==>_Skype_CallGetInputDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetInputDevice
; Description ...: Sets the input sound device
; Syntax.........: _Skype_CallSetInputDevice($oCall, $TCallIoDeviceType)
; Parameters ....: $oCall				- Call object
;				   $TCallIoDeviceType	- Input sound device
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetInputDevice($oCall, $TCallIoDeviceType)
	$oCall.InputDevice = $TCallIoDeviceType

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetInputDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetOutputDevice
; Description ...: Queries the output sound device
; Syntax.........: _Skype_CallGetOutputDevice($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Output sound device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetOutputDevice($oCall)
	Return $oCall.OutputDevice
EndFunc   ;==>_Skype_CallGetOutputDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetOutputDevice
; Description ...: Sets the output sound device
; Syntax.........: _Skype_CallSetOutputDevice($oCall, $TCallIoDeviceType)
; Parameters ....: $oCall				- Call object
;				   $TCallIoDeviceType	- Output sound device
; Return values .: Success      - Input sound device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetOutputDevice($oCall, $TCallIoDeviceType)
	$oCall.OutputDevice = $TCallIoDeviceType

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetOutputDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetCaptureMicDevice
; Description ...: Queries the mic capture device
; Syntax.........: _Skype_CallGetCaptureMicDevice($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Mic capture device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetCaptureMicDevice($oCall)
	Return $oCall.CaptureMicDevice
EndFunc   ;==>_Skype_CallGetCaptureMicDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallSetCaptureMicDevice
; Description ...: Sets the mic capture device
; Syntax.........: _Skype_CallSetCaptureMicDevice($oCall, $sCaptureMicDevice)
; Parameters ....: $oCall				- Call object
;				   $sCaptureMicDevice	- Mic capture device
; Return values .: Success      - Mic capture device
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallSetCaptureMicDevice($oCall, $sCaptureMicDevice)
	$oCall.CaptureMicDevice = $sCaptureMicDevice

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallSetCaptureMicDevice


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetInputStatus
; Description ...: Queries the call voice input status
; Syntax.........: _Skype_CallGetInputStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Voice input satus (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetInputStatus($oCall)
	Return $oCall.InputStatus
EndFunc   ;==>_Skype_CallGetInputStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetForwardedBy
; Description ...: Queries the the identity of the user who forwards a call
; Syntax.........: _Skype_CallGetForwardedBy($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Identity of the user
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetForwardedBy($oCall)
	Return $oCall.ForwardedBy
EndFunc   ;==>_Skype_CallGetForwardedBy


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetCanTransfer
; Description ...: Queries if a call can be transferred to contact or number
; Syntax.........: _Skype_CallGetCanTransfer($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Can transfert (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetCanTransfer($oCall, $sUserHandle)
	Return $oCall.CanTransfer($sUserHandle)
EndFunc   ;==>_Skype_CallGetCanTransfer


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetTransferStatus
; Description ...: Queries if a call can be transferred to contact or number
; Syntax.........: _Skype_CallGetTransferStatus($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - TCallStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetTransferStatus($oCall)
	Return $oCall.TransferStatus
EndFunc   ;==>_Skype_CallGetTransferStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetTransferActive
; Description ...: Returns true if the call has been transferred
; Syntax.........: _Skype_CallGetTransferActive($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Call transfert stauts (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetTransferActive($oCall)
	Return $oCall.TransferActive
EndFunc   ;==>_Skype_CallGetTransferActive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetTransferredBy
; Description ...: Queries the Skypename of the user who transferred the call
; Syntax.........: _Skype_CallGetTransferredBy($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Skypename of the user who transferred the call
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetTransferredBy($oCall)
	Return $oCall.TransferredBy
EndFunc   ;==>_Skype_CallGetTransferredBy


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetTransferredTo
; Description ...: Returns the Skypename of the user or phone number the call has been transferred to
; Syntax.........: _Skype_CallGetTransferredTo($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Skypename or phone number transferred
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetTransferredTo($oCall)
	Return $oCall.TransferredTo
EndFunc   ;==>_Skype_CallGetTransferredTo


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallGetTargetIdentity
; Description ...: Returns the target number for incoming SkypeIN calls
; Syntax.........: _Skype_CallGetTargetIdentity($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - Target number for incoming SkypeIN calls
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallGetTargetIdentity($oCall)
	Return $oCall.TargetIdentity
EndFunc   ;==>_Skype_CallGetTargetIdentity


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallClearChatHistory
; Description ...: Clears call history
; Syntax.........: _Skype_CallClearChatHistory()
; Parameters ....: $sUserHandle	- User handle to clear call history
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallClearHistory($sUserHandle = "ALL")
	$oSkype.ClearCallHistory($sUserHandle)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallClearHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallJoin
; Description ...: Joins two calls to a conference
; Syntax.........: _Skype_CallJoin($oCall, $oCall1)
; Parameters ....: $oCall		- Call object
;				   $oCall1		- Call object of another call to join
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallJoin($oCall, $oCall1)
	$oCall.Join($oCall1.Id)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallJoin


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallHold
; Description ...: Places a call on hold
; Syntax.........: _Skype_CallHold($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallHold($oCall)
	$oCall.Hold

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallHold


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallResume
; Description ...: Resumes a call that was on hold
; Syntax.........: _Skype_CallResume($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallResume($oCall)
	$oCall.Resume

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallResume


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallFinish
; Description ...: Ends a call
; Syntax.........: _Skype_CallFinish($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_CallFinish($oCall)
	$oCall.Finish

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallFinish


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallAnswer
; Description ...: Answers a call
; Syntax.........: _Skype_CallAnswer($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallAnswer($oCall)
	$oCall.Answer

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallAnswer


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallStartVideoSend
; Description ...: Starts video send
; Syntax.........: _Skype_CallStartVideoSend($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallStartVideoSend($oCall)
	$oCall.StartVideoSend

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallStartVideoSend


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallStopVideoSend
; Description ...: Stops video send
; Syntax.........: _Skype_CallStopVideoSend($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallStopVideoSend($oCall)
	$oCall.StopVideoSend

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallStopVideoSend


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallStartVideoReceive
; Description ...: Starts video receive
; Syntax.........: _Skype_CallStartVideoReceive($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallStartVideoReceive($oCall)
	$oCall.StartVideoReceive

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallStartVideoReceive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallStopVideoReceive
; Description ...: Stops video receive
; Syntax.........: _Skype_CallStopVideoReceive($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallStopVideoReceive($oCall)
	$oCall.StopVideoReceive

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallStopVideoReceive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallForward
; Description ...: Forwards an incoming call
; Syntax.........: _Skype_CallForward($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallForward($oCall)
	$oCall.Forward

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallForward


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CallRedirectToVoicemail
; Description ...: Redirects an incoming call to voicemail
; Syntax.........: _Skype_CallRedirectToVoicemail($oCall)
; Parameters ....: $oCall		- Call object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CallRedirectToVoicemail($oCall)
	$oCall.RedirectToVoicemail

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_CallRedirectToVoicemail


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetHandle
; Description ...: Queries the current user handle
; Syntax.........: _Skype_ProfileGetHandle()
; Parameters ....: None
; Return values .: Success      - User handle
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetHandle()
	Return StringTrimLeft(__Skype_SendCommand("GET CURRENTUSERHANDLE", "CURRENTUSERHANDLE"), 18)
EndFunc   ;==>_Skype_ProfileGetHandle


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetContacts
; Description ...: Queries the contact list in the current user profile
; Syntax.........: _Skype_ProfileGetContacts()
; Parameters ....: None
; Return values .: Success      - Users object
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetContacts()
	Local $sUsersHandles = ""

	For $oUser In $oSkype.Friends
		$sUsersHandles &= $oUser.Handle & Chr(0)
	Next

	Return StringSplit($sUsersHandles, Chr(0))
EndFunc   ;==>_Skype_ProfileGetContacts


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSaveAvatarToFile
; Description ...: Saves current user avatar to file
; Syntax.........: _Skype_ProfileSaveAvatarToFile($sFilePath, $iAvatarId = 1)
; Parameters ....: $sFilePath	- File path to save the avatar
;				   $iAvatarId	- Id of the avatar (default = 1)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: Destination file must be empty and the extension of the avatar must be BMP or JPG
; Related .......: _Skype_LoadAvatarFromFile
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSaveAvatarToFile($sFilePath, $iAvatarId = 1)
	$oSkype.Settings.SaveAvatarToFile($sFilePath, $iAvatarId)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSaveAvatarToFile


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileLoadAvatarFromFile
; Description ...: Replaces user current avatar with new avatar from file
; Syntax.........: _Skype_ProfileLoadAvatarFromFile($sFilePath, $iAvatarId = 1)
; Parameters ....: $sFilePath	- File path to get the avatar
;				   $iAvatarId	- Id of the avatar
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The extension of the avatar must be jpg; jpeg; bmp; png; skype
; Related .......: _Skype_SaveAvatarToFile
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileLoadAvatarFromFile($sFilePath, $iAvatarId = 1)
	$oSkype.Settings.LoadAvatarFromFile($sFilePath, $iAvatarId)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileLoadAvatarFromFile


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetOnlineStatus
; Description ...: Queries the online status of the current user
; Syntax.........: _Skype_ProfileGetOnlineStatus()
; Parameters ....: None
; Return values .: Success      - TUserStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetOnlineStatus()
	Return $oSkype.CurrentUserStatus
EndFunc   ;==>_Skype_ProfileGetOnlineStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetFullName
; Description ...: Sets the full name in the current user profile
; Syntax.........: _Skype_ProfileSetFullName($sFullName)
; Parameters ....: $sFullName	- Full name
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetFullName
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetFullName($sFullName)
	$oSkype.CurrentUserProfile.FullName = $sFullName

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetFullName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetFullName
; Description ...: Queries the full name in the current user profile
; Syntax.........: _Skype_ProfileGetFullName()
; Parameters ....: None
; Return values .: Success      - Full name
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetFullName
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetFullName()
	Return $oSkype.CurrentUserProfile.FullName
EndFunc   ;==>_Skype_ProfileGetFullName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetBirthday
; Description ...: Sets the birthday in the current user profile
; Syntax.........: _Skype_ProfileSetBirthday($sBirthday)
; Parameters ....: $sBirthday	- Birthday (format: YYYYMMDDHHMMSS)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetBirthday
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetBirthday($sBirthday)
	$oSkype.CurrentUserProfile.Birthday = $sBirthday

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetBirthday


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetBirthday
; Description ...: Queries the birthday in the current user profile
; Syntax.........: _Skype_ProfileGetBirthday()
; Parameters ....: None
; Return values .: Success      - Birthday (format: YYYYMMDDHHMMSS)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetBirthday
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetBirthday()
	Return $oSkype.CurrentUserProfile.Birthday
EndFunc   ;==>_Skype_ProfileGetBirthday


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetSex
; Description ...: Sets the sex in the current user profile
; Syntax.........: _Skype_ProfileSetSex($sSex)
; Parameters ....: $TUserSex	- TUserSex (const)
; Return values .: Success      - 0
;                  Failure      - 1 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetSex
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetSex($TUserSex)
	$oSkype.CurrentUserProfile.Sex = $TUserSex

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetSex


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetSex
; Description ...: Queries the sex in the current user profile
; Syntax.........: _Skype_ProfileGetSex()
; Parameters ....: None
; Return values .: Success      - TUserSex (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetSex
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetSex()
	Return $oSkype.CurrentUserProfile.Sex
EndFunc   ;==>_Skype_ProfileGetSex


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCountry
; Description ...: Sets the ISO country code in the current user profile
; Syntax.........: _Skype_ProfileSetCountry($sCountry)
; Parameters ....: $sCountry	- Country
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCountry
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetCountry($sCountry)
	$oSkype.CurrentUserProfile.Country = $sCountry

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetCountry


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCountry
; Description ...: Queries the ISO country code in the current user profile
; Syntax.........: _Skype_ProfileGetCountry()
; Parameters ....: None
; Return values .: Success      - Country
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCountry
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetCountry()
	Return $oSkype.CurrentUserProfile.Country
EndFunc   ;==>_Skype_ProfileGetCountry


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetProvince
; Description ...: Sets the province in the current user profile
; Syntax.........: _Skype_ProfileSetProvince()
; Parameters ....: $sProvince	- Province
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetProvince
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetProvince($sProvince)
	$oSkype.CurrentUserProfile.Province = $sProvince

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetProvince


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetProvince
; Description ...: Queries the province in the current user profile
; Syntax.........: _Skype_ProfileGetProvince()
; Parameters ....: None
; Return values .: Success      - Province
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetProvince
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetProvince()
	Return $oSkype.CurrentUserProfile.Province
EndFunc   ;==>_Skype_ProfileGetProvince


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCity
; Description ...: Sets the city in the current user profile
; Syntax.........: _Skype_ProfileSetCity($sCity)
; Parameters ....: $sCity		- City
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCity
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetCity($sCity)
	$oSkype.CurrentUserProfile.City = $sCity

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetCity


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCity
; Description ...: Queries the city in the current user profile
; Syntax.........: _Skype_ProfileGetCity()
; Parameters ....: None
; Return values .: Success      - City
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetCity
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetCity()
	Return $oSkype.CurrentUserProfile.City
EndFunc   ;==>_Skype_ProfileGetCity


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetPhoneHome
; Description ...: Sets the home phone number in the current user profile
; Syntax.........: _Skype_ProfileSetPhoneHome($iPhoneHome)
; Parameters ....: $sPhoneHome	- Phone Home
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetPhoneHome
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetPhoneHome($sPhoneHome)
	$oSkype.CurrentUserProfile.PhoneHome = $sPhoneHome

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetPhoneHome


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetPhoneHome
; Description ...: Queries the home phone number in the current user profile
; Syntax.........: _Skype_ProfileGetPhoneHome()
; Parameters ....: None
; Return values .: Success      - Phone Home
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetPhoneHome
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetPhoneHome()
	Return $oSkype.CurrentUserProfile.PhoneHome
EndFunc   ;==>_Skype_ProfileGetPhoneHome


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetPhoneMobile
; Description ...: Sets the mobile phone number in the current user profile
; Syntax.........: _Skype_ProfileSetPhoneMobile($iPhoneMobile)
; Parameters ....: $sPhoneMobile	- Phone Mobile
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetPhoneMobile
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetPhoneMobile($sPhoneMobile)
	$oSkype.CurrentUserProfile.PhoneMobile = $sPhoneMobile

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetPhoneMobile


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetPhoneMobile
; Description ...: Queries the mobile phone number in the current user profile
; Syntax.........: _Skype_ProfileGetPhoneMobile()
; Parameters ....: None
; Return values .: Success      - Phone Mobile
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetPhoneMobile
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetPhoneMobile()
	Return $oSkype.CurrentUserProfile.PhoneMobile
EndFunc   ;==>_Skype_ProfileGetPhoneMobile


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetHomepage
; Description ...: Sets the homepage url in the current user profile
; Syntax.........: _Skype_ProfileSetHomepage($Homepage)
; Parameters ....: $Homepage	- Home page
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetHomepage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetHomepage($Homepage)
	$oSkype.CurrentUserProfile.Homepage = $Homepage

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetHomepage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetHomepage
; Description ...: Queries the homepage url in the current user profile
; Syntax.........: _Skype_ProfileGetHomepage()
; Parameters ....: None
; Return values .: Success      - Home page
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetHomepage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetHomepage()
	Return $oSkype.CurrentUserProfile.Homepage
EndFunc   ;==>_Skype_ProfileGetHomepage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetAbout
; Description ...: Sets the "About" text in the current user profile
; Syntax.........: _Skype_ProfileSetAbout($sAbout)
; Parameters ....: $sAbout		- About text
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetAbout
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetAbout($sAbout)
	$oSkype.CurrentUserProfile.About = $sAbout

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetAbout


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetAbout
; Description ...: Queries the "About" text in the current user profile
; Syntax.........: _Skype_ProfileGetAbout()
; Parameters ....: None
; Return values .: Success      - About text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetAbout
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetAbout()
	Return $oSkype.CurrentUserProfile.About
EndFunc   ;==>_Skype_ProfileGetAbout


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetMoodText
; Description ...: Sets the mood text in the current user profile
; Syntax.........: _Skype_ProfileSetMoodText($sMoodText)
; Parameters ....: $sMoodText	- Mood text
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetMoodText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileSetMoodText($sMoodText)
	$oSkype.CurrentUserProfile.MoodText = $sMoodText

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetMoodText
; Description ...: Queries the mood text in the current user profile
; Syntax.........: _Skype_ProfileGetMoodText()
; Parameters ....: None
; Return values .: Success      - Mood text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetMoodText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ProfileGetMoodText()
	Return $oSkype.CurrentUserProfile.MoodText
EndFunc   ;==>_Skype_ProfileGetMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetTimezone
; Description ...: Sets the timezone in the current user profile
; Syntax.........: _Skype_ProfileSetTimezone($iTimezone)
; Parameters ....: $iTimezone	- Timezone
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetTimezone
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetTimezone($iTimezone)
	$oSkype.CurrentUserProfile.Timezone = $iTimezone

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetTimezone


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetTimezone
; Description ...: Queries the timezone in the current user profilele
; Syntax.........: _Skype_ProfileGetTimezone()
; Parameters ....: None
; Return values .: Success      - Time zone
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetTimezone
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetTimezone()
	Return $oSkype.CurrentUserProfile.Timezone
EndFunc   ;==>_Skype_ProfileGetTimezone


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCallNoAnswerTimeout
; Description ...: Sets the "call no answer timeout" in the current user profile
; Syntax.........: _Skype_ProfileSetCallNoAnswerTimeout($iTimeout)
; Parameters ....: $iTimeout	- Timeout (sec)
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCallNoAnswerTimeout
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetCallNoAnswerTimeout($iTimeout)
	$oSkype.CurrentUserProfile.CallNoAnswerTimeout = $iTimeout

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetCallNoAnswerTimeout


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCallNoAnswerTimeout
; Description ...: Queries the "call no answer timeout" in the current user profile
; Syntax.........: _Skype_ProfileGetCallNoAnswerTimeout()
; Parameters ....: None
; Return values .: Success      - Timeout (sec)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetCallNoAnswerTimeout
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetCallNoAnswerTimeout()
	Return $oSkype.CurrentUserProfile.CallNoAnswerTimeout
EndFunc   ;==>_Skype_ProfileGetCallNoAnswerTimeout


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCallApplyCF
; Description ...: Sets if call forwarding is set in the current user profile
; Syntax.........: _Skype_ProfileSetCallApplyCF($blCallApplyCF)
; Parameters ....: $blCallApplyCF	- CF status
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCallApplyCF
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetCallApplyCF($blCallApplyCF)
	$oSkype.CurrentUserProfile.CallApplyCF = $blCallApplyCF

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetCallApplyCF


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCallApplyCF
; Description ...: Queries if call forwarding is set in the current user profile
; Syntax.........: _Skype_ProfileGetCallApplyCF()
; Parameters ....: None
; Return values .: Success      - CF status
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetCallApplyCF
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetCallApplyCF()
	Return $oSkype.CurrentUserProfile.CallApplyCF
EndFunc   ;==>_Skype_ProfileGetCallApplyCF


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCallSendToVM
; Description ...: Sets whether calls will be sent to voicemail in the current user profile
; Syntax.........: _Skype_ProfileSetCallSendToVM($blCallSendToVM)
; Parameters ....: $blCallSendToVM	- CallSendToWM status
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCallSendToVM
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetCallSendToVM($blCallSendToVM)
	$oSkype.CurrentUserProfile.CallSendToVM = $blCallSendToVM
EndFunc   ;==>_Skype_ProfileSetCallSendToVM


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCallSendToVM
; Description ...: Queries whether calls will be sent to voicemail in the current user profile
; Syntax.........: _Skype_ProfileGetCallSendToVM()
; Parameters ....: None
; Return values .: Success      - CallSendToWM status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetCallSendToVM
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetCallSendToVM()
	Return $oSkype.CurrentUserProfile.CallSendToVM
EndFunc   ;==>_Skype_ProfileGetCallSendToVM


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetCallForwardRules
; Description ...: Sets the call forwarding rules in the current user profile
; Syntax.........: _Skype_ProfileSetCallForwardRules($sCallForwardRules)
; Parameters ....: $sCallForwardRules	- Call forwarding rules
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCallForwardRules
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetCallForwardRules($sCallForwardRules)
	$oSkype.CurrentUserProfile.CallForwardRules = $sCallForwardRules

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetCallForwardRules


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetCallForwardRules
; Description ...: Queries the call forwarding rules in the current user profile
; Syntax.........: _Skype_ProfileGetCallForwardRules()
; Parameters ....: None
; Return values .: Success      - Call forwarding rules
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetCallForwardRules
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetCallForwardRules()
	Return $oSkype.CurrentUserProfile.CallForwardRules
EndFunc   ;==>_Skype_ProfileGetCallForwardRules


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetBalance
; Description ...: Queries the balance in currency cents in the current user profile
; Syntax.........: _Skype_ProfileGetBalance()
; Parameters ....: None
; Return values .: Success      - Balance in currency cents
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetBalance()
	Return $oSkype.CurrentUserProfile.Balance
EndFunc   ;==>_Skype_ProfileGetBalance


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetBalanceToText
; Description ...: Queries the balance amount with currency symbol in the current user profile
; Syntax.........: _Skype_ProfileGetBalanceToText()
; Parameters ....: None
; Return values .: Success      - Balance amount with currency symbol
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetBalanceToText()
	Return $oSkype.CurrentUserProfile.BalanceToText
EndFunc   ;==>_Skype_ProfileGetBalanceToText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetIPCountry
; Description ...: Queries the ISO country code by IP address
; Syntax.........: _Skype_ProfileGetIPCountry()
; Parameters ....: None
; Return values .: Success      - ISO country code
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetIPCountry()
	Return $oSkype.CurrentUserProfile.IPCountry
EndFunc   ;==>_Skype_ProfileGetIPCountry


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetValidatedSmsNumbers
; Description ...: Requests a list of validated SMS numbers
; Syntax.........: _Skype_ProfileGetValidatedSmsNumbers()
; Parameters ....: None
; Return values .: Success      - List of validated SMS numbers
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetValidatedSmsNumbers()
	Return $oSkype.CurrentUserProfile.ValidatedSmsNumbers
EndFunc   ;==>_Skype_ProfileGetValidatedSmsNumbers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetRichMoodText
; Description ...: Sets rich mood text in logged in user profile
; Syntax.........: _Skype_ProfileSetRichMoodText($sRichMoodText)
; Parameters ....: $sRichMoodText	- Rich mood text
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetRichMoodText
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetRichMoodText($sRichMoodText)
	$oSkype.CurrentUserProfile.RichMoodText = $sRichMoodText

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetRichMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetRichMoodText
; Description ...: Returns rich mood text in logged in user profile
; Syntax.........: _Skype_ProfileGetRichMoodText()
; Parameters ....: None
; Return values .: Success      - Rich mood text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetRichMoodText
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetRichMoodText()
	Return $oSkype.CurrentUserProfile.RichMoodText
EndFunc   ;==>_Skype_ProfileGetRichMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileGetLanguage
; Description ...: Queries the language code in the current user profile
; Syntax.........: _Skype_ProfileGetLanguage()
; Parameters ....: None
; Return values .: Success      - Language code
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetLanguage
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileGetLanguage()
	Return $oSkype.CurrentUserProfile.Languages
EndFunc   ;==>_Skype_ProfileGetLanguage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ProfileSetLanguage
; Description ...: Sets the language code in the current user profile
; Syntax.........: _Skype_ProfileSetLanguage()
; Parameters ....: $sLanguage	- Language code
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileSetLanguage
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ProfileSetLanguage($sLanguage)
	$oSkype.CurrentUserProfile.Languages = $sLanguage

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ProfileSetLanguage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventError
; Description ...: Sets a function to be called on error
; Syntax.........: _Skype_OnEventError($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $iError	- Error number
;				   $sError	- Error description
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_OnEventError($sFunc)
	$sOnError = $sFunc
EndFunc   ;==>_Skype_OnEventError


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventAttachmentStatus
; Description ...: Sets a function to be called by a change in the status of an attachment to the Skype API
; Syntax.........: _Skype_OnEventAttachmentStatus($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $TAttachmentStatus	- TAttachmentStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventAttachmentStatus($sFunc)
	$sOnAttachmentStatus = $sFunc
EndFunc   ;==>_Skype_OnEventAttachmentStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventConnectionStatus
; Description ...: Sets a function to be called by a connection status change
; Syntax.........: _Skype_OnEventConnectionStatus($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $TConnectionStatus	- TConnectionStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventConnectionStatus($sFunc)
	$sOnConnectionStatus = $sFunc
EndFunc   ;==>_Skype_OnEventConnectionStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventUserStatus
; Description ...: Sets a function to be called by a user status change
; Syntax.........: _Skype_OnEventUserStatus($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $TUserStatus	- TUserStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventUserStatus($sFunc)
	$sOnUserStatus = $sFunc
EndFunc   ;==>_Skype_OnEventUserStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventOnlineStatus
; Description ...: Sets a function to be called by a change in the online status of a user
; Syntax.........: _Skype_OnEventOnlineStatus($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $TOnlineStatus	- TOnlineStatus (const)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_OnEventOnlineStatus($sFunc)
	$sOnOnlineStatus = $sFunc
EndFunc   ;==>_Skype_OnEventOnlineStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallStatus
; Description ...: Sets a function to be called by a change in call status
; Syntax.........: _Skype_OnEventCallStatus($sFunc, $TCallStatus)
; Parameters ....: $sFunc		- Function name to be called
;				   $TCallStatus	- TCallStatus (const)
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $oCall	- Call object
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_OnEventCallStatus($sFunc, $TCallStatus)
	$aOnCallStatus[$TCallStatus + 1] = $sFunc
EndFunc   ;==>_Skype_OnEventCallStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallHistory
; Description ...: Sets a function to be called by a change in call history
; Syntax.........: _Skype_OnEventCallHistory($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have no parameters or by default parameters
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallHistory($sFunc)
	$sOnCallHistory = $sFunc
EndFunc   ;==>_Skype_OnEventCallHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventMute
; Description ...: Sets a function to be called by a change in mute status
; Syntax.........: _Skype_OnEventMute($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $blMute	- Mute status (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventMute($sFunc)
	$sOnMute = $sFunc
EndFunc   ;==>_Skype_OnEventMute


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventMessageStatus
; Description ...: Sets a function to be called on message status changed
; Syntax.........: _Skype_OnEventMessageStatus($sFunc, $sMessageStatus)
; Parameters ....: $sFunc				- Function name to be called
;				   $TChatMessageStatus	- TChatMessageStatus (const)
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $oMsg - Message object
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_OnEventMessageStatus($sFunc, $TChatMessageStatus)
	$aOnMessageStatus[$TChatMessageStatus + 1] = $sFunc
EndFunc   ;==>_Skype_OnEventMessageStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventMessageHistory
; Description ...: Sets a function to be called by a change in message history
; Syntax.........: _Skype_OnEventMessageHistory($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sUserHandle - Userhandle
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventMessageHistory($sFunc)
	$sOnMute = $sFunc
EndFunc   ;==>_Skype_OnEventMessageHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventAutoAway
; Description ...: Sets a function to be called by a change of auto away status
; Syntax.........: _Skype_OnEventAutoAway($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $blAutoAway - Auto away status
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventAutoAway($sFunc)
	$sOnAutoAway = $sFunc
EndFunc   ;==>_Skype_OnEventAutoAway


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallDtmfReceived
; Description ...: Sets a function to be called by a call DTMF event
; Syntax.........: _Skype_OnEventAutoAway($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $sCode - Call dtmf code
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallDtmfReceived($sFunc)
	$sOnCallDtmfReceived = $sFunc
EndFunc   ;==>_Skype_OnEventCallDtmfReceived


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventVoicemailStatus
; Description ...: Sets a function to be called by a change in voicemail status
; Syntax.........: _Skype_OnEventVoicemailStatus($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oVM - Voicemail object
;				   $TVoicemailStatus - TVoicemailStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventVoicemailStatus($sFunc)
	$sOnVoiceMailStatus = $sFunc
EndFunc   ;==>_Skype_OnEventVoicemailStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventApplicationConnecting
; Description ...: Sets a function to be called by users connecting to an application
; Syntax.........: _Skype_OnEventApplicationConnecting($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oApp - Application object
;				   $oUsers - Users connected to the application
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventApplicationConnecting($sFunc)
	$sOnAppConnecting = $sFunc
EndFunc   ;==>_Skype_OnEventApplicationConnecting


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventContactsFocused
; Description ...: Sets a function to be called by the contacts tab gaining or losing focus
; Syntax.........: _Skype_OnEventContactsFocused($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sUserHandle - UserHandle selected in the contacts tab
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventContactsFocused($sFunc)
	$sOnContactsFocused = $sFunc
EndFunc   ;==>_Skype_OnEventContactsFocused


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventGroupVisible
; Description ...: Sets a function to be called by a user hiding/showing a group in the contacts tab
; Syntax.........: _Skype_OnEventGroupVisible($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $sId - Group Id
;				   $TGroupType - TGroupType (const)
;				   $sDisplayName - Group display name
;				   $blVisible - Visibility status (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventGroupVisible($sFunc)
	$sOnGroupVisible = $sFunc
EndFunc   ;==>_Skype_OnEventGroupVisible


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventGroupExpanded
; Description ...: Sets a function to be called by a user expanding or collapsing a group in the contacts tab
; Syntax.........: _Skype_OnEventGroupExpanded($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $sId - Group Id
;				   $TGroupType - TGroupType (const)
;				   $sDisplayName - Group display name
;				   $blVisible - Visibility status (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventGroupExpanded($sFunc)
	$sOnGroupExpanded = $sFunc
EndFunc   ;==>_Skype_OnEventGroupExpanded


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventGroupUsers
; Description ...: Sets a function to be called by a change in a contact group
; Syntax.........: _Skype_OnEventGroupUsers($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $sId - Group Id
;				   $TGroupType - TGroupType (const)
;				   $sDisplayName - Group display name
;				   $aUserHandle - UsersHandles (array)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventGroupUsers($sFunc)
	$sOnGroupUsers = $sFunc
EndFunc   ;==>_Skype_OnEventGroupUsers


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventGroupDeleted
; Description ...: Sets a function to be called by a user deleting a custom contact group
; Syntax.........: _Skype_OnEventGroupDeleted($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sId - Group Id
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventGroupDeleted($sFunc)
	$sOnGroupDeleted = $sFunc
EndFunc   ;==>_Skype_OnEventGroupDeleted


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventSmsMessageStatusChanged
; Description ...: Sets a function to be called by a change in the SMS message status
; Syntax.........: _Skype_OnEventSmsMessageStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oSMS - Sms object
;				   $TSmsMessageStatus - TSmsMessageStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventSmsMessageStatusChanged($sFunc)
	$sOnSmsMessageStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventSmsMessageStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventSmsTargetStatusChanged
; Description ...: Sets a function to be called by a change in the SMS target status
; Syntax.........: _Skype_OnEventSmsTargetStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $sTargetId - Target Id
;				   $iTarget - Target number
;				   $TSmsTargetStatus - TSmsTargetStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventSmsTargetStatusChanged($sFunc)
	$sOnSmsTargetStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventSmsTargetStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallInputStatusChanged
; Description ...: Sets a function to be called by a change in the Call voice input status change
; Syntax.........: _Skype_OnEventCallInputStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $blStatus - Call input status (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallInputStatusChanged($sFunc)
	$sOnCallInputStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallInputStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventAsyncSearchUsersFinished
; Description ...: Sets a function to be called when a search is completed
; Syntax.........: _Skype_OnEventAsyncSearchUsersFinished($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $iCookie - Search result cookie
;				   $aUsers - Users object (array)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventAsyncSearchUsersFinished($sFunc)
	$sOnCallInputStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventAsyncSearchUsersFinished


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallSeenStatusChanged
; Description ...: Sets a function to be called when the seen status of a call changes
; Syntax.........: _Skype_OnEventCallSeenStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $blStatus - Call seen status (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallSeenStatusChanged($sFunc)
	$sOnCallInputStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallSeenStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventPluginEventClicked
; Description ...: Sets a function to be called when a user clicks on a plug-in event
; Syntax.........: _Skype_OnEventPluginEventClicked($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sId - Plugin event Id
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventPluginEventClicked($sFunc)
	$sOnCallInputStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventPluginEventClicked


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventPluginMenuItemClicked
; Description ...: Sets a function to be called when a user clicks on a menu item
; Syntax.........: _Skype_OnEventPluginMenuItemClicked($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $aPluginMenuItem (array):
;					$sId - MenuItem Id
;					$TPluginContext - TPluginContext (const)
;					$sContextId - Context Id
;					$aUsers - Users object (array)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventPluginMenuItemClicked($sFunc)
	$sOnPluginMenuItemClicked = $sFunc
EndFunc   ;==>_Skype_OnEventPluginMenuItemClicked


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventWallpaperChanged
; Description ...: Sets a function to be called when a wallpaper changes
; Syntax.........: _Skype_OnEventWallpaperChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sPath - File path of the wallpaper
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventWallpaperChanged($sFunc)
	$sOnWallpaperChanged = $sFunc
EndFunc   ;==>_Skype_OnEventWallpaperChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventFileTransferStatusChanged
; Description ...: Sets a function to be called when a file transfer status changes
; Syntax.........: _Skype_OnEventFileTransferStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oTransfer - Transfert object
;				   $TFileTransferStatus - TFileTransferStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventFileTransferStatusChanged($sFunc)
	$sOnFileTransferStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventFileTransferStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallTransferStatusChanged
; Description ...: Sets a function to be called when a call transfer status changes
; Syntax.........: _Skype_OnEventCallTransferStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $TCallStatus - TCallStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallTransferStatusChanged($sFunc)
	$sOnCallTransferStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallTransferStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventChatMembersChanged
; Description ...: Sets a function to be called when a chat members change
; Syntax.........: _Skype_OnEventChatMembersChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oChat - Chat object
;				   $aUsers - Users object (array)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventChatMembersChanged($sFunc)
	$sOnChatMembersChanged = $sFunc
EndFunc   ;==>_Skype_OnEventChatMembersChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallVideoStatusChanged
; Description ...: Sets a function to be called when a call video status changes
; Syntax.........: _Skype_OnEventCallVideoStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $TCallVideoStatus - TCallVideoStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallVideoStatusChanged($sFunc)
	$sOnCallVideoStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallVideoStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallVideoSendStatusChanged
; Description ...: Sets a function to be called when a call video send status changes
; Syntax.........: _Skype_OnEventCallVideoSendStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $TCallVideoSendStatus - TCallVideoSendStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallVideoSendStatusChanged($sFunc)
	$sOnCallVideoSendStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallVideoSendStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventCallVideoReceiveStatusChanged
; Description ...: Sets a function to be called when a call video receive status changes
; Syntax.........: _Skype_OnEventCallVideoReceiveStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameters:
;				   $oCall - Call object
;				   $TCallVideoSendStatus - TCallVideoSendStatus (const)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventCallVideoReceiveStatusChanged($sFunc)
	$sOnCallVideoReceiveStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventCallVideoReceiveStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventSilentModeStatusChanged
; Description ...: Sets a function to be called when a silent mode is switched off
; Syntax.........: _Skype_OnEventSilentModeStatusChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $blSilent - Silent mode (bool)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventSilentModeStatusChanged($sFunc)
	$sOnSilentModeStatusChanged = $sFunc
EndFunc   ;==>_Skype_OnEventSilentModeStatusChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventUILanguageChanged
; Description ...: Sets a function to be called when user changes Skype client language
; Syntax.........: _Skype_OnEventUILanguageChanged($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $sCode - Language code
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventUILanguageChanged($sFunc)
	$sOnUILanguageChanged = $sFunc
EndFunc   ;==>_Skype_OnEventUILanguageChanged


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_OnEventUserAuthRequestReceived
; Description ...: Sets a function to be called when user sends you authorization request
; Syntax.........: _Skype_OnEventUserAuthRequestReceived($sFunc)
; Parameters ....: $sFunc	- Function name to be called
; Return values .: None
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......: The function called must have the following parameter:
;				   $oUser - User object
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_OnEventUserAuthRequestReceived($sFunc)
	$sOnUserAuthRequestReceived = $sFunc
EndFunc   ;==>_Skype_OnEventUserAuthRequestReceived


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetFullName
; Description ...: Queries the full name of the user
; Syntax.........: _Skype_UserGetFullName()
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User fullname
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_UserGetFullName($sUserHandle)
	Local $sUserFullName = $oSkype.User($sUserHandle).FullName

	If $sUserFullName = "" Then Return $sUserHandle
	Return $sUserFullName
EndFunc   ;==>_Skype_UserGetFullName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSendMessage
; Description ...: Sends a chat message to a user
; Syntax.........: _Skype_UserSendMessage($sUserHandle, $sMessage)
; Parameters ....: $sUserHandle	- Name/handle of the user
;				   $sMessage	- Message to send
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSendMessage($sUserHandle, $sMessage)
	$oSkype.SendMessage($sUserHandle, $sMessage)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_UserSendMessage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetBirthday
; Description ...: Queries the birthday of the user
; Syntax.........: _Skype_UserGetBirthday($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User birthday (format: YYYYMMDDHHMMSS)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetBirthday($sUserHandle)
	Return $oSkype.User($sUserHandle).Birthday
EndFunc   ;==>_Skype_UserGetBirthday


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetSex
; Description ...: Queries the sex of the user
; Syntax.........: _Skype_UserGetSex($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User sex
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetSex($sUserHandle)
	Return $oSkype.User($sUserHandle).Sex
EndFunc   ;==>_Skype_UserGetSex


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetCountry
; Description ...: Queries the ISO country code of the user
; Syntax.........: _Skype_UserGetCountry($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User country
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_ProfileGetCountry
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetCountry($sUserHandle)
	Return $oSkype.User($sUserHandle).Country
EndFunc   ;==>_Skype_UserGetCountry


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetProvince
; Description ...: Queries the province of the user
; Syntax.........: _Skype_UserGetProvince($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User province
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetProvince($sUserHandle)
	Return $oSkype.User($sUserHandle).Province
EndFunc   ;==>_Skype_UserGetProvince


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetCity
; Description ...: Queries the city of the user
; Syntax.........: _Skype_UserGetCity($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User city
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetCity($sUserHandle)
	Return $oSkype.User($sUserHandle).City
EndFunc   ;==>_Skype_UserGetCity


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetPhoneHome
; Description ...: Queries the home phone number of the user
; Syntax.........: _Skype_UserGetPhoneHome($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User phone home
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetPhoneHome($sUserHandle)
	Return $oSkype.User($sUserHandle).PhoneHome
EndFunc   ;==>_Skype_UserGetPhoneHome


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetPhoneMobile
; Description ...: Queries the mobile phone number of the user
; Syntax.........: _Skype_UserGetPhoneMobile($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - Phone Mobile
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetPhoneMobile($sUserHandle)
	Return $oSkype.User($sUserHandle).PhoneMobile
EndFunc   ;==>_Skype_UserGetPhoneMobile


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetHomepage
; Description ...: Queries the homepage url of the user
; Syntax.........: _Skype_UserGetHomepage()
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User home page
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetHomepage($sUserHandle)
	Return $oSkype.User($sUserHandle).Homepage
EndFunc   ;==>_Skype_UserGetHomepage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetAbout
; Description ...: Queries the "About" text of the user
; Syntax.........: _Skype_UserGetAbout($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - About text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetAbout($sUserHandle)
	Return $oSkype.User($sUserHandle).About
EndFunc   ;==>_Skype_UserGetAbout


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetMoodText
; Description ...: Queries the mood text of the user
; Syntax.........: _Skype_UserGetMoodText($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - Mood text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetMoodText($sUserHandle)
	Return $oSkype.User($sUserHandle).MoodText
EndFunc   ;==>_Skype_UserGetMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetTimezone
; Description ...: Queries the timezone of the user
; Syntax.........: _Skype_UserGetTimezone($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User timezone
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetTimezone($sUserHandle)
	Return $oSkype.User($sUserHandle).Timezone
EndFunc   ;==>_Skype_UserGetTimezone


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetRichMoodText
; Description ...: Returns rich mood text of the user
; Syntax.........: _Skype_UserGetRichMoodText($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User rich moodtext
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetRichMoodText($sUserHandle)
	Return $oSkype.User($sUserHandle).RichMoodText
EndFunc   ;==>_Skype_UserGetRichMoodText


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetBuddyStatus
; Description ...: Queries buddy status of the user
; Syntax.........: _Skype_UserGetBuddyStatus($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User TBuddyStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetBuddyStatus($sUserHandle)
	Return $oSkype.User($sUserHandle).BuddyStatus
EndFunc   ;==>_Skype_UserGetBuddyStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSetBuddyStatus
; Description ...: Sets buddy status of the user
; Syntax.........: _Skype_UserSetBuddyStatus($sUserHandle, $TBuddyStatus)
; Parameters ....: $sUserHandle		- User handle
;				   $TBuddyStatus	- TBuddyStatus (const)
; Return values .: Success      -
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSetBuddyStatus($sUserHandle, $TBuddyStatus)
	Return $oSkype.User($sUserHandle).BuddyStatus = $TBuddyStatus
EndFunc   ;==>_Skype_UserSetBuddyStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetAuthorized
; Description ...: Queries authorization status of the user
; Syntax.........: _Skype_UserGetAuthorized($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User athorization status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetAuthorized($sUserHandle)
	Return $oSkype.User($sUserHandle).IsAuthorized
EndFunc   ;==>_Skype_UserGetAuthorized


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSetAuthorized
; Description ...: Sets authorization status of the user
; Syntax.........: _Skype_UserSetAuthorized($sUserHandle, $blAuthorized)
; Parameters ....: $sUserHandle		- User handle
;				   $blAuthorized	- Athorization status
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSetAuthorized($sUserHandle, $blAuthorized)
	$oSkype.User($sUserHandle).IsAuthorized($blAuthorized)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_UserSetAuthorized


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetIsBlocked
; Description ...: Queries whether a user is blocked or not
; Syntax.........: _Skype_UserGetIsBlocked($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User blocked status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetIsBlocked($sUserHandle)
	Return $oSkype.User($sUserHandle).IsBlocked
EndFunc   ;==>_Skype_UserGetIsBlocked


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSetIsBlocked
; Description ...: Sets whether a user is blocked or not
; Syntax.........: _Skype_UserSetIsBlocked($sUserHandle, $blBlocked)
; Parameters ....: $sUserHandle	- User handle
;				   $blBlocked	- Blocked status
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSetIsBlocked($sUserHandle, $blBlocked)
	$oSkype.User($sUserHandle).IsBlocked($blBlocked)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_UserSetIsBlocked


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetDisplayName
; Description ...: Queries the display name for a user
; Syntax.........: _Skype_UserGetDisplayName($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User display name
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetDisplayName($sUserHandle)
	Return $oSkype.User($sUserHandle).DisplayName
EndFunc   ;==>_Skype_UserGetDisplayName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSetDisplayName
; Description ...: Sets the display name for a user
; Syntax.........: _Skype_UserSetDisplayName($sUserHandle, $sDisplayName)
; Parameters ....: $sUserHandle		- User handle
;				   $sDisplayName	- User display name
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSetDisplayName($sUserHandle, $sDisplayName)
	$oSkype.User($sUserHandle).DisplayName($sDisplayName)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_UserSetDisplayName


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetOnlineStatus
; Description ...: Queries the online status of the user
; Syntax.........: _Skype_UserGetOnlineStatus($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User TOnlineStatus (const)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_UserGetOnlineStatus($sUserHandle)
	Return $oSkype.User($sUserHandle).OnlineStatus
EndFunc   ;==>_Skype_UserGetOnlineStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetLastOnline
; Description ...: Queries the time when a user was last online
; Syntax.........: _Skype_UserGetLastOnline($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User last online time
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetLastOnline($sUserHandle)
	Return $oSkype.User($sUserHandle).LastOnline
EndFunc   ;==>_Skype_UserGetLastOnline


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetReceivedAuthRequest
; Description ...: Queries the authorization request text of the user
; Syntax.........: _Skype_UserGetReceivedAuthRequest($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User authorization request text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetReceivedAuthRequest($sUserHandle)
	Return $oSkype.User($sUserHandle).ReceivedAuthRequest
EndFunc   ;==>_Skype_UserGetReceivedAuthRequest


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetSpeedDial
; Description ...: Queries the speed dial code of the user
; Syntax.........: _Skype_UserGetSpeedDial($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User speed dial code
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetSpeedDial($sUserHandle)
	Return $oSkype.User($sUserHandle).SpeedDial
EndFunc   ;==>_Skype_UserGetSpeedDial


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserSetSpeedDial
; Description ...: Sets the speed dial code of the user
; Syntax.........: _Skype_UserSetSpeedDial($sUserHandle, $sSpeedDial)
; Parameters ....: $sUserHandle	- User handle
;				   $sSpeedDial	- Speed dial code
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserSetSpeedDial($sUserHandle, $sSpeedDial)
	$oSkype.User($sUserHandle).SpeedDial($sSpeedDial)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_UserSetSpeedDial


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetCanLeaveVoicemail
; Description ...: Queries if it is possible to send voicemail to a user
; Syntax.........: _Skype_UserGetCanLeaveVoicemail($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User send voicemail ability (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetCanLeaveVoicemail($sUserHandle)
	Return $oSkype.User($sUserHandle).CanLeaveVoicemail
EndFunc   ;==>_Skype_UserGetCanLeaveVoicemail


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetAliases
; Description ...: Queries the alias text of the user
; Syntax.........: _Skype_UserGetAliases($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User aliases
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetAliases($sUserHandle)
	Return $oSkype.User($sUserHandle).Aliases
EndFunc   ;==>_Skype_UserGetAliases


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetIsCallForwardActive
; Description ...: Queries the call forwarding status of the user
; Syntax.........: _Skype_UserGetIsCallForwardActive($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - Call forward active status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetIsCallForwardActive($sUserHandle)
	Return $oSkype.User($sUserHandle).IsCallForwardActive
EndFunc   ;==>_Skype_UserGetIsCallForwardActive


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetLanguage
; Description ...: Queries the language of the user
; Syntax.........: _Skype_UserGetLanguage($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User language
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetLanguage($sUserHandle)
	Return $oSkype.User($sUserHandle).Language
EndFunc   ;==>_Skype_UserGetLanguage


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetLanguageCode
; Description ...: Queries the ISO language code of the user
; Syntax.........: _Skype_UserGetLanguageCode($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User language code
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetLanguageCode($sUserHandle)
	Return $oSkype.User($sUserHandle).LanguageCode
EndFunc   ;==>_Skype_UserGetLanguageCode


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetIsVideoCapable
; Description ...: Queries if a user has video capability
; Syntax.........: _Skype_UserGetIsVideoCapable($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User video capability
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetIsVideoCapable($sUserHandle)
	Return $oSkype.User($sUserHandle).IsVideoCapable
EndFunc   ;==>_Skype_UserGetIsVideoCapable


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetIsSkypeOutContact
; Description ...: Queries whether a user is a SkypeOut contact
; Syntax.........: _Skype_UserGetIsSkypeOutContact($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User skypout contact status (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetIsSkypeOutContact($sUserHandle)
	Return $oSkype.User($sUserHandle).IsSkypeOutContact
EndFunc   ;==>_Skype_UserGetIsSkypeOutContact


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetNumberOfAuthBuddies
; Description ...: Queries the number of authenticated buddies of the contact
; Syntax.........: _Skype_UserGetNumberOfAuthBuddies($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User authbuddies number
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetNumberOfAuthBuddies($sUserHandle)
	Return $oSkype.User($sUserHandle).NumberOfAuthBuddies
EndFunc   ;==>_Skype_UserGetNumberOfAuthBuddies


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_UserGetIsVoicemailCapable
; Description ...: Returns user voicemail capability status
; Syntax.........: _Skype_UserGetIsVoicemailCapable($sUserHandle)
; Parameters ....: $sUserHandle	- User handle
; Return values .: Success      - User voicemail capability (bool)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_UserGetIsVoicemailCapable($sUserHandle)
	Return $oSkype.User($sUserHandle).IsVoicemailCapable
EndFunc   ;==>_Skype_UserGetIsVoicemailCapable


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertAttachmentStatus
; Description ...: Converts attachment status to text or vice versa
; Syntax.........: _Skype_ConvertAttachmentStatus($TAttachmentStatus, $blConvertWay)
; Parameters ....: $TAttachmentStatus	- TAttachmentStatus (const)
;				   or					- sAttachmentStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertAttachmentStatus($TAttachmentStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.AttachmentStatusToText($TAttachmentStatus)
	Else
		Return $oSkype.Convert.TextToAttachmentStatus($TAttachmentStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertAttachmentStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertConnectionStatus
; Description ...: Converts connection status to text or vice versa
; Syntax.........: _Skype_ConvertConnectionStatus($TConnectionStatus, $blConvertWay)
; Parameters ....: $TConnectionStatus	- TConnectionStatus (const)
;				   or					- sConnectionStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertConnectionStatus($TConnectionStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ConnectionStatusToText($TConnectionStatus)
	Else
		Return $oSkype.Convert.TextToConnectionStatus($TConnectionStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertConnectionStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertUserStatus
; Description ...: Converts user status to text or vice versa
; Syntax.........: _Skype_ConvertUserStatus($TUserStatus, $blConvertWay)
; Parameters ....: $TUserStatus	- TUserStatus (const)
;				   or			- sUserStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertUserStatus($TUserStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.UserStatusToText($TUserStatus)
	Else
		Return $oSkype.Convert.TextToUserStatus($TUserStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertUserStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallFailureReason
; Description ...: Converts call failure reason to text or vice versa
; Syntax.........: _Skype_ConvertCallFailureReason($TCallFailureReason, $blConvertWay)
; Parameters ....: $TCallFailureReason	- TCallFailureReason (const)
;				   or					- sCallFailureReason
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallFailureReason($TCallFailureReason, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallFailureReasonToText($TCallFailureReason)
	Else
		Return $oSkype.Convert.TextToCallFailureReason($TCallFailureReason)
	EndIf
EndFunc   ;==>_Skype_ConvertCallFailureReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallStatus
; Description ...: Converts call status to text or vice versa
; Syntax.........: _Skype_ConvertCallStatus($TCallStatus, $blConvertWay)
; Parameters ....: $TCallStatus	- TCallStatus (const)
;				   or			- sCallStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Skype_ConvertCallStatus($TCallStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallStatusToText($TCallStatus)
	Else
		Return $oSkype.Convert.TextToCallStatus($TCallStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertCallStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallType
; Description ...: Converts call type to text or vice versa
; Syntax.........: _Skype_ConvertCallType($TCallType, $blConvertWay)
; Parameters ....: $TCallType	- TCallType (const)
;				   or			- sCallType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallType($TCallType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallTypeToText($TCallType)
	Else
		Return $oSkype.Convert.TextToCallType($TCallType)
	EndIf
EndFunc   ;==>_Skype_ConvertCallType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallHistory
; Description ...: Converts call history to text or vice versa
; Syntax.........: _Skype_ConvertCallHistory($TCallHistory, $blConvertWay)
; Parameters ....: $TCallHistory	- TCallHistory (const)
;				   or				- sCallHistory
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallHistory($TCallHistory, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallHistoryToText($TCallHistory)
	Else
		Return $oSkype.Convert.TextToCallHistory($TCallHistory)
	EndIf
EndFunc   ;==>_Skype_ConvertCallHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallVideoStatus
; Description ...: Converts call video status to text or vice versa
; Syntax.........: _Skype_ConvertCallVideoStatus($TCallVideoStatus, $blConvertWay)
; Parameters ....: $TCallVideoStatus	- TCallVideoStatus (const)
;				   or					- sCallVideoStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallVideoStatus($TCallVideoStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallVideoStatusToText($TCallVideoStatus)
	Else
		Return $oSkype.Convert.TextToCallVideoStatus($TCallVideoStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertCallVideoStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallVideoSendStatus
; Description ...: Converts call video send status to text or vice versa
; Syntax.........: _Skype_ConvertCallVideoSendStatus($TCallVideoSendStatus, $blConvertWay)
; Parameters ....: $TCallVideoSendStatus	- TCallVideoSendStatus (const)
;				   or						- sCallVideoSendStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallVideoSendStatus($TCallVideoSendStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallVideoSendStatusToText($TCallVideoSendStatus)
	Else
		Return $oSkype.Convert.TextToCallVideoSendStatus($TCallVideoSendStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertCallVideoSendStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallIoDeviceType
; Description ...: Converts call IoDevice type to text or vice versa
; Syntax.........: _Skype_ConvertCallIoDeviceType($TCallIoDeviceType, $blConvertWay)
; Parameters ....: $TCallIoDeviceType	- TCallIoDeviceType (const)
;				   or					- sCallIoDeviceType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallIoDeviceType($TCallIoDeviceType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallIoDeviceTypeToText($TCallIoDeviceType)
	Else
		Return $oSkype.Convert.TextToCallIoDeviceType($TCallIoDeviceType)
	EndIf
EndFunc   ;==>_Skype_ConvertCallIoDeviceType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatMessageType
; Description ...: Converts chat message type to text or vice versa
; Syntax.........: _Skype_ConvertChatMessageType($TChatMessageType, $blConvertWay)
; Parameters ....: $TChatMessageType	- TChatMessageType (const)
;				   or					- sChatMessageType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatMessageType($TChatMessageType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatMessageTypeToText($TChatMessageType)
	Else
		Return $oSkype.Convert.TextToChatMessageType($TChatMessageType)
	EndIf
EndFunc   ;==>_Skype_ConvertChatMessageType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatMemberRole
; Description ...: Converts chat member role to text or vice versa
; Syntax.........: _Skype_ConvertChatMemberRole($TChatMemberRole, $blConvertWay)
; Parameters ....: $TChatMemberRole	- TChatMemberRole (const)
;				   or				- sChatMemberRole
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatMemberRole($TChatMemberRole, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatMemberRoleToText($TChatMemberRole)
	Else
		Return $oSkype.Convert.TextToChatMemberRole($TChatMemberRole)
	EndIf
EndFunc   ;==>_Skype_ConvertChatMemberRole


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertUserSex
; Description ...: Converts user sex to text or vice versa
; Syntax.........: _Skype_ConvertUserSex($TUserSex, $blConvertWay)
; Parameters ....: $TUserSex	- TUserSex (const)
;				   or			- sUserSex
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertUserSex($TUserSex, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.UserSexToText($TUserSex)
	Else
		Return $oSkype.Convert.TextToUserSex($TUserSex)
	EndIf
EndFunc   ;==>_Skype_ConvertUserSex


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertBuddyStatus
; Description ...: Converts buddy status to text or vice versa
; Syntax.........: _Skype_ConvertBuddyStatus($TBuddyStatus, $blConvertWay)
; Parameters ....: $TBuddyStatus	- TBuddyStatus (const)
;				   or				- sBuddyStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertBuddyStatus($TBuddyStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.BuddyStatusToText($TBuddyStatus)
	Else
		Return $oSkype.Convert.TextToBuddyStatus($TBuddyStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertBuddyStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertOnlineStatus
; Description ...: Converts online status to text or vice versa
; Syntax.........: _Skype_ConvertOnlineStatus($TOnlineStatus, $blConvertWay)
; Parameters ....: $TOnlineStatus	- TOnlineStatus (const)
;				   or				- sOnlineStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertOnlineStatus($TOnlineStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.OnlineStatusToText($TOnlineStatus)
	Else
		Return $oSkype.Convert.TextToOnlineStatus($TOnlineStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertOnlineStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertOnlineStatus
; Description ...: Converts online status to text or vice versa
; Syntax.........: _Skype_ConvertOnlineStatus($TOnlineStatus, $blConvertWay)
; Parameters ....: $TOnlineStatus	- TOnlineStatus (const)
;				   or				- sOnlineStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatLeaveReason($TChatLeaveReason, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatLeaveReasonToText($TChatLeaveReason)
	Else
		Return $oSkype.Convert.TextToChatLeaveReason($TChatLeaveReason)
	EndIf
EndFunc   ;==>_Skype_ConvertChatLeaveReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatStatus
; Description ...: Converts chat status to text or vice versa
; Syntax.........: _Skype_ConvertChatStatus($TChatStatus, $blConvertWay)
; Parameters ....: $TChatStatus	- TChatStatus (const)
;				   or			- sChatStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatStatus($TChatStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatStatusToText($TChatStatus)
	Else
		Return $oSkype.Convert.TextToChatStatus($TChatStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertChatStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatType
; Description ...: Converts chat type to text or vice versa
; Syntax.........: _Skype_ConvertChatType($TChatType, $blConvertWay)
; Parameters ....: $TChatType	- TChatType (const)
;				   or			- sChatType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatType($TChatType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatTypeToText($TChatType)
	Else
		Return $oSkype.Convert.TextToChatType($TChatType)
	EndIf
EndFunc   ;==>_Skype_ConvertChatType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatMyStatus
; Description ...: Converts chat mystatus to text or vice versa
; Syntax.........: _Skype_ConvertChatMyStatus($TChatMyStatus, $blConvertWay)
; Parameters ....: $TChatMyStatus	- TChatMyStatus (const)
;				   or				- sChatMyStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatMyStatus($TChatMyStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatMyStatusToText($TChatMyStatus)
	Else
		Return $oSkype.Convert.TextToChatMyStatus($TChatMyStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertChatMyStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertChatOptions
; Description ...: Converts chat options to text or vice versa
; Syntax.........: _Skype_ConvertChatOptions($TChatOptions, $blConvertWay)
; Parameters ....: $TChatOptions	- TChatOptions (const)
;				   or				- sChatOptions
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertChatOptions($TChatOptions, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ChatOptionsToText($TChatOptions)
	Else
		Return $oSkype.Convert.TextToChatOptions($TChatOptions)
	EndIf
EndFunc   ;==>_Skype_ConvertChatOptions


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertVoicemailType
; Description ...: Converts voicemail type to text or vice versa
; Syntax.........: _Skype_ConvertVoicemailType($TVoicemailType, $blConvertWay)
; Parameters ....: $TVoicemailType	- TVoicemailType (const)
;				   or				- sVoicemailType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertVoicemailType($TVoicemailType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.VoicemailTypeToText($TVoicemailType)
	Else
		Return $oSkype.Convert.TextToVoicemailType($TVoicemailType)
	EndIf
EndFunc   ;==>_Skype_ConvertVoicemailType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertVoicemailStatus
; Description ...: Converts voicemail status to text or vice versa
; Syntax.........: _Skype_ConvertVoicemailStatus($TVoicemailStatus, $blConvertWay)
; Parameters ....: $TVoicemailStatus	- TVoicemailStatus (const)
;				   or					- sVoicemailStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertVoicemailStatus($TVoicemailStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.VoicemailStatusToText($TVoicemailStatus)
	Else
		Return $oSkype.Convert.TextToVoicemailStatus($TVoicemailStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertVoicemailStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertVoicemailFailureReason
; Description ...: Converts voicemail failure reason to text or vice versa
; Syntax.........: _Skype_ConvertVoicemailFailureReason($TVoicemailFailureReason, $blConvertWay)
; Parameters ....: $TVoicemailFailureReason	- TVoicemailFailureReason (const)
;				   or						- sTVoicemailFailureReason
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertVoicemailFailureReason($TVoicemailFailureReason, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.VoicemailFailureReasonToText($TVoicemailFailureReason)
	Else
		Return $oSkype.Convert.TextToVoicemailFailureReason($TVoicemailFailureReason)
	EndIf
EndFunc   ;==>_Skype_ConvertVoicemailFailureReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertGroupType
; Description ...: Converts groupe type to text or vice versa
; Syntax.........: _Skype_ConvertGroupType($TGroupType, $blConvertWay)
; Parameters ....: $TGroupType	- TGroupType (const)
;				   or			- sGroupType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertGroupType($TGroupType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.GroupTypeToText($TGroupType)
	Else
		Return $oSkype.Convert.TextToGroupType($TGroupType)
	EndIf
EndFunc   ;==>_Skype_ConvertGroupType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertCallChannelType
; Description ...: Converts call channel type to text or vice versa
; Syntax.........: _Skype_ConvertCallChannelType($TCallChannelType, $blConvertWay)
; Parameters ....: $TCallChannelType	- TCallChannelType (const)
;				   or					- sCallChannelType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertCallChannelType($TCallChannelType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.CallChannelTypeToText($TCallChannelType)
	Else
		Return $oSkype.Convert.TextToCallChannelType($TCallChannelType)
	EndIf
EndFunc   ;==>_Skype_ConvertCallChannelType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertApiSecurityContext
; Description ...: Converts api security context to text or vice versa
; Syntax.........: _Skype_ConvertApiSecurityContext($TApiSecurityContext, $blConvertWay)
; Parameters ....: $TApiSecurityContext	- TApiSecurityContext (const)
;				   or					- sApiSecurityContext
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertApiSecurityContext($TApiSecurityContext, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.ApiSecurityContextToText($TApiSecurityContext)
	Else
		Return $oSkype.Convert.TextToApiSecurityContext($TApiSecurityContext)
	EndIf
EndFunc   ;==>_Skype_ConvertApiSecurityContext


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertSmsMessageType
; Description ...: Converts sms message type to text or vice versa
; Syntax.........: _Skype_ConvertSmsMessageType($TSmsMessageType, $blConvertWay)
; Parameters ....: $TSmsMessageType	- TSmsMessageType (const)
;				   or				- sSmsMessageType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertSmsMessageType($TSmsMessageType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.SmsMessageTypeToText($TSmsMessageType)
	Else
		Return $oSkype.Convert.TextToSmsMessageType($TSmsMessageType)
	EndIf
EndFunc   ;==>_Skype_ConvertSmsMessageType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertSmsMessageStatus
; Description ...: Converts sms message status to text or vice versa
; Syntax.........: _Skype_ConvertSmsMessageStatus($TSmsMessageStatus, $blConvertWay)
; Parameters ....: $TSmsMessageStatus	- TSmsMessageStatus (const)
;				   or					- sSmsMessageStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertSmsMessageStatus($TSmsMessageStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.SmsMessageStatusToText($TSmsMessageStatus)
	Else
		Return $oSkype.Convert.TextToSmsMessageStatus($TSmsMessageStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertSmsMessageStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertSmsFailureReason
; Description ...: Converts sms failure reason to text or vice versa
; Syntax.........: _Skype_ConvertSmsFailureReason($TSmsFailureReason, $blConvertWay)
; Parameters ....: $TSmsFailureReason	- TSmsFailureReason (const)
;				   or					- sSmsFailureReason
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertSmsFailureReason($TSmsFailureReason, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.SmsFailureReasonToText($TSmsFailureReason)
	Else
		Return $oSkype.Convert.TextToSmsFailureReason($TSmsFailureReason)
	EndIf
EndFunc   ;==>_Skype_ConvertSmsFailureReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertSmsTargetStatus
; Description ...: Converts sms target to text or vice versa
; Syntax.........: _Skype_ConvertSmsTargetStatus($TSmsTargetStatus, $blConvertWay)
; Parameters ....: $TSmsTargetStatus	- TSmsTargetStatus (const)
;				   or					- sSmsTargetStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertSmsTargetStatus($TSmsTargetStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.SmsTargetStatusToText($TSmsTargetStatus)
	Else
		Return $oSkype.Convert.TextToSmsTargetStatus($TSmsTargetStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertSmsTargetStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertPluginContext
; Description ...: Converts plugin context to text or vice versa
; Syntax.........: _Skype_ConvertPluginContext($TPluginContext, $blConvertWay)
; Parameters ....: $TPluginContext	- TPluginContext (const)
;				   or				- sPluginContext
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertPluginContext($TPluginContext, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.PluginContextToText($TPluginContext)
	Else
		Return $oSkype.Convert.TextToPluginContext($TPluginContext)
	EndIf
EndFunc   ;==>_Skype_ConvertPluginContext


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertPluginContactType
; Description ...: Converts plugin contact type to text or vice versa
; Syntax.........: _Skype_ConvertPluginContactType($TPluginContactType, $blConvertWay)
; Parameters ....: $TPluginContext	- TPluginContactType (const)
;				   or				- sPluginContactType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertPluginContactType($TPluginContactType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.PluginContactTypeToText($TPluginContactType)
	Else
		Return $oSkype.Convert.TextToPluginContactType($TPluginContactType)
	EndIf
EndFunc   ;==>_Skype_ConvertPluginContactType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertFileTransferType
; Description ...: Converts file transfer type to text or vice versa
; Syntax.........: _Skype_ConvertFileTransferType($TFileTransferType, $blConvertWay)
; Parameters ....: $TFileTransferType	- TFileTransferType (const)
;				   or					- sTFileTransferType
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertFileTransferType($TFileTransferType, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.FileTransferTypeToText($TFileTransferType)
	Else
		Return $oSkype.Convert.TextToFileTransferType($TFileTransferType)
	EndIf
EndFunc   ;==>_Skype_ConvertFileTransferType


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertFileTransferStatus
; Description ...: Converts file transfer status to text or vice versa
; Syntax.........: _Skype_ConvertFileTransferStatus($TFileTransferStatus, $blConvertWay)
; Parameters ....: $TFileTransferStatus	- TFileTransferStatus (const)
;				   or					- sFileTransferStatus
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertFileTransferStatus($TFileTransferStatus, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.FileTransferStatusToText($TFileTransferStatus)
	Else
		Return $oSkype.Convert.TextToFileTransferStatus($TFileTransferStatus)
	EndIf
EndFunc   ;==>_Skype_ConvertFileTransferStatus


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ConvertFileTransferFailureReason
; Description ...: Converts file transfer failure reason to text or vice versa
; Syntax.........: _Skype_ConvertFileTransferFailureReason($TFileTransferFailureReason, $blConvertWay)
; Parameters ....: $TFileTransferFailureReason	- TFileTransferFailureReason (const)
;				   or							- sFileTransferFailureReason
;				   $blConvertWay	- True to convert const to text
;									- False to convert text to const
; Return values .: Success      - Converted const or text
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ConvertFileTransferFailureReason($TFileTransferFailureReason, $blConvertWay)
	If $blConvertWay Then
		Return $oSkype.Convert.FileTransferFailureReasonToText($TFileTransferFailureReason)
	Else
		Return $oSkype.Convert.TextToFileTransferFailureReason($TFileTransferFailureReason)
	EndIf
EndFunc   ;==>_Skype_ConvertFileTransferFailureReason


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_FileTransfersGetDetails
; Description ...: Queries details of all file transfers
; Syntax.........: _Skype_FileTransfersGetDetails()
; Parameters ....: None
; Return values .: Success      - Details of all file transfers (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_FileTransfersGetActiveDetails
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_FileTransfersGetDetails()
	Local Const $iFileTransferCount = $oSkype.FileTransfers.Count
	If $iFileTransferCount = 0 Then Return 0

	Local $aFileTransfer[$iFileTransferCount], $i = 0

	For $oTransfer In $oSkype.FileTransfers
		$aFileTransfer[$i] = __Skype_FTDetails($oTransfer)
		$i += 1
	Next

	Return $aFileTransfer
EndFunc   ;==>_Skype_FileTransfersGetDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_FileTransfersGetActiveDetails
; Description ...: Queries details of all active file transfers
; Syntax.........: _Skype_FileTransfersGetActiveDetails()
; Parameters ....: None
; Return values .: Success      - Details of all active file transfers (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: _Skype_FileTransfersGetDetails
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_FileTransfersGetActiveDetails()
	Local Const $iFileTransferCount = $oSkype.ActiveFileTransfers.Count
	If $iFileTransferCount = 0 Then Return 0

	Local $aFileTransfer[$iFileTransferCount], $i = 0

	For $oTransfer In $oSkype.ActiveFileTransfers
		$aFileTransfer[$i] = __Skype_FTDetails($oTransfer)
		$i += 1
	Next

	Return $aFileTransfer
EndFunc   ;==>_Skype_FileTransfersGetActiveDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SMSSend
; Description ...: Sends an SMS message
; Syntax.........: _Skype_SendSMS($iPhoneNumber, $sMessage)
; Parameters ....: $iPhoneNumber	- Phone number
;				   $sMessage		- Message to send
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SMSSend($iPhoneNumber, $sMessage)
	$oSkype.SendSms($iPhoneNumber, $sMessage)

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SMSSend


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SMSGetDetails
; Description ...: Gets SMSs contents sent for the current user
; Syntax.........: _Skype_SMSGetDetails()
; Parameters ....: None
; Return values .: Success      - SMSs contents (array)
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: $aSMSs[$i][11] returns an array
;				   $aSMSs[$i][14] returns an array
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SMSGetDetails()
	Local $iSMSsCount = $oSkype.Smss.Count
	If $iSMSsCount = 0 Then Return 0

	Local $aSMSs[$iSMSsCount][11], $i = 0, $sSMSContents = ""

	For $oSms In $oSkype.Smss
		$aSMSs[$i][0] = $oSms.Id
		$aSMSs[$i][1] = __Skype_TimestampToDate($oSms.Timestamp)
		$aSMSs[$i][2] = $oSms.Type
		$aSMSs[$i][3] = $oSms.Type
		$aSMSs[$i][4] = $oSms.Status
		$aSMSs[$i][5] = $oSms.FailureReason
		$aSMSs[$i][6] = $oSms.IsFailedUnseen
		$aSMSs[$i][7] = $oSms.Price
		$aSMSs[$i][8] = $oSms.PricePrecision
		$aSMSs[$i][9] = $oSms.PriceCurrency
		$aSMSs[$i][10] = $oSms.ReplyToNumber

		$sSMSContents = ""
		For $oTarget In $oSms.Targets
			$sSMSContents &= $oTarget.Number & "," & $oTarget.Status & Chr(0)
		Next
		$aSMSs[$i][11] = StringSplit($sSMSContents, Chr(0))

		$aSMSs[$i][12] = $oSms.ReplyToNumber
		$aSMSs[$i][13] = $oSms.Body

		$sSMSContents = ""
		For $oChunk In $oSms.Chunks
			$sSMSContents &= $oChunk.Id & "," & $oChunk.Text & Chr(0)
		Next
		$aSMSs[$i][14] = StringSplit($sSMSContents, Chr(0))
	Next

	Return $sSMSContents
EndFunc   ;==>_Skype_SMSGetDetails


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_SMSMessageDelete
; Description ...: Deletes an SMS message
; Syntax.........: _Skype_SMSMessageDelete($oSms)
; Parameters ....: $oSms	- Sms object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_SMSMessageDelete($oSms)
	$oSms.SmsMessage.Delete

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_SMSMessageDelete


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ApplicationCreate
; Description ...: Creates the application context
; Syntax.........: _Skype_ApplicationCreate()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ApplicationCreate()
	$oSkype.Application.Create

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ApplicationCreate


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_ApplicationDelete
; Description ...: Deletes the application context
; Syntax.........: _Skype_ApplicationDelete($oApp)
; Parameters ....: $oApp	- Application object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_ApplicationDelete($oApp)
	$oApp.Application.Delete

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_ApplicationDelete


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CreateEvent
; Description ...: Creates a plug-in event
; Syntax.........: _Skype_CreateEvent($sEventId, $sCaption, $sHint)
; Parameters ....: $sEventId	- Unique identifier for the plug-in event
;				   $sCaption	- Caption text
;				   $sHint		- Hint text
; Return values .: Success      - Event object
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CreateEvent($sEventId, $sCaption, $sHint)
	Return $oSkype.Client.CreateEvent($sEventId, $sCaption, $sHint)
EndFunc   ;==>_Skype_CreateEvent


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_CreateEvent
; Description ...: Creates a menu item for a plug-in
; Syntax.........: _Skype_CreateMenuItem($sEventId, $sCaption, $sHint)
; Parameters ....: $sMenuItemId			- Unique identifier for menu item
;				   $cPluginContext		- Plug-in context
;				   $sCaption			- Caption text for the menu item
;				   $sHint				- Hint text for the menu item (optional)
;				   $sIconPath			- Path to an icon file (optional)
;				   $blEnabled			- Defines the initial state of the menu item (optional)
;				   $cContactType		- Contact type and is relevant only
;				   $blMultipleContacts	- Defines whether multiple contacts are allowed for this menu item
; Return values .: Success      - Menuitem object
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_CreateMenuItem($sMenuItemId, $cPluginContext, $sCaption, $sHint = "", $sIconPath = "", $blEnabled = True, _
		$cContactType = $cPluginContactTypeAll, $blMultipleContacts = False)
	Return $oSkype.Client.CreateMenuItem($sMenuItemId, $cPluginContext, $sCaption, $sHint, $sIconPath, $blEnabled, _
			$cContactType, $blMultipleContacts)
EndFunc   ;==>_Skype_CreateMenuItem


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_PluginEventDelete
; Description ...: Deletes a plug-in event from the events pane in the Skype client
; Syntax.........: _Skype_PluginEventDelete($oPluginEvent)
; Parameters ....: $oPluginEvent	- Plugin event object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_PluginEventDelete($oPluginEvent)
	$oPluginEvent.PluginEvent.Delete

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_PluginEventDelete


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_PluginMenuItemDelete
; Description ...: Removes a menu item from "Do More" menus
; Syntax.........: _Skype_PluginMenuItemDelete($oPluginEvent)
; Parameters ....: $oPluginMenuItem	- Plugin menu item object
; Return values .: Success      - 0
;                  Failure      - 1 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_PluginMenuItemDelete($oPluginMenuItem)
	$oPluginMenuItem.PluginMenuItem.Delete

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_PluginMenuItemDelete


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_VoicemailClearHistory
; Description ...: Clears voicemail history
; Syntax.........: _Skype_VoicemailClearHistory()
; Parameters ....: None
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_VoicemailClearHistory()
	$oSkype.ClearVoicemailHistory

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_VoicemailClearHistory


; #FUNCTION# ====================================================================================================================
; Name...........: _Skype_VoicemailDelete
; Description ...: Deletes a voicemail object
; Syntax.........: _Skype_VoicemailDelete($oVM)
; Parameters ....: $oVM	- Voicemail object
; Return values .: Success      - 1
;                  Failure      - 0 [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Skype_VoicemailDelete($oVM)
	$oVM.Voicemail.Delete

	Return __Skype_GetCommandReply()
EndFunc   ;==>_Skype_VoicemailDelete


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Skype_FTDetails
; Description ...: Queries details of a file transfer
; Syntax.........: __Skype_FTDetails($aTransfer)
; Parameters ....: $oTransfer	- FT object
; Return values .: Success      - FT details (array)
;                  Failure      - [Sets an error event]
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Skype_FTDetails($oTransfer)
	Local $aReturn[10]

	$aReturn[0] = $oTransfer.Id
	$aReturn[1] = $oTransfer.StartTime
	$aReturn[2] = $oTransfer.FinishTime
	$aReturn[3] = $oTransfer.Type
	$aReturn[4] = $oTransfer.Status
	$aReturn[5] = $oTransfer.PartnerHandle & "(" & $oTransfer.PartnerDisplayName & ")"
	$aReturn[6] = $oTransfer.FilePath
	$aReturn[7] = $oTransfer.BytesTransferred
	$aReturn[8] = $oTransfer.BytesPerSecond
	$aReturn[9] = $oTransfer.FailureReason

	Return $aReturn
EndFunc   ;==>__Skype_FTDetails


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Skype_SendCommand
; Description ...: Sends a command to the Skype client and gets it's result
; Syntax.........: __Skype_SendCommand($sCommandArg1, $sCommandArg2 = "")
; Parameters ....: $sCommandArg1	- First command argument to send
;				   $sCommandArg2	- Second command argument to send (optional)
; Return values .: Success      - Command result
;                  Failure      - 0 and sets an error event
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: __Skype_GetCommandReply
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __Skype_SendCommand($sCommandArg1, $sCommandArg2 = "")
;~ 	Local $aSpaceSplit = StringSplit($sCommandArg1, Chr(32), 1)
;~ 	Local $aOutCmdSpaceSplit[4]

	$oSkype.SendCommand($oSkype.Command(1, $sCommandArg1, $sCommandArg2, False, 5000))

	Return __Skype_GetCommandReply()
EndFunc   ;==>__Skype_SendCommand


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Skype_GetCommandReply
; Description ...: Gets a command result
; Syntax.........: __Skype_GetCommandReply()
; Parameters ....: None
; Return values .: Success      - Command result
;                  Failure      - @error and sets an error event
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......: __Skype_SendCommand
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Skype_GetCommandReply()
	Local Const $hTimer = TimerInit()

	While $sOutCmd = ""
		;Wait for the cmd reply

		If TimerDiff($hTimer) < $_iTimeout Then ContinueLoop

		;In case there is a problem (i.e: command overflow)
		Return SetError(1, 0, "ERROR_TIMEDOUT")
	WEnd

	Local $aOutCmdSpaceSplit = StringSplit($sOutCmd, " ", 1)

	If $aOutCmdSpaceSplit[0] = 1 Then Return SetError(2, 0, "ERROR_UNKNOWNREPLY")
	If $aOutCmdSpaceSplit[2] = "ERROR" Then Return SetError(3, 0, "ERROR_CMDFAILED")

	Local $sReturn = StringTrimLeft($sOutCmd, StringInStr($sOutCmd, " ", 2, 1))
	$sOutCmd = ""

	Return $sReturn
EndFunc   ;==>__Skype_GetCommandReply


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Skype_TimestampToDate
; Description ...: Converts a Skype's timestamp to date
; Syntax.........: __Skype_TimestampToDate($iTimestamp)
; Parameters ....: $iTimestamp	- Timestamp to convert
; Return values .: Success      - Date
;                  Failure      -
; Author ........: FireFox (d3mon)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Skype_TimestampToDate($iTimestamp)
	Return StringLeft($iTimestamp, 4) & "/" & _
			StringMid($iTimestamp, 4, 2) & "/" & _
			StringMid($iTimestamp, 6, 2) & " " & _
			StringMid($iTimestamp, 8, 2) & ":" & _
			StringMid($iTimestamp, 10, 2) & ":" & _
			StringMid($iTimestamp, 12, 2)
EndFunc   ;==>__Skype_TimestampToDate


#region Skype_Event
;This event indicates the API response to the command object
Func Skype_Reply($oCmd)
	If IsObj($oCmd) = 1 And StringInStr($oCmd.Reply, "#") > 0 Then
		Local Const $aOutCmd = StringSplit($oCmd.Reply, Chr(32))

		If $aOutCmd[2] = "ERROR" Then
			Local $iError = 0, $sError = ""

			$iError = $aOutCmd[3]
			$sError = StringTrimLeft($oCmd.Reply, StringInStr($oCmd.Reply, $aOutCmd[4], 1) - 1)

			Call($sOnError, $iError, $sError)
		Else
			$sOutCmd = $oCmd.Reply
;~ 			ConsoleWrite($sOutCmd & @CrLf) ;Debug
		EndIf
	EndIf
EndFunc   ;==>Skype_Reply


;This event indicates the error number and description associated with a bad command object
Func Skype_Error($oError2)
	MsgBox(0, "AutoIt.Error", "err.number is: " & @TAB & $oError2.number & @CRLF & _
			"err.windescription:" & @TAB & $oError2.windescription & @CRLF & _
			"err.description is: " & @TAB & $oError2.description & @CRLF & _
			"err.source is: " & @TAB & $oError2.source & @CRLF & _
			"err.helpfile is: " & @TAB & $oError2.helpfile & @CRLF & _
			"err.helpcontext is: " & @TAB & $oError2.helpcontext & @CRLF & _
			"err.lastdllerror is: " & @TAB & $oError2.lastdllerror & @CRLF & _
			"err.scriptline is: " & @TAB & $oError2.scriptline & @CRLF & _
			"err.retcode is: " & @TAB & $oError2.retcode)
EndFunc   ;==>Skype_Error


;This event is caused by a change in the status of an attachment to the Skype API
Func Skype_AttachmentStatus($TAttachmentStatus)
	If $TAttachmentStatus = $cAttachAvailable Then $oSkype.Attach()

	Return Call($sOnAttachmentStatus, $TAttachmentStatus)
EndFunc   ;==>Skype_AttachmentStatus


;This event is caused by a connection status change
Func Skype_ConnectionStatus($TConnectionStatus)
	Return Call($sOnConnectionStatus, $TConnectionStatus)
EndFunc   ;==>Skype_ConnectionStatus


;This event is caused by a user status change
Func Skype_UserStatus($TUserStatus)
	Return Call($sOnUserStatus, $TUserStatus)
EndFunc   ;==>Skype_UserStatus


;This event is caused by a change in the online status of a user
Func Skype_OnlineStatus($oUser, $TOnlineStatus)
	Return Call($sOnOnlineStatus, $oUser.Handle, $TOnlineStatus)
EndFunc   ;==>Skype_OnlineStatus


;This event is caused by a change in call status
Func Skype_CallStatus($oCall, $TCallStatus)
	Return Call($aOnCallStatus[$TCallStatus + 1], $oCall)
EndFunc   ;==>Skype_CallStatus


;This event is caused by a change in call history
Func Skype_CallHistory()
	Return Call($sOnCallHistory)
EndFunc   ;==>Skype_CallHistory


;This event is caused by a change in mute status
Func Skype_Mute($iMute)
	Local $blMute = False
	If $iMute = -1 Then $blMute = True
	Return Call($sOnMute, $blMute)
EndFunc   ;==>Skype_Mute


;This event is caused by a change in chat message status
Func Skype_MessageStatus($oMsg, $TChatMessageStatus)
	Return Call($aOnMessageStatus[$TChatMessageStatus + 1], $oMsg)
EndFunc   ;==>Skype_MessageStatus


;This event is caused by a change in message history
Func Skype_MessageHistory($sUserHandle)
	Return Call($sOnMessageHistory, $sUserHandle)
EndFunc   ;==>Skype_MessageHistory


;This event is caused by a change of auto away status
Func Skype_AutoAway($blAutoAway)
	Return Call($sOnAutoAway, $blAutoAway)
EndFunc   ;==>Skype_AutoAway


;This event is caused by a call DTMF event
Func Skype_CallDtmfReceived($oCall, $sCode)
	Return Call($sOnCallDtmfReceived, $oCall, $sCode)
EndFunc   ;==>Skype_CallDtmfReceived


;This event is caused by a change in voicemail status
Func Skype_VoicemailStatus($oVM, $TVoicemailStatus)
	Return Call($sOnVoiceMailStatus, $oVM, $TVoicemailStatus)
EndFunc   ;==>Skype_VoicemailStatus


;This event is caused by users connecting to an application
Func Skype_ApplicationConnecting($oApp, $oUsers)
	Return Call($sOnAppConnecting, $oApp, $oUsers)
EndFunc   ;==>Skype_ApplicationConnecting


;This event is caused by a change in application streams
Func Skype_ApplicationStreams($oApp, $oStreams)
	;This function isn't handled
EndFunc   ;==>Skype_ApplicationStreams

;This event is caused by the arrival of an application datagram
Func Skype_ApplicationDatagram($oApp, $oStreams, $sText)
	;This function isn't handled
EndFunc   ;==>Skype_ApplicationDatagram

;This event is caused by a change of application sending streams
Func Skype_ApplicationSending($oApp, $oStreams)
	;This function isn't handled
EndFunc   ;==>Skype_ApplicationSending

;This event is caused by a change of application receiving streams
Func Skype_ApplicationReceiving($oApp, $oStreams)
	;This function isn't handled
EndFunc   ;==>Skype_ApplicationReceiving


;This event is caused by the contacts tab gaining or losing focus
Func Skype_ContactsFocused($sUserHandle)
	Return Call($sOnContactsFocused, $sUserHandle)
EndFunc   ;==>Skype_ContactsFocused


;This event is caused by a user hiding/showing a group in the contacts tab
Func Skype_GroupVisible($oGroup, $blVisible)
	Return Call($sOnGroupVisible, $oGroup.Id, $oGroup.Type, $oGroup.DisplayName, $blVisible)
EndFunc   ;==>Skype_GroupVisible


;This event is caused by a user expanding or collapsing a group in the contacts tab
Func Skype_GroupExpanded($oGroup, $blExpanded)
	Return Call($sOnGroupExpanded, $oGroup.Id, $oGroup.Type, $oGroup.DisplayName, $blExpanded)
EndFunc   ;==>Skype_GroupExpanded


;This event is caused by a change in a contact group
Func Skype_GroupUsers($oGroup, $oUsers)
	Local $sUsersHandles

	For $oUser In $oUsers
		$sUsersHandles &= $oUser.Handle & Chr(0)
	Next

	Return Call($sOnGroupUsers, $oGroup.Id, $oGroup.Type, $oGroup.DisplayName, StringSplit($sUsersHandles, Chr(0)))
EndFunc   ;==>Skype_GroupUsers


;This event is caused by a user deleting a custom contact group
Func Skype_GroupDeleted($iGroupId)
	Return Call($sOnGroupDeleted, $iGroupId)
EndFunc   ;==>Skype_GroupDeleted


;This event is caused by a change in the mood text of the user
Func Skype_UserMood($oUser, $sMoodText)
	Return Call($sOnUserMood, $oUser, $sMoodText)
EndFunc   ;==>Skype_UserMood


;This event is caused by a change in the SMS message status
Func Skype_SmsMessageStatusChanged($oSms, $TSmsMessageStatus)
	Return Call($sOnSmsMessageStatusChanged, $oSms, $TSmsMessageStatus)
EndFunc   ;==>Skype_SmsMessageStatusChanged


;This event is caused by a change in the SMS target status
Func Skype_SmsTargetStatusChanged($oTarget, $TSmsTargetStatus)
	Return Call($sOnSmsTargetStatusChanged, $oTarget.Message.Id, $oTarget.Number, $TSmsTargetStatus)
EndFunc   ;==>Skype_SmsTargetStatusChanged


;This event is caused by a change in the Call voice input status change
Func Skype_CallInputStatusChanged($oCall, $blStatus)
	Return Call($sOnCallInputStatusChanged, $oCall, $blStatus)
EndFunc   ;==>Skype_CallInputStatusChanged


;This event occurs when a search is completed
Func Skype_AsyncSearchUsersFinished($iCookie, $oUsers)
	Local $sUsers

	For $oUser In $oUsers
		$sUsers &= $oUsers & Chr(0)
	Next

	Return Call($sOnAsyncSearchUsersFinished, StringSplit($sUsers, Chr(0)))
EndFunc   ;==>Skype_AsyncSearchUsersFinished


;This event occurs when the seen status of a call changes
Func Skype_CallSeenStatusChanged($oCall, $blStatus)
	Return Call($sOnCallSeenStatusChanged, $oCall, $blStatus)
EndFunc   ;==>Skype_CallSeenStatusChanged


;This event occurs when a user clicks on a plug-in event
Func Skype_PluginEventClicked($oEvent)
	Return Call($sOnPluginEventClicked, $oEvent.Id)
EndFunc   ;==>Skype_PluginEventClicked


;This event occurs when a user clicks on a menu item
Func Skype_PluginMenuItemClicked($oMenuItem, $oUsers, $TPluginContext, $sContextId)
	Local $aPluginMenuItem[5], $sUsers = ""

	$aPluginMenuItem[0] = $oMenuItem.Id
	$aPluginMenuItem[1] = $TPluginContext
	$aPluginMenuItem[2] = $sContextId

	For $oUser In $oUsers
		$sUsers &= $oUser & Chr(0)
	Next

	$aPluginMenuItem[3] = StringSplit($sUsers, Chr(0))

	Return Call($sOnPluginMenuItemClicked, $aPluginMenuItem)
EndFunc   ;==>Skype_PluginMenuItemClicked


;This event occurs when a wallpaper changes
Func Skype_WallpaperChanged($sPath)
	Return Call($sOnWallpaperChanged, $sPath)
EndFunc   ;==>Skype_WallpaperChanged


;This event occurs when a file transfer status changes
Func Skype_FileTransferStatusChanged($oTransfer, $TFileTransferStatus)
	Return Call($sOnFileTransferStatusChanged, $oTransfer, $TFileTransferStatus)
EndFunc   ;==>Skype_FileTransferStatusChanged


;This event occurs when a call transfer status changes
Func Skype_CallTransferStatusChanged($oCall, $TCallStatus)
	Return Call($sOnCallTransferStatusChanged, $oCall, $TCallStatus)
EndFunc   ;==>Skype_CallTransferStatusChanged


;This event occurs when a chat members change
Func Skype_ChatMembersChanged($oChat, $oMembers)
	Local $sUsers = ""

	For $oUser In $oMembers
		$sUsers &= $oUser & Chr(0)
	Next

	Return Call($sOnChatMembersChanged, $oChat, StringSplit($sUsers, Chr(0)))
EndFunc   ;==>Skype_ChatMembersChanged


;This event occurs when a chat member role changes
Func Skype_ChatMemberRoleChanged($oMember, $TChatMemberRole)
	;This function isn't handled
EndFunc   ;==>Skype_ChatMemberRoleChanged


;This event occurs when a call video status changes
Func Skype_CallVideoStatusChanged($oCall, $TCallVideoStatus)
	Return Call($sOnCallVideoStatusChanged, $oCall, $TCallVideoStatus)
EndFunc   ;==>Skype_CallVideoStatusChanged


;This event occurs when a call video send status changes
Func Skype_CallVideoSendStatusChanged($oCall, $TCallVideoSendStatus)
	Return Call($sOnCallVideoSendStatusChanged, $oCall, $TCallVideoSendStatus)
EndFunc   ;==>Skype_CallVideoSendStatusChanged


;This event occurs when a call video receive status changes
Func Skype_CallVideoReceiveStatusChanged($oCall, $TCallVideoSendStatus)
	Return Call($sOnCallVideoReceiveStatusChanged, $oCall, $TCallVideoSendStatus)
EndFunc   ;==>Skype_CallVideoReceiveStatusChanged


;This event occurs when a silent mode is switched off
Func Skype_SilentModeStatusChanged($blSilent)
	Return Call($sOnSilentModeStatusChanged, $blSilent)
EndFunc   ;==>Skype_SilentModeStatusChanged


;This event occurs when user changes Skype client language
Func Skype_UILanguageChanged($sCode)
	Return Call($sOnUILanguageChanged, $sCode)
EndFunc   ;==>Skype_UILanguageChanged


;This event occurs when user sends you authorization request
Func Skype_UserAuthorizationRequestReceived($oUser)
	Return Call($sOnUserAuthRequestReceived, $oUser)
EndFunc   ;==>Skype_UserAuthorizationRequestReceived
#endregion Skype_Event
