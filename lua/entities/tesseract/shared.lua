DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Tesseract"
ENT.Information = "What's inside, what's outside?"
ENT.Category = "Fun + Games"
ENT.Author = "Opossum"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
  self:NetworkVar("Vector", 0, "MinBounds")
  self:NetworkVar("Vector", 1, "MaxBounds")
  self:NetworkVar("Vector", 2, "Center")
  self:NetworkVar("Int", 3, "Scale")

  if(CLIENT)then return end
  self:NetworkVarNotify( "Scale", self.OnScaleChanged )
end
