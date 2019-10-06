pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--ldjam
--infinite token

function _init()
	game={}
	init_game()
end

function _update60()
	game.update()
end

function _draw()
	cls()
	game.draw()
end
-->8
--main menu

function init_menu()
	game.update=update_menu
	game.draw=draw_menu
end

function update_menu()
	if btnp(❎) then
		init_game()
	end
end

function draw_menu()
	print("ldjam",54,63,7)
	print("press ❎ to start",32,70,7)
end
-->8
--game

function init_game()
	init_level1()

	player=init_player()
	waves={}
	room=rooms[1]
	game.update=update_game
	game.draw=draw_game
end

function update_game()
	room:update()
	player:update()
	for wave in all(waves) do
		wave:update()
	end
end

function draw_game()
	room:draw()
	player:draw()
	for wave in all(waves) do
		wave:draw()
	end
end
-->8
--gameover

function init_gameover()
	game.update=update_gameover
	game.draw=draw_gameover
end

function update_gameover()
	if btnp(❎) then
		init_game()
	end
	if btnp(🅾️) then
		init_menu()
	end
end

function draw_gameover()
	print("press ❎ to restart",30,63,7)
	print("press 🅾️ to go to menu",23,70,7)
end
-->8
--helpers

function mhit(obj,flag)
	local hit=false

	local x1=obj.x/8
	local y1=obj.y/8
	local x2=(obj.x+obj.w-1)/8
	local y2=(obj.y+obj.h-1)/8
	local a=fget(mget(x1,y1),flag)
	local b=fget(mget(x1,y2),flag)
	local c=fget(mget(x2,y2),flag)
	local d=fget(mget(x2,y1),flag)

 hit=a or b or c or d

 return hit
end

function hit(obj1,obj2)
	local hit=false

 local xd=abs((obj1.x+(obj1.w/2))-(obj2.x+(obj2.w/2)))
 local xs=obj1.w*0.5+obj2.w*0.5
 local yd=abs((obj1.y+(obj1.h/2))-(obj2.y+(obj2.h/2)))
 local ys=obj1.h/2+obj2.h/2

 if xd<xs and yd<ys then
  hit=true
 end

 return hit
end
-->8
--objects

