--a foot switch interface


---------------------------------
-- for UI drawing
local rects = include("lib/rectangles")

-- Constants
local column_x = {7,26,46,66,86,106} -- Fixed column X positions (6 columns) TODO: base on the aFoot UI layout
local rect_speed = {1,1,1,1,1,1}              -- Speed at which rectangles grow

-- State
local active_rect = nil                  -- Currently growing rectangle
local current_column = nil               -- Current selected column X
local key2_down = false                  -- Tracks if key 2 is held
local grow_direction = "down"            -- "up" or "down", fixed per key press
local start_y = 6                        -- Y starting point for growing

-------------------------------------



sc = include('lib/sftct')
ft = include('lib/footie')
--scrn = include('lib/scrn')
--------------------------
--------------------------
-- screen controls  ------
--------------------------
width = 128
height = 64

posX = 40
posY = 1
i = 0.5
freq = 0.0025
amp = 2.75
offSet = 10
mult = 54.89
brite = 16

lStart = {1,51,101,151,201,251}

lEnd = {14,22,27,30,33,35} --as duration
scPre = {1,1,1,1,1,1}
scLev = {1,1,1,1,1,1}
scRte = {1,1,1,1,1,1}
scPan = {0.3,0.6,-0.6,0.9,-0.9,-0.3}
encPre = {"pre_1","pre_2","pre_3","pre_4","pre_5","pre_6"}
encLev = {"lev_1","lev_2","lev_3","lev_4","lev_5","lev_6"}
loopTimer = {loop1,loop2,loop3,loop4,loop5,loop6}

fall = {1,1,1,1,1,1}
fall1 = 1
fall2 = 1
fall3 = 1
fall4 = 1
fall5 = 1
fall6 = 1

micro = false
posOff = 0.0675
posPos = 1
curRec = 0
recording = false
fTime = 26

flipper = metro.init()
flipper.time = math.random(1,26)
flipper.event = function()
  flip()
end

flopper = metro.init()
flopper.time = math.random(1,26)
flopper.event = function()
  flop()
end

--------------------------
--------------------------

function init()

  sc.init()
  ft.init()
  audio.monitor_mono()
  
  for i=1,6 do
    loopTimer[i] = metro.init()
    loopTimer[i].time = lEnd[i]/(lEnd[i])
    rect_speed[i] = loopTimer[i].time
    loopTimer[i].event = function()
      if micro and (curRec+1) == i then
        fall[i] = (((fall[i]+0 ) % (lEnd[i])))
      else
        fall[i] = (((fall[i]+scRte[i] ) % (lEnd[i])))
      end
      checkRecs(i)
      --update()
      --redraw()
    end
    loopTimer[i]:start()
  end
 
  flipper:start()
  flopper:start()
 -- clock.run(checkActiveRecs)
  --params:set(“clock_tempo”, 30)
 -- redraw()
  
end

function checkRecs(v)
  if (curRec+1) == v then
    checkActiveRecs()
  end
end

function flip(v)
  
  local voice = math.random(1,6)
  local tV = 0
  local rate = {-1,1}
  local dir = math.random(2)
  
  if recording and curRec == (voice-1) then
  -- DO NOTHING
  print('not flipping on purpose')
  elseif v == nil then
    tV = voice
    softcut.rate(tV,rate[dir])
    scRte[tV] = rate[dir]
  elseif not(v == nil) then
    tV = v
    scRte[tV] = scRte[tV]*(-1)
    softcut.rate(tV,scRte[tV])
    --scRte[tV] = rate[dir]
  end
  
 
  flipper.time = math.random(1,fTime)
  print(tV,rate[dir],'dir')
  
end

function flop(v)
  
  shuffle(scPan)
  
  for i = 1, #scPan do
    --tV = voice
    softcut.pan(i,scPan[i])
     print(i,scPan[i],'pan')
  end
  flopper.time = math.random(1,fTime)
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i] , tbl[j] = tbl[j] , tbl[i]
  end
end

function updateLoops(v,t)
  lEnd[v] = math.min(t,49) 
  loopTimer[v].time = lEnd[v]/lEnd[v]
 
  softcut.loop_end(v,  lEnd[v] + lStart[v])
  
end

