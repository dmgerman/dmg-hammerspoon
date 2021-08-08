--- === dmg ===
---
--- dmg hammerspoon
---

local obj={}
obj.__index = obj

-- metadata

obj.name = "dmg"
obj.version = "0.1"
obj.author = "dmg <dmg@uvic.ca>"
obj.homepage = "https://github.com/dmgerman/dmg-spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- do this at the beginning in case we have an error
hs.hotkey.bind(
   {"cmd", "alt", "ctrl"}, "R",
   function() hs.reload()
end)



-- desk monitors
local lg49hdmi='9014FD62-F9BA-D7B5-3D19-FC1626C9B248'
local lg49dp='A7FC8831-E694-B548-0857-D6964E3302DB'


-- make sure it is loaded
--hs.loadSpoon("WinWin")

obj.wstate = {}

local gmailTitle = 'dmgerman@gmail'
local main_monitor = "LC49G95T"
local emacsTitle = 'emacsclient'

local speakers = 'ddd'
local headphones = 'ddd'
local bluehead = 'ddd'


defaultAudioDevice = 'External Headphones'

function obj:print_table0(t)
   for i,v in ipairs(t) do
      print(i, v)
   end
end


function obj:print_table(t, f)
    for i,v in ipairs(t) do
       print(i, f(v))
    end
end

function obj:print_windows()
   function w_info(w)
      return w:title() .. w:application():name()
   end
   obj:print_table(hs.window.visibleWindows(), w_info)
end

--function obj:print_windows()
-- for i,v in ipairs(hs.window.visibleWindows()) do
--       print(i, v:title(), v:application():name())
--   end
--end

------------------
-- select audio by command


local function list_audio_choices()
   local audiochoices = {}
   local current = hs.audiodevice.defaultOutputDevice()
   for i,v in ipairs(hs.audiodevice.allOutputDevices()) do
      if v:name() ~= current:name() then
         table.insert(audiochoices, {text = v:name(), idx=i})
      end
   end
   return audiochoices
end

local audioChooser = hs.chooser.new(function(choice)
      if not choice then hs.alert.show("Nothing chosen"); return end
      local idx = choice["idx"]
      local name = choice["text"]
      dev = hs.audiodevice.allOutputDevices()[idx]
      if not dev:setDefaultOutputDevice() then
         hs.alert.show("Unable to enable audio output device " .. name)
      else
         hs.alert.show("Audio output device is now: " .. name)
      end
end)


hs.hotkey.bind({"cmd", "alt"}, "A", function()
      local audioChoices = list_audio_choices()
      audioChooser:choices(audioChoices)
      audioChooser:placeholderText(defaultAudioDevice)
      audioChooser:show()
end)

-------------------------------
-- select window by title

theWindows = hs.window.filter.new()
theWindows:setDefaultFilter{}
theWindows:setSortOrder(hs.window.filter.sortByFocusedLast)
obj.currentWindows = {}
obj.previousSelection = nil  -- the idea is that one switches back and forth between two windows all the time

for i,v in ipairs(theWindows:getWindows()) do
   table.insert(obj.currentWindows, v)
end

local function callback_window_created(w, appName, event)

   if event == "windowDestroyed" then
--      print("deleting from windows-----------------", w)
      for i,v in ipairs(obj.currentWindows) do
         if v == w then
            table.remove(obj.currentWindows, i)
            return
         end
      end
--      print("Not found .................. ", w)
--      obj:print_table0(obj.currentWindows)
--      print("Not found ............ :()", w)
      return
   end
   if event == "windowCreated" then
--      print("inserting into windows.........", w)
      table.insert(obj.currentWindows, 1, w)
      return
   end
   if event == "windowFocused" then
      --otherwise is equivalent to delete and then create
      callback_window_created(w, appName, "windowDestroyed")
      callback_window_created(w, appName, "windowCreated")
--      obj:print_table0(obj.currentWindows)
   end
