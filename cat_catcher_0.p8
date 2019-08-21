pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--[[
  cat catcher 0 v0.0.1 - (c) lst 2019
  ===================================

  cat catcher 0 is the prequel
  to cat catcher. it's a simple
  game where our girl protagonist
  has to catch stray cats that
  are running rampant around the
  city and causing mischief.
  
  try to not let any cat escape!
  when they come close to you,
  press 🅾️ to capture them.
  be careful with the big ones,
  though! they are harder to
  catch.
--]]

function _init()
  t = 0
  -- actors can have .draw()
  -- and/or .update() methods
  actors = {}
  is_catching = false
  catching_t = 0
  -- delay after a "catch" action
  -- is done
  after_catching_t = 0
  stage_cleared_t = 0
  paw = { t = 0 }

  current_floor = 0
  score = 0
  high_score = 0
  stage = 4
  caught_cats = 0
  escaped_cats = 0
  -- cats that were either captured or escaped
  finished_cats = 0
  tries = 3
  floor_base_y = 40
  --[[
  game states:
  0 = title screen
  1 = stage introduction
  2 = game
  3 = stage clear
  4 = ending
  5 = game over
  --]]
  game_state = 1

  girl = girl_actor(8, floor_base_y + 32 * current_floor)
  add(actors, girl)

  elevator = elevator_actor(8, floor_base_y + 32 * current_floor)
  add(actors, elevator)

  --[[
    cats
    0 = small black
    1 = small brown
    2 = big black
    3 = big brown
				format:
				{ cat_code, tick, floor }
				if floor == -1 then the floor
				on which the cat will appear is
				randomized
  --]]
  cat_generation = {}
  -- stage 1 cats
  cat_generation[1] = {
    { 0, 30, 0 },
    { 0, 90, 1 },
    { 0, 150, 2 },
    { 0, 210, 0 },
    { 0, 270, 1 },
    { 0, 330, 2 },
    { 0, 360, 1 },
    { 1, 430, 0 },
    { 1, 480, 0 },
    { 1, 500, 1 },
    { 1, 520, 2 },
    { 2, 540, 0 },
    { 1, 580, 1 },
    { 3, 700, 1 },
    { 2, 860, 2 },
    { 0, 1020, 0 },
    { 0, 1050, 2 },
    { 0, 1080, 1 },
  }
  cat_generation[2] = {
    { 0, 30, 0 },
    { 0, 90, 2 },
    { 4, 150, 1 },
    { 4, 210, 1 },
    { 6, 310, 1 },
    { 6, 340, 0 },
    { 6, 370, 2 },
    { 7, 400, 1 },
    { 8, 550, 1 },
    { 7, 700, 1 },
    { 0, 840, 2 },
    { 6, 900, 2 },
    { 0, 920, 1 },
    { 6, 930, 0 },
    { 6, 960, 2 },
    { 0, 960, 1 },
    { 8, 980, 1 },
    { 6, 990, 0 },
    { 6, 1180, 1 },
  }
  cat_generation[3] = {
    { 9, 30, 1 },
    { 9, 60, 2 },
    { 9, 90, 0 },
    { 10, 130, 1 },
    { 10, 160, 0 },
    { 9, 160, 2 },
    { 10, 190, 1 },
    { 11, 200, 0 },
    { 10, 220, 2 },
    { 12, 290, 1 },
    { 11, 380, 2 },
    { 9, 450, 2 },
    { 9, 470, 1 },
    { 9, 530, 0 },
    { 10, 650, 2 },
    { 10, 670, 1 },
    { 10, 690, 0 },
    { 10, 710, 1 },
    { 10, 730, 2 },
    { 12, 730, 1 },
    { 10, 750, 1 },
    { 12, 750, 2 },
    { 10, 770, 0 },
    { 11, 830, 0 },
    { 13, 1050, 1 },
  }

  -- cats used for testing
  --[[
  cat = cat_actor(0)
  cat2 = cat_actor2(0)
  bigcat = bigcat_actor(1)
  bigcat2 = bigcat_actor2(2)
  add(actors, cat)
  add(actors, cat2)
  add(actors, bigcat)
  add(actors, bigcat2)
  still_cat = cat_actor(1)
  -- cats are caught between 20 and 28 x
  still_cat.x = 28
  function still_cat.update() end
  add(actors, still_cat)
  --]]

  small_paw = sprite(1, 1, { 4 })
  big_paw = sprite(2, 2, { 104, 105, 120, 121 })
end

function _update()
  t += 1

  if game_state == 0 then
    if btnp(❎) then
      game_state = 1
      stage = 1
      tries = 3
      t = 0
    end
    return
  elseif game_state == 1 then
    -- stage introduction
  	 if t == 60 then
  	   game_state = 2
  	   escaped_cats = 0
  	   caught_cats = 0
  	   finished_cats = 0
  	   actors = {}
  	   add(actors, girl)
  	   add(actors, elevator)
  	   if stage == 3 then
  	     -- add torches
  	     torch_positions = {
  	       { 32, 0 },
  	       { 32, 32 },
  	       { 56, 32 },
  	       { 32, 64 },
  	       { 56, 64 },
  	       { 80, 64 },
  	       { 32, 96 },
  	       { 56, 96 },
  	       { 80, 96 },
  	     }
  	     for tp in all(torch_positions) do
    	     add(actors, torch_actor(tp[1], tp[2]))
  	     end
  	   elseif stage == 4 then
  	     -- add animations
  	     add(actors, quasar_actor(90, 98))
  	     add(actors, portal_entrance_actor(100, 38))
  	   end
  	   t = 0
  	 end
	   return
  elseif game_state == 3 then
    -- stage clear
  	 if t == 60 then
  	   game_state = 1
  	   t = 0
      stage += 1
  	 end
  	 return
  elseif game_state == 5 then
    -- game over
    if btnp(❎) then
      game_state = 0
      t = 0
    end
    return
  end

  for obj in all(actors) do
    if obj.update != nil then
      obj.update()
    end
    if obj.escaped == true then
      if not obj.bonus then
		      escaped_cats += 1
		      if escaped_cats == 3 then
		        game_state = 1
		        t = 0
		        tries -= 1
		        if tries == 0 then
		          game_state = 5
		        end
		      end
		    end
		    finished_cats += 1
      del(actors, obj)
      if finished_cats == #cat_generation[stage] then
 	      stage_cleared_t = 45
 	      return
	     end
    end
  end

  if stage_cleared_t > 0 then
    stage_cleared_t -= 1
    if stage_cleared_t == 0 then
      game_state = 3
      t = 0
      return
    end
  end

  if after_catching_t > 0 then
    after_catching_t -= 1
  end
  if paw.t > 0 then
    paw.t -= 1
    if
      paw.t == 0
      and finished_cats == #cat_generation[stage]
    then
      stage_cleared_t = 45
    end
  end

  if is_catching then
    catching_t += 1
    if catching_t == 5 then
      catching_t = 0
      is_catching = false
      after_catching_t = 5
    end
  end
  if elevator.is_changing_floors() then
    girl.y = elevator.get_y()
  end

  for c in all(cat_generation[stage]) do
    if c[2] == t then
      generate_cats(c)
    end
  end

  if btn(⬆️) then
    change_floor(-1)
  end
  if btn(⬇️) then
    change_floor(1)
  end
  if btn(🅾️)
    and not elevator.is_changing_floors()
    and not is_catching
    and after_catching_t == 0
  then
    catch()
    is_catching = true
 	end
 
  --[[
  if btn(⬅️) then
    girl.walk(-2)
  end
  if btn(➡️) then
    girl.walk(2)
  end
  -- stops walking
  if girl.is_walking() and not btn(⬅️) and not btn(➡️) then
    girl.idle()
  end
  --]]
