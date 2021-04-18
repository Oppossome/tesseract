include("shared.lua")

local innerTarget = GetRenderTarget("tesseract-inner", ScrW(), ScrH(), false)
local innerMaterial = CreateMaterial("tesseract-inner", "UnlitGeneric", { ["$basetexture"] = "tesseract-inner"; ["$translucent"] = 1 })
local transMaterial = Material("Models/effects/vol_light001")
currentTesseract = currentTesseract

local function resetStencils()
	render.SetMaterial(transMaterial)
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
end

function ENT:Initialize()
  currentTesseract = self
end

function ENT:Draw()



end

hook.Add("PreRender", "tesseract", function()
  if IsValid(currentTesseract) then
    local localPos, localAng = WorldToLocal(EyePos(), EyeAngles(), currentTesseract:GetPos(), currentTesseract:GetAngles())
    local newPos = currentTesseract:GetCenter() + localPos * currentTesseract:GetScale()

    render.PushRenderTarget(innerTarget)
      render.Clear(0, 0, 0, 0, true, true)

      render.RenderView({
        origin = newPos,
        angles = localAng,
        bloomtone = false,
        drawviewmodel = false,
        w = ScrW(), h = ScrH(),
        x = 0, y = 0,
        zfar = 1e7
      })
    render.PopRenderTarget()
  end
end)

hook.Add("PostDrawTranslucentRenderables", "tesseract", function()
  EyeAngles()
  EyePos()

  if not IsValid(currentTesseract) then
    return
  end

  local currTarget = render.GetRenderTarget()
  if currTarget and currTarget:GetName() == "tesseract-inner" then
    resetStencils()
    render.SetStencilEnable(true)
      render.SetStencilReferenceValue(1)
      render.SetStencilCompareFunction(STENCIL_ALWAYS)
      render.SetStencilZFailOperation(STENCIL_REPLACE)

      render.SetBlend(0)
        render.DrawBox(currentTesseract:GetCenter(), Angle(), currentTesseract:GetMaxBounds(), currentTesseract:GetMinBounds())
      render.SetBlend(1)

      render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
      render.SetStencilZFailOperation(STENCIL_KEEP)

      render.ClearBuffersObeyStencil( 0, 0, 0, 0, false )
    render.SetStencilEnable(false)
    resetStencils()

    return
  end

  if not currTarget or currTarget:GetName() ~= "tesseract-outer" then
    local minBounds = currentTesseract:GetMinBounds() / currentTesseract:GetScale()
    local maxBounds = currentTesseract:GetMaxBounds() / currentTesseract:GetScale()
    render.DrawWireframeBox(currentTesseract:GetPos(),currentTesseract:GetAngles(), minBounds, maxBounds)

    resetStencils()
    render.SetStencilEnable(true)
      render.SetStencilReferenceValue(1)
      render.SetStencilCompareFunction(STENCIL_ALWAYS)
      render.SetStencilPassOperation(STENCIL_REPLACE)

      render.SetBlend(0)
        render.DrawBox(currentTesseract:GetPos(), currentTesseract:GetAngles(), minBounds, maxBounds) -- Clip anything that doesn't hit the box out
      render.SetBlend(1)

      render.SetStencilCompareFunction(STENCIL_EQUAL)
      render.SetStencilPassOperation(STENCIL_KEEP)

      render.SetMaterial(innerMaterial)
      render.DrawScreenQuad()
    render.SetStencilEnable(false)
    resetStencils()
  end
end)

hook.Add("SetupWorldFog", "tesseract", function()
  local currTarget = render.GetRenderTarget()
  if currTarget and currTarget:GetName():find("tesseract") then
    return true
  end
end)

hook.Add("PreDrawSkyBox", "tesseract", function()
  local currTarget = render.GetRenderTarget()
  if currTarget and currTarget:GetName():find("tesseract") then
    return true
  end
end)