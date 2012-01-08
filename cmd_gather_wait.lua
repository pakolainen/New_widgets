function widget:GetInfo()
  return {
    name      = "Gather/Time Wait",
    version   = "0.9 test",
    desc      = "Replaces shift+wait with gather wait and ctrl+wait with Timewait",
    author    = "Pako",
    date      = "2011.04.26 - 2011.05.27", --YYYY.MM.DD, created - updated
    license   = "GPL", --Spring widgets should be GPL compatible 
    layer     = 0,	--higher layer is loaded last 
    enabled   = false  --  loaded by default?
  }
end


function widget:CommandNotify(id, params, options)
 if id == CMD.WAIT then
   _,options.ctrl,_,options.shift = Spring.GetModKeyState() --probably some fucked up regression in Spring
  if options.shift then
    if options.ctrl then
      Spring.GiveOrder(CMD.TIMEWAIT, {20}, {"shift"})
    else
      Spring.GiveOrder(CMD.GATHERWAIT, {}, {"shift"})
    end
    return true
  elseif options.ctrl then
    Spring.GiveOrder(CMD.TIMEWAIT, {5}, {""})  
    return true
  end
 end
end