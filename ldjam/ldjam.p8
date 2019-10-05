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
	init_rooms()

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
		flip_x=false,
		flip_y=false,
		sprite=10,
		level=4,
		health=3,
		power=3,
		update=function(self)
			local lx=self.x
			local ly=self.y

			if btn(0) then
				self.sprite=11
				self.flip_x=true
				self.x-=self.v
			end
			if btn(1) then
				self.sprite=11
				self.flip_x=false
				self.x+=self.v
			end
			if btn(2) then
				self.sprite=10
				self.flip_y=false
				self.y-=self.v
			end
			if btn(3) then
				self.sprite=10
				self.flip_y=true
				self.y+=self.v
			end

			if(mhit(self,1)) self.x=lx self.y=ly

			for item in all(room.items) do
					if hit(self,item) and fget(item.sprite,1) then
					 self.x=lx self.y=ly
					end
					if hit(self,item) and fget(item.sprite,2) then
					 room:unlock()
					end
			end

			if self.x<-8 then
				room=rooms[room.west]
				self.x=128
			end
			if self.x>128 then
				room=rooms[room.east]
				self.x=0
			end
			if self.y<-8 then
				room=rooms[room.south]
				self.y=128
			end
			if self.y>128 then
				room=rooms[room.north]
				self.y=-8
			end
			--actions
			--secondary
			if btnp(4) then
			end
			--primary
			if btnp(5) then
				if self.level<4 then
					local sprite=12
					if self.sprite==11 then sprite=13 end
					local wave=init_wave(sprite,self.x,self.y,self.flip_x,self.flip_y,self.level*4)
					add(waves,wave)
				else
					add(waves,init_wave(12,self.x,self.y,false,false,self.level*2))
					add(waves,init_wave(12,self.x,self.y,false,true,self.level*2))
					add(waves,init_wave(13,self.x,self.y,true,false,self.level*2))
					add(waves,init_wave(13,self.x,self.y,false,false,self.level*2))
				end
			end
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
		end
	}
end

function init_rooms()
	rooms={}
	add(rooms,{
		mapn=0,
		north=2,
		west=2,
		south=1,
		east=1,
		items={
			init_item(3,2,37),
			init_item(7,15,49),
			init_item(8,15,49),
			init_item(10,11,38)
		},
		unlock=function(self)
			for item in all(self.items) do
 			if item.sprite==49 then
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
	})
	add(rooms,{
		mapn=0,
		north=2,
		west=2,
		south=1,
		east=1,
		items={
			init_item(2,13,37),
			init_item(5,5,37),
			init_enemy(6,6,39)
		},
		unlock=function(self)

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
	})
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

function init_wave(sprite,x,y,flip_x,flip_y,life)
	return {
		sprite=sprite,
		x=x,
		y=y,
		flip_x=flip_x,
		flip_y=flip_y,
		life=life,
		update=function(self)
			if self.sprite==12 then
		 	if self.flip_y then
		 		--up
		 		self.y+=4
		 	else
		 		--down
		  	self.y-=4
		 	end
		 else
		 	if self.flip_x then
		 		--left
		 		self.x-=4
		 	else
		 		--right
		 		self.x+=4
		 	end
		 end
		 self.life-=1
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
00000000000444006666666666666666666666666666567777566666666666565666666600bbbb00000000000000000000000000000000000000000000000000
00000000000455006666666666666666666666666666657777656666666666656566666600b3b300000330000bb000000000000000cc00000000000000000000
00700700000454006666666666666666666666666666567777566666666666565666666600bbbb00000aa00000bbb000000cc000000cc0000000000000000000
000770000004540066666666666666666666666666666577776566666666666565666666000bb00000b33b0000033a3000cccc000000cc000000000000000000
000770000004540066665656565656565656666666665677775666665656565656565656000bb00000b33b0000033a300cc00cc00000cc000000000000000000
00700700000454006666656565656565656566666666657777656666656565656565656503bbbb300bb00bb000bbb0000c0000c0000cc0000000000000000000
0000000000045500666656777777777777566666565656777756565677777777777777770b3bbbb30b0000b00bb000000000000000cc00000000000000000000
00000000000444006666657777777777776566666565657777656565777777777777777700b00b00000000000000000000000000000000000000000000000000
00000000004440006666567777777777775666665656567777565656777777777777777700000000000000000000000000000000000000000000000000000000
00000000005540006666657777575757776566666565657777656565777777777777777700000000000000000000000000000000000000000000000000000000
00000000004540006666567775767577775666666666567777566666565656565656565600000000000000000000000000000000000000000000000000000000
00000000004540006666657777676757776566666666657777656666656565656565656500000000000000000000000000000000000000000000000000000000
00000000004540006666567775767677775666666666567777566666666666565666666600000000000000000000000000000000000000000000000000000000
00000000004540006666657777576757776566666666657777656666666666656566666600000000000000000000000000000000000000000000000000000000
00000000005540006666567775757577775666666666567777566666666666565666666600000000000000000000000000000000000000000000000000000000
00000000004440006666657777777777776566666666657777656666666666656566666600000000000000000000000000000000000000000000000000000000
00000000000000006666567777777777775666663b3b3b3b9999999900cccc000000000000000000000000000000000000000000000000000000000000000000
000000000000000066666577777777777765666603b3b3b09999999900c99c000000000000000000000000000000000000000000000000000000000000000000
0000000000000000666656565656565656566666000ff00099c99c9900cccc000000000000000000000000000000000000000000000000000000000000000000
000000006666666666666565656565656565666600ffff009999c999000cc0000000000000000000000000000000000000000000000000000000000000000000
00000000655555566666666666666666666666660ff9fff0999c9999000cc0000000000000000000000000000000000000000000000000000000000000000000
00000000656666566666666666666666666666660fff9ff099c99c990cccccc00000000000000000000000000000000000000000000000000000000000000000
000000000000000066666666666666666666666600f9ff009999999900cccc000000000000000000000000000000000000000000000000000000000000000000
00000000000000006666666666666666666666660fff9ff099999999000cc0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000656666560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000655555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0002020202020202020000000000000000020200020202020200000000000000000202020202040000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0203030303030713130803030303030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0513131313131313131313131313130600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1513131313131313131313131313131600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131313131313131313131313131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223232323231713131823232323232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0003000001000000002c0002c0002c000000002b000290002900027000210001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
