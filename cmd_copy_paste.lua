function widget:GetInfo()
  return {
    name      = "Copy Paste",
    version   = "0.2 test",
    desc      = "Enables ctrl+c, ctrl+v. Copies selection and camera position,\npaste selects copied units and moves camera.\nShift copy/paste copies command queue.\nBindable commandnames: copy_sel_loc, paste_sel_loc",
    author    = "Pako",
    date      = "2011.04.22 - 2011.05.26", --YYYY.MM.DD, created - updated
    license   = "GPL", --Spring widgets should be GPL compatible
    layer     = 0,	--higher layer is loaded last
    enabled   = false  --  loaded by default?
  }
end

--TODO
--fix hardcoded key binding
--copy queue by unitDefID --sort selected units and save one queue per defID

function widget:Initialize()

  widgetHandler:AddAction("copy_sel_loc", copy)
  widgetHandler:AddAction("paste_sel_loc", paste)
--Spring.SendCommands({"bind Ctrl+c luaui copy_sel_loc"})
--Spring.SendCommands({"unbind Ctrl+v pastetext"})
--Spring.SendCommands({"bind Ctrl+v luaui paste_sel_loc"})
end

do
local selected
local camera
--TODO check if only the commander is selected(double ctrl+c)
function copy(cmd, line, words)
  selected = Spring.GetSelectedUnits()
  camera = Spring.GetCameraState()
  return true
end

function paste(cmd, line, words)
  if selected and #selected >= 0 and camera then
    Spring.SetCameraState(camera, 0.2)
    Spring.SelectUnitArray(selected)
    return true
  end
end
end


local queue
local function copyQueue()
  local selected = Spring.GetSelectedUnits()
  if selected and #selected > 0 then
    local queueTable = Spring.GetUnitCommands(selected[1])
    queue = nil
    queue = {}
    for i=1,#queueTable, 1 do
      local com = queueTable[i]
      if i~=1 then
				table.insert(com.options, "shift")
			end
      queue[i] = {com.id, com.params, com.options}
    end
  end
end

local function pasteQueue()
local selected = Spring.GetSelectedUnits()
  if queue and #queue > 0 and selected and #selected > 0 then

    Spring.GiveOrderArrayToUnitArray(selected, queue)
  end
end



function widget:KeyPress(key, mods, isRepeat)
  if mods.ctrl then
    if mods.shift then
        if  key == string.byte('c') then
          copyQueue()
          return true
      elseif key == string.byte('v') then
        pasteQueue()
        return true
      end
    else
    if  key == string.byte('c') then
      copy()
    elseif key == string.byte('v') then
      paste()
    end
    end
  end
end


function widget:Shutdown()

  widgetHandler:RemoveAction("copy_sel_loc", copy)
  widgetHandler:RemoveAction("paste_sel_loc", paste)
  --Spring.SendCommands({"unbindaction copy_sel_loc"})
  --Spring.SendCommands({"unbindaction paste_sel_loc"})

end
