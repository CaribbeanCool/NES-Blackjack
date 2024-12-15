# NES Blackjack Game

A blackjack card game implemented for the Nintendo Entertainment System (NES) using 6502 assembly.

## Task 1: Static Sprite and Background Pattern Definition and Rendering

This task aims to draw the table’s background and show the maximum number of cards in 
each player’s area. The “hole” card should also be displayed for the dealer in the first available 
location, as shown in Figure 1. Each card and background tile must be designed using an NES 
graphic tool such as Nexxt to perform this task. Then, the .chr or .char file must be invoked from 
the ASM code, and two subroutines must print a card or a background tile on the screen (one 
subroutine for cards and one for background). These subroutines must receive as parameters 
the card index (0-51) or background tile index and the X/Y position of the card or background 
tile. 

The size of each card should be at least 3x2 tiles. Remember that cards should have three 
colors: black, white, and red. Also, the “hole” card should have some design at the back that 
includes at least three colors (Figure 1 has red, black, and white). The background is expected to have the two playing zones, the identifiers of “Player” and 
“PC” or “Dealer,” and the cash reserve and bet amounts. It is also expected to have at least two colors for the playing area (background). Finally, the names of both team members are expected to be at the bottom of the screen.

## Task 2: The Controller

In this task, each of the cards shown in Task 1 must be shown progressively as the player 
presses the buttons. In this case, the game should react as follows: 
- A: Draw a card for the dealer 
- B: Draw a card for the player 
- UP/DOWN: Increase or decrease the bet in $5 steps. 
- RESET: Delete all the cards in the table. 

Notice that the cards do not necessarily need to appear randomly at this point. They can 
occur in a predictable sequence. The whole point here is to make the graphics react to the 
buttons. This task requires mapping the controller buttons and associating each of them to move the character in each direction.

## Task 3: The Random Cards

This task is similar to Task 2. However, each card shown must be randomly selected among the 52 possible cards. Also, no card must be repeated since the game is only played with a single deck. To perform this task, you must implement a Random Number Generator (RNG) on the NES to select an integer number between 0 and 51. Also, you need to record the cards being drawn to avoid repeating them.

## Task 4: The Game Logic

In this task, all the logic of the Blackjack game shown in the Simplified Blackjack rules 
section must be implemented in a single-player game.

## Running the game
To run the game, you will need an NES emulator. We recommend using [MESEN](https://github.com/SourMesen/Mesen2).

1. Install ca65 assembler and ld65 linker
2. Run the build task in VS Code for Task 2 or execute:

```sh
ca65 ./{taskFolder}/src/{taskFile}.asm
ca65 ./{taskFolder}/src/reset.asm  
ca65 ./{taskFolder}/src/controllers.asm
ld65 ./{taskFolder}/src/reset.o ./{taskFolder}/src/{taskFile}.o ./{taskFolder}/src/controllers.o -C nes.cfg -o ./{taskFolder}/src/{taskFile}.nes
```
