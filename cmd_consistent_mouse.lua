
function widget:GetInfo()
	return {
		name      = "Consistent mouse press", --widget to override the engine hardcoded retardness
		version   = "0.2",
		desc      = "Left mouse button always selects/unselects and right button does the commands\nAlso left button deactivates the activated command and moves camero with minimap",
		author    = "Pako",
		date      = "2011.12.15",
		license   = "GNU GPL v2",
		layer     = 10,
		enabled   = false --enable default for "new" players --TODO
	}
end

--BUG
--mouse press goes through UI
--area commands wont work perfectly
--custom formations etc. wont work perfectly because they have hardcoded buttons

local unitCMDs = {
[CMD.DEATHWAIT] = true,
    [CMD.ATTACK] = true,
    [CMD.GUARD] = true,
    [CMD.REPAIR] = true,
[CMD.LOAD_UNITS] = true,
[CMD.LOAD_ONTO] = true,
[CMD.RECLAIM] = true,
[CMD.RESURRECT] = true,
[CMD.CAPTURE] = true,
}

local function GetMouseWorldCoors(mx, my, unit)
	local tp,cwc
	if (Spring.IsAboveMiniMap(mx, my)) then
		tp, cwc = Spring.TraceScreenRay(mx, my, not unit, true)
	else
		tp, cwc = Spring.TraceScreenRay(mx, my, not unit)
	end
if tp ~= "ground" then
  cwc = {cwc}
end
	return cwc
end


function widget:MousePress(mx, my, mb)
	local idx, actCmdID, _, _      = Spring.GetActiveCommand()
	--local didx, defCmdID, _, _      = Spring.GetDefaultCommand()
	local alt, ctrl, meta, shift = Spring.GetModKeyState()
local cmdDesc = Spring.GetActiveCmdDesc( idx )
if (mb == 2)then  return false  end --middle
if cmdDesc and mb == 3 and idx ~= 0 then --build commands, force attack, fight etc.
--Spring.SetActiveCommand(idx, 3, false, false, false,false,false,false)
  local options = {""}
  options[#options+1] = alt and "alt" or nil -- #options wont increase if nil is added
  options[#options+1] = shift and "shift" or nil
  options[#options+1] = ctrl and "ctrl" or nil
  --options[#options+1] = meta and "right" or nil --what is right? --TODO
  Spring.GiveOrder(cmdDesc.id, GetMouseWorldCoors(mx, my, unitCMDs[cmdDesc.id] or false), options)--{alt and "alt" or "" .. (ctrl and " ctrl" or "")..( shift and " shift" or "")})
  return true
elseif mb == 1 then
 if Spring.IsAboveMiniMap(mx, my) then
   local _,pos = Spring.TraceScreenRay(mx, my, true, true)
   if pos and #pos > 0 then
    Spring.SetCameraTarget(unpack(pos))
   end
 end
 
 if idx ~= 0 then --first left click disables the activated command(like a build command) but doesn't deselct
  Spring.SetActiveCommand(0)
  return true --remove if conflicts with anything--only disables active command when shift is not held
 elseif not Spring.IsAboveMiniMap(mx, my) then --second left click or if was default, deselcts units
   Spring.SelectUnitArray({})
 end
end

end

function widget:MouseMove(mx, my, mdx, mdy, mb)
	return false
end

function widget:MouseRelease(mx, my, mb)
  return nil
end
