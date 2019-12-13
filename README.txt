This is a Q-Learner sword fighting AI for Roblox. The completed place file has been included in this repo. This was a final project for CS-6600 (Intellegent Systems) at Utah State University. As the author, I wrote a quick report to summerize the issue I ran into and what I learned. I've also uploaded a video to YouTube of the AI learning. Once trained these AI are very good at killing. There are however some limitations:
- For ease of development, I didn't integration the AI controller with the Humanoid Controls. Positions / Rotations are CFramed.
- For lack of interest at the time, the AIs cannot slash or lunge yet. These are trivial to add so I may soon.
- The map these AIs run on must be flat and without effects that could cause some positions to be less favorable. The reasons and solution are addressed in the report.

In this repo we have these files:
AI.rbxl - Completed Roblox place file
combat.lua - The main script
Control.lua - The AI's controller which is a ModuleScript
util.lua - General functions to help convert between representations and some math helpers
CS6600_Report.pdf - The class report (thrown together in 30 minutes mind you)

Here is the YouTube video:
https://youtu.be/U7qKrmCz2c4