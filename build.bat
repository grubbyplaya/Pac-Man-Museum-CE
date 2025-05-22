@echo off

set /P PlusTrig=Include Pac-Man Plus? (0 = No, 1 = Yes): 

echo Building launcher...
spasm64 -E -D PacPlus=PlusTrig -L src/pacmenu.asm bin/PacMan.8xp

echo Building Pac-Man (Arcade Ver.)
spasm64 -E -L src/Arcade/pacman.asm bin/PacArc.8xv

echo Building Pac-Man (GG Ver.)
spasm64 -E -L src/PacGG/pacman.asm bin/PacGG.8xv

echo Building Pac-Man (MSX Ver.)
spasm64 -E -L src/PacMSX/PacMSX.asm bin/PacMSX.8xv

echo Building Pac-Man (Coleco Ver.)
spasm64 -E -L src/ColecoPac/colecopac.asm bin/AtariPac.8xv

echo Building Ms. Pac-Man (Arcade Ver.)
spasm64 -E -L src/Arcade/mspac.asm bin/MsPacArc.8xv

echo Building Ms. Pac-Man (SMS Ver.)
spasm64 -E -L src/MSPacMan/MsPacMan.asm bin/MsPacMan.8xv

echo Building Super Pac-Man (Sord Ver.)
spasm64 -E -L src/PowerPac/powerpac.asm bin/SuperPac.8xv

if %PlusTrig%==1 echo Building Pac-Man Plus (Arcade Ver.)
if %PlusTrig%==1 spasm64 -E -L src/Arcade/PacPlus/pacplus.asm bin/PacPlus.8xv

echo Pac-Man Museum CE
echo 1980-2025 Namco. Ports made by grubbycoder