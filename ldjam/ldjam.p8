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
	rooms=init_rooms()
	room=rooms[19]

	player=init_player()
	waves={}
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

function hit(obj,flag)
	for item in all(room.items) do
		if fget(item.sprite,flag) then
			local xd=abs((obj.x+(obj.w/2))-(item.x+(item.w/2)))
			local xs=obj.w*0.5+item.w*0.5
			local yd=abs((obj.y+(obj.h/2))-(item.y+(item.h/2)))
			local ys=obj.h/2+item.h/2

			if xd<xs and yd<ys then
				return item
			end
		end
	end
	return nil
end

-->8
--objects

function init_player()
	local timer=10
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
		sprite_frame=0,
		sprite_timer=timer,
		level=1,
		health=4,
		max_health=0,
		energy=0,
		max_energy=0,
		rest=0,
		rest_period=20,
		holding={left=0,right=0,up=0,down=0},
		update=function(self)

			--death
			-- if self.health<=0 then
			-- 	if self.o_sprite==44 then
			-- 		self.frame+=1
			-- 	else
			-- 		self.o_sprite=44
			-- 		self.frame=0
			-- 	end
			-- 	return
			-- end

			local lx=self.x
			local ly=self.y

			if btn(0) then
				self.x-=self.v
				self.holding.left+=1
				if (mhit(self,1) or hit(self,1)) self.x=lx
			else
				--no longer holding
				self.holding.left=0
			end
			if btn(1) then
				self.x+=self.v
				self.holding.right+=1
				if (mhit(self,1) or hit(self,1)) self.x=lx
			else
				--no longer holding
				self.holding.right=0
			end
			if btn(2) then
				self.y-=self.v
				self.holding.up+=1
				if (mhit(self,1) or hit(self,1)) self.y=ly
			else
					--no longer holding
					self.holding.up=0
			end
			if btn(3) then
				self.y+=self.v
				self.holding.down+=1
				if (mhit(self,1) or hit(self,1)) self.y=ly
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

			-- sprite_timer
			if (self.sprite_timer<=0) self.sprite_timer=timer self.sprite_frame+=1
			self.sprite_timer-=1
			--sprite_frame
			if (self.sprite_frame>3) self.sprite_frame=0
			self.sprite=self.o_sprite+self.sprite_frame

			--effects
			--switch
			if (hit(self,2)) room:unlock()
			--level_up
			local level_up=hit(self,4)
			if level_up then
				self.level+=1
				self.energy+=1
				self.max_energy+=1
				del(room.items,level_up)
			end
			--heal
			if (hit(self,6) and self.health<=4) self.health=4
			--damage
			if (hit(self,0)) self.health-=1
			--rooms
			if self.x<-8 then
				local next_dir=room.dirs[1]
				if next_dir then
					room=rooms[next_dir+1]
					self.x=128
				else
					self.x=0
				end
			end
			if self.x>128 then
				local next_dir=room.dirs[2]
				if next_dir then
					room=rooms[next_dir+1]
					self.x=-8
				else
					self.x=120
				end
			end
			if self.y<-8 then
				local next_dir=room.dirs[3]
				if next_dir then
					room=rooms[next_dir+1]
					self.y=120
				else
					self.y=0
				end
			end
			if self.y>128 then
				local next_dir=room.dirs[4]
				if next_dir then

					room=rooms[next_dir+1]
					self.y=-8
				else
					self.y=120
				end
			end
			--actions
			--secondary
			if btnp(4) then
				if self.level>2 and self.energy>=3 then
					add(waves,init_wave(self.x,self.y,1,0,self.level*5))
					add(waves,init_wave(self.x,self.y,-1,0,self.level*5))
					add(waves,init_wave(self.x,self.y,0,1,self.level*5))
					add(waves,init_wave(self.x,self.y,0,-1,self.level*5))
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

				local wave=init_wave(self.x,self.y,v_x,v_y,self.level*5)
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
	local timer=10
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		vx=1,
		vy=1,
		sprite=sprite,
		o_sprite=sprite,
		sprite_frame=0,
		sprite_timer=timer,
		update=function(self)
			self.x+=self.vx
			self.y+=self.vy
			if(mhit(self,1)) self.vx=-self.vx self.vy=-self.vy

			-- sprite_timer
			if (self.sprite_timer<=0) self.sprite_timer=timer self.sprite_frame+=1
			self.sprite_timer-=1
			--sprite_frame
			if (self.sprite_frame>3) self.sprite_frame=0
			self.sprite=self.o_sprite+self.sprite_frame

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_wave(x,y,v_x,v_y,life)
	local timer=8
	return {
		sprite=13,
		alt_sprite=false,
		sprite_timer=timer,
		x=x,
		y=y,
		v=3,
		v_x=v_x,
		v_y=v_y,
		flip_x=false,
		flip_y=false,
		life=life,
		update=function(self)
			self.x+=(self.v*self.v_x)
			self.y+=(self.v*self.v_y)
			--alternate sprite
			if self.sprite_timer<=0 then
				self.sprite_timer=timer
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
			end
			self.sprite_timer-=1

			--life
			if self.life<=0 then
				del(waves,self)
			end
			self.life-=1
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
		end
	}