function key (n,z)
  
  -- KEY 2 clears current loop
  if n == 2 and z == 1 then
    
    softcut.buffer_clear_region(lStart[curRec+1]-1,lEnd[curRec+1]+2,0,0) -- a bit over the buffer length to ensure deletion
    dVlevel[curRec+1] = 1
    clearVox(curRec+1)
    --curRec = (curRec - 1) % 6
    --ft.setVoice(curRec + 1)
    print("loop", curRec + 1 , "cleared",(lStart[curRec+1]-1) + (lEnd[curRec+1]+2))
    
  end
  
  -- KEY 3 selects loop
   if n == 3 and z == 1 then
    
    curRec = (curRec + 1) % 6
    ft.setVoice(curRec + 1)
    print(curRec + 1)
    
  end
  
  
end

function enc (n,d)

  if n==1 then
    if micro then
      posOff = posOff + (d*0.01)
      softcut.query_position(curRec+1)
    else
      posOff = 0.0675
    end
    
  end

  -- ENCODER 2 controls LEVEL
  if n == 2 then
    scLev[curRec + 1] = util.clamp(scLev[curRec + 1] + (d * 0.06),0,1)
    sc.setLevel(curRec+1,scLev[curRec+1])
    --params:set(encPre[curRec+1], scPre[curRec+1])
    print(scLev[curRec+1])
    --redraw()
  end
  
  -- ENCODER 3 controls PRE
  if n == 3 then
    scPre[curRec + 1] = util.clamp(scPre[curRec + 1] + (d * 0.06),0,1)
    sc.setPre(curRec+1,scPre[curRec+1])
    --params:set(encPre[curRec+1], scPre[curRec+1])
    print(scPre[curRec+1])
    --redraw()
  end

end

function refresh()
  --update()
  redraw()
  --checkActiveRecs()
end

