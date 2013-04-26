all: code

code:
	gcc netfuck.c -o netfuck -std=gnu99
	
run: code
	./netfuck

test: code
	./netfuck test.txt irc.freenode.net:6667

clean:
	rm netfuck