end

function init_up_elevator(room)
	return {
		x=48,
		y=56,
		w=8,
		h=8,
		room=room,
		update=function(self)

		end,
		draw=function(self)
			spr(32,self.x,self.y)
		end
	}
end

function init_down_elevator(room)
	return {
		x=72,
		y=56,
		w=8,
		h=8,
		room=room,
		update=function(self)

		end,
		draw=function(self)
			spr(32,self.x,self.y,1,1,false,true)
		end
	}
end
-->8
--rooms

function init_room(mapn,dirs,items)
	return {
		mapn=mapn,
		dirs=dirs,
		items=items,
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
			local my=flr(self.mapn/8)*16
			local mx=(self.mapn-(flr(self.mapn/8)*8))*16

			map(mx,my)

			for item in all(self.items) do
				item:draw()
			end
		end
	}
end

function init_rooms()
	local rooms={}

	--level 1
	local room_0=init_room(1,{nil,nil,nil,2},{
		init_up_elevator(2) --fix; wrong room
	})

	local room_1=init_room()
	room_1.mapn=0
	room_1.dirs={nil,nil,nil,3}
	room_1.items={}

	local room_2=init_room()
	room_2.mapn=3
	room_2.dirs={nil,nil,0,4}
	room_2.items={}

	local room_3=init_room()
	room_3.mapn=3
	room_3.dirs={nil,nil,1,7}
	room_3.items={}

	local room_4=init_room()
	room_4.mapn=0
	room_4.dirs={nil,5,2,nil}
	room_4.items={}

	local room_5=init_room()
	room_5.mapn=2
	room_5.dirs={4,6,nil,nil}
	room_5.items={}

	local room_6=init_room()
	room_6.mapn=2
	room_6.dirs={5,7,nil,nil}
	room_6.items={}

	local room_7=init_room()
	room_7.mapn=6
	room_7.dirs={6,8,3,nil}
	room_7.items={}

	local room_8=init_room()
	room_8.mapn=12
	room_8.dirs={7,nil,nil,9}
	room_8.items={}

	local room_9=init_room()
	room_9.mapn=7
	room_9.dirs={nil,10,8,16}
	room_9.items={}

	local room_10=init_room()
	room_10.mapn=2
	room_10.dirs={9,11,nil,nil}
	room_10.items={}

	local room_11=init_room()
	room_11.mapn=0
	room_11.dirs={10,nil,nil,nil}
	room_11.items={}

	local room_12=init_room()
	room_12.mapn=11
	room_12.dirs={nil,13,nil,17}
	room_12.items={}

	local room_13=init_room()
	room_13.mapn=4
	room_13.dirs={12,14,nil,18}
	room_13.items={}

	local room_14=init_room()
	room_14.mapn=4
	room_14.dirs={13,15,nil,19}
	room_14.items={}

	local room_15=init_room()
	room_15.mapn=4
	room_15.dirs={14,16,nil,20}
	room_15.items={}

	local room_16=init_room()
	room_16.mapn=10
	room_16.dirs={15,nil,9,nil}
	room_16.items={}

	local room_17=init_room()
	room_17.mapn=0
	room_17.dirs={nil,nil,12,nil}
	room_17.items={}

	local room_18=init_room()
	room_18.mapn=0
	room_18.dirs={nil,nil,13,nil}
	room_18.items={
		init_item(3,2,16),
		init_item(7,15,6),
		init_item(8,15,7),
		init_item(12,10,38),
		init_item(7,5,48),
		init_item(4,3,49),
		init_item(6,2,50),
		init_item(8,1,51),
		init_item(3,12,39),
		init_enemy(12,3,56)
	}

	local room_19=init_room()
	room_19.mapn=0
	room_19.dirs={nil,nil,14,nil}
	room_19.items={}

	local room_20=init_room()
	room_20.mapn=0
	room_20.dirs={nil,nil,15,nil}
	room_20.items={}

	--level 2

	add(rooms,room_0)
	add(rooms,room_1)
	add(rooms,room_2)
	add(rooms,room_3)
	add(rooms,room_4)
	add(rooms,room_5)
	add(rooms,room_6)
	add(rooms,room_7)
	add(rooms,room_8)
	add(rooms,room_9)
	add(rooms,room_10)
	add(rooms,room_11)
	add(rooms,room_12)
	add(rooms,room_13)
	add(rooms,room_14)
	add(rooms,room_15)
	add(rooms,room_16)
	add(rooms,room_17)
	add(rooms,room_18)
	add(rooms,room_19)
	add(rooms,room_20)

	return rooms
