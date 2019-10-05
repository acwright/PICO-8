pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--particles
--by aaron wright

function _init()
  particles={}
end

function _update()
	cls(1)
	gen_particle()
	for p in all(particles) do
  p:update()
	end
end

function _draw()
	for p in all(particles) do
  p:draw()
	end
end
-->8
--helpers

function gen_particle()
  add(particles, {
   x=63,
   y=63,
   dx=rnd(10)-5,
   dy=rnd(10)-5,
   life=15,
   col=rnd(16),
   draw=function(self)
     pset(self.x,self.y,self.col)
   end,
   update=function(self)
     self.x+=self.dx
     self.y+=self.dy
     self.life-=1
     if self.life<0 then
       del(particles,self)
     end
   end
 })
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000