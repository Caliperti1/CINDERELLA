%% Feature Engineering
% Builds a matchup feature vector for Team1 vs Team2.
%
% Design goals of this version:
% 1) Keep "Method 2" stochasticity (Monte Carlo perturbation around team means)
% 2) Reintroduce explicit interaction terms (offense vs defense fit)
% 3) Add rating-based context (Elo and margin-adjusted Elo)
% 4) Keep training/simulation feature generation identical for consistency

function FeatureSet = FeatureEngineer(TeamIDYr1, TeamIDYr2, RawData, Data, varargin)

% Resolve row indices once. Using first match prevents accidental vector outputs.
Team1Idx = find(RawData.TeamIDs == TeamIDYr1, 1);
Team2Idx = find(RawData.TeamIDs == TeamIDYr2, 1);

if isempty(Team1Idx) || isempty(Team2Idx)
    error('FeatureEngineer:TeamNotFound', ...
        'Could not resolve TeamIDYr pair: %s vs %s', string(TeamIDYr1), string(TeamIDYr2));
end

% ---------------------------------------------------------------------
% Method 2: stochastic team profiles used by Monte Carlo
% ---------------------------------------------------------------------
% Data(..).SumStats stores [mean; std] for weighted per-game team features.
% We preserve the existing randomization concept: each feature can move
% +/- 1.5 std to simulate "good day / bad day" outcomes.
isRandomDraw = ~isempty(varargin);

[t1Mean, t1Std, t1Hotness] = getTeamProfile(Data, Team1Idx);
[t2Mean, t2Std, t2Hotness] = getTeamProfile(Data, Team2Idx);

if isRandomDraw
    t1Noise = -1.5 + (3 .* rand(1, numel(t1Mean)));
    t2Noise = -1.5 + (3 .* rand(1, numel(t2Mean)));
    Team1Feats = t1Mean + (t1Noise .* t1Std);
    Team2Feats = t2Mean + (t2Noise .* t2Std);
else
    Team1Feats = t1Mean;
    Team2Feats = t2Mean;
end

% Hotness/momentum context.
% Col 18 = conference tournament wins.
% Hotness(1) = wins in last 10 regular-season games.
% Hotness(2) = quality-weighted wins in last 10.
Team1Feats = [Team1Feats, RawData.TeamStats(Team1Idx, 18), t1Hotness(1), t1Hotness(2)];
Team2Feats = [Team2Feats, RawData.TeamStats(Team2Idx, 18), t2Hotness(1), t2Hotness(2)];

% ---------------------------------------------------------------------
% Interaction features: this is where matchup logic lives.
% ---------------------------------------------------------------------
% Team feature index mapping (from DataManager weighted vectors):
% 1:FGM 2:FGA 3:3FGM 4:3FGA 5:FTM 6:FTA 7:OR 8:DR 9:AST 10:TO 11:STL 12:BLK 13:PF
% 14:OppFGM 15:OppFGA 16:Opp3FGM 17:Opp3FGA 18:OppFTM 19:OppFTA
% 20:OppOR 21:OppDR 22:OppAST 23:OppTO 24:OppSTL 25:OppBLK 26:OppPF

t1FGPct = safeDivide(Team1Feats(1), Team1Feats(2));
t2FGPct = safeDivide(Team2Feats(1), Team2Feats(2));
t13Pct = safeDivide(Team1Feats(3), Team1Feats(4));
t23Pct = safeDivide(Team2Feats(3), Team2Feats(4));
t1FTPct = safeDivide(Team1Feats(5), Team1Feats(6));
t2FTPct = safeDivide(Team2Feats(5), Team2Feats(6));

% How Team offense fits against opponent defense profile.
t1VsT2FG = t1FGPct - safeDivide(Team2Feats(14), Team2Feats(15));
t1VsT23 = t13Pct - safeDivide(Team2Feats(16), Team2Feats(17));
t2VsT1FG = t2FGPct - safeDivide(Team1Feats(14), Team1Feats(15));
t2VsT13 = t23Pct - safeDivide(Team1Feats(16), Team1Feats(17));