function init_player()
	return {
		x=63,
		y=63,
		w=8,
		h=8,
		v=1,
		-- v_x=0,
		-- v_y=0,
		flip_x=false,
		flip_y=false,
		o_sprite=24,
		sprite=24,
		frame=0,
		level=4,
		health=3,
		max_health=0,
		energy=0,
		max_energy=3,
		rest=0,
		rest_period=20,
		holding={left=0,right=0,up=0,down=0},
		update=function(self)
			local lx=self.x
			local ly=self.y

			if btn(0) then
				self.x-=self.v
				-- self.v_x=-1
				self.holding.left+=1
				if (mhit(self,1)) self.x=lx
				for item in all(room.items) do
						if hit(self,item) and fget(item.sprite,1) then
							self.x=lx
						end
						if hit(self,item) and fget(item.sprite,2) then
							room:unlock()
						end
				end
			else
				--no longer holding
				self.holding.left=0
			end
			if btn(1) then
				self.x+=self.v
				-- self.v_x=1
				self.holding.right+=1
				if (mhit(self,1)) self.x=lx
				for item in all(room.items) do
						if hit(self,item) and fget(item.sprite,1) then
							self.x=lx
						end
						if hit(self,item) and fget(item.sprite,2) then
							room:unlock()
						end
						if hit(self,item) and fget(item.sprite,3) then
							player:level_up()
						end
				end
			else
				--no longer holding
				self.holding.right=0
			end
			if btn(2) then
				self.y-=self.v
				-- self.v_y=-1
				self.holding.up+=1
				if (mhit(self,1)) self.y=ly
				for item in all(room.items) do
						if hit(self,item) and fget(item.sprite,1) then
							self.y=ly
						end
						if hit(self,item) and fget(item.sprite,2) then
							room:unlock()
						end
				end
			else
					--no longer holding
					self.holding.up=0
			end
			if btn(3) then
				self.y+=self.v
				-- self.v_y=1
				self.holding.down+=1
				if (mhit(self,1)) self.y=ly
				for item in all(room.items) do
						if hit(self,item) and fget(item.sprite,1) then
							self.y=ly
						end
						if hit(self,item) and fget(item.sprite,2) then
							room:unlock()
						end
				end
			else
				--no longer holding
				self.holding.down=0
			end
			--longest held direction
			if (self.holding.left>self.holding.right) and (self.holding.left>self.holding.up) and (self.holding.left>self.holding.down) then
				--left
				self.o_sprite=40
				self.flip_x=false
			elseif (self.holding.right>self.holding.up) and (self.holding.right>self.holding.down) then
				--right
				self.o_sprite=40
				self.flip_x=true
			elseif (self.holding.up>self.holding.down) then
				--up
				self.o_sprite=28
				self.flip_y=false
			elseif (self.holding.down>0) then
				--updown
				self.o_sprite=24
				self.flip_y=false
			end

			--frame
			if (self.frame>3) self.frame=0
			self.sprite=self.o_sprite+self.frame
			self.frame+=1


			if self.x<-4 then
				room=rooms[room.dirs[1]]
				self.x=124
			end
			if self.x>124 then
				room=rooms[room.dirs[2]]
				self.x=-4
			end
			if self.y<-4 then
				room=rooms[room.dirs[3]]
				self.y=124
			end
			if self.y>124 then
				room=rooms[room.dirs[4]]
				self.y=-4
			end
			--actions
			--secondary
			if btnp(4) then
				if self.level>2 and self.energy>=3 then
					add(waves,init_wave(self.x,self.y,1,0,self.level*4))
					add(waves,init_wave(self.x,self.y,-1,0,self.level*4))
					add(waves,init_wave(self.x,self.y,0,1,self.level*4))
					add(waves,init_wave(self.x,self.y,0,-1,self.level*4))
					self.energy-=3
				end
			end
			--primary
			if btnp(5) then
				if (self.energy<1) return
				local v_x=0
				local v_y=0
				if self.o_sprite==24 then
					v_y=1
				elseif self.o_sprite==28 then
					v_y=-1
				elseif(self.o_sprite==40 and self.flip_x == false) then
					v_x=-1
				else
					v_x=1
				end

				local wave=init_wave(self.x,self.y,v_x,v_y,self.level*4)
				add(waves,wave)
				self.energy-=1
			end
			--energy
			if self.energy<self.max_energy then
				self.rest+=1
				if (self.rest==self.rest_period) self.energy+=1 self.rest=0
			end
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
			local health=''
			for i=1,self.health do
				health=health..'♥'
			end
			print(health,1,1,8)
			local energy=''
			for i=1,self.energy do
				energy=energy..'◆'
			end
			print(energy,1,8,12)
			--print('     energy',8,8,8)
		end
	}
end

function init_level1()
	rooms={}

	local room_0=init_room()
	room_0.mapn=0
	room_0.dirs={1,1,2,2}
	room_0.items={
		init_item(3,2,16),
		init_item(7,15,6),
		init_item(8,15,7),
		init_item(12,10,38),
		init_item(13,12,48),
		init_item(4,3,49),
		init_item(6,2,50),
		init_item(8,1,51)
	}

	local room_1=init_room()
	room_1.mapn=0
	room_1.dirs={1,2,2,1}
	room_1.items={
		init_item(3,5,16),
		init_item(4,11,32),
		init_item(14,14,32),
		init_enemy(10,11,96)
	}

	add(rooms,room_0)
	add(rooms,room_1)
end

function init_room()
	return {
		mapn=0,
		dirs={},
		items={},
		unlock=function(self)
			for item in all(self.items) do
 			if fget(item.sprite,3) then
  			del(self.items,item)
 			end
			end
		end,
		update=function(self)
			for item in all(self.items) do
				item:update()
			end
		end,
		draw=function(self)
			map(self.mapn)
			for item in all(self.items) do
				item:draw()
			end
		end
	}
end

function init_item(x,y,sprite)
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		sprite=sprite,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_enemy(x,y,sprite)
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		vx=1,
		vy=1,
		sprite=sprite,
		update=function(self)
			self.x+=self.vx
			self.y+=self.vy

			if(mhit(self,1)) self.vx=-self.vx self.vy=-self.vy
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_wave(x,y,v_x,v_y,life)
	return {
		sprite=13,
		alt_sprite=false,
		x=x,
		y=y,
		v=2,
		v_x=v_x,
		v_y=v_y,
		flip_x=false,
		flip_y=false,
		life=life,
		update=function(self)
			self.x+=(self.v*self.v_x)
			self.y+=(self.v*self.v_y)
		 self.life-=1
			if self.alt_sprite then
				self.sprite=13
				self.alt_sprite=false
			else
				self.alt_sprite=true
				if self.v_x == 1 then
					self.sprite=15
				elseif self.v_x == -1 then
					self.sprite=15
					self.flip_x=true
				elseif self.v_y == 1 then
					self.sprite=14
					self.flip_y=true
				else
					self.sprite=14
				end
			end
			if self.life==0 then
				del(waves,self)
			end
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
		end
	}
