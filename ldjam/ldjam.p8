pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--ldjam
--infinite token

function _init()
	game={}
	music(1)
	init_menu()
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
	menu={
		t=30,
		c=6,
		update=function(self)
			self.t-=1
			if self.t==0 then
				if self.c==6 then
					self.c=7
				else
					self.c=6
				end
				self.t=30
			end
		end,
		draw=function(self)
			map(112,16)
			spr(128,32,32,4,4)
			spr(132,64,32,4,4)
			print("press ❎ to start",31,97,self.c)
		end
	}
	game.update=update_menu
	game.draw=draw_menu
end

function update_menu()
	menu:update()
	if btnp(❎) then
		init_game()
	end
end

function draw_menu()
	menu:draw()
end
-->8
--game

function init_game()
	rooms=init_rooms()
	room=rooms[19]

	player=init_player()
	game.update=update_game
	game.draw=draw_game
end

function update_game()
	room:update()
	player:update()
end

function draw_game()
	room:draw()
	player:draw()
end
-->8
--gameover

function init_gameover()
	game.update=update_gameover
	game.draw=draw_gameover
	music(-1)
	sfx(8)
end

function update_gameover()
	if btnp(❎) then
		music(1)
		init_game()
	end
	if btnp(🅾️) then
		music(1)
		init_menu()
	end
end

function draw_gameover()
	print("press ❎ to restart",30,63,7)
	print("press 🅾️ to go to menu",23,70,7)
end
-->8
--credits

function init_credits()
	credits={
		t=30,
		c=6,
		l=1,
		lt=120,
		lines={
			{"created by","infinite token"},
			{"sprites","chris thompson"},
			{"sounds","chris thompson"},
			{"levels","daniel heupel"},
			{"programming","jay deaton"},
			{"programming","aaron wright"},
			{"assistant","river"}
		},
		update=function(self)
			self.t-=1
			self.lt-=1
			if self.t==0 then
				if self.c==6 then
					self.c=7
				else
					self.c=6
				end
				self.t=30
			end
			if self.lt==0 then
				self.l+=1
				if self.l==8 then
					self.l=1
				end
				self.lt=120
			end
		end,
		draw=function(self)
			map(112,16)
			print(self.lines[self.l][1],47,40,6)
			print(self.lines[self.l][2],38,50,6)
			print("press ❎",49,97,self.c)
		end
	}
	game.update=update_credits
	game.draw=draw_credits
	music(-1)
	sfx(9)
end

function update_credits()
	credits:update()
	if btnp(❎) then
		music(1)
		init_menu()
	end
end

function draw_credits()
	credits:draw()
end
-->8
--helpers

function mhit(mapn,obj,flag)
	local hit=false

	local x1=obj.x/8
	local y1=obj.y/8
	local x2=(obj.x+obj.w-1)/8
	local y2=(obj.y+obj.h-1)/8

	if (x1<0) x1=0
	if (y1<0) y1=0
	if (x2<0) x2=0
	if (y2<0) y2=0
	if (x1>15) x1=15
	if (y1>15) y1=15
	if (x2>15) x2=15
	if (y2>15) y2=15

	if (mapn>=8) y1+=16 y2+=16 mapn-=8
	x1+=16*mapn x2+=16*mapn

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
	local health_lock=15
	return {
		x=60,
		y=73,
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
		health=4,
		max_health=4,
		health_lock=0,
		energy=0,
		max_energy=0,
		rest=0,
		rest_period=20,
		locked=false,
		collectables=0,
		winning=false,
		winning_timer=60,
		death_timer=60,
		holding={left=0,right=0,up=0,down=0},
		update=function(self)
			local lx=self.x
			local ly=self.y

			if self.health<=0 then
				-- dying
				if self.o_sprite==44 then
					if self.sprite_frame==3 then
						if (self.death_timer<=0) init_gameover()
						self.death_timer-=1
					end
				else
					self.sprite_timer=timer*2
					self.o_sprite=44
					self.sprite=44
					self.sprite_frame=0
				end
			elseif self.winning then
				-- winning
				-- self.o_sprite=24
				if self.x < 60 then self.x+=self.v elseif self.x>60 then self.x-=self.v end
				if self.y < 62 then self.y+=self.v elseif self.y>62 then self.y-=self.v end
				if (self.x==60 and self.y==62) then
					self.o_sprite=24
					if (self.winning_timer<=0) init_credits()
					self.winning_timer-=1
				end
			else
				--left
				if btn(0) then
					self.x-=self.v
					self.holding.left+=1
				else
					--no longer holding
					self.holding.left=0
				end
				--right
				if btn(1) then
					self.x+=self.v
					self.holding.right+=1
				else
					--no longer holding
					self.holding.right=0
				end

				if (mhit(room.mapn,self,1) or hit(self,1)) self.x=lx

				--up
				if btn(2) then
					self.y-=self.v
					self.holding.up+=1
				else
						--no longer holding
						self.holding.up=0
				end
				--down
				if btn(3) then
					self.y+=self.v
					self.holding.down+=1
				else
					--no longer holding
					self.holding.down=0
				end

				if (mhit(room.mapn,self,1) or hit(self,1)) self.y=ly



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
					--down
					self.o_sprite=24
					self.flip_y=false
				end
				--lock movement after elevator
				if self.locked then
					self.x=lx
					self.y=ly
					self.o_sprite=24
					if (self.holding.left==0 and self.holding.right==0 and self.holding.up==0 and self.holding.down==0) self.locked=false
				end

				--effects
				--switch
				if (hit(self,2)) then
					room:unlock()
					music(-1)
					sfx(6)
					music(1)
				end
				--pickup
				local pickup=hit(self,4)
				if pickup then
					if (pickup.powerup) then
						self.energy+=1
						self.max_energy+=1
						music(-1)
						sfx(1)
						music(1)
					end
					if (pickup.collectable) then
						self.collectables+=1
						music(-1)
						sfx(2)
						music(1)
					end
					del(room.items,pickup)
				end
				--heal
				if hit(self,6) then
					self.health=4
					music(-1)
					sfx(4)
					music(1)
				end
				--elevator
				local el=hit(self,7)
				if el then
					room=rooms[el.room+1]
					self.locked=true
					if el.v>0 then
						self.x=76
					else
						self.x=44
					end
					self.y+=2
					music(-1)
					sfx(5)
					music(1)
				end
				--objective
				if (hit(self,5) and self.collectables==4) self.winning=true

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
					if self.energy>=3 then
						add(room.items,init_wave(self.x,self.y,1,0,self.max_enery*5))
						add(room.items,init_wave(self.x,self.y,-1,0,self.max_enery*5))
						add(room.items,init_wave(self.x,self.y,0,1,self.max_enery*5))
						add(room.items,init_wave(self.x,self.y,0,-1,self.max_enery*5))
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

					local wave=init_wave(self.x,self.y,v_x,v_y,self.max_energy*5)
					add(room.items,wave)
					self.energy-=1

					sfx(0)
				end
				--damage
				if (hit(self,0) and self.health_lock==0) sfx(3) self.health-=1 self.health_lock=health_lock
				if (self.health_lock>0) self.health_lock-=1

				--energy
				if self.energy<self.max_energy then
					self.rest+=1
					if (self.rest==self.rest_period) self.energy+=1 self.rest=0
				end
			end
			-- sprite_timer and sprite_frame
			if self.sprite_timer<=0 then
				if self.sprite_frame==3 then
					if (self.health>0) self.sprite_frame=0
				else
					self.sprite_frame+=1
				end
				if self.health>0 then self.sprite_timer=timer else self.sprite_timer=timer*2 end
			end
			self.sprite_timer-=1
			self.sprite=self.o_sprite+self.sprite_frame

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
			local health=''
			for i=1,self.health do
				health=health..'♥'
			end
			print(health,0,0,8)
			local energy=''
			for i=1,self.energy do
				energy=energy..'◆'
			end
			print(energy,0,8,12)
			local collect=''
			for i=4,0,-1 do
				if self.collectables>=i then
					collect=collect..'★'
				else
					collect=collect..'  '
				end
			end
			print(collect,96,0,9)
		end
	}
