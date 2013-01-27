function widget:GetInfo()
  return {
    name      = "Chili End Game",
    desc      = "End game sounds, graphs and awards",
    version   = "0.23 WIP",
    author    = "Pako",
    date      = "@2012 - 2013",
    license   = "GNU GPL, v2 or later",
    layer     = 10,
    enabled   = true, --  loaded by default?
	detailsDefault = 1
  }
end

local HistoryToTimeScale = (3+(52/60))/14

local Chili
local screen0

local window

local graphers = {}
local graphScales
local grapLabelStack
	  local highLightedLabel = false
	  local teamNamesStack
	  local Craph
	  local myScale 
	  
	  local EnabledStatGraphs = {energyProduced = {enabled = true, lastHist = 1,maxy=0,maxx=0, data = {}}} --TODO

local statNames = { --TODO some kind of ordering system
["energyProduced"] = "\255\200\210\40Energy Produced",
    ["metalProduced"] = "\255\40\100\150Metal Produced",
["unitsReceived"] = "Units Received",
["frame"] = false,
["time"] = false,
    }

local function getPlayerNames(team)
  local players = Spring.GetPlayerList(team)
  local name
  if #players > 0 then
	for i,m in ipairs(players) do --stupid bugs
		local n,_,spec,tID = Spring.GetPlayerInfo(m)
		if ((not spec) and team == tID or team ~= 0)and n then
			name = name and name..'\n'..n or n
		end
	end
  else
    _, name = Spring.GetAIInfo(team)
  end
  return name or 'Gaia'
end



local lshader


local shown
local function hideWindow()
  if shown then
    Chili.Screen0:RemoveChild(window)
    shown = false
  end
end

local function showWindow()
  if not window then 
    makeTheWindow()
  end
    shown = true
  Chili.Screen0:AddChild(window)
  window:BringToFront()
end

Graphs = function(cmd, optLine, optWords, _,isRepeat, release)
  if isRepeat then return true end
  if release then hideWindow(); return false end --FIX return ?
  if shown then
    hideWindow()
  else
    showWindow()
  end
  return true
end

function widget:GameOver(winners)
  showWindow()
end