end
theWindows:subscribe(hs.window.filter.windowCreated, callback_window_created)
theWindows:subscribe(hs.window.filter.windowDestroyed, callback_window_created)
theWindows:subscribe(hs.window.filter.windowFocused, callback_window_created)

local function list_window_choices()
   local windowChoices = {}
--   for i,v in ipairs(theWindows:getWindows()) do
   for i,w in ipairs(obj.currentWindows) do
      if w ~= hs.window.focusedWindow() then
         table.insert(windowChoices, {
                         text = w:title() .. "--" .. w:application():name(),
                         subText = w:application():name(),
                         uuid = i,
                         image = hs.image.imageFromAppBundle(w:application():bundleID()),
                         win=w})
      end
   end
   return windowChoices;
end

local windowChooser = hs.chooser.new(function(choice)
      if not choice then hs.alert.show("Nothing to focus"); return end
      local v = choice["win"]
      if v then
         v:focus()
      else
         hs.alert.show("unable fo focus " .. name)
      end
end)


hs.hotkey.bind({"alt"}, "b", function()
      local windowChoices = list_window_choices()
      windowChooser:choices(windowChoices)
      --windowChooser:placeholderText('')
      windowChooser:rows(12)         
      windowChooser:query(nil)         
      windowChooser:show()
end)

-------------------
function obj:isfullscreen(cwin)
   local cwin = hs.window.focusedWindow()
   local cscreen = cwin:screen()
   local ff = cscreen:frame()
   local wf = cwin:frame()
   return (ff.w < wf.w + 20) and (ff.h < wf.h + 20)
end

function obj:isvfullscreen(cwin)
   local cwin = hs.window.focusedWindow()
   local cscreen = cwin:screen()
   local ff = cscreen:frame()
   local wf = cwin:frame()
   return (ff.h < wf.h + 20)
end


function obj:fullscreen()
   local cwin = hs.window.focusedWindow()

   local cscreen = cwin:screen()
   local cres = cscreen:frame()
   local cwinid = cwin:id()
   local winf = cwin:frame()

   if obj.isfullscreen(cwin) then
      local oldwinf = obj.wstate[cwinid]
      if oldwinf then
         cwin:setFrame(oldwinf)
      else
         --         obj.wstate[cwinid] = winf
         cwin:setFrame({x=cres.x/2, y=cres.y/2, w=cres.w/2, h=cres.h/2})
      end
   else
      -- set  to full screen
      obj.wstate[cwinid] = winf
      cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
   end
end

function obj:verticalfullscreen()
   local cwin = hs.window.focusedWindow()

   local cscreen = cwin:screen()
   local cres = cscreen:frame()
   local cwinid = cwin:id()
   local winf = cwin:frame()

   if obj.isvfullscreen(cwin) then

      local oldwinf = obj.wstate[cwinid]
      if oldwinf then
         cwin:setFrame(oldwinf)
      else
         cwin:setFrame({x=cres.x/2, y=cres.y/2, w=cres.w/2, h=cres.h/2})
      end
   else
      obj.wstate[cwinid] = winf
      cwin:setFrame({x=winf.x, y=cres.y, w=winf.w, h=cres.h})
      
   end
end


function obj:bind_itunes()
   hs.hotkey.bind(dmgmash, "space", function()
                     hs.itunes.playpause()
   end)
   hs.hotkey.bind(dmgmash, ",", function()
                     hs.itunes.rw()
   end)
   hs.hotkey.bind(dmgmash, ".", function()
                     hs.itunes.ff()
   end)
end

dmgmash = {"alt"}
dmgmashshift = {"alt", 'shift'}


hs.hotkey.bind(dmgmash, "m", function()
                  print("Calling full screen")
                  obj.fullscreen()
end)

hs.hotkey.bind(dmgmash, "v", function()
                  print("Calling vertical full screen")
                  obj.verticalfullscreen()
end)

hs.hotkey.bind(dmgmash, "a", function()
                  hs.window.filter.focusWest()
end)

hs.hotkey.bind(dmgmash, "0", function()
                  hs.window.frontmostWindow():sendToBack()
end)


