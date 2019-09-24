pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--state
--by aaron wright

function _init()
	game={}
	init_menu()
end

function _update()
	game.update()
end

function _draw()
	game.draw()
end
-->8
--menu

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
	cls(5)
	print("game state",45,63,7)
	print("press ❎ to start",32,70,7)
end
-->8
--game

function init_game()
	x=63
	y=63
	game.update=update_game
	game.draw=draw_game
end

function update_game()
	if btn(0) then x-=2 end
	if btn(1) then x+=2 end
	if btn(2) then y-=2 end
	if btn(3) then y+=2 end
	
	if x<0 or x>124 or y<0 or y>124 then
		init_gameover()
	end
end

function draw_game()
	cls(6)
	circfill(x,y,3,7)
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
	cls(5)
	print("press ❎ to restart",30,63,7)
	print("press 🅾️ to go to menu",23,70,7)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
