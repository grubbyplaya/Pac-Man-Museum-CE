@echo off

echo Building launcher...
spasm64 -E -L src/pacmenu.asm bin/PacMan.8xp

echo Building Pac-Man (Arcade Ver.)
spasm64 -E -L src/Arcade/pacman.asm bin/PacArc.8xv

echo Building Pac-Man (GG Ver.)
spasm64 -E -L src/PacGG/pacman.asm bin/PacGG.8xv

echo Building Pac-Man (MSX Ver.)
spasm64 -E -L src/PacMSX/PacMSX.asm bin/PacMSX.8xv

echo Building Pac-Man (Coleco Ver.)
spasm64 -E -L src/ColecoPac/colecopac.asm bin/AtariPac.8xv

echo Building Ms. Pac-Man (SMS Ver.)
spasm64 -E -L src/MSPacMan/MsPacMan.asm bin/MsPacMan.8xv

echo Building Super Pac-Man (Sord Ver.)
spasm64 -E -L src/PowerPac/powerpac.asm bin/SuperPac.8xv
echo Pac-Man Museum CE
echo 1980-2024 Namco. Ports made by grubbycoder