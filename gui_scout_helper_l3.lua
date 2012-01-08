function widget:GetInfo()
  return {
    name      = "Scout Helper l3",
	version   = "Beta 3.1 lite",
    desc      = "Displays a map of LOS",
    author    = "Pako",
    date      = "13.09.2009 - 25.11.2011",
    license   = "",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

local floor = math.floor
local ceil = math.ceil
local abs = math.abs


local LOSPoints = {}

local areas = {}


local gridSize = 64  --dont change without changing 5 other points
local areaSize = 64		--dont change without changing 5 other points

local uTime = 0

local enabled = false --make options!!

function widget:Initialize()

  widgetHandler:AddAction("togglelos", showLOS) --gets called before the engine action
  widgetHandler:RemoveCallIn('DrawWorldPreUnit')
  local spec, fullView = Spring.GetSpectatingState()
  
  
  for x=0,ceil(Game.mapSizeX/gridSize) do
  LOSPoints[x] = {}
  for z=0,ceil(Game.mapSizeZ/gridSize) do
		LOSPoints[x][z] = 0.5
	end
	end
	
	local areasX = ceil(Game.mapSizeX/gridSize/areaSize)
	local areasZ = ceil(Game.mapSizeZ/gridSize/areaSize) --should we divide by screen size so that 4 areas usually in screen???
	for x=0, areasX do
		areas[x] = {}
		for z=0, areasZ do
			local mx, mz = (x*areaSize), (z*areaSize)
			local mxe, mze = (mx+areaSize), (mz+areaSize)
			if mxe > Game.mapSizeX/gridSize then
				mxe = Game.mapSizeX/gridSize
			end
			if mze > Game.mapSizeZ/gridSize then
				mze = Game.mapSizeZ/gridSize
			end
			areas[x][z] = {x=mx,z=mz,xe=mxe,ze=mze, updated = 0, viewDrawList = nil, changes=0, inView = false}
	end
	end
	
end

do
 local state = 2 
 function showLOS(cmd, optLine, optWords, _,isRepeat, release)
if isRepeat or release then return true end
   state = (state + 1)
   local lstate = state%4
    if (lstate==0) then
      return false
	  --Spring.SendCommands({"togglelos"}) 
    elseif lstate == 1 then
		widgetHandler:RemoveCallIn('DrawWorldPreUnit')
		enabled = false
		return true
	elseif lstate == 2 then
	  return false
		 --Spring.SendCommands({"togglelos"})
	 elseif lstate == 3 then
		widgetHandler:UpdateCallIn('DrawWorldPreUnit')
		enabled = true
		return true
    end
  end
  --return false
end --//end do



local function sq_distance(x,z,xx,zz)
  return (x-xx)^2 + (z-zz)^2
end



local function DrawLOSViewVertices(LOSPoints,xs,zs,xe,ze)

	local Scale = gridSize
	local sggh = Spring.GetGroundHeight
	local Vertex = gl.Vertex
	local glColor = gl.Color
	local sten = {zs, ze, zs}
	local i0, i1 = 0, xs*Scale
	for x=xs,xe-1,1 do
		--local last0, last1
		local ind = x%2
		local LOSp0 ,LOSp1 = LOSPoints[x], LOSPoints[x+1]
		i0, i1 = x*Scale, x*Scale+Scale
		if ind == 0 then --for culling, draw the tringle clokwise
		  LOSp0 ,LOSp1 = LOSp1 ,LOSp0
		  i0, i1 = i1, i0
		end
		for z=sten[ind+1], sten[ind+2], 1+(-ind*2) do
				local alc0, alc1 = LOSp0[z], LOSp1[z]
				local j = z*Scale
				glColor(0.01,0.01,0.01,alc0)
				Vertex(i0,sggh(i0,j),j)
				glColor(0.01,0.01,0.01,alc1)
				Vertex(i1,sggh(i1,j),j)
		end
	end
end

local function DrawLOSView(LOSPoints,xs,zs,xe,ze)
	--gl.Blending(false)
	
	--gl.UseShader(shaderProgram)  
	
	--gl.Blending(GL.SRC_ALPHA,GL.ZERO)
  gl.Culling(GL.BACK)
	gl.DepthTest(GL.LEQUAL)
	gl.BeginEnd(GL.TRIANGLE_STRIP,DrawLOSViewVertices,LOSPoints,xs,zs,xe,ze)
	gl.DepthTest(false)
	gl.Color(1,1,1,1)
	gl.Blending(GL.SRC_ALPHA,GL.ONE_MINUS_SRC_ALPHA)
	
	--gl.UseShader(0)
end


local function updateArea(area, dt)

local gplos = Spring.GetPositionLosState
local glos = Spring.IsPosInLos
local sggh = Spring.GetGroundHeight
local abs = abs
local gS = gridSize
local gridsX = ceil(Game.mapSizeX/gridSize)
local changes = 3

	for x=area.x, area.xe-1 do
	    local LOSPointsx = LOSPoints[x]
	    local LOSPointsx1 = LOSPoints[x+1]
		for z=area.z, area.ze-1 do
				--local inLos = glos((x)*gS,0,(z)*gS)
				local LorR, inLos, inRadar = gplos((x)*gS,0,(z)*gS)
				local color = inLos and 0 or inRadar and 0.2 or 0.5 --math.min(LOSPointsx[z]+0.08,0.6)
				LOSPointsx[z] = (LOSPointsx[z]+LOSPointsx[z+1]+LOSPointsx1[z]+color)/4
				LOSPointsx[z+1]= color
				LOSPointsx1[z] = color
				
		end
	end
	area.changes = changes + area.changes
end

local updateInt = 0.1

local function updateWorld()
local gameSec = Spring.GetGameSeconds()
local update = 0
for x=0,#areas do
	for z=0,#areas[x] do
		local dt = gameSec - areas[x][z].updated
		--if (areas[x][z].inView and dt > updateInt + update/10) or dt > 5*updateInt + update*2 then  --how this scales for diff size maps/ areasizes ??????????
		--Spring.Echo("update "..x..z)
			update = update + 2
			updateArea(areas[x][z], dt)
			areas[x][z].updated = gameSec
		--end
	end
end

for x=0,#areas,2 do
	for z=0,#areas[x],2 do
	  local area = areas[x][z]
		if area.changes > 1 then --fix
			area.changes = 0
			gl.DeleteList(area.viewDrawList)
			area.viewDrawList = nil
			area.viewDrawList=gl.CreateList(DrawLOSView, LOSPoints,
			    math.max(0,area.x-areaSize*0.5),
			    math.max(0,area.z-areaSize*0.5),
			    math.min(math.floor(Game.mapSizeX/gridSize), area.xe+areaSize*0.5),
			    math.min(math.floor(Game.mapSizeZ/gridSize), area.ze+areaSize*0.5))
	end
	end
end
return update
end



local vsx, vsy = widgetHandler:GetViewSizes()

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end


local update = 0
local defUpd = 0

local dtTime = 0
local tt = false

function widget:Update(dt)
dtTime = dtTime + dt
uTime = uTime+dt
tt = not tt
if tt or not enabled then return end --if FPS gets low this helps

if dtTime < updateInt then return end 	--TODO use update
	dtTime=0
local ticks = os.clock()
 local ground, xyz  = Spring.TraceScreenRay(0,vsy-1, true, false)
 local xs,zs,xe,ze
 if ground == "ground" then
	xs = xyz[1]
	zs = xyz[3]
 end
 
 ground, xyz  = Spring.TraceScreenRay(vsx-1,0, true, false)
  if ground == "ground" then
	xe = xyz[1]
	ze = xyz[3]
 end
 
 if not xs or not ze then
	ground, xyz  = Spring.TraceScreenRay(0,0, true, false)
	if ground == "ground" then
		xs = xyz[1]
		ze = xyz[3]
	end
 end
 
  if not xe or not zs then
	ground, xyz  = Spring.TraceScreenRay(vsx-1,vsy-1, true, false)
	if ground == "ground" then
		xe = xyz[1]
		zs = xyz[3]
	end
 end
local gaSize = gridSize*areaSize
xs = floor(xs and xs/gaSize or 0)
ze = floor(ze and ze/gaSize or ceil(Game.mapSizeZ/gaSize))
zs = floor(zs and zs/gaSize or 0)
xe = floor(xe and xe/gaSize or ceil(Game.mapSizeX/gaSize))

for x=0,#areas do
	for z=0,#areas[x] do
		if x >= xs and x <= xe and z >= zs and z <= ze then
			areas[x][z].inView = true
		else
			areas[x][z].inView = false
		end
	end
end

	update = update + updateWorld()
 ticks = os.clock ()-ticks
 updateInt = math.max(ticks*5, 1/30) --30FPS max
 --Spring.Echo(ticks)
end

function widget:Shutdown()

  widgetHandler:RemoveAction("togglelos", showLOS)

for x=0,#areas do
	for z=0,#areas[x] do
		if areas[x][z].viewDrawList then
			gl.DeleteList(areas[x][z].viewDrawList)
		end
	end
end

  
end

local Color = gl.Color
local tt=0
--function widget:DrawWorld()
function widget:DrawWorldPreUnit()
	gl.PolygonOffset(-100, -100)
	--gl.DepthMask(true)
	    --gl.Culling(GL.FRONT_AND_BACK)
  --gl.Culling(GL.FRONT)
for x=0,#areas do
	for z=0,#areas[x] do
		if  --areas[x][z].inView and --this maybe actually unnecessary
			areas[x][z].viewDrawList then
				gl.CallList(areas[x][z].viewDrawList)
		end
	end
end        
    gl.DepthMask(false)
    gl.PolygonOffset(false)
Color( 1, 1, 1, 1 )
end
