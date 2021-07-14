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



-- make sure it is loaded
--hs.loadSpoon("WinWin")

obj.wstate = {}

local gmailTitle = 'dmgmail - google chrome'
local main_monitor = "LC49G95T"

function obj:print_windows()
   for i,v in ipairs(hs.window.visibleWindows()) do
      print(i, v:title(), v:application():name())
   end
end

function obj:focus_by_title_or_app(st)
   st = st:lower()
   local cwin = hs.window.allWindows()
   for i,v in ipairs(hs.window.allWindows()) do
      if string.match(v:title():lower(), st) or string.match(v:application():name():lower(), st) then
         print('Matching', v:title())
         print(v:application():name())
         v:focus()
         return
      end
   end
   hs.alert.show(st .. " no window matches title or application")
end

function obj:focus_by_expression()
   hs.focus()
   wlist = ''
   for i,v in ipairs(hs.window.visibleWindows()) do
      wlist = wlist .. v:title() .. "\n"
   end

   local result,st = hs.dialog.textPrompt('prompt', wlist, 'default', 'ok', 'cancel')
   if result == 'ok' then
      obj:focus_by_title_or_app(st)
   end
end

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

hs.hotkey.bind(
   {"cmd", "alt", "ctrl"}, "R",
   function() hs.reload()
end)

dmgmash = {"alt"}


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
                  obj:focus_by_title_or_app(gmailTitle)
end)

hs.hotkey.bind(dmgmash, "b", function()
                  obj:focus_by_expression()
end)


hs.hotkey.bind(dmgmash, "e", function()
                  hs.application.launchOrFocus("emacs")
end)



if spoon.WinWin then
   hs.hotkey.bind(dmgmash, "home", function()
                     spoon.WinWin:moveAndResize("cornerNW")
   end)
   hs.hotkey.bind(dmgmash, "end", function()
                     spoon.WinWin:moveAndResize("cornerSW")
   end)
   hs.hotkey.bind(dmgmash, "pageup", function()
                     spoon.WinWin:moveAndResize("cornerNE")
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


hs.alert.show("dmg config loaded")

return obj
