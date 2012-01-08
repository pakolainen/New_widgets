--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Undo",
    version   = "0.9 beta",
    desc      = "Key 'u' undoes commands for selected units or selects last commanded units.\nActivated only for builders.",
    author    = "Pako",
    date      = "2010.01.29",
    license   = "GNU GPL, v2 or later",
    layer     = -1,
    enabled   = false  --  loaded by default?
  }
end
--TODO
--bug: when doing undo for single units, undo list pointer is reduced(2nd unit will get 2 undos 3rd 3 ...)
        --undo list pointer should be stored seperately for every unit-could bring difficult bugs
--dont reselect the same units when doing full undo -needs to follow when user changes selected units or maybe just compare
--bug: restores the full queue so already done commands gets undoed too -watch CmdDone callin and save the cmd tags and check when undoing
--redo
--modify customFormations and other custom commanding widgets to call _WG.UndoNotify() so we can store those events too
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local onlyForBuilders = true
local undoDepth = 1 + 10
-- Speedups

local GetUnitDefID     = Spring.GetUnitDefID
local GetSelectedUnits = Spring.GetSelectedUnits

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
  if Spring.GetSpectatingState() or Spring.IsReplay() then
    widgetHandler:RemoveWidget()
    return true
  end

  widgetHandler:AddAction("undo", Undo)
  Spring.SendCommands({"bind u undo"})

WG.UndoNotify = saveCommandsForSelUnits

end

function widget:Shutdown()

  widgetHandler:RemoveAction("undo", Undo)
  Spring.SendCommands({'unbindaction undo'})
  --Spring.SendCommands({'unbind u luaui undo'})
WG.UndoNotify = nil
end

local fullUndo --undo is made fully so following undo will select the previous unit selection first

local lastSelUnits = {}
local saves = {}

local savesC = 0
local save

function Undo()
  local fail, succ = -1, 1 --some bug makes 'U' stuck if returning false
if not save then return fail end
local ss = 0
    local selUnits = GetSelectedUnits()
    if (not (selUnits and #selUnits>0)) or fullUndo then
      if lastSelUnits[savesC] and #lastSelUnits[savesC] > 0 then
        Spring.SelectUnitArray(lastSelUnits[savesC])
        Spring.Echo("Restored selection of "..#lastSelUnits[savesC].." units.")
      end
      fullUndo = false
      return succ
	end
  fullUndo = #selUnits == #lastSelUnits[savesC] --bug -should be compared fully

    for _,unitID in ipairs(selUnits) do

		local saved = save[unitID]

		if saved then
    local orderArray = {}
		for i,cmd in ipairs(saved) do
			if i~=1 then
				table.insert(cmd.options, "shift")
			end
			table.insert(orderArray, {cmd.id, cmd.params, cmd.options})
		end
			--save[unitID] = nil
      Spring.GiveOrderArrayToUnitArray({unitID}, orderArray)
      ss = ss+1
      else
      fullUndo = false
		end
	end

if ss > 0 then
  saves[savesC] = nil
  save = nil

  savesC = savesC - 1
  if savesC == 0 then
    savesC = undoDepth
  end
  save = saves[savesC]
Spring.Echo("Restored command queues for "..ss.." units.")
else
Spring.Echo("No saved queues for selected units.")
end

	return succ
end

function saveCommandsForSelUnits()
  local selUnits = GetSelectedUnits()
   if selUnits and #selUnits>0 then
		savesC = savesC%undoDepth + 1
		saves[savesC] = {}
		save = saves[savesC]
    lastSelUnits[savesC] = selUnits
	end
  local ss = 0
    for i,unitID in ipairs(selUnits) do

      local unitDef = GetUnitDefID(unitID)

      if (not onlyForBuilders) or (unitDef ~= nil) and UnitDefs[unitDef].isBuilder then
        save[unitID] = Spring.GetCommandQueue(unitID)
        ss = ss+1
      end
    end
    --Spring.Echo("saved command queue for "..ss.." units. ")
    fullUndo = false
end

function widget:CommandNotify(commandID, params, options)
--TODO: filter some commands (like all shift commands could be filtered as they dont delete whole queue)
  saveCommandsForSelUnits()
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
