# CINDERELLA
**Computational Intelligence w/ NCAA Data for Evaluating Rankings and Learning &amp; Locating Anomalies (March Madness Pipeline)**

## Overall Approach 

The current method in this program is to train an ensamble of models based on per game stats of each team weighted by their opponents second degree strength of schedule. We then 'simulate' the tournament by predcitng a winner in each head to head matchup. We use a monte carlo simualtion to run our tounrnament simulation multiple times, each game pulling the features from a distribution of the team's summary stats.
 
## Data Source 
.csv files included in this repo are from the *Kaggle March Machine Learning Mania Challenge* (https://www.kaggle.com/competitions/march-machine-learning-mania-2024). Will update when the 2025 challenge is released.


## Contents 

# *CINDERELLA.m*
This is the main loop which allows you to specifiy the number of iterations of the monte carlo. Pools results and creates a visualization of the predicted bracket. If using to test on previous years visualization method will score and colorcode the bracket based on the "answerkey"

# *TournamentSim.m* 
Simulates a single iteration of the NCAA Tournament. 


