function blank(M, N, filename)
   return 0
end

function top(x, y)
    if x>= -200 and x<=200 then return 1 end
end 

function plot (r, M, N, filename)
   local file = io.open(filename, "w")
   file:write("P1\n", M, " ", N, "\n")
   for i = 1, N do
      local y = (N - i*2)/N
      for j = 1, M do
         local x = (M - j*2)/M
         file:write(r(x,y) and "1 " or "0 ")-- if the xy is true, then evalutate 
                                             --1 is black 
      end
      file:write("\n")
   end
   file:close()
end

plot(top, 400, 300, "top_test.pbm") 

function disk (cx, cy, rad) -- (number x number x number) -> function
   return function (x,y) -- (number x number) -> boolean
      return (x - cx)^2 + (y - cy)^2 <= rad^2 --what is happening here 
   end
end

function rect (left, right, bottom, up)
   return function (x,y)
      return left <= x and x <= right and bottom <= y and y <= up --and here
   end
end

function square(cx, cy, length) --centered at cxcy and length long
	return function(x, y)
		--return x >= ((cx-(length/2))^2 + (cy-(length/2))^2)  and x <= ((cx+(length/2))^2 + (cy+(length/2))^2) 
			--and y >= ((cx-(length/2))^2 + (cy-(length/2))^2) and y <= ((cx+(length/2))^2 + (cy+(length/2))^2)
		return (x-cx)^2 <= (length/2) and (y-cy)^2<=(length/2) and x <= (cx+length/2) and y <=(cy+length/2)
	end
end

plot(square(0, 0, 0.25), 500, 500, "square_test.pbm")
plot(disk (0, 0, .8), 640, 480, "dog_circle_test.pbm")
plot(complement, 640, 480, "dog_negate_test.pbm")

function loadimg(filename) --returns table w numbers
   local imgin = io.open(filename, "r")
   local iformat = imgin:read("*line")
   assert(iformat == "P1")
   local width = imgin:read("*number")
   local height = imgin:read("*number")
   local imgdata = {}
   for i=1,height do
      imgdata[i] = {}
      for j=1,width do
         imgdata[i][j] = imgin:read("*number")
      end
   end
   imgin:close()
   return {M = width, N = height, data = imgdata}
end

function img(r, x, y) --predicate funtion, will return boolean, uses x and y
	return 1
end
--true which means 1 (black) or false which means 0 (white)
--plot(img(loadimg("hacker_pup.pbm"), ))

--img(string) -->(function that is num x num) --> boolean


function above (p, q, rest1, rest2) --should call img bc you need the plot data
	if ((rest1 ~= nil) and (rest2 ~= nil)) then
		local m = 1
		local n = 1
	else
		local m = rest1
		local n = rest2
	end
	top= (m + n)/m
	bottom= (m + n)/n
	return (union(translate(scale (p, 1, top), 0, top-1), translate(scale(q, 1, bottom), 0, bottom-1)))
end

function beside(p, q, rest1, rest2)
	if ((rest1 ~= nil) and (rest2 ~= nil)) then
		local m = 1
		local n = 1
	else
		local m = rest1
		local n = rest2
	end
	top= (m + n)/m
	bottom= (m + n)/n
	return (complement(translate(scale (p, 1, top), 0, top-1), translate(scale(q, 1, bottom), 0, bottom-1)))
end

function mirror(p, q) 
	return function (x,y)
        return 
    end
end

function flip(p, q)
	return function (x,y)
        return r(y, x)
    end
end


plot (above (img(hacker_pup), mirror ((hacker_pup), 1, 2), 640, 480, "dog_above_test.pbm"))
--(define fish (scale (translate (img "fish.pbm") 0.17 -0.062) 1.35 1.175))

function quartet (p, q, r, s)
	return above(beside(p, q), beside(r, s))
end

function nonet(p, q, r, s, t, u, v, w, x)
	return above(beside(p,beside(q, r),1,2), above(beside(s, beside (u), 1, 2)), beside (v, beside (w, x), 1, 2), 1, 2) 
end

function squarelimit(n) 
	return nonet(corner)
end

function over(p, q) -- same thing as union
	return function (x, y)
        return r1(x, y) or r2(x, y)
    end
end

function rot45(r)
	local a = radians(45)
   return affine(r, math.cos(a), math.sin(a), -math.sin(a), math.cos(a), 0, 0)
end

function u(r)
	return over(over(over(smallfish, rotby(smallfish)), rotby(rotby(smallfish))), rotby(rotby(rotby(smallfish))))
end

function side(n)
	t = 1
	if n ==0 then return blank 
	else return quartet(side(n-1), side (n-1), rotby(t), t)
	end
end

function corner(n)
	if n==0 then return blank
		else return quartet(corner(n-1), side(n-1), rot(side(n-1)), u)
	end
end

function complement (r)
    return function (x,y)
        return not r(x, y)
    end
end
    
function union (r1, r2)
    return function (x, y)
        return r1(x, y) or r2(x, y)
    end
end
    
function intersection (r1, r2)
    return function (x, y)
        return r1(x, y) and r2(x, y)
    end
end
    
function difference (r1, r2)
    return function (x, y)
    	return r1(x, y) and (not r2(x, y))
    end
end


function translate(r, dx, dy)
   return function (x, y)
      return r(x - dx, y - dy)
   end
end

function scale(r, sx, sy)
   return function (x, y)
      return r(x / sx, y / sy)
   end
end

function affine(r, a, b, c, d, e, f)
   return function (x, y)
      return r(a * x + c * y + e, b * x + d * y + f)
   end
end

function radians(deg)
   return math.pi * (deg / 180)
end

function rotby(r, deg)
   local a = radians(deg)
   return affine(r, math.cos(a), math.sin(a), -math.sin(a), math.cos(a), 0, 0)
end
--fish only has one input
--for above : return union, translatem scale 
--hacker pup is a predicate 
--above (pred, pred) --> pred pred
--let should be a local variable 
--. rest is optional, but ALWYAS takes 4, so just set it to one
--side should use t (global) variable or number