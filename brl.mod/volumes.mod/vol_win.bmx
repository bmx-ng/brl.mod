' Copyright (c) 2007-2019 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Import BRL.Bank
Import BRL.LinkedList
Import Pub.Win32
Import BRL.Map

Import "main.bmx"

Import "-lkernel32"
Import "-lshell32"

Extern "win32"
	Function GetDiskFreeSpaceEx:Int(lpDirectoryName:Short Ptr, lpFreeBytesAvailableToCaller:ULong Var, lpTotalNumberOfBytes:ULong Var, lpTotalNumberOfFreeBytes:ULong Var) = "WINBOOL GetDiskFreeSpaceExW(LPCSTR , PULARGE_INTEGER , PULARGE_INTEGER , PULARGE_INTEGER )!"
	Function GetVolumeInformation:Int(lpRootPathName:Short Ptr, lpVolumeNameBuffer:Short Ptr, nVolumeNameSize:Int, ..
		lpVolumeSerialNumber:Int Var, lpMaximumComponentLength:Int Var, lpFileSystemFlags:Int Var, lpFileSystemNameBuffer:Short Ptr, nFileSystemNameSize:Int) = "WINBOOL GetVolumeInformationW(LPCSTR , LPSTR , DWORD , LPDWORD , LPDWORD , LPDWORD , LPSTR , DWORD )!"
	Function GetLogicalDrives:Int() = "DWORD GetLogicalDrives()!"
	Function SetErrorMode:Int(Mode:Int) = "UINT SetErrorMode(UINT )!"

	' volumes
	Function FindFirstVolume:Int(volumeName:Short Ptr, bufferSize:Int) = "HANDLE FindFirstVolumeW(LPSTR , DWORD )!"
	Function FindNextVolume:Int(handle:Int, volumeName:Short Ptr, bufferSize:Int) = "WINBOOL FindNextVolumeW(HANDLE , LPSTR , DWORD )!"
	Function FindVolumeClose:Int(handle:Int) = "WINBOOL FindVolumeClose(HANDLE)!"
	
	' volume paths
	Function GetVolumePathNamesForVolumeName:Int(volumeName:Short Ptr, volumePaths:Short Ptr, bufferSize:Int, copiedSize:Int Ptr) = "WINBOOL GetVolumePathNamesForVolumeNameW(LPCSTR , LPCH , DWORD , PDWORD )!"
	
	Function SHGetFolderPath:Int(hwndOwner:Byte Ptr, nFolder:Int, hToken:Byte Ptr, dwFlags:Int, pszPath:Short Ptr) = "SHGetFolderPathW"
End Extern

