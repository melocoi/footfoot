local sc = {}



function sc.init()
  print("initializing softcut")
  
	audio.level_cut(1.0)
	audio.level_adc_cut(1)
	audio.level_eng_cut(1)
  
  for i = 1, 6 do
    softcut.level(i, 1.0)
    softcut.level_slew_time(i, 0.25)
  	softcut.level_input_cut(1, i, 1.0)
  	softcut.level_input_cut(2, i, 1.0)
  	softcut.pan(i, 0.0)
  
    softcut.play(i, 1)
  	softcut.rate(i, 1)
  	softcut.rate_slew_time(i, 0)
  	
  	softcut.loop_start(i, lStart[i])
  	softcut.loop_end(i,  lEnd[i] + lStart[i])
  	softcut.loop(i, 1)
  	softcut.fade_time(i, 0.1)
  	softcut.rec(i, 1)
  	softcut.rec_level(i, 0)
  	softcut.pre_level(i, scPre[i])
  	softcut.recpre_slew_time(i,1.5)
  	softcut.position(i, 1)
  	softcut.enable(i, 1)
  	softcut.pan(i,scPan[i])
  	softcut.pan_slew_time(i,lEnd[i])
    
  	softcut.filter_dry(i, 1)
  	
  	--softcut.pre_filter_lp(i,1)
  	--softcut.filter_fc(i,3840)
  	--softcut.pre_filter_rq(i,4)
  	
  	softcut.phase_quant(i,0.125)
  	
  	print("softcut voice", i , "initialized")
  end

  softcut.event_position(sc.checkPos)

  params:add_group("loop levels",6)
  params:add{id="lev_1", name="lev 1", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(1,x) end}
  params:add{id="lev_2", name="lev 2", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(2,x) end}
  params:add{id="lev_3", name="lev 3", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(3,x) end}
  params:add{id="lev_4", name="lev 4", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(4,x) end}
  params:add{id="lev_5", name="lev 5", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(5,x) end}
  params:add{id="lev_6", name="lev 6", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setLevel(6,x) end}

  params:add_group("loop pres",6)
  params:add{id="pre_1", name="pre 1", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(1,x) end}
  params:add{id="pre_2", name="pre 2", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(2,x) end}
  params:add{id="pre_3", name="pre 3", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(3,x) end}
  params:add{id="pre_4", name="pre 4", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(4,x) end}
  params:add{id="pre_5", name="pre 5", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(5,x) end}
  params:add{id="pre_6", name="pre 6", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,1,""),
    action=function(x) sc.setPre(6,x) end}
  
  params:add_group("loop lengths",6)
  params:add{id="loop_1", name="loop 1", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[1],""),
    action=function(x) updateLoops(1,x) end}
  params:add{id="loop_2", name="loop 2", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[2],""),
    action=function(x) updateLoops(2,x) end}
  params:add{id="loop_3", name="loop 3", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[3],""),
    action=function(x) updateLoops(3,x) end}
  params:add{id="loop_4", name="loop 4", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[4],""),
    action=function(x) updateLoops(4,x) end}
  params:add{id="loop_5", name="loop 5", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[5],""),
    action=function(x) updateLoops(5,x) end}
  params:add{id="loop_6", name="loop 6", type="control", 
    controlspec=controlspec.new(0,49,'lin',0,lEnd[6],""),
    action=function(x) updateLoops(6,x) end}
 
  print("softcut params initialized")
  
end

function sc.checkPos(i, pos)
  softcut.loop_start(i, pos)
  softcut.loop_end(i, pos + posOff )
  
  print('checking position')
end

function sc.setLevel(v,x)
  
  softcut.level(v,x)
  scLev[v] = x
  params:set(encLev[curRec+1], scLev[curRec+1])
  
end

function sc.setPre(v,x)
  
  softcut.pre_level(v,x)
  scPre[v] = x
  params:set(encPre[curRec+1], scPre[curRec+1])
  
end



return sc