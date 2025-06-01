-- rectangles.lua
-- A module to manage wrapping and fading vertical rectangles

local Rectangles = {}
Rectangles.__index = Rectangles

function Rectangles:new()
  local r = {
    rects = {}
  }
  setmetatable(r, self)
  return r
end

function Rectangles:add(x, y, w, h, color, direction, v, loop_start, loop_end)
  table.insert(self.rects, {
    x = x,
    y = y,
    w = w,
    h = h,
    color = color or 16,
    direction = direction or "down",
    loop_start = loop_start or 6,
    loop_end = loop_end or 64, -- make based on lEnd[v] 
    fade = scPre[v], -- fade based on pre value of voice
    vox = v
  })
end

function Rectangles:update()
  for i = #self.rects, 1, -1 do
    local r = self.rects[i]
    --r.fade = r.fade - 0.01
    r.fade = scPre[r.vox]
  
      --r.color = math.floor(r.color * r.fade)
      r.color = math.ceil(r.color*scPre[r.vox])
    if r.color <= 0 then
      table.remove(self.rects, i) -- this should remove based on color beng 0
    end
  end
end

function Rectangles:draw()
  for _, r in ipairs(self.rects) do
    screen.level(math.floor(r.color))

    if r.direction == "down" then
      local head = r.y + r.h
      if head <= r.loop_end then
        screen.rect(r.x, r.y, r.w, r.h)
        screen.fill()
      else
        local h1 = r.loop_end - r.y
        local h2 = r.h - h1
        screen.rect(r.x, r.y, r.w, h1)
        screen.fill()
        screen.rect(r.x, r.loop_start, r.w, h2)
        screen.fill()
      end
    else
      local head = r.y - r.h
      if head >= r.loop_start then
        screen.rect(r.x, r.y - r.h, r.w, r.h)
        screen.fill()
      else
        local h1 = r.y - r.loop_start
        local h2 = r.h - h1
        screen.rect(r.x, r.loop_start, r.w, h1)
        screen.fill()
        screen.rect(r.x, r.loop_end - h2, r.w, h2)
        screen.fill()
      end
    end
  end
end

function Rectangles:clear()
  self.rects = {}
end

function Rectangles:remove_by_vox(vox)
  for i = #self.rects, 1, -1 do
    if self.rects[i].vox == vox then
      table.remove(self.rects, i)
    end
  end
end

return Rectangles:new()
