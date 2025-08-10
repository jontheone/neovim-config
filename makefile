
psmanager.so: src/*.cpp
	g++ src/*.cpp -lpq -fpic -shared -o lua/lib/psmanager.so


deafult: 
	g++ src/main.cpp src/yamlread.cpp -lpq -fpic -o main.out
	#g++ src/main.cpp src/update.cpp src/ErrorLogging.cpp src/yamlread.cpp -lpq -fpic -o main.out
	./main.out