% Glass control and turnover pressure edges.
t1ORBEdge = Team1Feats(7) - Team2Feats(21);
t1DRBEdge = Team1Feats(8) - Team2Feats(20);
t2ORBEdge = Team2Feats(7) - Team1Feats(21);
t2DRBEdge = Team2Feats(8) - Team1Feats(20);
t1TOPressure = Team2Feats(23) - Team1Feats(10); % opponent forces TO minus our TO
t2TOPressure = Team1Feats(23) - Team2Feats(10);

% Lightweight possession/efficiency proxies using box-score components.
t1EffProxy = Team1Feats(1) + 0.5 * Team1Feats(3) + 0.25 * Team1Feats(5) - 0.7 * Team1Feats(10);
t2EffProxy = Team2Feats(1) + 0.5 * Team2Feats(3) + 0.25 * Team2Feats(5) - 0.7 * Team2Feats(10);
effDiff = t1EffProxy - t2EffProxy;

% Momentum differential terms complement raw hotness values.
confWinsDiff = RawData.TeamStats(Team1Idx, 18) - RawData.TeamStats(Team2Idx, 18);
hotnessDiff = t1Hotness(1) - t2Hotness(1);
weightedHotnessDiff = t1Hotness(2) - t2Hotness(2);

InteractionFeats = [ ...
    t1VsT2FG, t1VsT23, t2VsT1FG, t2VsT13, ...
    t1ORBEdge, t1DRBEdge, t2ORBEdge, t2DRBEdge, ...
    t1TOPressure, t2TOPressure, ...
    t1FTPct - t2FTPct, ...
    effDiff, ...
    confWinsDiff, hotnessDiff, weightedHotnessDiff ...
];

% ---------------------------------------------------------------------
% Elo features: baseline Elo + margin-of-victory adjusted Elo.
% ---------------------------------------------------------------------
eloFeats = buildEloFeatures(TeamIDYr1, TeamIDYr2, RawData);

% Final feature vector includes team-level stochastic stats + matchup terms.
FeatureSet = [Team1Feats, Team2Feats, InteractionFeats, eloFeats];

end

function out = safeDivide(num, den)
% Protect all engineered ratios from NaN/Inf explosion.
if den == 0 || isnan(den)
    out = 0;
else
    out = num / den;
end

function [featMean, featStd, hotness] = getTeamProfile(Data, teamIdx)
% Defensive helper for teams with incomplete engineered stats.
% Most tournament teams have full profiles, but this keeps the pipeline
% from hard-failing if a profile is partially missing.

defaultLen = 26;

if isfield(Data, 'SumStats') && size(Data(teamIdx).SumStats, 1) >= 2
    featMean = Data(teamIdx).SumStats(1, :);
    featStd = Data(teamIdx).SumStats(2, :);
else
    featMean = zeros(1, defaultLen);
    featStd = zeros(1, defaultLen);
end

if isfield(Data, 'Hotness') && numel(Data(teamIdx).Hotness) >= 2
    hotness = Data(teamIdx).Hotness(1:2);
else
    hotness = [0, 0];
end
end
end

function eloFeats = buildEloFeatures(TeamIDYr1, TeamIDYr2, RawData)
% Computes team Elo features using regular-season games in the same season.
%
% Output features (scaled for model stability):
% 1  baseline Elo (team1 centered/scaled)
% 2  baseline Elo (team2 centered/scaled)
% 3  baseline Elo diff
% 4  baseline Elo expected win probability for team1
% 5  MOV-adjusted Elo (team1 centered/scaled)
% 6  MOV-adjusted Elo (team2 centered/scaled)
% 7  MOV-adjusted Elo diff
% 8  MOV-adjusted Elo expected win probability for team1

persistent cachedSeason cachedNGames cachedRatingsBase cachedRatingsMov

