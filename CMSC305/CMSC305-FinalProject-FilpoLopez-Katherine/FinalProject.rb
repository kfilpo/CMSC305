Express = "(+ (* 3 5) 6)" 
ExpressArray = Array.new
ExpressStack = Array.new
Dictionary = {}

#primative enviornment
#Dictionary[:+] = ExpressArray.pop + ExpressArray.pop
#Dictionary[:-] = ExpressArray.pop - ExpressArray.pop
#Dictionary[:/] = ExpressArray.pop / ExpressArray.pop
#Dictionary[:*] = ExpressArray.pop * ExpressArray.pop
Dictionary['cons'] = ExpressArray.push(ExpressArray.pop)
Dictionary['car'] = ExpressArray.pop
Dictionary['cdr'] = ExpressArray.pop
Dictionary['null'] = ' '
Dictionary['list'] = ExpressArray.pop
Dictionary['equal?'] = ExpressArray.pop
Dictionary['list?'] = ExpressArray.pop
#Dictionary['null?] = ExpressArray.pop
#Dictionary['append'] = ExpressArray.pop
#Dictionary['set!'] = ExpressArray.pop
#Dictionary[lambda] = 1


def Lexer(string)
	ExpressArray.push(string.gsub(/\(/, ' ( ' ).gsub(/\)/, ' ) ' ).split) 
	#take parenthesies that don't have whiteshpace, and put whitespace 
	#then split the whole string of input by whitespace
	print ExpressArray 
end

def Eval(array, hash) 
	if (ExpressArray != nil)
		i = 0
		while i >= 0
			if(ExpressArray[i].pop == "+") then return ExpressArray.pop[i+1] + ExpressArray[i+2].pop end
			if(ExpressArray[i].pop == "-") then return ExpressArray.pop[i+1] - ExpressArray[i+2].pop end
			if(ExpressArray[i].pop == "*") then return ExpressArray.pop[i+1] * ExpressArray[i+2].pop end
			if(ExpressArray[i].pop == "/") then return ExpressArray.pop[i+1] / ExpressArray[i+2].pop end
		end
		j = 0
		while j >= 0
			print ExpressArray[j].pop
		end
	end
end 


Lexer(Express)
Eval(Express, Dictionary)


#have it read in evenironment list things with the iterator and if it is in 
#the environment then push onto stack, right?? nesting 