end

__gfx__
00000000666666666666666666666666666655777755666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666666666666666655777755666600000000000000000000000000000000000000000000000000000000000000000000000000cc0000
00700700666666666666666666666666666655777755666666666666666666660055550000aaaa0000bbbb000022220000999900000cc000000cc000000cc000
00077000666666666666666666666666666655777755666655555556655555550055550000aaaa0000bbbb00002222000099990000cccc0000cccc000000cc00
00077000666655555555555555556666555555777755555566666666666666660055550000aaaa0000bbbb00002222000099990000cccc000cc00cc00000cc00
00700700666655555555555555556666555555777755555500000000000000000055550000aaaa0000bbbb000022220000999900000cc0000c0000c0000cc000
00000000666655777777777777556666777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000cc0000
00000000666655777777777777556666777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666655777777777777556666777777777777777700066600000656000000000000000000000000000000000000000000000000000000000000000000
66666666666655777777777777556666777777777777777700065600000656000b0000b00b0000b00b0000b00b0000b000033000000330000003300000033000
66666666666655777767777777556666555555777755555500065600000656000bb00bb00bb00bb00bb00bb00bb00bb0000aa000000aa0000008800000088000
666666666666557777777767775566665555557777555555000656000006560000b33b0000b33b0000b33b0000b33b0000b33b0000b33b0000b33b0000b33b00
666666666666557777777777775566666666557777556666000656000006560000b33b0000b33b0000b33b0000b33b0000b33b0000b33b0000b33b0000b33b00
6666666666665577776777777755666666665577775566660006560000065600000aa000000aa00000088000000880000bb00bb00bb00bb00bb00bb00bb00bb0
6666666666665577777777777755666666665577775566660006560000065600000330000003300000033000000330000b0000b00b0000b00b0000b00b0000b0
66666666666655777777777777556666666655777755666600065600000666000000000000000000000000000000000000000000000000000000000000000000
00044000666655777777777777556666777777777777777777777777999999990000000000000000000000000000000000000000000000000000000000000000
004444006666557777777777775566667757577777575757788888879999999900000bb000000bb000000bb000000bb005000050050000500500005005000050
04444440666655555555555555556666757675777577757778f77f8799c99c99000bbb00000bbb00000bbb00000bbb0005500550055005500550055005500550
040440406666555555555555555566667767775777777757787f77879999c99903a3300003a33000038330000383300000566500005665000056650000566500
0004400066666666666666666666666675777677757777777877f787999c999903a3300003a33000038330000383300000566500005665000056650000566500
00044000666666666666666666666666775767577757775778f77f8799c99c99000bbb00000bbb00000bbb00000bbb0000099000000bb00000099000000bb000
000440006666666666666666666666667775757775757577788888879999999900000bb000000bb000000bb000000bb000066000000660000006600000066000
00000000666666666666666666666666777777777777777777777777999999990000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00
000000000000000000000000000000000000000000000000000000000000000000c99c0000c99c0000c99c0000c99c0000c99c0000c99c0000c99c0000c99c00
000aa000000cc000000ee000000bb000004444000055550000dddd000088880000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00
00a99a0000cddc0000effe0000b66b00004aa4000059950000deed00008bb800000cc000000cc000000cc000000cc000000cc000000cc000000cc000000cc000
00a99a0000cddc0000effe0000b66b00004aa4000059950000deed00008bb800000cc000000cc000000cc000000cc000000cc000000cc000000cc000000cc000
000aa000000cc000000ee000000bb000004444000055550000dddd00008888000cccccc00cccccc00cccccc00cccccc00cccccc00cccccc00cccccc00cccccc0
000000000000000000000000000000000000000000000000000000000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00
0000000000000000000000000000000000000000000000000000000000000000000cc000000cc000000cc000000cc000000cc000000cc000000cc000000cc000
00bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb000000000000000000000000000000000000000000000000000000000000000000
00b3b30000b3b30000b3b30000b3b30000b3b30000b3b30000b3b30000b3b3000000000000000000000000000000000000000000000000000000000000000000
00bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb000044444444444400004444444444440000444444444444000044444444444400
000bb000000bb000000bb000000bb000000bb000000bb000000bb000000bb0000045555555555400004555555555540000455555555554000045555555555400
000bb000000bb000000bb000000bb000000bb000000bb000000bb000000bb0000045555555555400004555555555540000455555555554000045555555555400
03bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb300045555555555400004555555555540000455555555554000045555555555400
0b3bbbb30b3bbbb30b3bbbb30b3bbbb30b3bbbb30b3bbbb30b3bbbb30b3bbbb30045555555555400004555555555540000455555555554000045555555555400
00b00b0000b00b0000b00b0000b00b0000b00b0000b00b0000b00b0000b00b000045555555555400004555555555540000455555555554000045555555555400
00999900009999000099990000999900009999000099990000999900009999000045555555555400004555555555540000455555555554000045555555555400
00939300009393000093930000939300009393000093930000939300009393000045555555555400004555555555540000455555555554000045555555555400
00999900009999000099990000999900009999000099990000999900009999000045555555555400004555555555540000455555555554000045555555555400
00099000000990000009900000099000000990000009900000099000000990000045555555555400004555555555540000455555555554000045555555555400
00099000000990000009900000099000000990000009900000099000000990000045555555555400004555555555540000455555555554000045555555555400
03999930039999300399993003999930039999300399993003999930039999300044444444444400004444444444440000444444444444000044444444444400
09399993093999930939999309399993093999930939999309399993093999930000000000000000000000000000000000000000000000000000000000000000
00900900009009000090090000900900009009000090090000900900009009000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444444444444000044444444444400004444444444440000444444444444000044444444444400004444444444440000444444444444000044444444444400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00455555555554000045555555555400004555555555540000455555555554000045555555555400004555555555540000455555555554000045555555555400
00444444444444000044444444444400004444444444440000444444444444000044444444444400004444444444440000444444444444000044444444444400
__gff__
0002020202020a0a02020202020000000202000202020a0a0000000000000000000202020000040400000000000000000404040402020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020412120502020202020301020202020204121205020202020203010202020202020202020202020202030102020202031112121301020202020301020202020202020202020202020203010202020202041212130102020202030102020202020412120502020202020301020202020311121205020202020203
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213212222222222141212152222222222231112121212131112121311121212121321222222222214121215222222222223111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
0412121212121212121212121212120504121212121522141522141212121205020202020202041212050202020202021112121212050412120504121212121302020202020204121205020202020202041212121212121212050412121212130412121212121212121212121212120511121212120504121212121212121205
1212121212121212121212121212121212121212121312111312111212121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121211121212121212121212121212121212
1212121212121212121212121212121212121212120512040512041212121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121211121212121212121212121212121212
1412121212121212121212121212121514121212121212121212121212121215222222222222141212152222222222221112121212151412121514121212121314121212121212121212121212121215141212121212121212151412121212132222222222221412121522222222222211121212121514121212121212121215
1112121212121212121212121212121311121212121212121212121212121213010202020202041212050202020202031112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212130102020202020412120502020202020311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
2122222222221412121522222222222321222222222214121215222222222223212222222222222222222222222222232122222222221112121321222222222321222222222214121215222222222223212222222222141212132122222222232122222222222222222222222222222321222222222211121215222222222223
0102020202020412120502020202020301020202020204121205020202020203010202020202041212050202020202030102020202020202020202020202020301020202020202020202020202020203010202020202041212050202020202030102020202020202020202020202020301020202020202020202020202020203
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121223222222222222222221121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
0412121212121212121212121212120511121212121212121212121212121205041212121212121212121212121212131112121212121212121212121212120504121212121212121212121212121213111212121212121212121212121212130412121212121212121212121212121311121213101010101010101011121213
1212121212121212121212121212121211121212121212121212121212121212121212121212121212121212121212131112121212121212121212121212121212121212121212121212121212121213111212121212121212121212121212131212121212121212121212121212121311121213101010101010101011121213
1212121212121212121212121212121211121212121212121212121212121212121212121212121212121212121212131112121212121212121212121212121212121212121212121212121212121213111212121212121212121212121212131212121212121212121212121212121311121213101010101010101011121213
1412121212121212121212121212121511121212121212121212121212121215141212121212121212121212121212131112121212121212121212121212121514121212121212121212121212121213111212121212121212121212121212131412121212121212121212121212121311121203020202020202020201121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121222222222222222222221121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121203020202020202020201121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
2122222222221412121522222222222321222222222222222222222222222223212222222222222222222222222222232122222222221412121522222222222321222222222214121215222222222223212222222222222222222222222222232122222222222222222222222222222321222222222222222222222222222223