end

function generate_cats(c)
  local floor
  if c[3] != -1 then
    floor = c[3]
  else
    floor = flr(rnd(3))
  end

  local new_cat = cat_map[c[1]](floor)
  add(actors, new_cat)
end

function change_floor(direction)
  if direction == -1 
    and current_floor > 0 
    and elevator.can_change_to(direction)
  then
    current_floor -= 1
    elevator.change_floor(direction)
    girl.change_floor(direction)
  end
  if direction == 1
    and current_floor < 2
    and elevator.can_change_to(direction)
  then
    current_floor += 1
    elevator.change_floor(direction)
    girl.change_floor(direction)
  end
end

function catch()
  sfx(12)
  girl.catch()
  for actor in all(actors) do
    if 
      actor.is_cat
      and girl.is_close_enough_to(actor)
      and actor.caught()
    then
	 	   score += actor.value
	 	   caught_cats += 1
	 	   finished_cats += 1
	 	   paw = {
	 	     t = 15,
	 	     x = actor.x,
	 	     y = actor.y,
	 	     sprite = small_paw
      }
      if actor.value >= 50 then
        paw.sprite = big_paw
      end
	 	   del(actors, actor)
    end
  end
end

function _draw()
  cls(1)
  
  if game_state == 0 then
			 print("cat catcher 0", 64 - 26, 61)
			 print("press ❎ to start", 32, 90)
			 print("lst 2019", 64 - 16, 120)
  elseif game_state == 1 then
    print("stage " .. stage, 64 - 14, 61)
    print("tries x " .. tries, 46, 80)
  elseif game_state == 3 then
    print("stage clear!", 40, 61)
  elseif game_state == 5 then
    print("game over", 46, 61)
  elseif game_state == 2 then

    if stage == 2 then
      cls(2)
    elseif stage == 3 then
      cls(1)
    elseif stage == 4 then
      cls(0)
    end
		  map((stage - 1) * 16, 0, 0, 0, 16, 16)
		  if stage == 2 then
		    -- vine 1
		    line(95, 88, 63, 120, 3)
		    line(96, 88, 64, 120, 11)
		    line(97, 88, 65, 120, 3)

      -- vine 2		    
		    line(71, 88, 39, 56, 3)
		    line(72, 88, 40, 56, 11)
		    line(73, 88, 41, 56, 3)
		  end
		  
		  rectfill(girl.x + 1, girl.y + 1, girl.x + 15, girl.y + 15, 0)
		  for gfx in all(actors) do
		    if gfx.draw != nil then
		      gfx.draw()
		    end
		    if gfx.is_girl and stage == 3 then
		      palt(8, true)
		      palt(0, false)
				    spr(166, girl.x, girl.y)
				    spr(167, girl.x + 8, girl.y)
				    palt()
		    end
		  end
		  if stage == 3 then
  		  map(32, 0, 0, 0, 16, 16, 1)
  		end

		  if is_catching then
		    spr(52, girl.x + 16, girl.y + 8)
		  end
		  if paw.t > 0 then
		    paw.sprite.draw(paw.x, paw.y)
		  end
		  
		  print("score: " .. score, 0, 0, 7)
		  print("escaped: " .. escaped_cats .. "/3", 80, 0, 7)
		  
		end
end

-->8
function girl_actor(x, y)
  local t = 0
  local w = 16
  local h = 16
  local idle_t = 0
  local floor = 0
  local transparent_color = 8

  local girl1 = sprite(2, 2, { 20, 21, 36, 37 }, transparent_color)
  local animation_idle = animation()
  animation_idle.add_frame(girl1, 30)
  local idle_state = state(
    "idle",
    animation_idle
  )

  local girl2 = sprite(2, 2, { 22, 23, 38, 39 }, transparent_color)
  local girl3 = sprite(2, 2, { 24, 25, 40, 41 }, transparent_color)
  local animation_blink = animation()
  animation_blink.add_frame(girl2, 2)
  animation_blink.add_frame(girl3, 5)
  animation_blink.add_frame(girl2, 2)
  local blink_state = state(
    "blink",
    animation_blink
  )

  local girl4 = sprite(2, 2, { 26, 27, 42, 43 }, transparent_color)
  local girl5 = sprite(2, 2, { 28, 29, 44, 45 }, transparent_color)
  animation_yawn = animation()
  animation_yawn.add_frame(girl2, 5)
  animation_yawn.add_frame(girl3, 20)
  animation_yawn.add_frame(girl4, 13)
  animation_yawn.add_frame(girl5, 40)
  animation_yawn.add_frame(girl4, 13)
  animation_yawn.add_frame(girl3, 20)
  animation_yawn.add_frame(girl2, 5)
  local yawn_state = state(
    "yawn",
    animation_yawn
  )
  
  local girl6 = sprite(2, 2, { 30, 31, 46, 47 }, transparent_color)
  animation_walk = animation()
  animation_walk.add_frame(girl6, 5)
  animation_walk.add_frame(girl1, 5)
  local walk_state = state(
    "walk",
    animation_walk
  )

  local girl = actor(x, y, {
    idle_state,
    blink_state,
    yawn_state,
    walk_state
  })
  
  function girl.update()
    t += 1
    if girl.is_idle() then
      idle_t += 1
    else
      idle_t = 0
    end
    
    -- idle
		  if girl.current_state == 1 then
     	if t % 10 == 0 and flr(rnd(100)) > 70 then
     	  girl.change_to_state(2)
      elseif idle_t > 300 then
        girl.change_to_state(3)
        idle_t = 0
      end
    end

    girl.update_state()
  end
  
  function girl.walk(distance)
    girl.x += distance
    girl.change_to_state(4)
  end

  function girl.idle()
    girl.change_to_state(1)
  end

  function girl.is_walking()
  	 return girl.current_state == 4
  end

  function girl.is_idle()
    return girl.current_state >= 1 and girl.current_state <= 3
  end

  function girl.change_floor(direction)
    if direction == -1 and floor > 0 then
      floor -= 1
      idle_t = 0
    elseif direction == 1 and floor < 2 then
      floor += 1
      idle_t = 0
    end
  end

  function girl.catch()
    idle_t = 0
  end

  function girl.is_close_enough_to(cat)
    if 
      girl.x + w - 4 <= cat.x
      and girl.x + w + 4 >= cat.x
      and floor == cat.floor
      and cat.is_vulnerable
    then
      return true
    end
  end

  girl.is_girl = true
  blink_state.set_finished_callback(girl.idle)
  yawn_state.set_finished_callback(girl.idle)
  
  return girl
