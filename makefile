all: psmanager.so modyamllib.so

psmanager.so: src/psmanager/*.cpp
	g++ src/psmanager/*.cpp -lpq -fpic -shared -o lua/lib/psmanager.so

modyamllib.so: src/modyaml/*.c
	gcc src/modyaml/*.c -fpic -shared -o lua/lib/modyamllib.so