Const CSIDL_ADMINTOOLS:Int = $0030
Const CSIDL_ALTSTARTUP:Int = $001d
Const CSIDL_APPDATA:Int = $001a
Const CSIDL_BITBUCKET:Int = $000a
Const CSIDL_CDBURN_AREA:Int = $003b
Const CSIDL_COMMON_ADMINTOOLS:Int = $002f
Const CSIDL_COMMON_ALTSTARTUP:Int = $001e
Const CSIDL_COMMON_APPDATA:Int = $0023
Const CSIDL_COMMON_DESKTOPDIRECTORY:Int = $0019
Const CSIDL_COMMON_DOCUMENTS:Int = $002e
Const CSIDL_COMMON_FAVORITES:Int = $001f
Const CSIDL_COMMON_MUSIC:Int = $0035
Const CSIDL_COMMON_OEM_LINKS:Int = $003a
Const CSIDL_COMMON_PICTURES:Int = $0036
Const CSIDL_COMMON_PROGRAMS:Int = $0017
Const CSIDL_COMMON_STARTMENU:Int = $0016
Const CSIDL_COMMON_STARTUP:Int = $0018
Const CSIDL_COMMON_TEMPLATES:Int = $002d
Const CSIDL_COMMON_VIDEO:Int = $0037
Const CSIDL_COMPUTERSNEARME:Int = $003d
Const CSIDL_CONNECTIONS:Int = $0031
Const CSIDL_CONTROLS:Int = $0003
Const CSIDL_COOKIES:Int = $0021
Const CSIDL_DESKTOP:Int = $0000
Const CSIDL_DESKTOPDIRECTORY:Int = $0010
Const CSIDL_DRIVES:Int = $0011
Const CSIDL_FAVORITES:Int = $0006
Const CSIDL_FLAG_CREATE:Int = $8000
Const CSIDL_FLAG_DONT_VERIFY:Int = $4000
Const CSIDL_FLAG_MASK:Int = $FF00
Const CSIDL_FLAG_NO_ALIAS:Int = $1000
Const CSIDL_FLAG_PER_USER_INIT:Int = $0800
Const CSIDL_FONTS:Int = $0014
Const CSIDL_HISTORY:Int = $0022
Const CSIDL_INTERNET:Int = $0001
Const CSIDL_INTERNET_CACHE:Int = $0020
Const CSIDL_LOCAL_APPDATA:Int = $001c
Const CSIDL_MYMUSIC:Int = $000d
Const CSIDL_MYPICTURES:Int = $0027
Const CSIDL_MYVIDEO:Int = $000e
Const CSIDL_NETHOOD:Int = $0013
Const CSIDL_NETWORK:Int = $0012
Const CSIDL_PERSONAL:Int = $0005
Const CSIDL_PRINTERS:Int = $0004
Const CSIDL_PRINTHOOD:Int = $001b
Const CSIDL_PROFILE:Int = $0028
Const CSIDL_PROGRAM_FILES:Int = $0026
Const CSIDL_PROGRAM_FILES_COMMON:Int = $002b
Const CSIDL_PROGRAM_FILES_COMMONX86:Int = $002c
Const CSIDL_PROGRAM_FILESX86:Int = $002a
Const CSIDL_PROGRAMS:Int = $0002
Const CSIDL_RECENT:Int = $0008
Const CSIDL_RESOURCES:Int = $0038
Const CSIDL_RESOURCES_LOCALIZED:Int = $0039
Const CSIDL_SENDTO:Int = $0009
Const CSIDL_STARTMENU:Int = $000b
Const CSIDL_STARTUP:Int = $0007
Const CSIDL_SYSTEM:Int = $0025
Const CSIDL_SYSTEMX86:Int = $0029
Const CSIDL_TEMPLATES:Int = $0015
Const CSIDL_WINDOWS:Int = $0024
Const CSIDL_MYDOCUMENTS:Int = CSIDL_PERSONAL

Const SHGFP_TYPE_CURRENT:Int = 0

Const SEM_FAILCRITICALERRORS:Int = 1