end

-->8
function sprite(w, h, sprites, transparent_color)
  local w = w
  local h = h
  local sprites = sprites
  local self = {}
  local transparent_color = transparent_color

  function self.draw(x, y)
	   if transparent_color != nil then
      palt(transparent_color, true)
      palt(0, false)
    end
    for i = 0, h - 1 do
	     for j = 0, w - 1 do
	       spr(
  	       sprites[i * w + j + 1],
  	       x + j * 8,
  	       y + i * 8
  	     )
  	   end
  	 end
    palt()
  end

  return self
end

function animation()
  local sprites = {}
  local durations = {}
  local number_of_sprites = 0
  local current_frame = 1
  local ticks = 0
  local finished_callback = nil

  local self = {}
  function self.add_frame(sprite, duration)
    add(sprites, sprite)
    add(durations, duration)
    number_of_sprites += 1
  end
  function self.set_finished_callback(callback)
    finished_callback = callback
  end
  function self.start()
    ticks = 0
    current_frame = 1
  end
  function self.update()
    ticks += 1
    if ticks >= durations[current_frame] then
      current_frame += 1
      if current_frame > number_of_sprites then
        current_frame = 1
        if finished_callback != nil then
          finished_callback()
        end
      end
      ticks = 0
    end
  end
	 function self.draw(x, y)
	   sprites[current_frame].draw(x, y)
	 end

  return self
end

function state(name, animation)
  local self = {
    name = name,
    animation = animation
  }

  function self.set_finished_callback(callback)
    animation.set_finished_callback(callback)
  end
  function self.start()
    animation.start()
  end
  function self.update()
    animation.update()
  end
  function self.draw(x, y)
    animation.draw(x, y)
  end

  return self
end

function actor(x, y, states)
  local states = states
  local self = {
    x = x,
    y = y,
    h = 8,
    w = 8,
    current_state = 1
  }

  function self.change_to_state(new_state)
    self.current_state = new_state
    states[self.current_state].start()
  end
  function self.get_current_state()
    return states[self.current_state].name
  end
  -- remember to call this in
  -- the actor's update() method 
  function self.update_state()
    states[self.current_state].update()
  end
  function self.draw()
    states[self.current_state].draw(self.x, self.y)
  end

  return self
end

-->8
function base_cat_actor(sprites, floor)
  local life = 1
  local animation = animation()
  animation.add_frame(sprites[1], 8)
  animation.add_frame(sprites[2], 8)
  local walking = state(
  	 "walking",
  	 animation
  )
  local cat = actor(
    128,
    floor_base_y + 8 + floor * 32,
    { walking }
  )
  
  function cat.caught()
    life -= 1
    if life == 0 then
      sfx(8)
      return true
    end
    return false
  end
  
  cat.is_cat = true
  cat.floor = floor
	 cat.is_vulnerable = true
	 cat.value = 10
	 cat.update_functions = {}

  function cat.base_update()
    for f in all(cat.update_functions) do f() end
  end
  
  return cat
end

