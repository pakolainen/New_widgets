--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    ico_customicons.lua
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "CustomIcons3",
    desc      = "Sets custom unit icons for FA",
    author    = "trepan,BD,TheFatController,Pako",
    date      = "Jan 8, 2007 - 2011",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local wasLuaModUIEnabled = 0

--------------------------------------------------------------------------------


function widget:Shutdown()
  -- revert our changes
  for udid,ud in pairs(UnitDefs) do
    if ((ud ~= nil) and (ud.origIconType ~= nil)) then
      Spring.SetUnitDefIcon(udid, ud.origIconType)
    end
  end
end


--------------------------------------------------------------------------------

function widget:Initialize()

  Spring.AddUnitIcon("armcom.user", "LuaUI/Icons/armcom.png",2)
  Spring.AddUnitIcon("corcom.user", "LuaUI/Icons/corcom.png",2)
  Spring.AddUnitIcon("cross.user", "LuaUI/Icons/cross.png",1,1,1)
  Spring.AddUnitIcon("diamond.user", "LuaUI/Icons/diamond.png",1.1,1,true)
  Spring.AddUnitIcon("e.user", "LuaUI/Icons/energy1.dds",0.9,1,true)
  Spring.AddUnitIcon("e2.user", "LuaUI/Icons/energy2.dds",1.4)
  Spring.AddUnitIcon("e3.user", "LuaUI/Icons/energy3.dds",2.9)
  Spring.AddUnitIcon("hemi-down.user", "LuaUI/Icons/hemi-down.png",1.3,1,true)
  Spring.AddUnitIcon("hemi-up.user", "LuaUI/Icons/hemi-up.png",1.1,1)
  Spring.AddUnitIcon("hemi.user", "LuaUI/Icons/hemi.png",1,1,1)
  Spring.AddUnitIcon("hourglass-side.user", "LuaUI/Icons/hourglass-side.png",1,1,true)
  Spring.AddUnitIcon("hourglass.user", "LuaUI/Icons/hourglass.png",1,1,true)
  Spring.AddUnitIcon("krogoth.user", "LuaUI/Icons/krogoth.png",3)
  Spring.AddUnitIcon("m-down.user", "LuaUI/Icons/m-down.png",1,1,true)
  Spring.AddUnitIcon("m-up.user", "LuaUI/Icons/m-up.png",1,1,true)
  Spring.AddUnitIcon("m.user", "LuaUI/Icons/m.png",1,1,true)
  Spring.AddUnitIcon("nuke.user", "LuaUI/Icons/nuke.dds",1.25,1,true)
  Spring.AddUnitIcon("sphere.user", "LuaUI/Icons/sphere.png",1,1,true)
  Spring.AddUnitIcon("sphere2.user", "LuaUI/Icons/sphere.png",1.1,1,true)
  Spring.AddUnitIcon("sphere3.user", "LuaUI/Icons/sphere.png",1.2,1,true)
  Spring.AddUnitIcon("square.user", "LuaUI/Icons/square.png",1,1,true)
  Spring.AddUnitIcon("square_+.user", "LuaUI/Icons/square_+.png",1,1,true)
  Spring.AddUnitIcon("square_x.user", "LuaUI/Icons/square_x.png",1,1,true)
  Spring.AddUnitIcon("square_x_factory.user", "LuaUI/Icons/square_x.png",1,1,true)
  Spring.AddUnitIcon("star-dark.user", "LuaUI/Icons/star-dark.png",1,1,true)
  Spring.AddUnitIcon("star.user", "LuaUI/Icons/star.png",1,1,true)
  Spring.AddUnitIcon("tri-down.user", "LuaUI/Icons/tri-down.png",1.3,1,true)
  Spring.AddUnitIcon("tri-up.user", "LuaUI/Icons/tri-up.png",1.4,1,true)
  Spring.AddUnitIcon("tri-up_fighter.user", "LuaUI/Icons/tri-up.png",0.9)
  Spring.AddUnitIcon("triangle-down.user", "LuaUI/Icons/triangle-down.png",1,1,true)
  Spring.AddUnitIcon("triangle-up.user", "LuaUI/Icons/triangle-up.png",1,1,true)
  Spring.AddUnitIcon("x.user", "LuaUI/Icons/x.png",1,1,true)

  -- Setup the unitdef icons
  for udid,ud in pairs(UnitDefs) do

    if (ud ~= nil) then
      if (ud.origIconType == nil) then
        ud.origIconType = ud.iconType
      end

      if (ud.name=="armwin") or (ud.name=="corwin") or (ud.name=="armsolar") or (ud.name=="corsolar")then
        Spring.SetUnitDefIcon(udid, "e.user")
      elseif (ud.name:find("geo")) then
	Spring.SetUnitDefIcon(udid, "e3.user")
      elseif (ud.name=="armfig") or (ud.name=="corveng") or (ud.name=="armhawk") or (ud.name=="corvamp") then
        Spring.SetUnitDefIcon(udid, "tri-up_fighter.user")
      elseif (ud.name=="cafus") or (ud.name=="aafus") then
        Spring.SetUnitDefIcon(udid, "e3.user")
      elseif (ud.name=="armfus") or (ud.name=="corfus") or (ud.name=="armckfus") or (ud.name=="armdf") or (ud.name=="armuwfus") or (ud.name=="coruwfus") then
        Spring.SetUnitDefIcon(udid, "e2.user")
      elseif (ud.name=="armcom") or (ud.name=="armdecom") then
        Spring.SetUnitDefIcon(udid, "armcom.user")
      elseif (ud.name=="corcom") or (ud.name=="cordecom") then
        Spring.SetUnitDefIcon(udid, "corcom.user")
      elseif (ud.name=="corkrog") then
        Spring.SetUnitDefIcon(udid, "krogoth.user")
      elseif (ud.isFactory) then
        -- factories
        Spring.SetUnitDefIcon(udid, "square_x_factory.user")
      elseif (ud.isBuilder) then
        -- builders
        if ((ud.speed > 0) and ud.canMove) then
          Spring.SetUnitDefIcon(udid, "cross.user")     -- mobile
        else
          Spring.SetUnitDefIcon(udid, "square_+.user")  -- immobile
        end
      elseif (ud.stockpileWeaponDef ~= nil) then
      	-- nuke / antinuke ( stockpile weapon anyway )
      	Spring.SetUnitDefIcon(udid, "nuke.user")
      elseif (ud.canFly) then
        -- aircraft
        Spring.SetUnitDefIcon(udid, "tri-up.user")
      elseif ((ud.speed <= 0) and ud.hasShield) then
        -- immobile shields
        Spring.SetUnitDefIcon(udid, "hemi-up.user")
      elseif ((ud.extractsMetal > 0) or (ud.makesMetal > 0)) then
        -- metal extractors and makers
        Spring.SetUnitDefIcon(udid, "m.user")
      elseif ((ud.totalEnergyOut > 10) and (ud.speed <= 0)) then
        -- energy generators
        Spring.SetUnitDefIcon(udid, "e.user")
      elseif (ud.isTransport) then
        -- transports
        Spring.SetUnitDefIcon(udid, "diamond.user")
      elseif ((ud.minWaterDepth > 0) and (ud.speed > 0) and (ud.waterline > 10)) then
        -- submarines
        Spring.SetUnitDefIcon(udid, "tri-down.user")
      elseif ((ud.minWaterDepth > 0) and (ud.speed > 0)) then
        -- ships
        Spring.SetUnitDefIcon(udid, "hemi-down.user")
      elseif (((ud.radarRadius > 1) or
               (ud.sonarRadius > 1) or
               (ud.seismicRadius > 1)) and (ud.speed <= 0)) then
        -- sensors
        Spring.SetUnitDefIcon(udid, "hourglass-side.user")
      elseif (((ud.jammerRadius > 1) or
               (ud.sonarJamRadius > 1)) and (ud.speed <= 0)) then
        -- jammers
        Spring.SetUnitDefIcon(udid, "hourglass.user")
      elseif (ud.isBuilding or (ud.speed <= 0)) then
         -- defenders and other buildings
         if (not ud.weaponCount) then
            ud.weaponCount = 0
         end
        if (ud.weaponCount <= 0) then
          Spring.SetUnitDefIcon(udid, "square.user")
        else
          Spring.SetUnitDefIcon(udid, "x.user")
        end
      else
        if (ud.techLevel == 4) then
          Spring.SetUnitDefIcon(udid, "sphere2.user")
        elseif (ud.techLevel == 6) then
          Spring.SetUnitDefIcon(udid, "sphere3.user")
       -- else
         -- Spring.SetUnitDefIcon(udid, "sphere.user")
        end
      end
    end
  end
end


--------------------------------------------------------------------------------

