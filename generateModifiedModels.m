% Generate diff between currrent and ancestor commit
[~, currentRevision] = system('git rev-parse HEAD');
[~, ancestorRevision] = system('git rev-parse "HEAD^"');
currentRevision = replace(currentRevision, newline, "");
ancestorRevision = replace(ancestorRevision, newline, "");

fprintf("Current revision: %s %s", currentRevision, newline);
fprintf("Ancestor revision: %s %s", ancestorRevision, newline);

system(sprintf('git diff %s %s --name-status > diff.txt', ancestorRevision, currentRevision));
diff = fileread('diff.txt');
delete('diff.txt');

disp(pwd);
disp("Diff result:")
disp(diff);

function extractedFileName = copyAncestorModel(model, ancestorRevision)
[path, filename, ext] = fileparts(model);
shortenedCommitID = extractBetween(ancestorRevision, 1, 8);
extractedFileName = fullfile(path, filename + "_" + shortenedCommitID + ext);
system(sprintf('git show %s:%s > %s', ancestorRevision, model, extractedFileName));
end

modelsToCleanup = strings(0);

% Summarize diff results
rows = string(strsplit(diff, newline));
diffData = struct([]);
for row = rows
    splitRow = strsplit(row, char(9));
    if length(splitRow) >= 2
        [~, ~, ext] = fileparts(splitRow(2));
        if ext == ".slx" || ext == ".mdl"
            changeType = splitRow(1);
            diffData(end+1).ChangeType = changeType;
            if changeType == "A"
                diffData(end).Left = "emptyModel.slx";
                diffData(end).Right = splitRow(2);
                diffData(end).Summary = splitRow(2);
            elseif changeType == "D"
                extractedFileName = copyAncestorModel(splitRow(2), ancestorRevision);
                modelsToCleanup(end+1) = extractedFileName;
                diffData(end).Left = extractedFileName;
                diffData(end).Right = "emptyModel.slx";
                diffData(end).Summary = splitRow(2);
            elseif contains(changeType, "R")
                extractedFileName = copyAncestorModel(splitRow(2), ancestorRevision);
                modelsToCleanup(end+1) = extractedFileName;
                diffData(end).Left = extractedFileName;
                diffData(end).Right = splitRow(3);
                diffData(end).Summary = splitRow(3);
            elseif changeType == "M"
                extractedFileName = copyAncestorModel(splitRow(2), ancestorRevision);
                modelsToCleanup(end+1) = extractedFileName;
                diffData(end).Left = extractedFileName;
                diffData(end).Right = splitRow(2);
                diffData(end).Summary = splitRow(2);
            end
        end
    end
end

disp("diffData generation finished");

% Create folder containing modified models and list of changes
if isempty(diffData)
    warning("No diffed models found - zip file not generated!");
    clear
    return;
end

disp("Saving diff data");
save("diffData", "diffData");
cleanupMat = onCleanup(@() delete("diffData.mat"));

outputFolderName = 'model-diffs';

if exist(outputFolderName, 'dir'), rmdir(outputFolderName, 's'); end
mkdir(outputFolderName);

filesToOutput = [[diffData.Left], [diffData.Right], "diffData.mat", "summarizeDiffs.m", "showDiffs.bat"];
filesToOutput = unique(filesToOutput, 'stable');
disp("Copying modified files");

function copyOutputFile(file, outputFolderName)
[path] = fileparts(file);
outputSubFolder = fullfile(outputFolderName, path);
if ~exist(outputSubFolder, 'dir'), mkdir(outputSubFolder); end
copyfile(file, fullfile(outputFolderName, file));
end
arrayfun(@(file) copyOutputFile(file, outputFolderName), filesToOutput);

% Cleanup
disp("Cleaning up models");
arrayfun(@(model) delete(model), modelsToCleanup)
disp("Clearing workspace");
clear