function cat_actor(floor)
  local sprites = {
    sprite(1, 1, { 1 }),
    sprite(1, 1, { 2 }),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
    cat.base_update()
    cat.x -= 1
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end

  return cat
end

function cat_actor2(floor)
  local sprites = {
    sprite(1, 1, { 10 }),
    sprite(1, 1, { 11 }),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
			 cat.base_update()
    cat.x -= 2
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end

  cat.value = 30

  return cat
end

-- adds climbing behavior to a cat
function climber(cat, climb_velocity)
	 add(cat.update_functions, function()
    if cat.is_going_down then
      cat.y += climb_velocity
      if cat.y == 120 - cat.h then
        cat.is_going_down = false
      end
    end
    if cat.is_going_up then
      cat.y -= climb_velocity
      if cat.y == 56 - cat.h then
        cat.is_going_up = false
      end
    end
    if cat.floor == 1 then
      if cat.x == 94 and flr(rnd(10)) > 5 then
        cat.is_going_down = true
        cat.floor = 2
      end
      if cat.x == 70 and flr(rnd(10)) > 5 then
        cat.is_going_up = true
        cat.floor = 0
      end
    end
	 end)
	 return cat
end

-- cat that goes up and down
-- the vines in stage 2
function cat_actor3(floor)
  return climber(cat_actor(floor), 1)
end

function cat_actor4(floor)
  return climber(cat_actor2(floor), 2)
end

-- tiger climber cat
function cat_actor5(floor)
  local sprites = {
    sprite(1, 1, { 50 }),
    sprite(1, 1, { 51 }),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
			 cat.base_update()
    cat.x -= 2
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end

  cat.value = 30

  return climber(cat, 2)
end

-- bonus green cat
function cat_actor_bonus(floor)
  local sprites = {
    sprite(1, 1, { 53 }),
    sprite(1, 1, { 54 }),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
    cat.base_update()
    cat.x -= 4
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end
  cat.bonus = true
  cat.value = 1000
  return cat
end

-- black cat with helmet
function cat_actor6(floor)
  local sprites = {
    sprite(1, 1, { 122 }, 1),
    sprite(1, 1, { 123 }, 1),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
    cat.base_update()
    cat.x -= 1
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end

  return cat
end

-- white fast cat
function cat_actor7(floor)
  local sprites = {
    sprite(1, 1, { 12 }),
    sprite(1, 1, { 13 }),
  }
  local cat = base_cat_actor(sprites, floor)

  function cat.update()
    cat.update_state()
			 cat.base_update()
    cat.x -= 2
    if cat.x < -8 then
      sfx(8)
      cat.escaped = true
    end
  end
  cat.value = 30
  return cat
end

function base_bigcat_actor(sprites, floor)
  local life = 3
  local cat1 = sprites[1]
  local cat2 = sprites[2]
  local animation_walk = animation()
  animation_walk.add_frame(cat1, 8)
  animation_walk.add_frame(cat2, 8)
  local walking = state(
  	 "walking",
  	 animation_walk
  )

  local stun1 = sprites[3]
  local animation_stunned = animation()
  animation_stunned.add_frame(stun1, 30)
  local stunned = state(
    "stunned",
    animation_stunned
  )

  local bigcat = actor(
    128,
    floor_base_y + floor * 32,
    { walking, stunned }
  )

  stunned.set_finished_callback(function()
    bigcat.change_to_state(1)
    bigcat.is_vulnerable = true
  end)

  function bigcat.update()
    bigcat.update_state()
    bigcat.base_update()

    if bigcat.current_state == 1 then
		    bigcat.x -= 1
      if bigcat.x < -16 then
        sfx(8)
        bigcat.escaped = true
      end
		  elseif bigcat.current_state == 2 then
		    -- stunned
		    bigcat.x += 1
      -- todo: implement bumps with gravity
    end
  end
  
  function bigcat.caught()
    life -= 1
    bigcat.change_to_state(2)
    bigcat.is_vulnerable = false
    if life == 0 then
      sfx(8)
      return true
    end
    return false
  end

	 bigcat.update_functions = {}

  function bigcat.base_update()
    for f in all(bigcat.update_functions) do f() end
  end

  bigcat.is_cat = true
  bigcat.floor = floor
  bigcat.is_vulnerable = true
  bigcat.value = 50
  bigcat.w = 16
  bigcat.h = 16
  
  return bigcat
end

function bigcat_actor(floor)
  local sprites = {
    -- walking
    sprite(2, 2, { 16, 17, 32, 33 }),
    sprite(2, 2, { 18, 19, 34, 35 }),
    -- stunned
    sprite(2, 2, { 98, 99, 114, 115 }),
  }
  local bigcat = base_bigcat_actor(sprites, floor)
  return bigcat
end

function bigcat_actor2(floor)
  local sprites = {
    sprite(2, 2, { 64, 65, 80, 81 }),
    sprite(2, 2, { 66, 67, 82, 83 }),
    sprite(2, 2, { 100, 101, 116, 117 }),
  }
  local bigcat = base_bigcat_actor(sprites, floor)
  return bigcat
end

-- climber bigcat
function bigcat_actor3(floor)
  return climber(bigcat_actor(floor), 1)
end

function bigcat_actor4(floor)
  return climber(bigcat_actor2(floor), 1)
end

function bigcat_actor5(floor)
  local sprites = {
    sprite(2, 2, { 128, 129, 144, 145 }),
    sprite(2, 2, { 130, 131, 146, 147 }),
    sprite(2, 2, { 132, 133, 148, 149 }),
  }
  local bigcat = base_bigcat_actor(sprites, floor)
  return bigcat
end

function bigcat_actor6(floor)
  local sprites = {
    sprite(2, 2, { 160, 161, 176, 177 }, 1),
    sprite(2, 2, { 162, 163, 178, 179 }, 1),
    sprite(2, 2, { 164, 165, 180, 181 }, 1),
  }
  local bigcat = base_bigcat_actor(sprites, floor)
  return bigcat
end

cat_map = {
  -- 0 - normal cat
  [0] = cat_actor,
  -- 1 - fast cat
  cat_actor2,
  -- 2 - big black cat
  bigcat_actor,
  -- 3 - big brown cat
  bigcat_actor2,
  -- 4 - climber normal cat
  cat_actor3,
  -- 5 - climber fast cat
  cat_actor4,
  -- 6 - climber tiger cat
  cat_actor5,
  -- 7 - climber big cat
  bigcat_actor3,
  -- 8 - climber brown bigcat
  bigcat_actor4,
  -- 9 - black cat with helmet
  cat_actor6,
  -- 10 - white fast cat
  cat_actor7,
  -- 10 - big cat with helmet
  bigcat_actor5,
  -- 11 - big black cat with helmet
  bigcat_actor6,
  -- 12 - bonus green cat
  cat_actor_bonus,
}
-->8
function elevator_actor(x, y)
	 local x = x
	 local y = y
	 local t = 0
	 local state = 0
	 --[[
	   states:
	   0 = open, still
	   1 = closing
	   2 = moving between floors
	   3 = opening
	 --]]
	 local gap_width = 7
	 local current_floor = 0
	 local destination_floor = 0
	 local direction = 0 -- -1 -> up, 1 -> down
	 local self = {}

  function self.draw()
    line(x, y, x + 15, y, 5)
    line(x, y, x, y + 15, 5)
    line(x + 15, y, x + 15, y + 15, 5)
    if state != 0 then
      rectfill(x + 1, y + 1, x + 7 - gap_width, y + 15, 6)
      rectfill(x + 8 + gap_width, y + 1, x + 14, y + 15, 6)
		    local left_gap = x + 7 - gap_width
		    local right_gap = x + 8 + gap_width
		    line(left_gap, y + 1, left_gap, y + 15, 13)
		    line(right_gap, y + 1, right_gap, y + 15, 7)
		  end
  end

  function self.update()
    t += 1

    if state == 1 then
      gap_width -= 2
      if gap_width <= 0 then
        gap_width = 0
        state = 2
      end
    elseif state == 2 then
      y = 40 + destination_floor * 32
      state = 3
    elseif state == 3 then
      gap_width += 2
      if gap_width >= 7 then
        gap_width = 7
        state = 0
        floor = destination_floor
      end
    end
  end

  function self.change_floor(new_direction)
    if self.is_changing_floors() and direction == new_direction then return end

    direction = new_direction
    state = 1
    destination_floor += new_direction
    if destination_floor < 0 then
      destination_floor = 0
    elseif destination_floor > 2 then
      destination_floor = 2
    end
  end
  
  function self.can_change_to(new_direction)
    if not self.is_changing_floors() then
      return true
    end
    if direction == new_direction then
      return false
    end
    return true
  end
  
  function self.get_y()
    return y
  end

  function self.is_changing_floors()
    return state != 0
  end

	 return self
end

function torch_actor(x, y)
	 local t = 0
	 
  local sprites = {
    sprite(1, 1, { 61 }),
    sprite(1, 1, { 62 }),
    sprite(1, 1, { 63 }),    
  }
  local animation = animation()
  
  animation.add_frame(sprites[1], flr(rnd(4)) + 2)
  animation.add_frame(sprites[2], flr(rnd(6)) + 3)
  animation.add_frame(sprites[3], flr(rnd(4)) + 2)
  local idle = state("idle", animation)
  local torch = actor(x, y, { idle })
  
  function torch.update()
    torch.update_state()
  end
  
  return torch
end

function quasar_actor(x, y)
	 local t = 0
	 
  local sprites = {
    sprite(1, 1, { 142 }),
    sprite(1, 1, { 143 }),
    sprite(1, 1, { 158 }),
    sprite(1, 1, { 159 }),
    sprite(1, 1, { 174 }),
    sprite(1, 1, { 175 }),
    sprite(1, 1, { 190 }),
    sprite(1, 1, { 191 }),
    sprite(1, 1, { 187 }),
    sprite(1, 1, { 188 }),
    sprite(1, 1, { 171 }),
    sprite(1, 1, { 172 }),
    sprite(1, 1, { 173 }),
    sprite(1, 1, { 189 }),
    
    --[[
    sprite(1, 1, { 175 }),
    sprite(1, 1, { 174 }),
    sprite(1, 1, { 159 }),
    sprite(1, 1, { 158 }),
    sprite(1, 1, { 143 }),
    sprite(1, 1, { 142 }),
    --]]
  }
  local animation = animation()
  for i = 1, 14 do
    animation.add_frame(sprites[i], 3)
  end
  local idle = state("idle", animation)
  local quasar = actor(x, y, { idle })
  
  function quasar.update()
    quasar.update_state()
  end
  
  return quasar
end

function portal_entrance_actor(x, y)
	 local t = 0
	 
  local sprites = {
    sprite(1, 2, { 192, 208 }),
    sprite(1, 2, { 193, 209 }),
    sprite(1, 2, { 194, 210 }),
    sprite(1, 2, { 195, 211 }),
    sprite(1, 2, { 196, 212 }),
    sprite(1, 2, { 197, 213 }),
    sprite(1, 2, { 198, 214 }),
    sprite(1, 2, { 199, 215 }),
    sprite(1, 2, { 200, 216 }),
  }
  local animation = animation()
  for i = 1, 8 do
    animation.add_frame(sprites[i], 2)
  end
  animation.add_frame(sprites[9], 30)
  for i = 8, 1, -1 do
    animation.add_frame(sprites[i], 2)
  end
  local idle = state("idle", animation)

  local portal = actor(x, y, { idle })
  function portal.update()
    portal.update_state()
  end
  return portal
end

function portal_exit_actor(x, y)
	 local t = 0
	 
  local sprites = {
    sprite(1, 2, { 194, 210 }),
    sprite(1, 2, { 195, 211 }),
    sprite(1, 2, { 196, 212 }),
    sprite(1, 2, { 197, 213 }),
    sprite(1, 2, { 198, 214 }),
    sprite(1, 2, { 199, 215 }),
    sprite(1, 2, { 200, 216 }),
    sprite(1, 2, { 201, 217 }),
    sprite(1, 2, { 192, 208 }),
  }
  local animation = animation()
  for i = 1, 9 do
    animation.add_frame(sprites[i], 3)
  end
  local idle = state("idle", animation)

  local portal = actor(x, y, { idle })
  function portal.update()
    portal.update_state()
  end
  return portal
end

__gfx__
000000005050005550500005444444440000000000000000555555550444444033333333111111110000000000000090a0a00077a0a000070066a00000000000
00000000555000055550000544b4b44405555500000000006666666644999944b3b3b3a3cccccccc4040009440400004aaa00007aaa00007066666a000000000
00000000a5a00005a5a00005bbbbbbb4557575500000ccc06666666649499494bbbbbbbbccc7c7cc4440000444400004c7c00007c7c000074444444400000000
000000005555555555555555bbbbbbb457555750000ccc0c6666666649944994abbbbbbbcccccc77a4a00004a4a0000477774777777747774444444400000000
000000005555555555555555b3bb3bb45557555000cccc776666666649944994bbbbabbb77cccccc444494944444949477774777777747770444444000000000
000000005050050550500505bbbbbbb405777500ccc777706666666649499494bbbbbbbacccccccc444444404444444077774777777747770444444000000000
000000005050050550550555b3bb3bbb057575000c0000006666666644999944bbabbbbbcccc7cc7444444404444444470700707707007770444444000000650
000000005050050505000005b3333bbb05555500000000005555555504444440bbbbbbbbcccccccc404040400404000070700707070700070500005000600550
50000005000066505000000500000000888882222224448888888222222444888888822222244488888882222224448888888222222444888888822222244488
5500005500006555550000550000665588882222224f244888882222224f244888882222224f244888882222224f244888882222224f244888882222224f2448
5550055500000055555005550000655588822222224ff24488822222224ff24488822222224ff24488822222224ff24488822222224ff24488822222224ff244
555555550000005555555555000000558882222224ffff248882222224ffff248882222224ffff248882222224ffff248882222224ffff248882222224ffff24
555555550000005555555555000000558882222244ffff248882222244ffff248882222244ffff248882222244ffff248882222244ffff248882222244ffff24
5aa55aa5500000555aa55aa55000005582c2222447ff07f282c222244ffffff282c222244ffffff282c222244ffffff282c222244ffffff282c2222447ff07f2
5aa55aa5555555555aa55aa55555555522c2244f00ff00f222c2244f07ff07f222c2244ffffffff222c2244ffffffff222c2244ffffffff222c2244f00ff00f2
555e555555555555555e55555555555522c244ff00ff00f222c244ff00ff00f222c244f000ff000222c244f000ff000222c244f000ff000222c244ff00ff00f2
6555556665555555655555666555555522144fff04ff04ff22144fff44ff44ff22144fffffffffff22144fffffffffff22144ff7ffffff7f22144fff04ff04ff
5555555555555555555555555555555522844fff44ff44ff22844fffffffffff22844fffffffffff22844fffffffffff22844ffffeeeefff22844fff44ff44ff
55566555555555555556655555555550248844ffffffffff248844ffffffffff248844ffffffffff248844ffffeeffff248844fffeeeefff248844ffffffffff
556006555555055555600655555505502488844ffffffff82488844ffffffff82488844ffffffff82488844fffeefff82488844ffeeeeff82488844ffffffff8
55000055055000555500005505500555224888fffffff888224888fffffff888224888fffffff888224888fffffff888224888fffffff888224888fffffff888
550000550550005555600055055005552224488bbabb88882224488bbabb88882224488bbabb88882224488bbabb88882224488bbabb88882224488bbabb8888
550000550550005556600056055500558222888bbbbb88888222888bbbbb88888222888bbbbb88888222888bbbbb88888222888bbbbb88888222881bbbbb1888
66000066065000650000006605560066888888818881888888888881888188888888888188818888888888818881888888888881888188888888888888888888
101000611010006100000000000000400000000000000000000000e0909000559090000505555550055555555555555655554556000a00000000a00000000a00
1110000111100001909000499090000900067670b0b000ebb0b0000b99900005999000055565666555656a655666566666565665000aaa00000aaa00000aaa00
a1a00001a1a00001999000099990000900676767bbb0000bbbb0000ba5a00005a5a0000556666654566666556565656656656665000a9a00000a9a00000a9a00
11161611111616117970000979700009007676767b70000b7b70000b55554555555545555656666556a666656665466666545666000a9a00000a9a00000a9a00
1111111111111111999949499999494900676767bbbbebebbbbbebeb55554555555545555666656556666565566656a666556656000444000004440000044400
1010010110100101994949409949494000767676bbbbbbb0bbbbbbb05050050550500505556666555566665566465565666546a6000444000004440000044400
1010010110160161994949409994949900676767bbbbbbb0bbbbbbbb505005055055055554565645595656456665445665645466000040000000400000004000
6060060606000006909090900909000099999999b0b0b0b00b0b0000505005050500000555455550055555555555554556555555000040000000400000004000
70000007000077407000000700000000d000000d0000dd10d000000d000000000099990000000000000000000000000066666666666666666666666600000000
44000044000074444400004400007744110000110000d111110000110000dd11099999900555555500090000000300006cccccc66cccccccccccccc604444440
444004440000004444400444000074441110011100000011111001110000d111099999900565556504444444000030306cccccc66cccccccccccccc604ffff40
444444440000004444444444000000441111111100000011111111110000001109999990056666650000400000003b006cccccc66ccccccc7777ccc604f22f40
4444444400000044444444440000004411111111000000111111111100000011889999880555555500004000000030006cccc7766ccccc7777777cc604fe2f40
4aa44aa4400000444aa44aa44000004417711771100000111771177110000011889999880565556500004000005555506cc777766777ccccccccccc604feef40
4aa44aa4447474444aa44aa4447474441771177111d1d1111771177111d1d111898888980566666500004000000666006cccccc667777cccccccccc604444440
4449444444474744444944444447474411161111111d1d1111161111111d1d118999999805555555000444000006660066666666666666666666666600000000
74444477744444447444447774444444d11111ddd1111111d11111ddd111111100ffffffffffff00000000000000000000000000000000005050005550500005
44444444444444444444444444444444111111111111111111111111111111110ffffffffffffff0055555000000000003300333000000005550000555500005
44477444444444444447744444444440111dd11111111111111dd111111111100ffffffffffffff0557575500000000033333300000bbb00a5a00005a5a00005
4470074444440444447007444444044011d00d111111011111d00d11111101100ffffffffffffff05755575000000000333bbbb000bbabb05555555555555555
4400004404400044440000440440044411000011011000111100001101100111eeffffffffffffee555755500000000033bb3bbb0bbbbbb05555555555555555
44000044044000444470004404400444110000110110001111d0001101100111efeffffffffffefe057775000000000030bb4bbb0bbbbb005050050550500505
4400004404400044477000470444004411000011011000111dd0001d01110011efeeeeeeeeeeeefe05757500000000000bb0440b0bbbb0005050050550550555
77000077074000740000007704470077110000110d1000d1000000dd011d00ddefeffffffffffefe05555500000000000b0044000bbbbb005050050505000005
5555555000000005500000050000000070000007000000005555555555555555000000000000000033333333333333330000ff000000000000000000b0000000
5600006500000005550000550000665544000044000077445666666d7666666500000055555550003b33b3bbb33bb3bb0000440000000000000008000b000000
5060060500000005555005550000655544400444000074445666666d766666650000055775775500bbbbbb4bbbbbbbbb00004400000000000000b00000b00003
5006700500000005555555550000005544444444000000445666666d7666666500555577757775004bbbbbbbbb3bb9ab0000ff0000000300000b0000000b00b0
5006600500000005555555550000005544444444000000445666666d766666650557757775777500bbbb3bbbbbb3b3bb000044000300b000000b0300000b0b00
50600605000000055a5555a5500000554a4444a4400000445666666d766666650577755775775550b3bbbbbbbbab3bbb0000440000b0b0000003b030bb03b000
560000650000000555a55a555555555544a44a44447474445666666d766666650577755555555755bbbbb3bbbbbb3bbb0000ff00000b00000030b00000bbb3bb
0555555500000005555e55555555555544494444444747445666666d766666650557555777557775bbbbbb3bbbb3bbbb00004400000b00000000b00000033000
5000000055555550655555666555555574444477744444445666666d766666650000557777755775919111009191111000000000000000000000000000000000
5000000056000065555555555555555544444444444444445666666d766666650005577777775555999111109991111000000000000000000000000000000000
5000000050600605555665555555555044477444444444405666666d766666650005777777777500a0a11110a0a1111000000000000000000000000000000000
5000000050067005556006555555055044700744444404405666666d766666650005777777777500000040000000400000000000000000000000000000000000
5000000050066005550000550550055544000044044004445666666d766666650005577557777500000040000000400000000000000000000000000000000000
5000000050600605556000550550055544700044044004445666666d766666650000555555775500010110100101101000000000000000000000000000000000
5000000056000065566000560555005547700047044400445666666d766666650000000005555000010110100100100000000000000000000000000000000000
5000000005555555000000660556006600000077044700775666666d766666650000000000000000010110101011111000000000000000000000000000000000
00aaaa000000665000aaaa000000000000aaaa0000000000555555555555555500000000000900000000000000000000007777000000000009a00a9009a00090
04aaaaa00000655504aaaaa00000665504aaaaa0000066555566665555666655007000000000000000000ffffff0000006666670000000009a9700a99a9700a9
444444440000005544444444000065554444444400006555566665555666666507770000000000000000f000000f0000d6656667000c0000a000009a0000a09a
a4aaaaaa00000055a4aaaaaa00000055a4aaaaaa000000555666556655566555007000000000000000000000000000005d666566000000000007707000a77070
5555555500000055555555550000005555555555000000555565556666555565000000000000000000f0007777000f0055d56666000000000707700007077a00
5aa55aa5500000555aa55aa5500000555a5555a550000055555556666556666500000000000000000f000000000000f05d5dd65600000000a900000aa90a0000
5aa55aa5555455555aa55aa55554555555a55a5555545555555666666566666500000000000000700f007000000700f0055d5dd0000000009a0079a99a0079a9
555e555555554555555e555555554555555e555555554555556666666566666500000000000000000f00700aa00700f0005555000000000009a00a9009000a90
655555666555455565555566655545556555556665554555556666666556666500000007000000700f00700aa00700f04dddddd7d000000d09a0009009a00000
555555555555455555555555555545555555555555554555555666666556665500000000000000000f007000000700f05666666d6000000690970009000a0009
555665555555455555566555555545505556655555554550655666665555555600000000000000000f000000000000f05655556dd000000d0000a09a0000a00a
5560065555540555556006555554055055600655555405505555556655566655000000000000a00000f0007777000f005656666d6000000600a7707000aaa0a0
5500005505500055550000550550055555000055055005555566655555666665000000000000000000000000000000005666656dd000000d07077a000a0aaa00
550000550550005555600055055005555560005505500555556666555666665500a00000000000000000f000000f00005655556d66666666a90a0000a00a0000
5500005505500055566000560555005556600056055500555556665566665555000000000000000000000ffffff000005666666d77777777900079099000a000
660000660650006500000066055600660000006605560066555555555555555600000000000000000000000000000000d5555554a000000a09000a9000000a90
11aaaa111111660111aaaa111111111111aaaa111111111188888aaaaaaaaa88ddddddd70000ccccccc00000090000a0090000a009a000a000a0000000000000
14aaaaa11111600014aaaaa11111660014aaaaa1111166008888aaaaaaaaaaa85666666d000cccccccccc000a0900009a0900009a0900009000a0000000a0000
444444441111110044444444111160004444444411116000888aaaaaaaaaaa4a5655556d00cc777777cccc00000000900000a0900000a09a0000a00a0000a000
a4aaaaaa11111100a4aaaaaa11111100a4aaaaaa1111110088844444444444445656666d0cc77777777cccc00009a00000a9f00000a9700000aaa0a000afa0a0
000000001111110000000000111111000000000011111100888aaaaaaaaaaa4a5666656d0c77700700777cc0000a9000000f9a0000079a000a0aaa000a0afa00
0aa00aa0011111000aa00aa0011111000a0000a00111110088888888888888885655556d0c777007007777cc09000000090a0000a90a0000a00a0000000a0000
0aa00aa0000400000aa00aa00004000000a00a000004000088888888888888885666666dc66677887766666c9000090a9000090a9000090a0000a0000000a000
000e000000004000000e000000004000000e00000000400088888888888888885555555dc7777788777777cc0a0000900a0000900a000a9000000a0000000000
6000006660004000600000666000400060000066600040000000000000000000d6666567c66677767766666c000000a0090000a009a000a00000000000000000
0000000000004000000000000000400000000000000040000000666600000000d5555566c77eeeeeeeee77cca0000000a0000009af9a00f90000000000000000
00066000000040000006600000004001000660000000400100005d670008a000d56666560c7eeeeeeeee77cc00000000000000000000a09a0000a00000000000
00611600000410000061160000041001006116000004100100005d6600066000d55666560c7eeeeeeeee77c00009a0000009a00000a970a000afa000000f0000
00111100100111000011110010011000001111001001100000005d66000ca000d565655600c7eeeeeee77cc0000a9000000a90000a079a00000afa000000f000
00111100100111000061110010011000006111001001100055005d660006600055565656000c7eeeee77cc000000000000000000a90a0000000a000000000000
0011110010011100066111061000110006611106100011005d005d6600066000d55555560000c77777ccc0000000000a9000000a9f00a9fa0000000000000000
6611116616011160111111661006116611111166100611665d005d660006600055ddddd500000cccccc000000a0000000a0000900a000a900000000000000000
0000000000000000000000000000000000000000000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000ee000000ee00000e00e0000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ee00000e00e0000e00e0000e00e0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000ee00000e00e0000e00e0000e00e000e0000e000000000000000000000000000000000000000000000000000000000
000000000000000000000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
0000000000000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
00000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
000ee00000e00e0000e00e0000e00e000e0000e00e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
000ee00000e00e0000e00e0000e00e000e0000e00e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
00000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
0000000000000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
000000000000000000000000000ee00000e00e0000e00e000e0000e00e0000e00e0000e000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000ee00000e00e0000e00e0000e00e000e0000e000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ee00000e00e0000e00e0000e00e0000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000ee000000ee00000e00e0000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000
__label__
17711771177177717771111111117771717177711111111111111111111111111111111111111111777117711771777177717771771111111111777111717771
71117111717171717111171111111171717171711111111111111111111111111111111111111111711171117111717171717111717117111111117117111171
77717111717177117711111111117771777171711111111111111111111111111111111111111111771177717111777177717711717111111111777117111771
11717111717171717111171111117111117171711111111111111111111111111111111111111111711111717111717171117111717117111111711117111171
77111771771171717771111111117771117177711111111111111111111111111111111111111111777177111771717171117771777111111111777171117771
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111116666666611111111111111111111111111111111111111111111111111111111666666666666666611111111
11111111111111111111111111111111111111116cccccc6111111111111111111111111144444411111111111111111111111116cccccccccccccc611111111
11111111111111111111111111111111111111116cccccc611111111111111111111111114ffff411111111111111111111111116cccccccccccccc611111111
11111111111111111111111111111111111111116cccccc611111111111111111111111114f22f411111111111111111111111116ccccccc7777ccc611111111
11111111111111111111111111111111111111116cccc77611111111111111111111111114fe2f411111111111111111111111116ccccc7777777cc611111111
11111111111111111111111111111111111111116cc7777611111111111111111111111114feef411111111111111111111111116777ccccccccccc611111111
11111111111111111111111111111111111111116cccccc61111111111111111111111111444444111111111111111111111111167777cccccccccc611111111
11111111111111111111111111111111111111116666666611111111111111111111111111111111111111111111111111111111666666666666666611111111
11111111111111111111111111111111119999111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111199999911111111111111111111111111111111111131111155555551555555515555555155555551119111111131111
11111111111111111111111111111111199999911111111111111111111111111111111111113131156555651565556515655565156555651444444411113131
11111111111111111111111111111111199999911111111111111111111111111111111111113b11156666651566666515666665156666651111411111113b11
11111111111111111111111111111111889999881111111111111111111111111111111111113111155555551555555515555555155555551111411111113111
11111111111111111111111111111111889999881111111111111111111111111111111111555551156555651565556515655565156555651111411111555551
11111111111111111111111111111111898888981111111111111111111111111111111111166611156666651566666515666665156666651111411111166611
11111111111111111111111111111111899999981111111111111111111111111111111111166611155555551555555515555555155555551114441111166611
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111555555555555555511111111666666666666666611111111111111111111111166666666111111111111111111111111111111111111111111111111
111111115666666d76666665111111116cccccccccccccc61111111111111111111111116cccccc6111111111111111111111111111111111444444111111111
111111115666666d76666665111111116cccccccccccccc61111111111111111111111116cccccc61111111111111111111111111111111114ffff4111111111
111111115666666d76666665111111116ccccccc7777ccc61111111111111111111111116cccccc61111111111111111111111111111111114f22f4111111111
111111115666666d76666665111111116ccccc7777777cc61111111111111111111111116cccc7761111111111111111111111111111111114fe2f4111111111
111111115666666d76666665111111116777ccccccccccc61111111111111111111111116cc777761111111111111111111111111111111114feef4111111111
111111115666666d766666651111111167777cccccccccc61111111111111111111111116cccccc6111111111111111111111111111111111444444111111111
111111115666666d7666666511111111666666666666666611111111111111111111111166666666111111111111111111111111111111111111111111111111
111111115666666d7666666511111111111111111111111111999911111111111111111111111111111111515111151111111111119999111111111111111111
111111115666666d7666666511111111111111111111111119999991111111111111111111111111111311555111151111111111199999911111111111111111
111111115666666d7666666511111111111111111111111119999991111111111111111111111111111131a5a111151111111111199999911111111111111111
111111115666666d766666651111111111111111111111111999999111111111111111111111111111113b555555551111111111199999911111111111111111
111111115666666d7666666511111111111111111111111188999988111111111111111111111111111131555555551111111111889999881111111111111111
111111115666666d7666666511111111111111111111111188999988111111111111111111111111115555515115151111111111889999881111111111111111
111111115666666d7666666511111111111111111111111189888898111111111111111111111111111666515515551111111111898888981111111111111111
111111115666666d7666666511111111111111111111111189999998111111111111111111111111111666151111151111111111899999981111111111111111
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111555555555555555511111111111111116666666611111111111111111111111111111111666666666666666611111111111111116666666611111111
111111115666666d7666666511111111111111116cccccc6111111111111111111111111111111116cccccccccccccc611111111111111116cccccc611111111
111111115666666d7666666511111111111111116cccccc6111111111111111111111111111111116cccccccccccccc611111111111111116cccccc611111111
111111115666666d7666666511111111111111116cccccc6111111111111111111111111111111116ccccccc7777ccc611111111111111116cccccc611111111
111111115666666d7666666511111111111111116cccc776111111111111111111111111111111116ccccc7777777cc611111111111111116cccc77611111111
111111115666666d7666666511111111111111116cc77776111111111111111111111111111111116777ccccccccccc611111111111111116cc7777611111111
111111115666666d7666666511111111111111116cccccc61111111111111111111111111111111167777cccccccccc611111111111111116cccccc611111111
111111115666666d7666666511111111111111116666666611111111111111111111111111111111666666666666666611111111111111116666666611111111
111111115666666d76666665111111111111111111111111111111111111111111111111111111111111111111ffffffffffff11111111111111111111111111
111111115666666d7666666511111111111311111111111111111111111911111111111115555555155555551ffffffffffffff1111311111555555515555555
111111115666666d7666666511111111111131311111111111111111144444441111111115655565156555651ffffffffffffff1111131311565556515655565
111111115666666d766666651111111111113b111111111111111111111141111111111115666665156666651ffffffffffffff111113b111566666515666665
111111115666666d766666651111111111113111111111111111111111114111111111111555555515555555eeffffffffffffee111131111555555515555555
111111115666666d766666651111111111555551111111111111111111114111111111111565556515655565efeffffffffffefe115555511565556515655565
111111115666666d766666651111111111166611111111111111111111114111111111111566666515666665efeeeeeeeeeeeefe111666111566666515666665
111111115666666d766666651111111111166611111111111111111111144411111111111555555515555555efeffffffffffefe111666111555555515555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111555555555555555511111111666666666656666615111111111111111111111111111111111111111111111111111111111111111111111166666666
1111111150002222224f2445111111116ccccccccc55ccc65511116655111111144444411111111111111111111111111111111111111111111111116cccccc6
1111111150022222224ff245111111116ccccccccc555cc5551111655511111114ffff411111111111111111111111111111111111111111111111116cccccc6
111111115002222224ffff25111111116ccccccc77555555551111115511111114f22f411111111111111111111111111111111111111111111111116cccccc6
111111115002222244ffff25111111116ccccc7777555555551111115511111114fe2f411111111111111111111111111111111111111111111111116cccc776
1111111152c2222447ff07f5111111116777cccccc5aa55aa55111115511111114feef411111111111111111111111111111111111111111111111116cc77776
1111111152c2244f00ff00f51111111167777ccccc5aa55aa555555555111111144444411111111111111111111111111111111111111111111111116cccccc6
1111111152c244ff00ff00f5111111116666666666555e5555555555551111111111111111111111111111111111111111111111111111111111111166666666
1111111152144fff04ff04f5111111111111111111655555666555555511111111111111119999111111111111ffffffffffff11111111111111515111151111
1111111152044fff44ff44f511111111111111111155555555555555551111111111111119999991111111111ffffffffffffff1111111111113555111151111
11111111540044fffffffff511111111111111111155566555555555511111111111111119999991111111111ffffffffffffff1111111111111a5a111151111
111111115400044ffffffff511111111111111111155611655555515511111111111111119999991111111111ffffffffffffff1111111111111555555551111
11111111524000fffffff0051111111111111111115511115515511555111111111111118899998811111111eeffffffffffffee111111111111555555551111
111111115224400bbabb00051111111111111111115561115555555555111111111111118899998811111111efeffffffffffefe111111111155555115151111
111111115222000bbbbb00051111111111111111115661115615551155111111111111118988889811111111efeeeeeeeeeeeefe111111111116565515551111
1111111150000001000100051111111111111111111111116615561166111111111111118999999811111111efeffffffffffefe111111111116651111151111
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000101000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000000000000000000000000000969787868786878687008889000000000089000000008c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004c0000004f0000004d4e0000005c5c000000000000000000005c000000000000000000009696979697969700989900008900989900008d0098000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000048000000004b494949494a4b006e6c6c6d006f5d006e6d0000006c00006d000e000000000f978697868786870000b6b700b70000350000008d00b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060606060606060606066a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a39393a393a3939399697969796979697a8a8a8a8a8b8a8a8a8a8a8a8a8a8b8a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000868687868786879800000000000089009d00009900008900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006667004d4e0000004c000000004f00006667005c0000000000005c00000000006667000000000000969697969796970066679800000098000000999800009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007677000000480000004b0000480000007677006c0000006d00006c0000006d0076770000000000000f008786878687007677000000008d000088b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060606060606060606066a6a6b6a6a6a6a6a6a6a6a6a6a6a6b6a393a39393939393a3939969796979697a8b8a8a8a8a8a8b8a8a8a8a8a8a8a8a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086878687980000888c00000098000000009d008900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666700004c000000004d4e00004c00006667000000000000005c00005c00000066670000000000000000000096969700666700008900008d8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007677004b00004a00494958594b4949007677006e6d000000006c00006c6e006d76770000000f00000000000f008687b67677000000b700980089000000890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060606060606060606066a6a6a6a6a6b6a6a6a6a6a6b6a6a6a6a3939393a393939393a39393996979697b8a8a8a8a8a8a8a8a8b8a8a8a8a8a8b800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686870098000099009989890000000000009800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006667004d4e00004f0000000000004c0066670000005c0000000000000000000066670000000000000000000f9796978966670000008998000099000000890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0076770000004b000048005859004b000076770000006c0000006d00006f006e0076770f000000000f0e000086878687007677008900008d89000000b798b68800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060606060606060606066b6a6a6a6a6a6a6a6b6a6a6a6a6b6a6a3a393939393a39393939869796979697a8a8a8b8a8a8a8a8a8a8a8a8a8b8a8a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000002d0502f050310503105033050340503505036050370503705037050380503805038050370503505033050300502d0502a0502705024050210501e0501b050180501605014050120501105010050
011e00000c550105500c550105500c550105500c550105500b550105500b550105500b550105500b550105500c550105500c550105500c550105500c55010550135501755013550175500e550115500e55011550
011000002d250092500000009250000000d2500f2500000000000000000000000000000000000000000000002d250092500000009250000000d2500f250000000000000000000000000000000000000000000000
011000001f1501a050001001a0501f0501a05000100000000000000000000001f1501a0501f1501a050001001a0501f0501a05000100001000010000100001001f1501a0501f1501a050001001a0501f0501a050
01100000247502475024750247502875028750287502875026750267502675026750297502975029750297502b7502b7502b7502b750297502975029750297502875028750287502875024750247502475024750
011000001335010350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0002000035550365503755038550395503b5503c5503e5503f5503f5503f5503f5503f5503f5503e5503d5503c5503a5503855037550355503355025500005000050000500005000050000500005000050000500
010f00000c550000000c5500c5500c550075500c5500e550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000285502a5502c5502e55030550315503255032550315502e5502c550305502e550295502755025550215501d5500000000000000000000000000000000000000000000000000000000000000000000000
000200003075032750347503675037750397503a7503a75038750367503775039750377503475032750307502d7502a7502975000700007000070000700007000070000700007000070000700007000070000700
00050000360503c050290502e05037050210502705000000170500000007050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000285502b5502d5502e5502f550305502f5502e5502a5502f5502c550285502455024550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400000562004610026000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000000c550005000c5500e55010550005000c5500e5501055013550005001155000500105500c550005001755015550115500050010550005000e5500c5500b5500050016550005000c550005000050000000
001000001435015350333501f35000000000000000000000000001a350000000000000000000002c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 04034344

