function [BracketFigure] = BracketVisualization(netWinners,netwin_conf, Games,varargin)

Bracket = BracketBuilder(Games, netWinners,netwin_conf);
BracketCheck = BracketBuilder(Games, netWinners);
if length(varargin) > 0
    answerKeyBracket = BracketBuilder(Games,varargin{1});
end 


%% Plot 
if length(varargin) == 0
    [row, col] = size(Bracket);
    
    c_spacing = 6;
    r_spacing = .75;
    
    BracketFigure = figure;
    hold on;
    axis equal;
    xlim([0, (col+1) * c_spacing]);
    ylim([0, (row+1) * r_spacing]);
    set(gca, 'XTick', [], 'YTick', [], 'XColor', 'w', 'YColor', 'w'); % Remove axis labels
    
    c_spacing = 6;
    r_spacing = .75;
    
    % Loop through the array and plot text in corresponding positions
    for r = 1:row
        for c = 1:col
            if ~strcmp(Bracket(r, c), "") && ~strcmp(Bracket(r, c), " ") % Ignore empty spaces
    
                textStr = [Bracket(r, c)];
    
                text(c*c_spacing, (row - r)*r_spacing + 1, textStr, 'HorizontalAlignment', 'center','FontSize', 6);
                line([c * c_spacing - 1.5, c * c_spacing + 1.5], ...
                     [((row - r) * r_spacing + 1) - 0.4, ((row - r) * r_spacing + 1) - 0.4], ...
                     'Color', 'k', 'LineWidth', 1);
            end
        end
    end
    title('2024 NCAA Tournament: CINDERELLA Results')
    
    hold off;

%% if we get the answer key we can color code the results
else 

    Score = ScoreBracket(netWinners,varargin{1});
    Score = sum(Score);

        [row, col] = size(answerKeyBracket);
    
    c_spacing = 6;
    r_spacing = .75;
    
    BracketFigure = figure;
    hold on;
    axis equal;
    xlim([0, (col+1) * c_spacing]);
    ylim([0, (row+1) * r_spacing]);
    set(gca, 'XTick', [], 'YTick', [], 'XColor', 'w', 'YColor', 'w'); % Remove axis labels
    
    c_spacing = 6;
    r_spacing = .75;
    
    % Loop through the array and plot text in corresponding positions
    for r = 1:row
        for c = 1:col

            if ~strcmp(Bracket(r, c), "") && ~strcmp(Bracket(r, c), " ") % Ignore empty spaces
    
                textStr = [Bracket(r, c)];
                if c ~= 1 && c ~= col(end)
                   if strcmp(BracketCheck(r,c),answerKeyBracket(r,c))
                        text(c*c_spacing, (row - r)*r_spacing + 1, textStr, 'HorizontalAlignment', 'center','FontSize', 6, 'Color','g');
                   else 
                        text(c*c_spacing, (row - r)*r_spacing + 1, textStr, 'HorizontalAlignment', 'center','FontSize', 6, 'Color', 'r');
                    
                   end
                     line([c * c_spacing - 1.5, c * c_spacing + 1.5], ...
                     [((row - r) * r_spacing + 1) - 0.4, ((row - r) * r_spacing + 1) - 0.4], ...
                     'Color', 'k', 'LineWidth', 1);
                else 
                    text(c*c_spacing, (row - r)*r_spacing + 1, textStr, 'HorizontalAlignment', 'center','FontSize', 6);
                    line([c * c_spacing - 1.5, c * c_spacing + 1.5], ...
                     [((row - r) * r_spacing + 1) - 0.4, ((row - r) * r_spacing + 1) - 0.4], ...
                     'Color', 'k', 'LineWidth', 1);
                end 
            end
        end
    end
    titleText = ["2024 NCAA Tournament: CINDERELLA Results", " ", "Score:", num2str(Score)];

    title(titleText)
    
    hold off;
    



end 