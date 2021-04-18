AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function getWorldBounds()
  local minBounds, maxBounds = Vector(), Vector()
  for _, surfInfo in ipairs(game.GetWorld():GetBrushSurfaces()) do
    for _, vert in ipairs(surfInfo:GetVertices()) do
      for _, axis in ipairs({"X", "Y", "Z"}) do
        if(minBounds[axis] > vert[axis])then
          minBounds[axis] = vert[axis]
        end

        if(maxBounds[axis] < vert[axis])then
          maxBounds[axis] = vert[axis]
        end
      end
    end
  end

  local center = Vector()
  for _, axis in ipairs({"X", "Y", "Z"}) do
    center[axis] = (maxBounds[axis] + minBounds[axis]) / 2
  end

  return minBounds, maxBounds, center
end

function ENT:Initialize()
  self:DrawShadow(false)

  local minBounds, maxBounds, center = getWorldBounds()
  self:SetMinBounds(minBounds)
  self:SetMaxBounds(maxBounds)
  self:SetCenter(center)
  self:SetScale(256)
end

function ENT:OnRemove()
  physenv.SetGravity(Vector(0, 0, -800))
end

function ENT:Think()
  local _, nAng = WorldToLocal(self:GetPos() + Vector(0, 0, 1), Angle(), self:GetPos(), self:GetAngles())

  local grav = nAng:Up() * -(800)
  physenv.SetGravity(grav)

  for _, ent in pairs(ents.GetAll()) do
    ent:PhysWake()
  end
end

function ENT:OnScaleChanged(_, _, new)
  self:PhysicsInitBox(self:GetMinBounds() / new, self:GetMaxBounds() / new)
end