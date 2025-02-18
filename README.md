# CINDERELLA
Computational Intelligence w/ NCAA Data for Evaluating Rankings and Learning &amp; Locating Anomalies (March Madness Pipeline)

## Overall Approach 
I threw this code together the night before brackets were due last year, so we are uploading the current state of the code so we can get a little more of a head start on it this year!

The current method in this program is to train an ensamble of models based on per game stats of each team weighted by their strength of schedule. We then 'simulate' the tournament by predcitng a winner in each head to head matchup. Final result of this approach is the amount of 'Bracket challenge' points a team is projected to earn, allowing us to retain teams that have a greater chance of winnign subsequent matchups if they were to win their earlier ones. Over the next month and change we will clean up and update this appraoch to build a bracket for the 2025 tournament and with whatever time we have left we'll build out a few other methods of predicting brackets in MATLAB and Python. 

## Data Source 
.csv files included in this repo are from the *Kaggle March Machine Learning Mania Challenge* (https://www.kaggle.com/competitions/march-machine-learning-mania-2024). Will update when the 2025 challenge is released.


## Contents 
