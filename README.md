# Joust
Following @mwenge's [project][mwenge] to get Defender compiling ROM files that can be ran in [MAME][mamedev].

I would like to achieve the same thing for Joust from the source code which was also published under [historicalsource/joust][joust].

As I understand it the Joust arcade game used the same arcade cabinet hardware as Defender and even shares a sound ROM?

No idea how feasible this is, so far I've tried using the same tools [`asm6809`][asm6809] and [`vasm`][vasm] but there are some assembly instructions in the Joust source code that the do not recognise.



[vasm]:    http://www.compilers.de/vasm.html
[asm6809]: https://www.6809.org.uk/asm6809/
[joust]:   https://github.com/historicalsource/joust
[mwenge]:  https://github.com/mwenge/defender
[mamedev]: https://www.mamedev.org/index.php