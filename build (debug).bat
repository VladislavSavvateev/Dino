@echo off
_exec\asm68k /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- main.asm, rom.bin, rom.sym, rom.lst
_exec\fixheadr rom.bin
convsym rom.sym rom.bin -input asm68k_sym -a
pause
start _exec\gens rom.bin