--[[
function widget:DrawScreen()
    
  gl.DepthTest(true)
  
--  gl.Color(self.lineColor)
  gl.PushMatrix()
  gl.Translate(400, 800, 1)
  gl.Scale(700/10, 500/10, 1)
  gl.UseShader(lshader)
  
  gl.BeginEnd(GL.LINE_STRIP, function() 
    local glVertex = gl.Vertex
    local line = {0.9,1,2.3,6,9,6,2,4}
  
    --glVertex(-1, 1)
  for i=1, #line, 1 do
    glVertex(i, -line[i])
  end
    --glVertex(#line+2, -line[#line]-1)
end)

  gl.UseShader(0)
  gl.PopMatrix()
  gl.Color(1,1,1,1)
end
--]]

------
--[[
require("keysym.lua")
function widget:KeyPress(keyCode, modKeys, isRepeat, keySet, unicode)
  if not shown then return end
  
  if keyCode == KEYSYMS.TAB then
    hideDialog()
  elseif keyCode == KEYSYMS.ENTER or keyCode == KEYSYMS.RETURN then
      hideDialog()
  end
end--]]
---------

function widget:Initialize()
--[[
		if gl.CreateShader then
    lshader = gl.CreateShader(shaderTable1)
    Spring.Echo(gl.GetShaderLog())
    if lshader then
	Spring.Echo("SUUCCEESS")
    else
      Spring.Echo("shader fail")
    end
  end
  --]]
	if (not WG.Chili) then
		widgetHandler:RemoveWidget()
		return
	end

	Chili = WG.Chili
	widgetHandler:AddAction("show_grapher", Graphs)
	Spring.SendCommands("bind tab show_grapher")
	makeTheWindow()
	showWindow()
end

function makeTheWindow()
  
  local function drawGraphLines(self) 
    local glVertex = gl.Vertex
    local line = self.lineData
  
    --glVertex(-1, 1)
  for i=1, #line, 1 do
    glVertex(i-1, -line[i])
  end
    --glVertex(#line+2, -line[#line]-1)
end

	  Craph = Chili.Control:Inherit{
	    backgroundColor = {1, 1, 1, 0},
	lineColor = {0,1,0,1}, --TODO add 2x coloroing for E and M lines+shader
	lineWidth = 3,
	lineData = {0.9,1,2.3,6,9,6},
	lineScaleX = 10,
	lineScaleY = 10,
	highLighted = false,
	stipple = {1,0xffff},
	noDraw = false,
	  width = "100%",
      height = "100%",
      safeOpengl = false,
      AddData = function(self, dat, scaleX, scaleY)
	    for i=1,#dat do
	      self.lineData[#self.lineData + 1] = dat[i]
	    end
	    self.lineScaleX,self.lineScaleY = math.max(0.0001,scaleX), math.max(0.0001,scaleY)
	    self:Invalidate()
	  end,
      DrawControl = function(self)
  if self.noDraw then return end --TODO TODO
  --self:DrawBackground()
  gl.Color(self.lineColor)
  gl.PushMatrix()
  gl.Translate(self.x, self.y+self.height, 1)
  gl.Scale(self.width/self.lineScaleX, self.height/self.lineScaleY, 1)
  if self.highLighted then gl.LineWidth(4) end --BUG BUG BUG --linewidth fails with ATI and wrong smoothing settings
  gl.LineStipple(unpack(self.stipple))
  --gl.UseShader(lshader)
--  gl.Smoothing(false,true,false)
  gl.BeginEnd(GL.LINE_STRIP, drawGraphLines, self)
--  gl.Smoothing(false,false,false) --??
  --gl.UseShader(0)
  gl.LineStipple(false)
  if self.highLighted then gl.LineWidth(1) end
  gl.PopMatrix()
  gl.Color(1,1,1,1)
  self:DrawBorder()
end
	  }
	  myScale = Chili.Scale:Inherit{
  classname = "myscale",
  min = 0,
  max = 100,
  step = 10,
  smallStep = 2,
  height = "100%",
  width = "100%",
  safeOpengl = false,
  defaultWidth     = 90,
  defaultHeight    = 12,
  color = {0,0,0,1},
  		Set = function(self, scaleX)
		  self.max = math.max(0.001,scaleX)
		  self.step = math.floor(self.max/4/10+0.5)*10
		  self.smallStep = self.step/5
		  self:Invalidate()
  end,
  
  drawScaleLines = function(self) 
  local hline = self.y + self.height
  local h1 = self.y + self.height+10
  local h2 = self.y + 0
  
  local scale = self.width / (self.max-self.min)
  local xxp = self.x
  
  local glVertex = gl.Vertex
  local glColor = gl.Color
    if self.vertical  then
      hline = self.y + self.height
      h1 = self.x + self.width+10
      h2 = self.x + 0
      
      glVertex(self.x + self.width, hline)
      glVertex(self.x + self.width, self.y)
      
      xxp = self.y
      scale = self.height / (self.max-self.min)
      glVertex = function(x,y) gl.Vertex(y,x) end
    else
  glVertex(self.x, hline)
  glVertex(self.x + self.width,hline)
    end
		
		for v = self.min, self.max, self.step do 
			local xp = xxp +  scale * v --(v - self.min)
			glColor(0,0,0,1)
			glVertex(xp,  h1)
			glColor(0.3,0.3,0.3,0.02)
			glVertex(xp,  h2)
		end h1 = h1-10 ---NOTE
				for v = self.min, self.max, self.smallStep do 
			local xp = xxp +  scale * v --(v - self.min)
			glColor(0,0,1,0.3)
			glVertex(xp,  h1)
			glColor(0,0,0.3,0.01)
			glVertex(xp,  h2)
		end 
	
end ,

    DrawControl = function(self)
  gl.Color(self.color)
  gl.BeginEnd(GL.LINES, self.drawScaleLines, self)

  local font = self.font
  --[[   
  if (self.min <=0 and self.max >= 0) then 
    local scale = self.width / (self.max-self.min)
    font:Print(0, self.x +  scale * (0 - self.min), self.y, "center", "ascender")
  end 

  font:Print(self.min, self.x, self.y, "left", "ascender")
  font:Print("+"..self.max, self.x+self.width, self.y, "right", "ascender")--]]
  if self.vertical  then 
    --font:Print(0, self.x+self.width, self.y+self.height-10, "left", "ascender")
  font:Print(math.floor(self.max), self.x+self.width, self.y+5)
  local scale = self.height / (self.max-self.min)
  		for v = self.min+self.step, self.max-self.step, self.step do 
			font:Print(math.floor(v), self.x+self.width, self.y+self.height-v*scale+5, "left") --TODO SI rounding
		end
  else
  font:Print("00:00", self.x, self.y+self.height+10, "left", "ascender")
  font:Print(string.format("%02d:%02d",math.floor(self.max*HistoryToTimeScale),math.floor(self.max*HistoryToTimeScale%1*60+0.5)), self.x+self.width, self.y+self.height+10, "right", "ascender")
  local scale = self.width / (self.max-self.min)
  		for v = self.min+self.step, self.max, self.step-0.01 do 
			font:Print(
			 string.format("%02d:%02d",math.floor(v*HistoryToTimeScale),math.floor(v*HistoryToTimeScale%1*60+0.5))
			  , self.x+(v)*scale, self.y+self.height+10, "center", "ascender") --TODO SI rounding
		end
  end
end,
}


	  
	  teamNamesStack = Chili.StackPanel:New{TeamNames = {},
	    backgroundColor = {1, 1, 1, 0},
						width = 150,
						    		height = '50%',
								x = "25%",
								y = "15%",
								maxHeight       = 500,
		itemMargin  = {0,0,0,0},
					resizeItems = true,
					centerItems = false,
					autosize = true,
		  selectable    = true,
						itemPadding = {0,0,0,0},
						}
	    
	   	   grapLabelStack = Chili.StackPanel:New{
	    backgroundColor = {1, 1, 1, 0},
					  width = (100-75) .."%",
					  --minWidth
      height = "80%",
      bottom = "5%",
		itemMargin  = {0,0,0,0},
					resizeItems = true,
					centerItems = true,
					autosize = false,
		  selectable    = true,
						itemPadding = {0,0,0,0},
						children = {	
		Chili.Checkbox:New{
			  caption="Mouse",
			      boxalign = 'left',
			      checked = false, --true, --default
			  fontShadow=true,
			  fontSize = 20,
			  clickStats = false,
			  OnChange = {
			  function(self, checked)
			  if checked then
			    if not self.clickStats then
			      local ch = {}
			      
			      for _,playerID in pairs(Spring.GetPlayerList()) do --TODO flags and ranks
			      local mPix,mClick,keyPress,nComm,uComm = Spring.GetPlayerStatistics(playerID)
			      local name,_,_,teamID = Spring.GetPlayerInfo(playerID)
			      local r,g,b = Spring.GetTeamColor(teamID or 0)
			      ch[#ch+1] = Chili.Label:New{
				caption=string.char(255,r*254+1,g*254+1,b*254+1)..name.."\255\255\255\255\tMouse clicks/minute: ".. tostring(mClick) .. "\tMouse pix/minute: " .. 
				    tostring(mPix).. "\tKey Presses/minute: " .. tostring(keyPress) .."\tCommands/Commanding size: " .. tostring(nComm) .."/".. tostring(Comm)
				,fontsize = 16,
			      }
			    end
			    
			      self.clickStats = Chili.Control:New({width = "100%",height = "100%", children = {Chili.StackPanel:New{width = "100%", height="100%",children=ch}}})
			    end
			    graphScales:AddChild(self.clickStats)
			    graphScales:RemoveChild(teamNamesStack)
			    Spring.Echo("Mouse",checked)
			  else
			    graphScales:RemoveChild(self.clickStats)
			    graphScales:AddChild(teamNamesStack)
			    Spring.Echo("Mouse",checked)
			  end
			  local a,c,m,s = Spring.GetModKeyState() 
			  if not (s or c) then --if shift or ctrl pressed add a new graph
			    for k,v in pairs(EnabledStatGraphs) do
			      v.enabled = false
			    end
			    			    for _,v in ipairs(grapLabelStack.children) do
					if v.checked then v.checked = false; v:Invalidate() end	      
			    end
			  end
			  end
			  },
		    }}
		
						}
	    
	    
	  	graphScales = Chili.StackPanel:New{ --background, Label and graphs for every team 
	  backgroundColor = {1, 1, 1, 0.8},	--team name label and "highlight"-left click hides and right constatn hilight
  width = "75%",
      height = "80%",
      right = "3%",
      bottom = "5%",
      color = {0,1,0,1},
      					resizeItems = true,
					centerItems = true,
					autosize = false,
      
		    children = {--teamNamesStack,
		    
		  }
		    
}

  local childs = {teamNamesStack,grapLabelStack,graphScales}
	--childs[#childs+1] = graphs
	--childs[#childs+1] = grapLabelStack
	
	window = Chili.Window:New{  
		--dockable = true,
		name = "Graph window",
		    preserveChildrenOrder = true, --
		x = "15%",  
		y = "15%",
		width  = "70%",
		height = "70%",
		--parent = Chili.Screen0,
		draggable = true,
		tweakDraggable = true,
		resizable = true,
		minimizable = true,
		children = childs,
	}
	
end


local lastHist = 1

local ttt = 0
function widget:Update(dt)
    ttt = ttt+dt
    if ttt < 1 or not grapLabelStack then return end
    ttt = 0
    
if not grapLabelStack.initialized then
    	local history = Spring.GetTeamStatsHistory(Spring.GetTeamList(Spring.GetAllyTeamList()[1])[1])
	history = Spring.GetTeamStatsHistory(Spring.GetTeamList(Spring.GetAllyTeamList()[1])[1], 1, history)
	if history and #history > 0 then
	  grapLabelStack.initialized = true
	    for lName,_ in pairs(history[1]) do
	      local hName = statNames[lName]
	      if hName == nil then hName = lName end --we can add arbitrary stats there like: history.economy = history.energyProduced + history.metalProduced
	      if hName then
		grapLabelStack:AddChild(
		Chili.Checkbox:New{
			  caption=hName,
			      boxalign = 'left',
			      --width = 200,
			      statName = lName,
			      checked = false, --lName == "energyProduced", --default
			  fontShadow=true,
			  fontSize = 20,
			  OnChange = {
			  function(self, checked)
			  local a,c,m,s = Spring.GetModKeyState() 
			  if not (s or c) then --if shift or ctrl pressed add a new graph
			    for k,v in pairs(EnabledStatGraphs) do
			      v.enabled = false
			    end
			    			    for _,v in ipairs(grapLabelStack.children) do
					if v.checked then v.checked = false; v:Invalidate() end	      
			    end
			  end
			  if EnabledStatGraphs[self.statName] then
				    EnabledStatGraphs[self.statName].enabled = checked
			  else
			    EnabledStatGraphs[self.statName] =  {enabled = checked, lastHist = 1,maxy=0,maxx=0, data = {}}
			  end
			  end
			  },
		    }
		)
	      end
	    end
	end
end
    
	for _,allyID in ipairs(Spring.GetAllyTeamList()) do
	for _,teamID in ipairs(Spring.GetTeamList(allyID)) do
	  local history = Spring.GetTeamStatsHistory(teamID)
	  if history then --and lastHist <= history then
	    local historyD
	    for statName, dat in pairs(EnabledStatGraphs) do
	      if dat.enabled then
	     if not (historyD and dat.lastHist+#historyD == history)then historyD = Spring.GetTeamStatsHistory(teamID, dat.lastHist, history) end --rare? BUG
	    if historyD and #historyD > 0 then
	      dat.maxx = math.max(dat.maxx, history)
	      dat.data[teamID] = {}
	      local tEu = dat.data[teamID]
	      for i,v in pairs(historyD) do
		dat.maxy = math.max(dat.maxy, v[statName])
		tEu[#tEu + 1] = v[statName]
	      end
	    else
	      Spring.Echo("History Graph Error?")
	    end
	      end
	  end
	  end
	end
	end
  for statName, dat in pairs(EnabledStatGraphs) do
	local graph = graphers[statName]
	if not graph then 
	  graph = newGrapher({2,-1});--math.random(0xffff)}); 
	  graphers[statName] = graph; 
	  --window:AddChild(graph)
	  graphScales:AddChild(graph)
	end
    if dat.lastHist <= dat.maxx then
      graph:AddHistoryGraphs(dat.data, dat.maxx, dat.maxy)
    end
dat.lastHist = math.max(dat.lastHist,dat.maxx + 1)
if graph.enabled ~= dat.enabled then 
  if graph.enabled then
      graphScales:RemoveChild(graph)
  else
    graphScales:AddChild(graph) --BUG
  end
end
 graph.enabled = dat.enabled
  end


end

local count = 0

function newGrapher(stipple)
  count = count + 1
  local       	    hScale = myScale:New{
	    bottom = 20,
		width = "95%",
		height = "95%",
		  fontOutline=true,
  fontsize = 14,
	    }
	      local       	    vScale = myScale:New{
	    bottom = 20,
		vertical = true,
		width = "95%",
		height = "95%",
		  fontOutline=true,
  fontsize = 14,
	    }
  local graphs = Chili.Control:New{ --background, Label and graphs for every team 
	  backgroundColor = {1, 1, 1, 0.8},	--team name label and "highlight"-left click hides and right constatn hilight
  --width = "75%",
     -- height = "80%",
      --right = "3%",
      --bottom = 20, --"5%",
	width = "100%",      
	--height = "100%",
      color = {0,1,0,1},
      Craphs = {},
      enabled = true,
      safeOpengl = false,
      AddHistoryGraphs = function(self, data, scaleX, scaleY)
	  vScale:Set(scaleY)
	  hScale:Set(scaleX)
	  for teamID, dat in pairs(data) do
	    local cra = self.Craphs[teamID]
	    if not cra then
	      local color = {Spring.GetTeamColor(teamID)}
	      self.Craphs[teamID] = Craph:New{
		bottom = 20,
		width = "95%",
		height = "95%",
		lineColor = color,
		lineData=dat,
		lineScaleX=scaleX,lineScaleY=scaleY,
		stipple = stipple,
	      }
		self:AddChild(self.Craphs[teamID])
		if not teamNamesStack.TeamNames[teamID] then
		teamNamesStack.TeamNames[teamID] = Chili.Checkbox:New{
		      caption=getPlayerNames(teamID),
			--boxalign = 'left',
			  width = 200,
		      teamID = teamID,
		      textColor=color, 
		      fontOutline=true,
		      HighLight = function(cbSelf, lighted)
		      if lighted then
			if highLightedLabel then highLightedLabel:HighLight(false) end
			highLightedLabel = cbSelf
		      end
		      		--	local craph = self.Craphs[cbSelf.teamID]
			--craph.highLighted = lighted
			--craph:Invalidate()
		      for _,gr in pairs(graphers) do
			local craph = gr.Craphs[cbSelf.teamID]
			if craph then
			  craph.highLighted = lighted
			  craph:Invalidate()
			end
		      end
		end,
		      OnChange = {
		      function(cbSelf, checked)
					      			--[[local craph = self.Craphs[cbSelf.teamID]
			craph.noDraw = not checked
			craph:Invalidate()--]]
		      		      for _,gr in pairs(graphers) do
			local craph = gr.Craphs[cbSelf.teamID]
			if craph then
			  craph.noDraw = not checked
			  craph:Invalidate()
			end
		      end
		      end
		      },
		      HitTest = function (self)
			self:HighLight(true)
  return self
end,
		}
		teamNamesStack:AddChild(teamNamesStack.TeamNames[teamID])
	      else 
		--TODO add another check box for highlighting??
	      end
	      else
		--Spring.Echo("ADDDD",#dat,scaleX, scaleY)
		cra:AddData(dat,scaleX, scaleY)
	    end
	  end
		end,
		    children = {--teamNamesStack,
		  vScale,hScale
		  }
		    
}

	--if count > 1 then  --hack
  graphs.DrawControl = function(self)
 --[[ if self.snapToGrid then
    self.x = math.floor(self.x) + 0.5
    self.y = math.floor(self.y) + 0.5
  end
  
self:DrawBackground()
  
  --gl.Color(self.color)
  --gl.BeginEnd(GL.LINES, drawGraphLines, self) --TODO draw the scales
  
  --self:DrawBorder()
  --]]
end
--else
  --graphs:AddChild(teamNamesStack)
--end
graphs.orgDraw = graphs.DrawForList
graphs.DrawForList = function(self) if graphs.enabled then graphs:orgDraw() end end --TODO upd. Chili and fix

return graphs
end

function widget:Shutdown()
  if lshader then
    gl.DeleteShader(lshader)
  end
  if window then
window:Dispose()
window = nil
  end
  widgetHandler:RemoveAction("show_grapher", Graphs)
end 