hs.hotkey.bind(dmgmash, "f", function()
                  hs.window.filter.focusEast()
end)

hs.hotkey.bind(dmgmash, "n", function()
                  hs.window.filter.focusNorth()
end)

hs.hotkey.bind(dmgmash, "p", function()
                  hs.window.filter.focusSouth()
end)

hs.hotkey.bind(dmgmash, "g", function()
                  
                  if (not obj:focus_by_title(gmailTitle))  then
                     hs.alert.show(" no gmail... doing it the hard way")
                     s = hs.execute("/Users/dmg/bin/goto_gmail.py", true)
                     obj:focus_by_title(gmailTitle)
                  end
end)

hs.hotkey.bind(dmgmashshift, "g", function()
                  obj:focus_by_title(emacsTitle)
end)
hs.hotkey.bind(dmgmashshift, "y", function()
                  obj:focus_by_title("youtube")
end)

hs.hotkey.bind(dmgmash, "e", function()
                  hs.application.launchOrFocus("emacs")
end)

;;;;;;;;;;;;;;;;
   
if spoon.WinWin then
   hs.hotkey.bind(dmgmash, "home", function()
                     spoon.WinWin:moveAndResize("halfleft")
   end)
   hs.hotkey.bind(dmgmash, "pageup", function()
                     spoon.WinWin:moveAndResize("halfright")
   end)
   hs.hotkey.bind(dmgmashshift, "home", function()
                     spoon.WinWin:moveAndResize("cornerNW")
   end)
   hs.hotkey.bind(dmgmashshift, "pageup", function()
                     spoon.WinWin:moveAndResize("cornerNE")
   end)
   hs.hotkey.bind(dmgmash, "end", function()
                     spoon.WinWin:moveAndResize("cornerSW")
   end)
   hs.hotkey.bind(dmgmash, "pagedown", function()
                     spoon.WinWin:moveAndResize("cornerSE")
   end)

end

-- place windows according to the display


-- application, window title, screen,
---        rectangle (can be geometry(x,y, w,h) in proportions e.g. (0.5,0.5, .75, .75))
--                it can be a function
--         full frame rectangle ? who knows
--         function to compare window titles, if nill use ==
local wide_layout= {
   {"Emacs",         nil,        main_monitor, hs.geometry.rect(0.7, 0, 0.3, 1),   nil, nil},
   {"Google Chrome", nil,        main_monitor, hs.geometry.rect(0.4, 0, 0.3, 1),   nil, nil},
   {"Google Chrome", gmailTitle, main_monitor, hs.geometry.rect(0, 0, 0.3, 1),     nil, nil},
}

--reorganize my windows to the main ones I use
hs.hotkey.bind(dmgmash, '9', function()
                  hs.application.launchOrFocus('Emacs')
                  hs.application.launchOrFocus('Google Chrome')
                  hs.layout.apply(wide_layout)
end)

---------------------------------------------
-- zoom

zoomStatusMenuBarItem = hs.menubar.new(nil)
zoomStatusMenuBarItem:setClickCallback(function()
      spoon.Zoom:toggleMute()
end)

updateZoomStatus = function(event)
   hs.printf("updateZoomStatus(%s)", event)
   if (event == "from-running-to-meeting") then
      zoomStatusMenuBarItem:returnToMenuBar()
   elseif (event == "muted") then
      zoomStatusMenuBarItem:setTitle("🙊") --🙈😡🔴
   elseif (event == "unmuted") then
      zoomStatusMenuBarItem:setTitle("😈") --🎥
   elseif (event == "from-meeting-to-running") or (event == "from-running-to-closed") then
      zoomStatusMenuBarItem:removeFromMenuBar()
   end
end
hs.loadSpoon("Zoom")
spoon.Zoom:setStatusCallback(updateZoomStatus)
spoon.Zoom:start()
hs.hotkey.bind(dmgmash, 'f13', function()
                  spoon.Zoom:toggleMute()
end)
hs.hotkey.bind(dmgmash, 'f14', function()
                  spoon.Zoom:toggleVideo()
end)


