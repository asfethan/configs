import XMonad hiding ((|||))
import Data.Ratio ((%))
import XMonad.Actions.NoBorders
import XMonad.Actions.Plane
import XMonad.Actions.OnScreen
import XMonad.Config.Gnome
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Circle
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Magnifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.ShowWName
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Workspace
import XMonad.Util.Run
import XMonad.Util.Loggers
import XMonad.Util.EZConfig
import XMonad.Util.NamedWindows (getName)
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import System.IO

myFont = "xft:Tahoma:size=8"
myFgHiColor = "#fdf6e3"
myFgNoColor = "#073642"
myBgColor	= "#002b36"
--myFgNoColor = "#7298b8"

myTheme :: Theme
myTheme = defaultTheme
	{ 
		activeColor		= myFgHiColor	-- tab BG / active
		,inactiveColor		= myBgColor	-- tab BG / inactive
		,urgentColor		= myBgColor	-- tab BG / urgent
		,activeTextColor	= myBgColor	-- tab FG / active
		,inactiveTextColor	= "#dfdfdf"	-- tab FG / inactive
		,urgentTextColor	= "#ff0000"	-- tab FG / urgent
		,activeBorderColor	= myFgHiColor   -- tab BD / active
		,inactiveBorderColor	= myFgNoColor	-- tab BD / inactive 
		,urgentBorderColor	= "#ff0000"	-- tab BD / urgent
		,fontName		= myFont
		,decoHeight		= 18
	}

myShellPrompt = defaultXPConfig
       {
		font				= "-*-terminus-medium-r-*-*-14-*-*-*-*-*-iso10646-1"
		, bgColor           = myFgNoColor
		, fgColor           = "#dfdfdf"
		, fgHLight          = "#34302c"
		, bgHLight          = myFgHiColor
		, borderColor       = myFgHiColor
		, promptBorderWidth = 0
		, position          = Bottom
		, height            = 20
		, defaultText       = []
       }
 
myManageHook = composeAll . concat $
	[ 
	  [ className		=? c --> doFloat				| c <- floatsList ]
	, [ className		=? c --> doIgnore				| c <- ignoresList ]
	, [ className		=? c --> doF (W.shift "web")	| c <- toWeb ]
	, [ className		=? c --> doF (W.shift "com")	| c <- toCom ]
	, [ className		=? c --> doF (W.shift "tab")	| c <- toTab ]
	, [ className		=? c --> doF (W.shift "fun")	| c <- toFun ]
	, [ className		=? c --> doF (W.shift "uti")	| c <- toUti ]
	, [ className		=? c --> doF (W.shift "vms")	| c <- toVms ]
	, [ isDialog		-->	doCenterFloat ]
	]

ignoresList = []

toWeb = [ "Iceweasel", "Firefox", "Navigator", "Minefield", "chromium-browser", "Chromium-browser" ]
toCom = [ "Pidgin", "Skype", "Gwibber", "gwibber", "gajim.py", "Gajim.py", "claws-mail", "Claws-mail", "ts3client_linux_amd64", "Ts3client_linux_amd64" ]
toUti = [ "keepassx", "Keepassx", "gnomint" ]
toTab = [ "evolution", "Evolution" ]
toFun = [	"mplayer"
			,"MPlayer"
			,"ffplay"
			,"smplayer"
			,"Smplayer"
			,"vlc"
			,"Vlc"
			,"Gimp"
			,"gimp"
			,"Gimp-2.6"
			,"gimp-2.6"
			,"Inkscape"
			,"inkscape"
			,"gimp-2.8"
			,"Gimp-2.8"
			,"Steam"
			,"steam"
		]
toVms = [	 "vmware"
			,"virtualbox"
			,"VirtualBox"
			,"wine"
			,"Wine"
		]

floatsList = [	"pinentry-gtk-2"
				,"pinentry"
				,"Pinentry"
				,"cryptkeeper"
				,"Cryptkeeper"
				,"spring"
				,"Spring"
				,"ffplay"
				,"smplayer"
				,"Smplayer"
				,"mplayer"
				,"MPlayer"
				,"vlc"
				,"Vlc"
				,"kupfer.py"
				,"Kupfer.py"
				,"ASA.exe"
			 ]

myWorkspaces = ["rem", "loc", "web", "com", "tab", "fun", "uti", "vms" ]

defaultKeys = keys defaultConfig
newKeys x = foldr M.delete (defaultKeys x) (removedKeys x)
myKeys x = (newKeys x) `M.union` (addedKeys x)