end

function init_item(x,y,sprite,destructable)
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		destructable=destructable,
		sprite=sprite,
		update=function(self)
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_enemy(x,y,sprite,health)
	local timer=10
	local move_timer=20
	local moves=20
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		v=1,
		moves=0,
		move_timer=move_timer,
		health=health,
		sprite=sprite,
		o_sprite=sprite,
		sprite_frame=0,
		sprite_timer=timer,
		update=function(self)
			-- ai
			local lx=self.x
			local ly=self.y

			if self.moves>0 then
				if player.x < self.x then self.x-=self.v else self.x+=self.v end
				if (mhit(room.mapn,self,1) or hit(self,1)) self.x=lx

				if player.y < self.y then self.y-=self.v else self.y+=self.v end
				if (mhit(room.mapn,self,1) or hit(self,1)) self.y=ly

				self.moves-=1
			else
				if self.move_timer<=0 then
					self.moves=moves
					self.move_timer=move_timer
				else
					self.move_timer-=1
				end
			end

			if (mhit(room.mapn,self,1) or hit(self,1)) self.x=lx self.y=ly

			--damage
			local wave=hit(self,3)
			if (hit(self,3)) self.health-=1 del(room.items,wave)
			if (self.health<=0) del(room.items,self)

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

function init_boss(x,y,sprite,health)
	local timer=10
	local move_timer=20
	local moves=20
	return {
		x=x*8,
		y=y*8,
		w=16,
		h=16,
		v=1,
		moves=0,
		move_timer=move_timer,
		health=health,
		sprite=sprite,
		o_sprite=sprite,
		sprite_frame=0,
		sprite_timer=timer,
		update=function(self)
			-- ai
			local lx=self.x
			local ly=self.y

			if self.moves>0 then
				if player.x < self.x then self.x-=self.v else self.x+=self.v end
				if (mhit(room.mapn,self,1) or hit(self,1)) self.x=lx

				if player.y < self.y then self.y-=self.v else self.y+=self.v end
				if (mhit(room.mapn,self,1) or hit(self,1)) self.y=ly

				self.moves-=1
			else
				if self.move_timer<=0 then
					self.moves=moves
					self.move_timer=move_timer
				else
					self.move_timer-=1
				end
			end

			if (mhit(room.mapn,self,1) or hit(self,1)) self.x=lx self.y=ly

			--damage
			local wave=hit(self,3)
			if (hit(self,3)) self.health-=1 del(room.items,wave)
			if (self.health<=0) del(room.items,self)

			-- sprite_timer
			if (self.sprite_timer<=0) self.sprite_timer=timer self.sprite_frame+=1
			self.sprite_timer-=1
			--sprite_frame
			if (self.sprite_frame>3) self.sprite_frame=0
			self.sprite=self.o_sprite+(self.sprite_frame*2)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,self.w/8,self.h/8)
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
		w=8,
		h=8,
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
				del(room.items,self)
			end
			self.life-=1

			local hit=hit(self,1)
			if (hit and hit.destructable) del(room.items,hit) del(room.items,self)
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,self.flip_x,self.flip_y)
		end
	}