Global _FOLDERID_NetworkFolder:Int[]=[$D20BEEC4,$49055CA8,$25BF3BAE,$539BA01E]
Global _FOLDERID_ComputerFolder:Int[]=[$0AC0837C,$452ABBF8,$D0790D85,$A77C668E]
Global _FOLDERID_InternetFolder:Int[]=[$4D9F7874,$49044E0C,$B0407B96,$4B3E0CD2]
Global _FOLDERID_ControlPanelFolder:Int[]=[$82A74AEB,$465CAEB4,$97D014A0,$636D34EE]
Global _FOLDERID_PrintersFolder:Int[]=[$76FC4E2D,$4519D6AD,$BD3763A6,$85810656]
Global _FOLDERID_SyncManagerFolder:Int[]=[$43668BF8,$49B2C14E,$7774C997,$B784D784]
Global _FOLDERID_SyncSetupFolder:Int[]=[$F214138,$4A90B1D3,$CB27A9BB,$9A38C5C0]
Global _FOLDERID_ConflictFolder:Int[]=[$4BFEFB45,$4006347D,$0CACBEA5,$927156B0]
Global _FOLDERID_SyncResultsFolder:Int[]=[$289A9A43,$4057BE44,$7A581BA4,$F9E7D776]
Global _FOLDERID_RecycleBinFolder:Int[]=[$B7534046,$4C183ECB,$CD644EBE,$ACD6B74C]
Global _FOLDERID_ConnectionsFolder:Int[]=[$6F0CD92B,$45D12E97,$D1B0FF88,$DDDEB886]
Global _FOLDERID_Fonts:Int[]=[$FD228CB7,$4AE3AE11,$F3164C86,$FEB80A91]
Global _FOLDERID_Desktop:Int[]=[$B4BFCC3A,$424CDB2C,$E97F29B0,$41C6879A]
Global _FOLDERID_Startup:Int[]=[$B97D20BB,$4C97F46A,$365E10BA,$54084308]
Global _FOLDERID_Programs:Int[]=[$A77F5D77,$44C32E2B,$A6ABA2A6,$514A0501]
Global _FOLDERID_StartMenu:Int[]=[$625B53C3,$4EC1AB48,$EFA11FBA,$19FC4641]
Global _FOLDERID_Recent:Int[]=[$AE50C081,$438AEBD2,$098A5586,$7A98342E]
Global _FOLDERID_SendTo:Int[]=[$8983036C,$404B27C0,$2D10088F,$74FDDC10]
Global _FOLDERID_Documents:Int[]=[$FDD39AD0,$46AF238F,$856CB4AD,$C7690348]
Global _FOLDERID_Favorites:Int[]=[$1777F761,$4D8A68AD,$B730BD87,$DD33FA59]
Global _FOLDERID_NetHood:Int[]=[$C5ABBF53,$4121E17F,$62860089,$73C9C26F]
Global _FOLDERID_PrintHood:Int[]=[$9274BD8D,$41C3CFD1,$3FB15EB3,$F458A755]
Global _FOLDERID_Templates:Int[]=[$A63293E8,$48DB664E,$75DF79A0,$F709059E]
Global _FOLDERID_CommonStartup:Int[]=[$82A5EA35,$47C5D9CD,$5DE12996,$6E4E712F]
Global _FOLDERID_CommonPrograms:Int[]=[$0139D44E,$49F26AFE,$AF3D9086,$B8FFE6CA]
Global _FOLDERID_CommonStartMenu:Int[]=[$A4115719,$491DD62E,$4BE77CAA,$67B0E38B]
Global _FOLDERID_PublicDesktop:Int[]=[$C4AA340D,$4863F20F,$7EF8EFAF,$25BAE6F2]
Global _FOLDERID_ProgramData:Int[]=[$62AB5D82,$4DC3FDC1,$0D07DDA9,$975D491D]
Global _FOLDERID_CommonTemplates:Int[]=[$B94237E7,$434757AC,$8CB05191,$F7D1326C]
Global _FOLDERID_PublicDocuments:Int[]=[$ED4824AF,$45A8DCE4,$79FCE281,$34360865]
Global _FOLDERID_RoamingAppData:Int[]=[$3EB685DB,$4CF665F9,$EFE33AA0,$3D9F7265]
Global _FOLDERID_LocalAppData:Int[]=[$F1B32785,$4FCF6FBA,$8E7B559D,$9170157F]
Global _FOLDERID_LocalAppDataLow:Int[]=[$A520A1A4,$4FF61780,$731618BD,$16AFC543]
Global _FOLDERID_InternetCache:Int[]=[$352481E8,$425133BE,$076085BA,$9DCFEDCA]
Global _FOLDERID_Cookies:Int[]=[$2B0F765D,$4171C0E9,$A6088E90,$F64FB811]
Global _FOLDERID_History:Int[]=[$D9DC8A3B,$432EB784,$115A81A7,$6359A730]
Global _FOLDERID_System:Int[]=[$1AC14E77,$4E5D02E7,$B12E44B7,$B79851AE]
Global _FOLDERID_SystemX86:Int[]=[$D65231B0,$4857B2F1,$E7A8CEA4,$277DEAC6]
Global _FOLDERID_Windows:Int[]=[$F38BF404,$42F21D43,$DE670593,$23FC280B]
Global _FOLDERID_Profile:Int[]=[$5E6C858F,$47600E22,$33EAFE9A,$7371B617]
Global _FOLDERID_Pictures:Int[]=[$33E28130,$46764E1E,$39985A83,$BBC33B5C]
Global _FOLDERID_ProgramFilesX86:Int[]=[$7C5A40EF,$4BFCA0FB,$F2C04A87,$8EFAB9E0]
Global _FOLDERID_ProgramFilesCommonX86:Int[]=[$DE974D24,$4D3ED9C6,$45F491BF,$17B92051]
Global _FOLDERID_ProgramFilesX64:Int[]=[$6D809377,$444B6AF0,$77A35789,$0E20023F]
Global _FOLDERID_ProgramFilesCommonX64:Int[]=[$6365D5A7,$45E5F0D,$A5DF687,$7D4F6A6B]
Global _FOLDERID_ProgramFiles:Int[]=[$905E63B6,$494EC1BF,$B7659CB2,$1AD2D332]
Global _FOLDERID_ProgramFilesCommon:Int[]=[$F7F1ED05,$47A29F6D,$D329AEAA,$66F0C617]
Global _FOLDERID_AdminTools:Int[]=[$724EF170,$4FEFA42D,$0EB6269F,$4FBA6F84]
Global _FOLDERID_CommonAdminTools:Int[]=[$D0384E7D,$4797BAC3,$A2CB148F,$B592B329]
Global _FOLDERID_Music:Int[]=[$4BD8D571,$48D36D19,$224297BE,$430E0820]
Global _FOLDERID_Videos:Int[]=[$18989B1D,$455B99B5,$7CAB1C84,$FCDDE474]
Global _FOLDERID_PublicPictures:Int[]=[$B6EBFB86,$413C6907,$C24FF79A,$C57CF0AB]
Global _FOLDERID_PublicMusic:Int[]=[$3214FAB5,$42989757,$A99261BB,$FF44AADE]
Global _FOLDERID_PublicVideos:Int[]=[$2400183A,$49FB6185,$394AD8A2,$A32B602A]
Global _FOLDERID_ResourceDir:Int[]=[$8AD10C31,$42962ADB,$70E4F7A8,$72C93212]
Global _FOLDERID_LocalizedResourcesDir:Int[]=[$2A00375E,$49DE224C,$0D44D1B8,$DC3DEFF7]
Global _FOLDERID_CommonOEMLinks:Int[]=[$C1BAE2D0,$433410DF,$A27ADDBE,$9D7A220B]
Global _FOLDERID_CDBurning:Int[]=[$9E52AB10,$49DFF80D,$3043B8AC,$557868F5]
Global _FOLDERID_UserProfiles:Int[]=[$0762D272,$4BB0C50A,$7D6982A3,$809B72CD]
Global _FOLDERID_Playlists:Int[]=[$DE92C1C7,$4F69837F,$E686BBA3,$234A2031]
Global _FOLDERID_SamplePlaylists:Int[]=[$15CA69B3,$49C130EE,$5E6BE1AC,$B5AF72C3]
Global _FOLDERID_SampleMusic:Int[]=[$B250C668,$4EE1F57D,$0E293CA6,$1FAAD1E7]
Global _FOLDERID_SamplePictures:Int[]=[$C4900540,$4C752379,$E6644B84,$6B71F8FA]
Global _FOLDERID_SampleVideos:Int[]=[$859EAD94,$48AD2E85,$69091AA7,$CDA656CB]
Global _FOLDERID_PhotoAlbums:Int[]=[$69D2CF90,$4FB7FC33,$B0EB0C9A,$3CB4FCF0]
Global _FOLDERID_Public:Int[]=[$DFDF76A2,$4D63C82A,$44566A90,$857345AC]
Global _FOLDERID_ChangeRemovePrograms:Int[]=[$DF7266AC,$48679274,$D63B558D,$2D87DE61]
Global _FOLDERID_AppUpdates:Int[]=[$A305CE99,$492BF527,$767E1A8B,$E4D698FA]
Global _FOLDERID_AddNewPrograms:Int[]=[$DE61D971,$4F025EBC,$826CA9A3,$045C5E89]
Global _FOLDERID_Downloads:Int[]=[$374DE290,$4565123F,$C4396491,$7B465E92]
Global _FOLDERID_PublicDownloads:Int[]=[$3D644C9B,$4F301FB8,$70F6459B,$C0795F23]
Global _FOLDERID_SavedSearches:Int[]=[$7D1D3A04,$4115DEBB,$292FCF95,$DA2029DA]
Global _FOLDERID_QuickLaunch:Int[]=[$52A4F021,$48A97B75,$874B6B9F,$8FBC10A2]
Global _FOLDERID_Contacts:Int[]=[$56784854,$462BC6CB,$E3886981,$82B8AC50]
Global _FOLDERID_TreeProperties:Int[]=[$5B3749AD,$49C1B49F,$3715EB83,$8248BD0F]
Global _FOLDERID_PublicGameTasks:Int[]=[$DEBF2536,$4C59E1A8,$4541A2B6,$EA6A4786]
Global _FOLDERID_GameTasks:Int[]=[$54FAE61,$47874DD8,$29B680,$0B7C420]
Global _FOLDERID_SavedGames:Int[]=[$4C5C32FF,$43B0BB9D,$722DB4B5,$A4AA4EE5]
Global _FOLDERID_Games:Int[]=[$CAC52C1A,$4EDCB53D,$2E6BD792,$3494C18A]
Global _FOLDERID_RecordedTV:Int[]=[$BD85E001,$431E112E,$157B3B98,$F1FF09AC]
Global _FOLDERID_SEARCH_MAPI:Int[]=[$98EC0E18,$4D442098,$97664486,$81A21593]
Global _FOLDERID_SEARCH_CSC:Int[]=[$EE32E446,$4ABA31CA,$EBA54F81,$5E6DFDD2]
Global _FOLDERID_Links:Int[]=[$BFB9D5E0,$404CC6A9,$6DAEB2B2,$6849AFB6]
Global _FOLDERID_UsersFiles:Int[]=[$F3CE0F7C,$4ACC4901,$D4D54886,$8FEF044B]
Global _FOLDERID_SearchHome:Int[]=[$190337D1,$4121B8CA,$476D39A6,$2A97162D]
Global _FOLDERID_OriginalImages:Int[]=[$2C36C0AA,$4B875812,$D04CD0BF,$399BB1DF]

