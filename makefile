psmanager.so: src/*.cpp
	g++ src/*.cpp -lpq -fpic -shared -o lua/lib/psmanager.so
