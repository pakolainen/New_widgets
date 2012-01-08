function widget:GetInfo()
  return {
    name      = "Error Logger/Reporter", --WARNING this widget is not tested at all for multiplayer
    version   = "0.1 beta",
    desc      = "Saves Lua errors to a file.\nAdds reloadLastWidget action.\nSends error message to others",
    author    = "Pako",
    date      = "2011.04.22 - 2011.05.29", --YYYY.MM.DD, created - updated
    license   = "GPL", --widgets should be GPL compatible
    layer     = 10,	--higher layer is loaded last
    handler = true,
    enabled   = false  --  loaded by default?
  }
end

--TODO use better hash function
--move reloadLastWidget to other widget?

local receiveNetErrors = false --for lua devs.
local sendNetErrors = true
if receiveNetErrors and sendNetErrors then --can't send and receiva at the same time
  receiveNetErrors = false
end

local errors = {}

local pathToSave = "LuaUI/Widgets/LuaErrorLogs/"
local errorFileName = "localErrors.log"
local netErrorFileName = "netErrors.log"

local files = {}

function widget:Initialize()
  Spring.CreateDir(pathToSave)
  if receiveNetErrors then
    local number
    for line in io.lines(pathToSave..errorFileName) do
      if number then
        errors[number] = line --this fails with multiline errors but we actually need only the crc map
      else
        number = tonumber(line)
      end
    end
    number = nil
    for line in io.lines(pathToSave..netErrorFileName) do
      if number then
        errors[number] = line
      else
        number = tonumber(line)
      end
    end
  end

    widgetHandler.actionHandler:AddAction(widget, "reloadLastWidget", reloadWidget)
    --Spring.SendCommands({"bind y reloadLastWidget"})

end
function widget:Shutdown()
  widgetHandler.actionHandler:RemoveAction(widget, "reloadLastWidget", reloadWidget)
  --Spring.SendCommands({'unbindaction reloadLastWidget'})
  for _,file in pairs(files) do
    file:close()
  end
end

local lastWidgetBasename, lastWidget

function reloadWidget()
 if lastWidgetBasename then
  for name, widget in pairs(widgetHandler.knownWidgets) do
    --Spring.Echo(widget.filename)
				if (widget.filename == lastWidgetBasename) then
					lastWidget = name
					lastWidgetBasename = nil
				end
			end
  if lastWidget then
    widgetHandler:ToggleWidget(lastWidget)
    return true
  end
 end
end


local sendAllErrors

local function saveError(filename, errMsg, crc)
 local errorFile = files[filename]
 errorFile = errorFile or io.open(pathToSave..filename,'a+')
 if errorFile then
  files[filename] = errorFile
  errorFile:seek("end")
  local misc = Game.modName.." "..Game.modVersion.." "..Game.version.." "..os.date()
  errorFile:write("\n"..crc.."  "..misc.."\n")
	errorFile:write(errMsg.."\n")
 end
end


local remStr = "Removed:"
local loadStr ="Loading:"
local errorIn = "Error in"
--Error in GameFrame(): [string "LuaUI/Widgets/ddd.lua"]:314: attempt to index upvalue 'file' (a nil value)
function widget:AddConsoleLine(msg, priority)
  if (string.find (msg, remStr) or string.find (msg, loadStr)) then
    lastWidgetBasename = string.sub(msg, string.len(remStr)+3)
  elseif (string.find (string.sub(msg, 1, 15), errorIn)) then
    local longbytes = VFS.UnpackU32(msg,1,string.len(msg)/4)
    local crc = math.bit_xor(0, unpack(longbytes))
    saveError(errorFileName, msg, crc)
   if string.len(msg) < 500 and sendNetErrors then
    errors[crc] = msg
    Spring.SendLuaUIMsg("lErR"..VFS.PackU32(crc),"allies")
   end
  end
end


function widget:RecvLuaMsg(msg, playerID)
if (msg:sub(1,4)=="lErR") and receiveNetErrors then --report from player
  local crc = VFS.UnpackU32(msg:sub(5))
  if not errors[crc] then
    Spring.Echo("Got Lua error reporting...")
    Spring.SendLuaUIMsg("lErA"..VFS.PackU32(crc),"allies") --we should check if we are spectating or the sender is spectating
  else
    Spring.Echo("Got error collision on report Lua errors.")
  end
elseif (msg:sub(1,4)=="lErS") and receiveNetErrors then --sent msg
  local name = Spring.GetPlayerInfo(playerID)
  local crc = VFS.UnpackU32(msg:sub(5), 5+4)
  local err = msg:sub(9)
  saveError(netErrorFileName, name..": "..err, crc) --dont check collision to see if it was synced error
  if not errors[crc] then
    Spring.Echo("Got Lua error from "..name..": " .. err)
    errors[crc] = err
  else
    Spring.Echo("Got error collision on receive Lua errors.")
  end
elseif (msg:sub(1,4)=="lErA") and sendNetErrors then --asked to send
  local crc = VFS.UnpackU32(msg:sub(5))
  if errors[crc] then
    Spring.SendLuaUIMsg("lErS"..msg:sub(5)..errors[crc],"allies")
    errors[crc] = nil
  end
  if crc == 0 then
    sendAllErrors = true
  end
end
end


local ttt = 0
function widget:Update(dt)
  ttt = ttt+dt
  if ttt < 3 or not lastWidgetBasename then return end
  ttt=0

  local ind,file = next(files)
  if file then
    file:close()
    file = nil
    files[ind] = nil
  end

  if sendAllErrors then
    local msg
    sendAllErrors, msg = next(errors)
    if sendAllErrors then
      Spring.SendLuaUIMsg("lErS"..VFS.PackU32(sendAllErrors)..msg,"allies")
      errors[crc] = nil
    end
  end

end