-----------------------------------------
-- to go specific destinations

function currentSelection()
   local elem=hs.uielement.focusedElement()
   local sel=nil
   if elem then
      sel=elem:selectedText()
   end
   if (not sel) or (sel == "") then
      hs.eventtap.keyStroke({"cmd"}, "c")
      hs.timer.usleep(20000)
      sel=hs.pasteboard.getContents()
   end
   return (sel or "")
end

function selectionToJisho()
   term = currentSelection()
   local url = "open Https://jisho.org/search/" .. term
   print(term)
   print("to go to do")
   print(url)
   hs.execute(url)   
--   hs.pasteboard.setContents("https://jisho.org/search/" .. term)
--   hs.timer.usleep(20000)
--   hs.eventtap.keyStroke({"cmd"}, "v")
end

hs.hotkey.bind({'cmd', 'ctrl'}, 'j', function()
      selectionToJisho()
end)

hs.alert.show("trial areaa")

function first_display()
   return hs.screen.primaryScreen()
end
function second_display()
   return hs.screen.primaryScreen()
end

fdisp =  hs.screen.find(1):getUUID()
fdisp2 = hs.screen.find(2):getUUID()

local config = {
   spaces = {
      {
         text = "Deep",
         subText = "Work on focused work.",
         blacklist = {'distraction'},
         intentRequired = true
      },
      {
         text = "gmail",
         subText = "Do email",
         intentRequired = true
      },
      {
         text = "zoom",
         subText = "Talk to people.",
--         blacklist = {'focus'},
         image = hs.image.imageFromAppBundle('us.zoom.xos'),
         launch = {'communication'},
         funcs = 'example',
         layouts = {
            {"zoom.us", nil, fdisp,  hs.geometry.rect(0,0  ,0.5,0.5)},
            {"OBS",     nil, fdisp2, hs.geometry.rect(0,0.5,0.5,1)}
         },
      }
   },
   Applications = {
      ['com.apple.finder'] = {
         bundleID = 'com.apple.finder',
         hyperKey = 'f',
         tags = {'communication'}
      },
      ['us.zoom.xos'] = {
         bundleID = 'us.zoom.xos',
         layouts = {
            {"zoom.us", nil, nil, hs.geometry.rect{0,400,1048,800}}
         },
         tags = {'communication'}
      },
      ['obs'] = {
         bundleID = 'com.obsproject.obs-studio',
         tags = {'communication'}
      },
      ['com.microsoft.VSCode'] = {
         bundleID = 'com.microsoft.VSCode',
         tags = {'focus'},
      },
   },
   funcs = {
      example = {
         setup = function()
            print("Setting up the example workspace")
         end,
         teardown = function()
            print("Ending up the example workspace")
         end
      }
   }
}

-- Load spoon
-- https://www.hammerspoon.org/docs/hs.html#loadSpoon


hs.loadSpoon('Headspace')
--spoon.Headspace:start()
--   :bindHotKeys({ choose = {{'control', 'alt', 'cmd'}, 'space'}})
--   :setTogglKey('string of toggl API key')
--   :loadConfig(config)


--------------------
-- window management


local editor = "Emacs"
obj.quick_edit_app = nil