team1Str = char(string(TeamIDYr1));
team2Str = char(string(TeamIDYr2));
seasonKey = regexp(team1Str, '^\d+', 'match', 'once');
if isempty(seasonKey)
    seasonKey = 'unknown';
end

% Rebuild cache only when season/game-count changes.
nGames = height(RawData.regularSeason);
if isempty(cachedSeason) || ~strcmp(cachedSeason, seasonKey) || cachedNGames ~= nGames
    [cachedRatingsBase, cachedRatingsMov] = computeSeasonElo(RawData, seasonKey);
    cachedSeason = seasonKey;
    cachedNGames = nGames;
end

e1 = lookupRating(cachedRatingsBase, team1Str);
e2 = lookupRating(cachedRatingsBase, team2Str);
m1 = lookupRating(cachedRatingsMov, team1Str);
m2 = lookupRating(cachedRatingsMov, team2Str);

eloProb1 = 1 / (1 + 10.^((e2 - e1) / 400));
movProb1 = 1 / (1 + 10.^((m2 - m1) / 400));

eloFeats = [ ...
    (e1 - 1500) / 100, ...
    (e2 - 1500) / 100, ...
    (e1 - e2) / 100, ...
    eloProb1, ...
    (m1 - 1500) / 100, ...
    (m2 - 1500) / 100, ...
    (m1 - m2) / 100, ...
    movProb1 ...
];
end

function [ratingsBase, ratingsMov] = computeSeasonElo(RawData, seasonKey)
% Builds two Elo tables from regular-season games:
% - ratingsBase: standard Elo update
% - ratingsMov: Elo update scaled by margin-of-victory multiplier

ratingsBase = containers.Map('KeyType', 'char', 'ValueType', 'double');
ratingsMov = containers.Map('KeyType', 'char', 'ValueType', 'double');

allTeams = string(RawData.TeamIDs);
seasonPrefix = seasonKey + "_";
seasonTeams = allTeams(startsWith(allTeams, seasonPrefix));
for ii = 1:numel(seasonTeams)
    key = char(seasonTeams(ii));
    ratingsBase(key) = 1500;
    ratingsMov(key) = 1500;
end

regW = string(RawData.regularSeason.WTeamIDYr);
regL = string(RawData.regularSeason.LTeamIDYr);
seasonMask = startsWith(regW, seasonPrefix) & startsWith(regL, seasonPrefix);

kFactor = 20;

for gg = find(seasonMask)'
    wk = char(regW(gg));
    lk = char(regL(gg));

    if ~isKey(ratingsBase, wk)
        ratingsBase(wk) = 1500;
        ratingsMov(wk) = 1500;
    end
    if ~isKey(ratingsBase, lk)
        ratingsBase(lk) = 1500;
        ratingsMov(lk) = 1500;
    end

    % --------------------------
    % Standard Elo update
    % --------------------------
    rw = ratingsBase(wk);
    rl = ratingsBase(lk);
    ew = 1 / (1 + 10.^((rl - rw) / 400));
    delta = kFactor * (1 - ew);
    ratingsBase(wk) = rw + delta;
    ratingsBase(lk) = rl - delta;

    % --------------------------
    % Margin-adjusted Elo update
    % --------------------------
    mw = ratingsMov(wk);
    ml = ratingsMov(lk);
    em = 1 / (1 + 10.^((ml - mw) / 400));

    margin = abs(double(RawData.regularSeason.WScore(gg) - RawData.regularSeason.LScore(gg)));
    movMultiplier = log(margin + 1) * (2.2 / ((mw - ml) * 0.001 + 2.2));
    movDelta = kFactor * movMultiplier * (1 - em);

    ratingsMov(wk) = mw + movDelta;
    ratingsMov(lk) = ml - movDelta;
end
end

function rating = lookupRating(ratingMap, teamKey)
if isKey(ratingMap, teamKey)
    rating = ratingMap(teamKey);
else
    rating = 1500;
end
end