end
__gfx__
0000000011111111111111111111111111111bb11bb1111100500500005005000111111003000300000660000000000000000000000000000000000000000000
0000000011111111111111111111111111111bb11bb1111110510510015015011100001130333030000660000400004005005005000000000000000000cc0000
00700700111111111111111111111111111112bbbb21111155555555555555551006600103000303006666000044440050050050000cc000000cc000000cc000
0007700011111111111111111111111111111bb22bb11111005005000050050010600601300300300077a700004554005005005000cccc0000cccc000000cc00
0007700011112b1bb0220bb0b1b21111b0220bb00bb0220b105105100150150110600601303030300779a770004444000555550000cccc000cc00cc00000cc00
00700700111120bbbb00bbbbbb021111bb00bbbbbbbb00bb555555555555555510066001303003030779a7700045540000444000000cc0000c0000c0000cc000
00000000111112bb0bbbb00bbb2111110bbbb00bb00bbbb000500500005005001100001103033030077777700044440000444000000000000000000000cc0000
000000001111bb0020bb022000bb111120bb02200220bb0210510510015015010111111000300300007777000400004000444000000000000000000000000000
111111111111bb0222222212bb02111120bb02200220bb02015015101051050100aaa000000aaa0000aaa000000aaa0000099900009990000009990000999000
1111111111110bb0222212220bb011110bbbb00bb00bbbb010510501015015100aacaa0000aacaa00aacaa0000aacaa000a999a00a999a0000a999a00a999a00
11111111111120bb2222222220bb1111bb00bbbbbbbb00bb055555501555555100aaa000000aaa0000aaa009900aaa0000099900009990009009990000999009
11111111111120bb2222222220bb1111b0220bb00bb0220b105105010150151000030009000030000003000330003009900aaa0000aaa000300aaa0090aaa003
1111111111110bb0212222220bb0111111111bb22bb1111101501510105105010003333333333000000333333333300333333000000333333333300030033333
111111111111bb0222222222bb021111111112bbbb21111115555551055555503333300090033333333330000003333300033333333330090003333333333000
111111111111bb0212222222bb02111111111bb11bb1111101501510105105019003300000033009900330000003300000033009900330000003300900033000
1111111111110bb0222222220bb0111111111bb11bb1111110510501015015100003300000033000000330000003300000033000000330000003300000033000
222bb2221111bbb00b0bb0bb00bb1111222222112222221200000000006660000000a0000000a0000000a0000000a00000444000004440000044400000000000
21bbbb2211111bb0bbbb00bbbb211111222112222222121200000000066566000000a9000000a9000000a9000000a900044c4400044c44000448440004000000
2bbbbbb21111b02bb00bbbb0bb02111122222222222212220444000000666000000ca900000ca900000ca900000ca90000444000004440000044400044400000
2b2bb2b21111221b0220bb02b1b211112122222222222222c0443333000000080000a9000000a9000000a9090000a909000300090003000a0003000848480000
222bb22211111111111111111111111121222222211222220c040000000000000090a3330000a3330000a3330090a33300033333000334440003344444488000
122bb222111111111111111111111111222222222222222200c00000000000000033330900333309003333000033330033333000444330004443300004088000
222bb212111111111111111111111111122222221122222200000000800000000000330000903300009033000000330090033000900330008003300044488008
22222222111111111111111111111111122222222222222200000000000000000000330000003300000033000000330000033000000330000003300080088444
0333444003334440033344400333000000000000000000000000000b090909090000000000eeee0000eeee000000000000000000000ee000000ee00000000000
033c0440033c0440033c0440033044400000000000000000004444bb9090909000eeee00eee00eeeeee00eee00000000000ee00000eeee0000eeee0000000000
0330c0400330c0400330c040033c0440000000000000000004404bb0090aaa09eee00eeee0e00e0ee0e00e0e00eeee0000eeee000e0ee0e00e0ee0e000eeee00
ffff0c00ffff0c00ffff0c00ffffc040999999990000000044400b4490aaaaa0e0e00e0ee0e00e0e00000000eeeeeeee0e0ee0e0000ee000000000000e0ee0e0
f00ff0fff00ff0fff00ff0ff00000c00099559900004400040040b0409aaaaa9e0e00e0ee0e00e0e00000000eeeeeeee0e0ee0e0000ee000000000000e0ee0e0
0f00fff00f00fff00000fff000000000095995900044440044f0004490aaaaa0eee00eeee0e00e0ee0e00e0e00eeee0000eeee000e0ee0e00e0ee0e000eeee00
f00f0000f00f00000000000000000000099559900444444004f4f440090aaa0900eeee00eee00eeeeee00eee00000000000ee00000eeee0000eeee0000000000
0000f00f0000000000000000000000000099990044444444ff444ff0909090900000000000eeee0000eeee000000000000000000000ee000000ee00000000000
99900999009009000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000050090000900900009009999990000000000000000000000000000000000000d444444d00000000d444444d00000000d444444d00000000d444444d0000
05555550955555599555555995555559000000000000000000000000000000000000d444444d00000000d444444d00000000d444444d00000000d444444d0000
5caeeac55caeeac55caeeac55caeeac5999905059909050509000505000005050000dd0000dd00000000dd0000dd00000000dd0000dd00000000dd0000dd0000
eaceecaeeaceecaeeaceecaeeaceecae9095eeac9095eeac0095eeac0995eeac00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd00000
ecaaaaceecaaaaceecaaaaceecaaaace900aacee000aacee000aacee090aacee0000000dd00000000000000dd00000000000000dd00000000000000dd0000000
0eceece00eceece00eceece00eceece0909acaca909acaca009acaca099acaca0000000dd00000000000000dd00000000000000dd00000000000000dd0000000
500aa005500aa005500aa005500aa005999905059909050509000505000005050000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000000000000000888000008880000000000000000000000000000008080800000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000070000800700000807080008070000070000000700000087800080878080000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000777000087770888077708880777000777000007870000078700008787800000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00055577000850770000857780008577000050000000500000085800080858080005555555555000000555555555500000055555555550000005555555555000
00050070000050700888057008880570000050000000500000005000008080800005555555555000000555555555500000055555555550000005555555555000
00050660000006600000066080000660000666000006660000066600080687080005555555555000000555555555500000055555555550000005555555555000
00000666000006660000066600000666000666000006660000066600000666000000555555550000000055555555000000005555555500000000555555550000
00000666000006660000066600000666000666000006660000066600000666000000005555000000000000555500000000000055550000000000005555000000
__gff__
0002020202020a0a02020202020000000202000202020a0a0000000000000000800202020000044000000000000000001010101002020202010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020412120502020202020301020202020204121205020202020203010202020202020202020202020202030102020202031112121301020202020301020202020202020202020202020203010202020202041212130102020202030102020202020412120502020202020301020202020311121205020202020203
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213212222222222141212152222222222231112121212131112121311121212121321222222222214121215222222222223111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
0412121212121212121212121212120504121212121522141522141212121205020202020202041212050202020202021112121212050412120504121212121302020202020204121205020202020202041212121212121212050412121212130412121212121212121212121212120511121212120504121212121212121205
1212121212121212121212121212121212121212121312111312111212121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121711121212121212121212121212121212
1212121212121212121212121212121212121212120512040512041212121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121611121212121212121212121212121212
1412121212121212121212121212121514121212121212121212121212121215222222222222141212152222222222221112121212151412121514121212121314121212121212121212121212121215141212121212121212151412121212132222222222221412121522222222222211121212121514121212121212121215
1112121212121212121212121212121311121212121212121212121212121213010202020202041212050202020202031112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212130102020202020406070502020202020311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
2122222222221412121522222222222321222222222214121215222222222223212222222222222222222222222222232122222222221112121321222222222321222222222214121215222222222223212222222222141212132122222222232122222222222222222222222222222321222222222311121215222222222223
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