hs.hotkey.bind(
    {"alt"},
    "`",
    function()
        print("Entering function")
        local emacs = hs.application.find(editor)
        local current_app = hs.window.focusedWindow()
        if current_app:title():sub(1, 5) == editor then
            if obj.quick_edit_app == nil then
                hs.alert("🤔 No edit in progress")
                return
            end
            hs.eventtap.keyStroke({"cmd", "shift"}, ";")
            hs.eventtap.keyStrokes("(dmg/quick-edit-end)")
            hs.eventtap.keyStroke({}, "return")
            obj.quick_edit_app:focus()
            os.execute("sleep " .. tonumber(1))
            hs.eventtap.keyStroke({"cmd"}, "a")
            hs.eventtap.keyStroke({"cmd"}, "v")
            obj.quick_edit_app = nil
        else
            obj.quick_edit_app = hs.window.focusedWindow()
            hs.eventtap.keyStroke({"cmd"}, "a")
            hs.eventtap.keyStroke({"cmd"}, "c")
            print("activating emacs")
            emacs:activate()
            os.execute("sleep " .. tonumber(1))
            --            hs.eventtap.keyStroke({"command", "shift"}, ";")
            hs.eventtap.keyStroke({"cmd", "shift"}, ";")
            hs.eventtap.keyStrokes("(dmg/quick-edit)")
            hs.eventtap.keyStrokes("\n")

--            hs.eventtap.keyStroke({}, "ESCAPE")
            --os.execute("sleep " .. tonumber(1))
            --hs.eventtap.keyStrokes("xdmg/quick-edit\n")
            --os.execute("sleep " .. tonumber(1))
            --hs.eventtap.keyStrokes("\ntest...\n")
            --hs.eventtap.keyStroke({"ctrl"}, "p")

        end
    end
)

-- from diego zamboni
function currentSelection()
   local elem=hs.uielement.focusedElement()
   local sel=nil
   if elem then
      sel=elem:selectedText()
   end
   if (not sel) or (sel == "") then
      hs.eventtap.keyStroke({"cmd"}, "c")
      hs.timer.usleep(20000)
      sel=hs.pasteboard.getContents()
   end
   return (sel or "")
end

obj.emacs = nil
obj.current_win = nil

function do_emacs()
   -- this is a callback to wait until other keys are consumed
   obj.emacs:activate()
   hs.eventtap.keyStroke({"cmd", "shift"}, ";")
   hs.eventtap.keyStrokes("(dmg/hs-edit-begin)")
   hs.eventtap.keyStrokes("\n")
end

function edit_in_emacs(everything)
   print("Entering")
   editor = "Emacs"
--   do return end

   obj.emacs = hs.application.find(editor)
   obj.current_win = hs.window.focusedWindow()
   if obj.current_win:title():sub(1, 5) == "Emacs" then
      hs.alert("🤔 already in emacs")
   else
      -- i think it is more useful iis there is a selection
      -- we use the clipboard to communicate both ways with emacs...
      -- there could be other ways, but this is simple and effective
      if everything then
         hs.eventtap.keyStroke({"cmd"}, "a")
      end
      hs.eventtap.keyStroke({"cmd"}, "c")
      hs.timer.doAfter(0.5,do_emacs)
   end
end

function emacs_sends_back(everything)
   -- the text is in the clipboard
   -- enable the original window and see what happens
   -- this is usually run by emacs using hs
   -- hs -c "emacs_sends_back()"

   print("emacs is sendinb back the text")

   if not obj.current_win then
      hs.alert("No current window active")
   else
      if (obj.current_win:focus()) then
         if everything then
            hs.eventtap.keyStroke({"cmd"}, "a")
         end
         hs.eventtap.keyStroke({"cmd"}, "v")
      else
         hs.alert("Window to send back text does not exist any more")
      end
   end

end


hs.hotkey.bind({"alt"}, '2', nil, function()
      print("abcdef")
      edit_in_emacs(True)
end)

hs.hotkey.bind({"alt", "shift"}, '2', nil, function()
      print("Edit in emacs only selection")
      edit_in_emacs(False)
end)



hs.hotkey.bind({"alt"}, '3', nil, function()
      print("rebinding cmd v")
      local emacs = hs.application.find(editor)
      local current_app = hs.window.focusedWindow()
      if current_app:title():sub(1, 5) == "Emacs" then
         hs.alert("🤔 already in emacs")
      else
         hs.eventtap.keyStroke({"cmd"}, "a")
         hs.eventtap.keyStroke({"cmd"}, "c")
      end
end)

---------------------

require ("hs.ipc")

if not hs.ipc.cliStatus() then
   hs.alert("hs nOT installed.. installing")
   hs.ipc.cliInstall('/Users/dmg/')
end




hs.alert.show("dmg config loaded")

return obj