end

function init_up_elevator(room)
	return {
		sprite=32,
		x=44,
		y=56,
		w=8,
		h=8,
		v=1,
		room=room,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_down_elevator(room)
	return {
		sprite=32,
		x=76,
		y=56,
		w=8,
		h=8,
		v=-1,
		room=room,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,1,1,false,true)
		end
	}
end

function init_powerup(x,y,sprite)
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		sprite=sprite,
		powerup=true,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_collectable(x,y,sprite)
	return {
		x=x*8,
		y=y*8,
		w=8,
		h=8,
		sprite=sprite,
		collectable=true,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end
	}
end

function init_objective(x,y)
	return {
		sprite=136,
		x=32,
		y=48,
		w=64,
		h=32,
		update=function(self)

		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y,self.w/8,self.h/8)
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
			if (player.health<=0) return
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

	-- init_collectable(2,2,52),
	-- init_collectable(13,2,53),
	-- init_collectable(13,13,54),
	-- init_collectable(2,13,55)
	--test items
	-- init_item(3,2,16),
	-- init_item(12,10,38),
	-- init_powerup(7,5,48),
	-- init_powerup(4,3,49),
	-- init_powerup(6,2,50),
	-- init_powerup(8,1,51),
	-- init_item(3,12,39),
	-- init_enemy(2,2,56),
	-- init_enemy(13,2,56),
	-- init_enemy(13,13,56),
	-- init_enemy(2,13,56)

	local room_0=init_room(1,{nil,nil,nil,2},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19),
		init_up_elevator(21)
	})
	local room_1=init_room(12,{nil,nil,nil,3},{
		init_item(7,7,39)
	})
	local room_2=init_room(3,{nil,nil,0,4},{})
	local room_3=init_room(3,{nil,nil,1,7},{
		init_item(7,0,6),
		init_item(8,0,7),
		init_item(2,2,38)
	})
	local room_4=init_room(9,{nil,5,2,nil},{
		init_item(7,0,6),
		init_item(8,0,7),
		init_item(2,2,38),
		init_objective(7,7)
	})
	local room_5=init_room(2,{4,6,nil,nil},{
		init_item(7,5,6),
		init_item(8,5,7),
		init_item(13,13,38)
	})
	local room_6=init_room(2,{5,7,nil,nil},{})
	local room_7=init_room(6,{6,8,3,nil},{})
	local room_8=init_room(8,{7,nil,nil,9},{})
	local room_9=init_room(7,{nil,10,8,16},{})
	local room_10=init_room(2,{9,11,nil,nil},{})
	local room_11=init_room(14,{10,nil,nil,nil},{})
	local room_12=init_room(11,{nil,13,nil,17},{})
	local room_13=init_room(4,{12,14,nil,18},{})
	local room_14=init_room(4,{13,15,nil,19},{})
	local room_15=init_room(4,{14,16,nil,20},{})
	local room_16=init_room(10,{15,nil,9,nil},{})
	local room_17=init_room(13,{nil,nil,12,nil},{})
	local room_18=init_room(13,{nil,nil,13,nil},{
		init_item(7,0,6),
		init_item(8,0,7),
		init_item(13,13,38),
		init_item(7,7,39)
	})
	local room_19=init_room(13,{nil,nil,14,nil},{})
	local room_20=init_room(13,{nil,nil,15,nil},{})

	--level 2

	local room_21=init_room(1,{nil,nil,nil,22},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19),
		init_down_elevator(0),
		init_up_elevator(80)
	})
	local room_22=init_room(3,{nil,nil,21,28},{})
	local room_23=init_room(11,{nil,24,nil,29},{})
	local room_24=init_room(2,{23,25,nil,nil},{})
	local room_25=init_room(2,{24,26,nil,nil},{})
	local room_26=init_room(2,{25,27,nil,nil},{})
	local room_27=init_room(8,{26,nil,nil,31},{})
	local room_28=init_room(0,{nil,nil,22,33},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_29=init_room(13,{nil,nil,23,nil},{})
	local room_30=init_room(12,{nil,nil,nil,37},{})
	local room_31=init_room(3,{nil,nil,27,39},{})
	local room_32=init_room(12,{nil,nil,nil,41},{})
	local room_33=init_room(0,{nil,34,28,42},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_34=init_room(2,{33,35,nil,nil},{})
	local room_35=init_room(0,{34,36,nil,nil},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_36=init_room(2,{35,37,nil,nil},{})
	local room_37=init_room(0,{36,38,30,43},{})
	local room_38=init_room(8,{37,nil,nil,44},{})
	local room_39=init_room(7,{nil,40,31,45},{})
	local room_40=init_room(2,{39,41,nil,nil},{})
	local room_41=init_room(0,{40,nil,32,46},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_42=init_room(0,{nil,nil,33,47},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_43=init_room(3,{nil,nil,37,51},{})
	local room_44=init_room(7,{nil,45,38,52},{})
	local room_45=init_room(5,{44,nil,39,53},{})
	local room_46=init_room(0,{nil,nil,41,54},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_47=init_room(9,{nil,48,42,nil},{})
	local room_48=init_room(2,{47,49,nil,nil},{})
	local room_49=init_room(14,{48,nil,nil,nil},{})
	local room_50=init_room(12,{nil,nil,nil,55},{})
	local room_51=init_room(9,{nil,52,43,nil},{})
	local room_52=init_room(10,{51,nil,44,nil},{})
	local room_53=init_room(3,{nil,nil,45,58},{})
	local room_54=init_room(13,{nil,nil,46,nil},{})
	local room_55=init_room(9,{nil,56,50,nil},{})
	local room_56=init_room(2,{55,57,nil,nil},{})
	local room_57=init_room(2,{56,58,nil,nil},{})
	local room_58=init_room(10,{57,nil,53,nil},{})

	--level 3

	local room_59=init_room(11,{nil,60,nil,66},{})
	local room_60=init_room(2,{59,61,nil,nil},{})
	local room_61=init_room(8,{60,62,nil,67},{})
	local room_62=init_room(11,{61,63,nil,68},{})
	local room_63=init_room(0,{62,64,nil,69},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_64=init_room(2,{63,65,nil,nil},{})
	local room_65=init_room(8,{64,nil,nil,70},{})
	local room_66=init_room(3,{nil,nil,59,71},{})
	local room_67=init_room(3,{nil,68,61,73},{})
	local room_68=init_room(3,{67,69,62,74},{})
	local room_69=init_room(3,{68,nil,63,75},{})
	local room_70=init_room(3,{nil,nil,65,77},{})
	local room_71=init_room(0,{nil,72,66,78},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_72=init_room(2,{71,73,nil,nil},{})
	local room_73=init_room(0,{72,74,67,79},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_74=init_room(13,{73,75,68,80},{})
	local room_75=init_room(0,{74,76,69,81},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_76=init_room(2,{75,77,nil,82},{})
	local room_77=init_room(10,{76,nil,70,83},{})
	local room_78=init_room(0,{nil,nil,71,84},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_79=init_room(13,{nil,80,73,86},{})
	local room_80=init_room(1,{79,81,74,87},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_down_elevator(21),
		init_up_elevator(102)
	})
	local room_81=init_room(0,{80,82,75,88},{})
	local room_82=init_room(2,{81,83,76,89},{})
	local room_83=init_room(14,{82,nil,77,83},{})
	local room_84=init_room(0,{nil,85,78,91},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_85=init_room(2,{84,86,nil,nil},{})
	local room_86=init_room(0,{85,87,79,nil},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_87=init_room(0,{86,88,80,92},{})
	local room_88=init_room(0,{87,89,81,93},{})
	local room_89=init_room(2,{88,90,nil,nil},{})
	local room_90=init_room(8,{89,nil,nil,94},{})
	local room_91=init_room(3,{nil,nil,84,95},{})
	local room_92=init_room(3,{nil,nil,87,98},{})
	local room_93=init_room(3,{nil,nil,88,99},{})
	local room_94=init_room(3,{nil,nil,90,101},{})
	local room_95=init_room(9,{nil,96,91,nil},{})
	local room_96=init_room(2,{95,97,nil,nil},{})
	local room_97=init_room(0,{96,98,nil,nil},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_98=init_room(10,{97,nil,92,nil},{})
	local room_99=init_room(9,{nil,100,93,nil},{})
	local room_100=init_room(2,{99,101,nil,nil},{})
	local room_101=init_room(10,{100,nil,94,nil},{})

	--level 4

	local room_102=init_room(1,{nil,103,nil,nil},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34),
		init_down_elevator(80),
		init_up_elevator(139)
	})
	local room_103=init_room(0,{102,104,nil,108},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_104=init_room(0,{103,105,nil,109},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_105=init_room(2,{104,106,nil,nil},{})
	local room_106=init_room(2,{105,107,nil,nil},{})
	local room_107=init_room(8,{106,nil,nil,110},{})
	local room_108=init_room(0,{nil,109,103,112},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_109=init_room(10,{108,nil,104,nil},{})
	local room_110=init_room(7,{nil,111,107,115},{})
	local room_111=init_room(14,{110,nil,nil,nil},{})
	local room_112=init_room(3,{nil,nil,108,116},{})
	local room_113=init_room(0,{nil,114,nil,nil},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_114=init_room(8,{113,nil,nil,119},{})
	local room_115=init_room(13,{nil,nil,110,nil},{})
	local room_116=init_room(9,{nil,117,112,nil},{})
	local room_117=init_room(2,{116,118,nil,nil},{})
	local room_118=init_room(0,{117,119,nil,120},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_119=init_room(10,{118,nil,114,nil},{})
	local room_120=init_room(9,{nil,121,118,nil},{})
	local room_121=init_room(8,{120,nil,nil,127},{})
	local room_122=init_room(11,{nil,123,nil,129},{})
	local room_123=init_room(0,{122,124,nil,130},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_124=init_room(8,{123,nil,nil,131},{})
	local room_125=init_room(11,{nil,126,nil,132},{})
	local room_126=init_room(0,{125,127,nil,nil},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_127=init_room(0,{126,128,121,134},{})
	local room_128=init_room(0,{127,129,nil,nil},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_129=init_room(0,{128,130,122,nil},{
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_130=init_room(10,{129,nil,123,nil},{})
	local room_131=init_room(3,{nil,nil,124,138},{})
	local room_132=init_room(9,{nil,133,125,nil},{})
	local room_133=init_room(14,{132,nil,nil,nil},{})
	local room_134=init_room(9,{nil,135,127,nil},{})
	local room_135=init_room(2,{134,136,nil,nil},{})
	local room_136=init_room(2,{135,137,nil,nil},{})
	local room_137=init_room(2,{136,138,nil,nil},{})
	local room_138=init_room(10,{137,nil,131,nil},{})

	--level 5

	local room_139=init_room(1,{nil,140,nil,145},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17),
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2),
		init_down_elevator(102)
	})
	local room_140=init_room(0,{139,141,nil,146},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_141=init_room(0,{140,142,nil,147},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_142=init_room(0,{141,143,nil,148},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_143=init_room(0,{142,144,nil,149},{
		init_item(6,0,2),
		init_item(7,0,2),
		init_item(8,0,2),
		init_item(9,0,2)
	})
	local room_144=init_room(8,{143,nil,nil,150},{})
	local room_145=init_room(0,{nil,146,139,151},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_146=init_room(0,{145,147,140,152},{})
	local room_147=init_room(0,{146,148,141,153},{})
	local room_148=init_room(0,{147,149,142,154},{})
	local room_149=init_room(0,{148,150,143,155},{})
	local room_150=init_room(0,{149,nil,144,156},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_151=init_room(0,{nil,152,145,157},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_152=init_room(0,{151,153,146,158},{})
	local room_153=init_room(0,{152,154,147,159},{})
	local room_154=init_room(0,{153,155,148,160},{})
	local room_155=init_room(0,{154,156,149,161},{})
	local room_156=init_room(0,{155,nil,150,162},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_157=init_room(0,{nil,158,151,163},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_158=init_room(0,{157,159,152,164},{})
	local room_159=init_room(0,{158,160,153,165},{})
	local room_160=init_room(0,{159,161,154,166},{})
	local room_161=init_room(0,{160,162,155,167},{})
	local room_162=init_room(0,{161,nil,156,168},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_163=init_room(0,{nil,164,157,169},{
		init_item(0,6,17),
		init_item(0,7,17),
		init_item(0,8,17),
		init_item(0,9,17)
	})
	local room_164=init_room(0,{163,165,158,170},{})
	local room_165=init_room(0,{164,166,159,171},{})
	local room_166=init_room(0,{165,167,160,172},{})
	local room_167=init_room(0,{166,168,161,173},{})
	local room_168=init_room(0,{167,nil,162,174},{
		init_item(15,6,19),
		init_item(15,7,19),
		init_item(15,8,19),
		init_item(15,9,19)
	})
	local room_169=init_room(9,{nil,170,163,nil},{})
	local room_170=init_room(0,{169,171,164,nil},{
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_171=init_room(0,{170,172,165,nil},{
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_172=init_room(0,{171,173,166,nil},{
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_173=init_room(0,{172,174,167,nil},{
		init_item(6,15,34),
		init_item(7,15,34),
		init_item(8,15,34),
		init_item(9,15,34)
	})
	local room_174=init_room(10,{173,nil,168,nil},{})

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
	add(rooms,room_21)
	add(rooms,room_22)
	add(rooms,room_23)
	add(rooms,room_24)
	add(rooms,room_25)
	add(rooms,room_26)
	add(rooms,room_27)
	add(rooms,room_28)
	add(rooms,room_29)
	add(rooms,room_30)
	add(rooms,room_31)
	add(rooms,room_32)
	add(rooms,room_33)
	add(rooms,room_34)
	add(rooms,room_35)
	add(rooms,room_36)
	add(rooms,room_37)
	add(rooms,room_38)
	add(rooms,room_39)
	add(rooms,room_40)
	add(rooms,room_41)
	add(rooms,room_42)
	add(rooms,room_43)
	add(rooms,room_44)
	add(rooms,room_45)
	add(rooms,room_46)
	add(rooms,room_47)
	add(rooms,room_48)
	add(rooms,room_49)
	add(rooms,room_50)
	add(rooms,room_51)
	add(rooms,room_52)
	add(rooms,room_53)
	add(rooms,room_54)
	add(rooms,room_55)
	add(rooms,room_56)
	add(rooms,room_57)
	add(rooms,room_58)
	add(rooms,room_59)
	add(rooms,room_60)
	add(rooms,room_61)
	add(rooms,room_62)
	add(rooms,room_63)
	add(rooms,room_64)
	add(rooms,room_65)
	add(rooms,room_66)
	add(rooms,room_67)
	add(rooms,room_68)
	add(rooms,room_69)
	add(rooms,room_70)
	add(rooms,room_71)
	add(rooms,room_72)
	add(rooms,room_73)
	add(rooms,room_74)
	add(rooms,room_75)
	add(rooms,room_76)
	add(rooms,room_77)
	add(rooms,room_78)
	add(rooms,room_79)
	add(rooms,room_80)
	add(rooms,room_81)
	add(rooms,room_82)
	add(rooms,room_83)
	add(rooms,room_84)
	add(rooms,room_85)
	add(rooms,room_86)
	add(rooms,room_87)
	add(rooms,room_88)
	add(rooms,room_89)
	add(rooms,room_90)
	add(rooms,room_91)
	add(rooms,room_92)
	add(rooms,room_93)
	add(rooms,room_94)
	add(rooms,room_95)
	add(rooms,room_96)
	add(rooms,room_97)
	add(rooms,room_98)
	add(rooms,room_99)
	add(rooms,room_100)
	add(rooms,room_101)
	add(rooms,room_102)
	add(rooms,room_103)
	add(rooms,room_104)
	add(rooms,room_105)
	add(rooms,room_106)
	add(rooms,room_107)
	add(rooms,room_108)
	add(rooms,room_109)
	add(rooms,room_110)
	add(rooms,room_111)
	add(rooms,room_112)
	add(rooms,room_113)
	add(rooms,room_114)
	add(rooms,room_115)
	add(rooms,room_116)
	add(rooms,room_117)
	add(rooms,room_118)
	add(rooms,room_119)
	add(rooms,room_120)
	add(rooms,room_121)
	add(rooms,room_122)
	add(rooms,room_123)
	add(rooms,room_124)
	add(rooms,room_125)
	add(rooms,room_126)
	add(rooms,room_127)
	add(rooms,room_128)
	add(rooms,room_129)
	add(rooms,room_130)
	add(rooms,room_131)
	add(rooms,room_132)
	add(rooms,room_133)
	add(rooms,room_134)
	add(rooms,room_135)
	add(rooms,room_136)
	add(rooms,room_137)
	add(rooms,room_138)
	add(rooms,room_139)
	add(rooms,room_140)
	add(rooms,room_141)
	add(rooms,room_142)
	add(rooms,room_143)
	add(rooms,room_144)
	add(rooms,room_145)
	add(rooms,room_146)
	add(rooms,room_147)
	add(rooms,room_148)
	add(rooms,room_149)
	add(rooms,room_150)
	add(rooms,room_151)
	add(rooms,room_152)
	add(rooms,room_153)
	add(rooms,room_154)
	add(rooms,room_155)
	add(rooms,room_156)
	add(rooms,room_157)
	add(rooms,room_158)
	add(rooms,room_159)
	add(rooms,room_160)
	add(rooms,room_161)
	add(rooms,room_162)
	add(rooms,room_163)
	add(rooms,room_164)
	add(rooms,room_165)
	add(rooms,room_166)
	add(rooms,room_167)
	add(rooms,room_168)
	add(rooms,room_169)
	add(rooms,room_170)
	add(rooms,room_171)
	add(rooms,room_172)
	add(rooms,room_173)
	add(rooms,room_174)

	return rooms
end
__gfx__
0000000011111111111111111111111111111bb11bb1111100500500005005000111111003000300000660000000000000000000000000000000000000000000
0000000011111111111111111111111111111bb11bb1111110510510015015011100001130333030000660000400004005005005000000000000000000cc0000
00700700111111111111111111111111111112bbbb21111155555555555555551006600103000303006666000044440050050050000cc000000cc000000cc000
0007700011111111111111111111111111111bb22bb11111005005000050050010600601300300300077a700004554005005005000cccc0000cccc000000cc00
0007700011112b1bb5225bb5b1b21111b5225bb55bb5225b105105100150150110600601303030300779a770004444000555550000cccc000cc00cc00000cc00
00700700111125bbbb55bbbbbb521111bb55bbbbbbbb55bb555555555555555510066001303003030779a7700045540000444000000cc0000c0000c0000cc000
00000000111112bb5bbbb55bbb2111115bbbb55bb55bbbb500500500005005001100001103033030077777700044440000444000000000000000000000cc0000
000000001111bb5525bb522555bb111125bb52255225bb5210510510015015010111111000300300007777000400004000444000000000000000000000000000
111111111111bb5222222212bb52111125bb52255225bb52015015101051050100aaa000000aaa0000aaa000000aaa0000099900009990000009990000999000
1111111111115bb5222212225bb511115bbbb55bb55bbbb510510501015015100aacaa0000aacaa00aacaa0000aacaa000a999a00a999a0000a999a00a999a00
11111111111125bb2222222225bb1111bb55bbbbbbbb55bb055555501555555100aaa000000aaa0000aaa009900aaa0000099900009990009009990000999009
11111111111125bb2222222225bb1111b5225bb55bb5225b105105010150151000030009000030000003000330003009900aaa0000aaa000300aaa0090aaa003
1111111111115bb5212222225bb5111111111bb22bb1111101501510105105010003333333333000000333333333300333333000000333333333300030033333
111111111111bb5222222222bb521111111112bbbb21111115555551055555503333300090033333333330000003333300033333333330090003333333333000
111111111111bb5212222222bb52111111111bb11bb1111101501510105105019003300000033009900330000003300000033009900330000003300900033000
1111111111115bb5222222225bb5111111111bb11bb1111110510501015015100003300000033000000330000003300000033000000330000003300000033000
222bb2221111bbb55b5bb5bb55bb1111222222112222221244444444006660000000a0000000a0000000a0000000a00000444000004440000044400000000000
21bbbb2211111bb5bbbb55bbbb211111222112222222121246666664066566000000a9000000a9000000a9000000a900044c4400044c44000448440004000000
2bbbbbb21111b52bb55bbbb5bb52111122222222222212224655556400666000000ca900000ca900000ca900000ca90000444000004440000044400044400000
2b2bb2b21111221b5225bb52b1b21111212222222222222246666664000000080000a9000000a9000000a9090000a909000300090003000a0003000848480000
222bb222111111111111111111111111212222222112222246555564000000000090a3330000a3330000a3330090a33300033333000334440003344444488000
122bb222111111111111111111111111222222222222222246666664000000000033330900333309003333000033330033333000444330004443300004088000
222bb212111111111111111111111111122222221122222244444444800000000000330000903300009033000000330090033000900330008003300044488008
22222222111111111111111111111111122222222222222200044000000000000000330000003300000033000000330000033000000330000003300080088444
0333444003334440033344400333000000000000000000000000000b090909090000000000eeee0000eeee000000000000000000000ee000000ee00000000000
033c0440033c0440033c0440033044400000000000000000004444bb9090909000eeee00eee00eeeeee00eee00000000000ee00000eeee0000eeee0000000000
0330c0400330c0400330c040033c0440000000000000000004404bb0090aaa09eee00eeee0e00e0ee0e00e0e00eeee0000eeee000e0ee0e00e0ee0e000eeee00
ffff0c00ffff0c00ffff0c00ffffc040999999990000000044400b4490aaaaa0e0e00e0ee0e00e0e00000000eeeeeeee0e0ee0e0000ee000000000000e0ee0e0
f00ff0fff00ff0fff00ff0ff00000c00099559900004400040040b0409aaaaa9e0e00e0ee0e00e0e00000000eeeeeeee0e0ee0e0000ee000000000000e0ee0e0
0f00fff00f00fff00000fff000000000095995900044440044f0004490aaaaa0eee00eeee0e00e0ee0e00e0e00eeee0000eeee000e0ee0e00e0ee0e000eeee00
f00f0000f00f00000000000000000000099559900444444004f4f440090aaa0900eeee00eee00eeeeee00eee00000000000ee00000eeee0000eeee0000000000
0000f00f0000000000000000000000000099990044444444ff444ff0909090900000000000eeee0000eeee000000000000000000000ee000000ee00000000000
999009990090090000999900000000000000000000000000000000000000000000000000000000000000d444444d000000000000000000000000d444444d0000
05000050090000900900009009999990000000000000000000000000000000000000d444444d00000000d444444d00000000d444444d00000000d444444d0000
05555550955555599555555995555559000000000000000000000000000000000000d444444d00000000dd0000dd00000000d444444d00000000dd0000dd0000
5caeeac55caeeac55caeeac55caeeac5999905059909050509000505000005050000dd0000dd000000000dddddd000000000dd0000dd000000000dddddd00000
eaceecaeeaceecaeeaceecaeeaceecae9095eeac9095eeac0095eeac0995eeac00000dddddd000000000000dd000000000000dddddd000000000000dd0000000
ecaaaaceecaaaaceecaaaaceecaaaace900aacee000aacee000aacee090aacee0000000dd00000000000000dd00000000000000dd00000000000000dd0000000
0eceece00eceece00eceece00eceece0909acaca909acaca009acaca099acaca0000000dd00000000000000dd00000000000000dd00000000000000dd0000000
500aa005500aa005500aa005500aa005999905059909050509000505000005050000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000000000000000888000008880000000000000000000000000000008080800000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000070000800700000807080008070000070000000700000087800080878080000000dd00000000000000dd00000000000000dd00000000000000dd0000000
00000777000087770888077708880777000777000007870000078700008787800000000dd000000000055555555550000000000dd00000000005555555555000
00055577000850770000857780008577000050000000500000085800080858080005555555555000000555555555500000055555555550000005555555555000
00050070000050700888057008880570000050000000500000005000008080800005555555555000000555555555500000055555555550000005555555555000
00050660000006600000066080000660000666000006660000066600080687080005555555555000000055555555000000055555555550000000555555550000
00000666000006660000066600000666000666000006660000066600000666000000555555550000000000555500000000005555555500000000005555000000
00000666000006660000066600000666000666000006660000066600000666000000005555000000000000000000000000000055550000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00557000000005000000000567000000005570000000050000000005670000000445000000000500000000000000000004450000000005000000000000000000
00056700000555000000005567000000000567000005550000000055670000000045500000055500000000000000000000455000000555000000000000000000
00055770005567000000005567000000000557700055670000000055670000000004450000556700000000000000000000044500005567000000000000000000
00005677056770000000005567000000000056770567700000000055670000000000445505677000044444440000000000004455056770000444444400000000
00000556557700000077777565555500000005565577000000777775655555000000004455770000044444446555550000000044557700000444444465555500
00000055567000000666666565555550000000555670000006666665655555500000000456700000000000556555555000000004567000000000005565555550
00000765550000000555555556666660000007655500000005555555566666600000000455000000000000555666666000000004550000000000005556666660
00007755655000000055555657777700000077556550000000555556577777000000004465500000044444445777770000000044655000000444444457777700
00077650776500000000007655000000000776507765000000000076550000000000445577650000044444440000000000004455776500000444444400000000
00765500077550000000007655000000007655000775500000000076550000000004450007755000000000000000000000044500077550000000000000000000
00555000007650000000007655000000005550000076500000000076550000000045500000765000000000000000000000455000007650000000000000000000
00500000000755000000007650000000005000000007550000000076500000000445000000075500000000000000000004450000000755000000000000000000
00000000000000000000000600000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000000000000000000000000000cc000000000000000000000000000000c5555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000007700000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000077777700000000000000000000000007000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000077700000700000000000077770000000007770000000005444445444444444544444445444444444445444444445444444444444444445
00000070000000000770000000700000000777700000000000007707700000005444444444444444444444444444444444444444444444444444445444444445
00000070000000000070000000700000000700000000000000007000770000005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000700000007000000000000000070000070000005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000700000007000000000000000770000077000005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000700000007000000000000000700000007000005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000700000007000000000000000700000007700005444444444444444444444444444444444444444444444444444444444444445
00000070000000000007000000700000007000000000000000700000000700005444444444444444444444444444444444444444444444444444444444444445
00000070000000000007000000700000007000000000000000700000000700005444444444444444444444444444444444444444444444444444444444444445
00000070000000000007000000700000007000000000000000700000000070005444444444444444444444444444445444445444444444445444445444445445
00000070000000000070000000700000007000007000000000700000000070005444444444544444454444444444444444444444444444444444444444444445
00000070000000000070000000700000007700077770000000700000000070005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000770000000700000007700000770000000070005444444444444444444444444444444444444444444444444444444444444445
00000070000000000070000000070000000700000007700000070000000070005444444444444444444444444444444444444444444444444444444444444445
00000070000770000070000777770000000700000077000000077700000770005444444444444444444444444444444444444444444444444444444444444445
00000077777000000077777700000000000077777770000000000777777000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444454444444444544445
00000000000000000000000000000000000000000000000000000000000000005444444454444444544444444454444444444544444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444445444444544444444544444444445444444444454444444454444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
00000000000000000000000000000000000000000000000000000000000000005444444444444444444444444444444444444444444444444444444444444445
c000000000000000000000000000000cc000000000000000000000000000000c5555555555555555555555555555555555555555555555555555555555555555
__gff__
0002020202020a0a02020202020808080202000202020a0a0000000000000000800202020000044000000000000000001010101010101010010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000200202020202020200000000000000000220202020202002000000000000000002202020202020020000000000000000022020202020200200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020412120502020202020301020202020204121205020202020203010202020202020202020202020202030102020202031112121301020202020301020202020202020202020202020203010202020202041212130102020202030102020202020412120502020202020301020202020311121205020202020203
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213212222222222141212152222222222231112121212131112121311121212121321222222222214121215222222222223111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
0412121212121212121212121212120504121212152222141522221412121205020202020202041212050202020202021112121212050412120504121212121302020202020204121205020202020202041212121212121212050412121212130412121212121212121212121212120511121212120504121212121212121205
1212121212121212121212121212121212121212131212111312121112121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121211121212121212121212121212121212
1212121212121212121212121212121212121212051212040512120412121212121212121212121212121212121212121112121212121212121212121212121312121212121212121212121212121212121212121212121212121212121212131212121212121212121212121212121211121212121212121212121212121212
1412121212121212121212121212121514121212121212121212121212121215222222222222141212152222222222221112121212151412121514121212121314121212121212121212121212121215141212121212121212151412121212132222222222221412121522222222222211121212121514121212121212121215
1112121212121212121212121212121311121212121212121212121212121213010202020202041212050202020202031112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212130102020202020412120502020202020311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212131112121311121212121311121212121212121212121212121213111212121212121212131112121212131112121212121212121212121212121311121212121311121212121212121213
2122222222221412121522222222222321222222222214121215222222222223212222222222222222222222222222232122222222221112121321222222222321222222222214121215222222222223212222222222141212132122222222232122222222222222222222222222222321222222222311121215222222222223
0102020202020202020202020202020301020202020204121205020202020203010202020202041212050202020202030102020202020202020202020202020301020202020202020202020202020203010202020202041212050202020202030102020202020202020202020202020301020202020202020202020202020203
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121204222222222222222205121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
0412121212121212121212121212121311121212121212121212121212121205041212121212121212121212121212131112121212121212121212121212120511121212121212121212121212121213111212121212121212121212121212130412121212121212121212121212121311121213101010101010101011121213
1212121212121212121212121212121311121212121212121212121212121212121212121212121212121212121212131112121212121212121212121212121211121212121212121212121212121213111212121212121212121212121212131212121212121212121212121212121311121213101010101010101011121213
1212121212121212121212121212121311121212121212121212121212121212121212121212121212121212121212131112121212121212121212121212121211121212121212121212121212121213111212121212121212121212121212131212121212121212121212121212121311121214020202020202020215121213
1412121212121212121212121212121311121212121212121212121212121215141212121212121212121212121212131112121212121212121212121212121511121212121212121212121212121213111212121212121212121212121212131412121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121204222222222222222205121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121213101010101010101011121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121214020202020202020215121213
1112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213111212121212121212121212121212131112121212121212121212121212121311121212121212121212121212121213
2122222222221412121522222222222321222222222222222222222222222223212222222222222222222222222222232122222222221412121522222222222321222222222214121215222222222223212222222222222222222222222222232122222222222222222222222222222321222222222222222222222222222223
__sfx__
000300000c0100c0500c0500d050251502515025150251500e050251500e050291500d05030150371500a050391503b1503f15008050080500800008000080000600001000020000200023300020000300002000
000800000b1500c250102501325017250182501f1502115021150211501c3001c300263502b35030350313502a2002a200353503a3503c3503c3503f2003f200281002c10033100351002c20030200397003e200
00100000000002a3502e35030350000000000000000000003035032350353500000000000000000000033350353503a3503b3500000000000000003b3503d3503e3503f350000000000000000000000000000000
0003000033270322702f2702d27029270272702727008470084702e270242702b2702827025270212701f2701b27019270272001f200182002d2002d2002d2002c2002b2002820026200232001d2001920000000
0005000000000000002b350302502e2003305030350000002f4502f450304503145033450374503c4503e45000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000375006750097500c7500e75010750137501575017750197501b7501d7501f750217502375025750277502a7502c7502d7502f7503075032750347503675037750397503a7503b7503e7503f7503f750
001000002775000000287500000028750000002775000000267502475022750007000070026750177402510026750267500000000000227502e30029750000002f75035750000002f30037770176003675000000
0019002013840178401c84002840158401c8402284001840178401d840248400084029840238401f840008401c840198400084012840008401284000840128400084012840008401284000840128401584000040
00100000148501585017850188501a8501b8501b8500000000000000002d1502d1502c1502b15000000000002515023150201501f1501c150000001b150181501515000000071500715007150071500715007150
001000000000000000000001c15000000000002b25000000000002e35000000000002c35000000000002745000000247501a150247502a1501b1502a15032050292501e250292502a4502b4502e4503245037450
__music__
00 41424344
03 07474344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
02 41474344
