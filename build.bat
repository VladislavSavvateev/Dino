@echo off
_exec\asm68k /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- main.asm, rom.bin, , rom.lst
_exec\fixheadr rom.bin
pause
start _exec\fusion rom.bin
