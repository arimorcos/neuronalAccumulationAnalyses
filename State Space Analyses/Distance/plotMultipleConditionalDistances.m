function plotMultipleConditionalDistances(folder,fileStr, which_point)
%plotMultipleConditionalDistances.m Plots multiple conditional distances 
%
%INPUTS
%folder - folder to search in
%fileStr - file string to match 
%
%ASM 2/16

if nargin < 3 || isempty(which_point)
    which_point = 5;
end
pointLabels = {'Trial Start','Cue 1','Cue 2','Cue 3','Cue 4',...
    'Cue 5','Cue 6','Early Delay','Late Delay','Turn'};

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nDset 
nDatasets = length(matchFiles);

%loop through each file and create array 
allOut = cell(nDatasets,1);
for fileInd = 1:nDatasets
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
end

% get condition labels 
cond_labels = allOut{1}.conditions;
cond_labels = {'All correct trials',...
                  'Same choice',...
                  'Same 6-0 choice', ...
                  '6-0, curr & prev choice',...
                  '6-0, curr & prev choice/reward'};
num_conditions = length(cond_labels);

% concatenate each variable 
all_variance = cellfun(@(x) x.mean_variance, allOut, 'uniformoutput', false);
all_variance = cat(3, all_variance{:});

all_distance = cellfun(@(x) x.mean_distance, allOut, 'uniformoutput', false);
all_distance = cat(3, all_distance{:});

all_cosine_distance = cellfun(@(x) x.mean_cosine_distance, allOut, 'uniformoutput', false);
all_cosine_distance = cat(3, all_cosine_distance{:});

% normalize each variable
all_variance = bsxfun(@rdivide, all_variance, all_variance(:, 1, :));
all_distance = bsxfun(@rdivide, all_distance, all_distance(:, 1, :));
all_cosine_distance = bsxfun(@rdivide, all_cosine_distance, all_cosine_distance(:, 1, :));

% take mean and error for each 
mean_variance = nanmean(all_variance, 3);
sem_variance = calcSEM(all_variance, 3);

mean_distance = nanmean(all_distance, 3);
sem_distance = calcSEM(all_distance, 3);

mean_cosine_distance = nanmean(all_cosine_distance, 3);
sem_cosine_distance = calcSEM(all_cosine_distance, 3);

%create figure 
figH = figure;
axH = axes; 
hold(axH,'on');

% plot 
marker = 'o';
scat_var = errorbar(0.8:1:num_conditions-0.2, mean_variance(which_point, :),...
    sem_variance(which_point, :));
scat_var.Marker = marker;
scat_var.LineStyle = 'none';
scat_var.LineWidth = 2;
scat_var.MarkerSize = 20;
scat_var.MarkerFaceColor = scat_var.MarkerEdgeColor;

scat_dist = errorbar(1:1:num_conditions, mean_distance(which_point, :),...
    sem_distance(which_point, :));
scat_dist.Marker = marker;
scat_dist.LineStyle = 'none';
scat_dist.LineWidth = 2;
scat_dist.MarkerSize = 20;
scat_dist.MarkerFaceColor = scat_dist.MarkerEdgeColor;

scat_cosine = errorbar(1.2:1:num_conditions+0.2, mean_cosine_distance(which_point, :),...
    sem_cosine_distance(which_point, :));
scat_cosine.Marker = marker;
scat_cosine.LineStyle = 'none';
scat_cosine.LineWidth = 2;
scat_cosine.MarkerSize = 20;
scat_cosine.MarkerFaceColor = scat_cosine.MarkerEdgeColor;


% label 
beautifyPlot(figH, axH);
axH.XTick = 1:num_conditions;
axH.XTickLabels = cond_labels;
axH.XTickLabelRotation = -45;
axH.Title.String = pointLabels{which_point};

legH = legend([scat_var, scat_dist, scat_cosine], ...
    {'Variance', 'Mean pairwise Euclidean distance',...
    'Mean pairwise cosine distance'},...
    'Location', 'Southwest');