Private

Global _shell32:Byte Ptr = LoadLibraryA("shell32")
Global _ole32:Byte Ptr = LoadLibraryA("ole32")

Public

Global SHGetKnownFolderPath( rfid:Byte Ptr, dwFlags:Int, hToken:Int, ppszPath:Short Ptr Ptr)"win32" =  GetProcAddress( _shell32,"SHGetKnownFolderPath" )
Global CoTaskMemFree(pv:Byte Ptr)"win32" =  GetProcAddress( _ole32,"CoTaskMemFree" )

Global winVolume_driver:TWinVolumeDriver = New TWinVolumeDriver

Type TWinVolumeDriver

	Method New()
		volume_driver = TWinVolume.Create()
	End Method

End Type


Type TWinVolume Extends TVolume

	Const PATH_MAX:Int = $104

	Field vs:TVolSpace

	Function Create:TWinVolume()
		Local this:TWinVolume = New TWinVolume
		
		Return this
	End Function

	Method ListVolumes:TList() Override
		Local volumes:TMap

		' create buffer
		Local nameBuffer:Short[] = New Short[PATH_MAX]
		Local mpBuffer:Short[] = New Short[PATH_MAX]
		
		' get the first volume
		Local handle:Int = FindFirstVolume(nameBuffer, PATH_MAX)
		If handle Then

			volumes = New TMap

			While True

				' retrieve the paths
				Local pathsBuffer:Short[] = New Short[PATH_MAX]
				Local bufferSize:Int
				
				Local paths:String[]

				If GetVolumePathNamesForVolumeName(nameBuffer, pathsBuffer, Self.PATH_MAX, Varptr bufferSize) Then

					paths = String.FromShorts(pathsBuffer, bufferSize).Trim().split("~0")

				' Some error occured - if the buffer was too small we will set it to the
				' right size and try it again
				Else If bufferSize > PATH_MAX Then

					If GetVolumePathNamesForVolumeName(nameBuffer, pathsBuffer, bufferSize, Varptr bufferSize) Then
						paths = String.FromShorts(pathsBuffer, bufferSize).Trim().split("~0")
					EndIf

				EndIf

				For Local path:String = EachIn paths
					volumes.Insert(path, GetVolumeInfo(path))
				Next

				' get the next volume or quit the loop if there is none
				If Not FindNextVolume(handle, nameBuffer, PATH_MAX) Then
					Exit
				End If
			Wend

			' end the volumes search
			FindVolumeClose(handle)

		End If


		' now look for missing drives...
		Local bitmap:Int = GetLogicalDrives()
		
		For Local i:Int = 1 To 26
			If bitmap & 1 Then

				If Not volumes Then
					volumes = New TMap
				End If
				
				Local path:String = Chr(64 + i) + ":\"
				
				If Not volumes.Contains(path) Then
					volumes.Insert(path, GetVolumeInfo(path))
				End If
				
			End If
			
			bitmap:Shr 1
		Next
		
		' return a list of volumes
		If volumes Then
			Local list:TList = New TList
			For Local volume:TVolume = EachIn volumes.Values()
				list.AddLast(volume)
			Next
			
			Return list
		Else
			Return Null
		End If

	End Method
	
	Method GetVolumeFreeSpace:Long(vol:String) Override

		Local _vs:TVolSpace = TVolSpace.GetDiskSpace(vol)
		
		Return _vs.fb
	End Method

	Method GetVolumeSize:Long(vol:String) Override

		Local _vs:TVolSpace = TVolSpace.GetDiskSpace(vol)
		
		Return _vs.tb
	End Method
	
	Method GetVolumeInfo:TVolume(vol:String) Override

		Local Mode:Int = SetErrorMode(SEM_FAILCRITICALERRORS)

		Local volume:TWinVolume = New TWinVolume

		volume.volumeDevice = vol

		Local volname:Short[PATH_MAX]
		Local filesys:Short[PATH_MAX]
		Local snum:Int
		Local maxLength:Int
		Local flags:Int

		Local ret:Int = GetVolumeInformation(volume.volumeDevice, volname, PATH_MAX, ..
			snum, maxLength, flags, filesys, PATH_MAX)

		If ret Then
			volume.volumeName = String.fromWString(volname)
			volume.volumeType = String.fromWString(filesys)
			
			volume.vs = TVolSpace.GetDiskSpace(volume.volumeDevice)
			volume.volumeSize = volume.vs.tb
			volume.volumeFree = volume.vs.fb
			
			volume.available = True
		End If
		
		SetErrorMode(Mode)
				
		Return volume
	End Method

	Method Refresh() Override
		If Not vs Then
			Return
		End If
		
		Local ret:Int = vs.refresh()
		
		If ret Then
			volumeSize = vs.tb
			volumeFree = vs.fb
			
			available = True
		Else
			available = False
		End If
		
	End Method

	Method GetUserHomeDir:String() Override
		Return _getFolderPath(CSIDL_PROFILE)
	End Method
	
	Method GetUserDesktopDir:String() Override
		Return _getFolderPath(CSIDL_DESKTOPDIRECTORY)
	End Method
	
	Method GetUserAppDir:String() Override
		Return _getFolderPath(CSIDL_APPDATA)
	End Method
	
	Method GetUserDocumentsDir:String() Override
		Return _getFolderPath(CSIDL_PERSONAL)
	End Method

	Method GetCustomDir:String(dirType:Int, flags:Int = 0) Override
		If dirType < 0 Then
			Select dirType
				Case DT_USERPICTURES
					Return _getFolderPath(CSIDL_MYPICTURES)
				Case DT_USERMUSIC
					Return _getFolderPath(CSIDL_MYMUSIC)
				Case DT_USERMOVIES
					Return _getFolderPath(CSIDL_MYVIDEO)
			End Select
		Else
			' assume these are CSIDL paths
			Return _getFolderPath(dirType)
		End If
		
		Return Null
	End Method
	
	Method _getFolderPath:String(kind:Int)
		If SHGetKnownFolderPath Then
		
			Local mappedId:Int[] = mapCSIDL(kind)
		
			If mappedId Then
				Local b:Short Ptr
				SHGetKnownFolderPath(mappedId, 0, 0, Varptr b)
				
				Local s:String = String.fromWString(b)
				CoTaskMemFree(b)
				Return s
			End If
		Else
			Local b:Short[] = New Short[MAX_PATH]
		
			Local ret:Int = SHGetFolderPath(Null, kind, Null, SHGFP_TYPE_CURRENT, b)
		
			Return String.fromWString(b)
		End If
	End Method
	
	Method mapCSIDL:Int[](kind:Int)
		Select kind
			Case CSIDL_PROFILE
				Return _FOLDERID_Profile
			Case CSIDL_DESKTOPDIRECTORY
				Return _FOLDERID_Desktop
			Case CSIDL_APPDATA
				Return _FOLDERID_RoamingAppData
			Case CSIDL_PERSONAL
				Return _FOLDERID_Documents
			Case CSIDL_MYPICTURES
				Return _FOLDERID_Pictures
			Case CSIDL_MYMUSIC
				Return _FOLDERID_Music
			Case CSIDL_MYVIDEO
				Return _FOLDERID_Videos
			Case CSIDL_ADMINTOOLS
				Return _FOLDERID_AdminTools
			Case CSIDL_ALTSTARTUP
				Return _FOLDERID_Startup
			Case CSIDL_BITBUCKET
				Return _FOLDERID_RecycleBinFolder
			Case CSIDL_CDBURN_AREA
				Return _FOLDERID_CDBurning
			Case CSIDL_COMMON_ADMINTOOLS
				Return _FOLDERID_CommonAdminTools
			Case CSIDL_COMMON_ALTSTARTUP
				Return _FOLDERID_CommonStartup
			Case CSIDL_COMMON_APPDATA
				Return _FOLDERID_ProgramData
			Case CSIDL_COMMON_DESKTOPDIRECTORY
				Return _FOLDERID_PublicDesktop
			Case CSIDL_COMMON_DOCUMENTS
				Return _FOLDERID_PublicDocuments
			Case CSIDL_COMMON_FAVORITES
				Return _FOLDERID_Favorites
			Case CSIDL_COMMON_MUSIC
				Return _FOLDERID_PublicMusic
			Case CSIDL_COMMON_OEM_LINKS
				Return _FOLDERID_CommonOEMLinks
			Case CSIDL_COMMON_PICTURES
				Return _FOLDERID_PublicPictures
			Case CSIDL_COMMON_PROGRAMS
				Return _FOLDERID_CommonPrograms
			Case CSIDL_COMMON_STARTMENU
				Return _FOLDERID_CommonStartMenu
			Case CSIDL_COMMON_STARTUP
				Return _FOLDERID_CommonStartup
			Case CSIDL_COMMON_TEMPLATES
				Return _FOLDERID_CommonTemplates
			Case CSIDL_COMMON_VIDEO
				Return _FOLDERID_PublicVideos
			Case CSIDL_COMPUTERSNEARME
				Return _FOLDERID_NetworkFolder
			Case CSIDL_CONNECTIONS
				Return _FOLDERID_ConnectionsFolder
			Case CSIDL_CONTROLS
				Return _FOLDERID_ControlPanelFolder
			Case CSIDL_COOKIES
				Return _FOLDERID_Cookies
			Case CSIDL_DESKTOP
				Return _FOLDERID_Desktop
			Case CSIDL_DRIVES
				Return _FOLDERID_ComputerFolder
			Case CSIDL_FAVORITES
				Return _FOLDERID_Favorites
			Case CSIDL_FONTS
				Return _FOLDERID_Fonts
			Case CSIDL_HISTORY
				Return _FOLDERID_History
			Case CSIDL_INTERNET
				Return _FOLDERID_InternetFolder
			Case CSIDL_INTERNET_CACHE
				Return _FOLDERID_InternetCache
			Case CSIDL_LOCAL_APPDATA
				Return _FOLDERID_LocalAppData
			Case CSIDL_NETHOOD
				Return _FOLDERID_NetHood
			Case CSIDL_NETWORK
				Return _FOLDERID_NetworkFolder
			Case CSIDL_PRINTERS
				Return _FOLDERID_PrintersFolder
			Case CSIDL_PRINTHOOD
				Return _FOLDERID_PrintHood
			Case CSIDL_PROGRAM_FILES
				Return _FOLDERID_ProgramFiles
			Case CSIDL_PROGRAM_FILES_COMMON
				Return _FOLDERID_ProgramFilesCommon
			Case CSIDL_PROGRAM_FILES_COMMONX86
				Return _FOLDERID_ProgramFilesCommonX86
			Case CSIDL_PROGRAM_FILESX86
				Return _FOLDERID_ProgramFilesX86
			Case CSIDL_PROGRAMS
				Return _FOLDERID_Programs
			Case CSIDL_RECENT
				Return _FOLDERID_Recent
			Case CSIDL_RESOURCES
				Return _FOLDERID_ResourceDir
			Case CSIDL_RESOURCES_LOCALIZED
				Return _FOLDERID_LocalizedResourcesDir
			Case CSIDL_SENDTO
				Return _FOLDERID_SendTo
			Case CSIDL_STARTMENU
				Return _FOLDERID_StartMenu
			Case CSIDL_STARTUP
				Return _FOLDERID_Startup
			Case CSIDL_SYSTEM
				Return _FOLDERID_System
			Case CSIDL_SYSTEMX86
				Return _FOLDERID_SystemX86
			Case CSIDL_TEMPLATES
				Return _FOLDERID_Templates
			Case CSIDL_WINDOWS
				Return _FOLDERID_Windows
		End Select
	End Method
	
End Type

Type TVolSpace
	Field vol:String
	Field fbc:ULong
	Field tb:ULong
	Field fb:ULong
	
	Function GetDiskSpace:TVolSpace(vol:String)
		Local this:TVolSpace = New TVolSpace
		
		Local dir:Short Ptr = vol.toWString()

		Local ret:Int = GetDiskFreeSpaceEx(dir, this.fbc, this.tb, this.fb)
		
		If dir Then
			MemFree(dir)
		End If
		
		Return this
	End Function
	
	Method refresh:Int()
		Local Mode:Int = SetErrorMode(SEM_FAILCRITICALERRORS)
		
		Local dir:Short Ptr = vol.toWString()

		Local ret:Int = GetDiskFreeSpaceEx(dir, fbc, tb, fb)
		
		If dir Then
			MemFree(dir)
		End If
		
		SetErrorMode(Mode)
		Return ret
	End Method

End Type
