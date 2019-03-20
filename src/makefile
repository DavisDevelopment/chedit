
default: compile run-js run-cpp

IN=~/Desktop/heroes/clickerHeroSave-v1.txt
OUT=~/Desktop/heroes/clickerHeroSaveEdited.txt
MODS=--add rubies:20 --multiply heroSouls:2

compile:
	haxe build.hxml

run-cpp:
	cd build/cpp/ && ./CHEdit --input ${IN} --output ${OUT} ${MODS}

run-js:
	cd build/js/ && node chedit.js --input ${IN} --output ${OUT} --add rubies,gold:20,5e420 --multiply heroSouls:2

run-neko:
	cd build/neko/ && neko chedit.n --input ${IN} --output ${OUT} ${MODS}

run-java:
	cd build/java/ && java -jar CHEdit.jar --input ${IN} --output ${OUT} ${MODS}

install-cpp:
	sudo rm -rf ~/.local/bin/chedit-cpp && sudo cp build/cpp/CHEdit ~/.local/bin/chedit

install: install-cpp