addedKeys conf = mkKeymap conf $
	[ 
		("M-p", shellPrompt myShellPrompt)
		,("M-a g", spawn "/usr/bin/gvim")
		,("M-a f", spawn "firefox")
		,("M-a s", spawn "/usr/bin/smplayer")
		,("M-a c", spawn "/usr/bin/claws-mail")
--		Multimedia keys
--		,("M-m", spawn "/usr/bin/mocp -p")
		,("M-x", spawn "/usr/bin/xscreensaver-command -lock")
		,("M-u", spawn "/usr/bin/uzbl")
--		,("M-z", spawn "sleep 5 && /usr/bin/xset dpms force off")
		,("<XF86AudioLowerVolume>", spawn "/usr/bin/amixer set -c 0 Master 2%- unmute")
		,("<XF86AudioRaiseVolume>", spawn "/usr/bin/amixer set -c 0 Master 2%+ unmute")
		,("<XF86AudioMute>", spawn "/usr/bin/amixer set -c 0 Master toggle")
		,("<XF86AudioPlay>", spawn "/usr/bin/mocp -G")
		,("<XF86AudioNext>", spawn "/usr/bin/mocp -f")
		,("<XF86AudioPrev>", spawn "/usr/bin/mocp -r")
		,("<XF86AudioStop>", spawn "/usr/bin/mocp -s")
		,("M-<Return>", spawn $ XMonad.terminal conf)
		,("M-<Up>",  sendMessage $ Go U)
		,("M-<Down>", sendMessage $ Go D)
		,("M-<Left>", sendMessage $ Go L)
		,("M-<Right>",sendMessage $ Go R)
		,("M-S-<Up>", sendMessage $ Swap U)
		,("M-S-<Down>", sendMessage $ Swap D)
		,("M-S-<Left>", sendMessage $ Swap L)
		,("M-S-<Right>", sendMessage $ Swap R)
		,("M-S-<Return>", windows W.swapMaster)
	]
	++
	[

		(m ++ "M4-" ++ "<F" ++ show k ++ ">", windows $ f i) | (i, k) <- zip myWorkspaces [ 1 .. 12 ]
--		, (f, m) <- [(W.view, ""), (W.shift, "S-")]
		, (f, m) <- [(viewOnScreen 0, ""), (W.shift, "S-")]
	]

removedKeys conf@(XConfig {XMonad.modMask = modm}) =
	[
		(modm, xK_p)
		,(modm, xK_r)
		,(modm, xK_m)
		,(modm, xK_Return)
		,(modm .|. shiftMask, xK_Return)
	]
	++
	[
		(modm, k) | k <- [xK_1 .. xK_9]
	]
	++
	[
		(shiftMask, k) | k <- [xK_1 .. xK_9]
	]

main = do
	mainSbar	<- spawnPipe "/usr/bin/xmobar /home/jpetras/.xmobarrc"
	xmonad	$ withUrgencyHookC NoUrgencyHook urgencyConfig { suppressWhen = Focused } $ defaultConfig
		{
			manageHook = myManageHook <+> manageDocks
			,startupHook = windows (viewOnScreen 1 "vms")
--			,logHook		= ewmhDesktopsLogHook >> dynamicLogWithPP ( myPP mainSbar )
			,logHook		= ewmhDesktopsLogHook >> dynamicLogWithPP xmobarPP
				{ ppOutput = hPutStrLn mainSbar
				, ppTitle				= wrap (" <fc=#586e75>«</fc><fc=#eee8d5> ") (" </fc><fc=#586e75>»</fc>") . shorten 75
				, ppCurrent 			= wrap ("<fc=" ++ myBgColor ++ "," ++ myFgHiColor ++ "> ") " </fc>"
				, ppVisible 			= wrap " " " "
				, ppHidden				= wrap "<fc=#dfdfdf,#073642> " " </fc>"
				, ppHiddenNoWindows		= wrap "<fc=#586e75,#002b36> " " </fc>"
				, ppUrgent				= wrap "<fc=#fdf6e3,#cb4b16> " " </fc>"
				, ppSep					= ""
				, ppWsSep				= ""
				, ppLayout				= wrap "<fc=,#073642> </fc><fc=#eee8d5> " " </fc><fc=,#073642> </fc> " .
					(\x -> case x of
						"Magrid"	-> "MGRD"
						"Tall"		-> "TALL"
						"Mirror"	-> "MIRR"
						"Full"		-> "FULL"
						"TrueFull"	-> "TFUL"
						"Tabbed"	-> "TABB"
						"Grid"		-> "GRID"
						"GIMP"		->"^GIMP"
					)
				}

			,terminal 		= "xterm"
			,normalBorderColor	= myFgNoColor
			,focusedBorderColor	= myFgHiColor
			,modMask		= mod4Mask
            ,focusFollowsMouse = False
			,borderWidth		= 1
			,workspaces		= myWorkspaces
			,keys			= myKeys
			,layoutHook		= myLayout
		}


myLayout = windowNavigation
        $ smartBorders
		$ onWorkspace "web" (tabs)
		$ onWorkspace "com" (tabs)
		$ onWorkspace "tab" (tabs)
		$ onWorkspace "fun" (tfull)
		$ onWorkspace "vms" (tfull)
        $ (htiled ||| vtiled ||| magrid ||| full ||| tabs ||| grid)

	 where
		htiled = named "Tall" (avoidStrutsOn [U,D] (Tall 1 (3/100) (1/2)))
		vtiled = named "Mirror" (avoidStrutsOn [U,D] (Mirror (Tall 1 (3/100) (1/2))))
		magrid = named "Magrid" (desktopLayoutModifiers (magnifier (Grid)))
		full   = named "Full" (avoidStrutsOn [U,D] (noBorders (Full)))
		tfull  = named "TrueFull" (lessBorders (OnlyFloat) ( noBorders (Full)))
		tabs   = named "Tabbed" (avoidStrutsOn [U,D] (smartBorders (tabbed shrinkText myTheme)))
		grid   = named "Grid" (avoidStrutsOn [U,D] (Grid))
-- EOF
