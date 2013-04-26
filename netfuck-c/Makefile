all: code

code:
	gcc netfuck.c -o netfuck -std=c99 
	
run: code
	./netfuck

test: code
	./netfuck test.txt irc.freenode.net:6667

debug:
	gcc netfuck.c -g -o netfuck -std=c99
	gdb netfuck

clean:
	rm netfuck