function redraw()
  screen.clear()
  ---------------------
  ------------------------------------------
  ---------------------
  -- recording selected
  --screen.level(16)
  screen.level(math.ceil(scLev[curRec+1] * 16))
  screen.rect(4+recRec,4,18,56)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
  -- voice 1
  screen.level(1)
  screen.rect(7,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(7,lEnd[1]+6)
  screen.line(21,lEnd[1]+6)
  screen.stroke(2)
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[1]*16))
  --screen.rect(7,20,14,38)
  screen.rect(7,lEnd[1]+6,14,52-(lEnd[1]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
  -- voice 2
  screen.level(1)
  screen.rect(26,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(26,lEnd[2]+6)
  screen.line(40,lEnd[2]+6)
  screen.stroke(2)
  ---------------------
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[2]*16))
  --screen.rect(26,24,14,34)
  screen.rect(26,lEnd[2]+6,14,52-(lEnd[2]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
  -- voice 3
  screen.level(1)
  screen.rect(46,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(46,lEnd[3]+6)
  screen.line(60,lEnd[3]+6)
  screen.stroke(2)
  ---------------------
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[3]*16))
  --screen.rect(46,30,14,28)
  screen.rect(46,lEnd[3]+6,14,52-(lEnd[3]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
  -- voice 4
  screen.level(1)
  screen.rect(66,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(66,lEnd[4]+6)
  screen.line(80,lEnd[4]+6)
  screen.stroke(2)
  ---------------------
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[4]*16))
  --screen.rect(66,36,14,22)
  screen.rect(66,lEnd[4]+6,14,52-(lEnd[4]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
  -- voice 5
  screen.level(1)
  screen.rect(86,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(86,lEnd[5]+6)
  screen.line(100,lEnd[5]+6)
  screen.stroke(2)
  ---------------------
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[5]*16))
  --screen.rect(86,42,14,16)
  screen.rect(86,lEnd[5]+6,14,52-(lEnd[5]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ---------------------
   -- voice 6
  screen.level(1)
  screen.rect(106,6,14,52)
  screen.fill()
  ---------------------
  ---------------------
  screen.level(0)
  screen.line_width(3)
  screen.move(106,lEnd[6]+6)
  screen.line(120,lEnd[6]+6)
  screen.stroke(2)
  ---------------------
  ---------------------
  
  -- voice PRE
  screen.level(math.ceil(scPre[6]*16))
  --screen.rect(106,48,14,10)
  screen.rect(106,lEnd[6]+6,14,52-(lEnd[6]+6)+6)
  screen.fill()
  ---------------------
  ------------------------------------------
  ------------------------------------------
  ------------------------------------------
  ---------------------
  -- RECTS DRAWING
  rects:draw()

  if active_rect then
    draw_wrapped_rect(active_rect)
  end
  ---------------------
  ------------------------------------------
  ------------------------------------------
  ------------------------------------------
  ---------------------
  
  -- falling line 1
  screen.level(0)
  screen.line_width(1)
  screen.move(7,fall[1]+7)
  screen.line(21,fall[1]+7)
  screen.stroke(2) 
  ----------------------
  -- falling line 2
  screen.level(0)
  screen.line_width(1)
  screen.move(26,fall[2]+7)
  screen.line(40,fall[2]+7)
  screen.stroke(2) 
  ----------------------
  -- falling line 3
  screen.level(0)
  screen.line_width(1)
  screen.move(46,fall[3]+7)
  screen.line(60,fall[3]+7)
  screen.stroke(2) 
  ----------------------
  -- falling line 4
  screen.level(0)
  screen.line_width(1)
  screen.move(66,fall[4]+7)
  screen.line(80,fall[4]+7)
  screen.stroke(2) 
  ---------------------
  -- falling line 5
  screen.level(0)
  screen.line_width(1)
  screen.move(86,fall[5]+7)
  screen.line(100,fall[5]+7)
  screen.stroke(2) 
  ---------------------
  -- falling line 6
  screen.level(0)
  screen.line_width(1)
  screen.move(106,fall[6]+7)
  screen.line(120,fall[6]+7)
  screen.stroke(2) 
  ---------------------
  
  screen.update()
end

-------------
-------------
-- rect drawing functions


-- called from footie, should update to record from key 2 also
function handle_rectangle_key(v, z)
  
    if z == 1 then -- Key down
      key2_down = true
      current_column = column_x[v] -- base this on the ui in aFoot
      grow_direction = scRte[v] > 0 and "down" or "up" -- base this on the scRte value < 0 or > 0 
      start_y = fall[v]+7 -- to update for the Fall[curRec+1]+7
      start_new_rectangle(start_y,v)
    else -- Key up
      key2_down = false
      if active_rect then
        finalize_active_rect()
      end
    end
end

-- Start a new growing rectangle from a starting Y
function start_new_rectangle(y,v)
  active_rect = {
    x = current_column,
    y = y,
    w = 14,
    h = 0,
    color = 16,
    vox = v
  }
end

-- Finalize active rectangle and move it to fading list
function finalize_active_rect()
  rects:add(
    active_rect.x,
    active_rect.y,
    active_rect.w,
    active_rect.h,
    active_rect.color,
    grow_direction,
    curRec+1 
  )
  active_rect = nil
end
-- will want to utilize curRec and the timer associated with it. 
function checkActiveRecs()
  
  if active_rect then
    active_rect.h = active_rect.h + 1 --(1 / lEnd[curRec+1])
    
    --active_rect.h = (fall[curRec+1]+7) - active_rect.y-- speed needs to be based on loopTimer for this curRec+1 vox

    if grow_direction == "down" then
      if active_rect.y + active_rect.h >= (lEnd[curRec+1]+6) then --update the 64 to use lEnd[curRec+1]+6???
        finalize_active_rect()
        if key2_down then start_new_rectangle(6) end
      end
    else -- direction == "up"
      if active_rect.y - active_rect.h <= 6 then
        finalize_active_rect()
        if key2_down then start_new_rectangle(lEnd[curRec+1]+6) end --update the 64 to use lEnd[curRec+1]+6???
      end
    end
  end
  
end

function update()
  rects:update()
  
  --redraw()
end

-- Draw the growing rectangle with wrap support
function draw_wrapped_rect(r)
  screen.level(math.floor(r.color))
  local y = r.y
  local h = r.h

  if grow_direction == "down" then
    if y + h <= lEnd[curRec+1]+6 then --update the 64 to use lEnd[curRec+1]+6???
      screen.rect(r.x, y, r.w, h)
      screen.fill()
    else
      local h1 = lEnd[curRec+1]+6 - y --update the 64 to use lEnd[curRec+1]+6???
      local h2 = h - h1
      screen.rect(r.x, y, r.w, h1)
      screen.fill()
      screen.rect(r.x, 6, r.w, h2)
      screen.fill()
    end
  else -- up
    if y - h >= 6 then
      screen.rect(r.x, y - h, r.w, h)
      screen.fill()
    else
      local h1 = y
      local h2 = h - h1
      screen.rect(r.x, 6, r.w, h1)
      screen.fill()
      screen.rect(r.x, lEnd[curRec+1]+6 - h2, r.w, h2)  --update the 64 to use lEnd[curRec+1]+6???
      screen.fill()
    end
  end
end

function clearRects()
  rects:clear()
end

function clearVox(v)
  rects:remove_by_vox(v)
end
