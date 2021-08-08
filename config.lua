-- Specify Spoons which will be loaded
hspoon_list = {
    "AClock",
    -- "BingDaily",
    -- "Calendar",
    -- "CircleClock",
    "ClipShow",
    "CountDown",
    "FnMate",
    "HCalendar",
    --"HSaria2",
    "HSearch",
    -- "KSheet",
    --"SpeedMenu",
    -- "TimeFlow",
    -- "UnsplashZ",
    "WinWin",
    "dmg",
    "Zoom"
}

-- appM environment keybindings. Bundle `id` is prefered, but application `name` will be ok.
hsapp_list = {
    {key = 'a', name = 'Atom'},
    {key = 'c', id = 'com.google.Chrome'},
--    {key = 'd', name = 'ShadowsocksX'},
    {key = 'e', name = 'Emacs'},
    {key = 'f', name = 'Finder'},
    {key = 'i', name = 'iTerm'},
--    {key = 'k', name = 'KeyCastr'},
--    {key = 'l', name = 'Sublime Text'},
--    {key = 'm', name = 'MacVim'},
--    {key = 'o', name = 'LibreOffice'},
    {key = 'p', name = 'mpv'},
    {key = 'r', name = 'VimR'},
    {key = 's', name = 'Safari'},
    {key = 't', name = 'Terminal'},
    {key = 'v', id = 'com.apple.ActivityMonitor'},
    {key = 'w', name = 'Mweb'},
    {key = 'y', id = 'com.apple.systempreferences'},
}

-- Modal supervisor keybinding, which can be used to temporarily disable ALL modal environments.
hsupervisor_keys = {{"cmd", "shift", "ctrl"}, "Q"}

-- Reload Hammerspoon configuration
hsreload_keys = {{"cmd", "shift", "ctrl"}, "R"}

-- Toggle help panel of this configuration.
hshelp_keys = {{"alt", "shift"}, "/"}

-- aria2 RPC host address
hsaria2_host = "http://localhost:6800/jsonrpc"
-- aria2 RPC host secret
hsaria2_secret = "token"

----------------------------------------------------------------------------------------------------
-- Those keybindings below could be disabled by setting to {"", ""} or {{}, ""}

-- Window hints keybinding: Focuse to any window you want
hswhints_keys = {"alt", "tab"}

-- appM environment keybinding: Application Launcher
hsappM_keys = {"alt", "E"}

-- clipshowM environment keybinding: System clipboard reader
hsclipsM_keys = {"alt", "C"}

-- Toggle the display of aria2 frontend
hsaria2_keys = {"alt", "D"}

-- Launch Hammerspoon Search
hsearch_keys = {{"alt", "ctrl"}, "G"}

-- Read Hammerspoon and Spoons API manual in default browser
hsman_keys = {"alt", "H"}

-- countdownM environment keybinding: Visual countdown
hscountdM_keys = {"alt", "I"}

-- Lock computer's screen
hslock_keys = {"alt", "ctrl", "alt", "shift", "L"}

-- resizeM environment keybinding: Windows manipulation
hsresizeM_keys = {"alt", "R"}

-- cheatsheetM environment keybinding: Cheatsheet copycat
hscheats_keys = {"alt", "S"}

-- Show digital clock above all windows
hsaclock_keys = {"alt", "T"}

-- Type the URL and title of the frontmost web page open in Google Chrome or Safari.
hstype_keys = {"alt", "ctrl", "V"}

-- Toggle Hammerspoon console
hsconsole_keys = {"alt", "Z"}

---------------

hs.loadSpoon("SpoonInstall")

hyper = {"cmd","alt","ctrl"}
myGrid = { w = 6, h = 4 }

Install=spoon.SpoonInstall


Install:andUse("WindowGrid",
               {
                  config = { gridGeometries =
                                { { myGrid.w .."x" .. myGrid.h } } },
                  hotkeys = {show_grid = {hyper, "g"}},
                  start = true
               }
)

--- move then to next, previous screen

Install:andUse("WindowScreenLeftAndRight",
               {
                  config = {
                     animationDuration = 0
                  },
                  hotkeys = 'default',
                  --                 loglevel = 'debug'
               }
)

Install:andUse("WindowHalfsAndThirds",
               {
                  config = {
                     use_frame_correctness = true
                  },
                  hotkeys = 'default',
                  loglevel = 'debug'
               }
)
-- load the default keys
spoon.WindowHalfsAndThirds:bindHotkeys(spoon.WindowHalfsAndThirds.defaultHotkeys)

urlProvides = {
   rhbz = { name = "Red Hat Bugzilla", url = "https://bugzilla.redhat.com/show_bug.cgi?id=%s", },
   lp = { name = "Launchpad Bug", url = "https://launchpad.net/bugs/%s", },
}


Install:andUse("Seal",
               {
                  hotkeys = { show = { {"cmd", "ctrl"}, "space" } },
                  fn = function(s)
                     s:loadPlugins({"apps",
                                    "calc",
                                    "safari_bookmarks",
                                    "urlformats",
                                    "screencapture",
                                    "pasteboard",
                                    "useractions"})
                     s.plugins.safari_bookmarks.always_open_with_safari = false
                     s.plugins.useractions.actions =
                        {
                           ["Hammerspoon docs webpage"] = {
                              url = "http://hammerspoon.org/docs/",
                              icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon),
                           },
                           ["Translate using Jisho"] = {
                              url = "https://jisho.org/search/${query}",
                              icon = 'favicon',
                              keyword = "ji",
                           },
                           ["Kanji damage"] = {
                              url = "http://www.kanjidamage.com/kanji/search?utf8=%E2%9C%93&q=${query}",
                              icon = 'favicon',
                              keyword = 'kd'
                           }
                           
                        }
                     s:refreshAllCommands()
                     s.plugins.urlformats:providersTable(urlProvides)
                  end,
                  start = true,
               }
)
