## Chemotaxis games ##

This repository contains two simple scripts which can be used explore chemotaxis strategies used by bacteria. 

**Bacterial chemotaxis** When swimming thought their environment bacteria, such as *E. coli*, follow a biased random walk. Bacteria move by alternating periods of swimming in a straight line followed by tumbling one the spot. The transitions between these two behaviours are made at *random* but the probability of switching between the two states is modified (*biased*) by the presence of attractants (such as food) and repellents (which cause harm). These codes explore different approaches to switching between the swimming and tumbling behaviours.

**Processing 3** The models are written in Processing 3, a simple language for creating visualisations. Read more and download [here](https://processing.org/). Note that model .pde files need to be placed in their own folder to run.

Two models are provided:

The **base_model** simulates a single bug in an environment devoid of food. Food can be dropped using the mouse by left clicking.

The **four_stratergies_model** simulates populations of four different bugs each exhibiting a different potential chemotaxis strategy: (i) no movement, (ii) random movement, (iii) movement based on the current food levels and (iv) movement with adaptation. Upon pressing the space bar a large amount of food is deposited in the centre of the four groups, equally distant from each. Which strategy seems most successful? Which bugs spend most time in the food? (This file writes the locations of the bugs and food levels to a text file to allow downstream further analysis.)

