% Generate diff between currrent and ancestor commit
[~, currentRevision] = system('git rev-parse HEAD');
[~, ancestorRevision] = system('git rev-parse HEAD~');
currentRevision = replace(currentRevision, newline, "");
ancestorRevision = replace(ancestorRevision, newline, "");

[~, diff] = system(sprintf('git diff %s %s --name-status', ancestorRevision, currentRevision));

modelsToCleanup = strings(0);

% Summarize diff results
rows = string(strsplit(diff, "\n"));
diffData = struct([]);
for row = rows
    splitRow = strsplit(row, char(9));
    if splitRow ~= ""
        [~, ~, ext] = fileparts(splitRow(2));
        if ext == ".slx" || ext == ".mdl"
            changeType = splitRow(1);
            diffData(end+1).ChangeType = changeType;
            if changeType == "A"
                diffData(end).Left = "emptyModel.slx";
                diffData(end).Right = splitRow(2);
                diffData(end).Summary = splitRow(2);
            elseif changeType == "D"
                % Need to implement
            elseif changeType == "R085"
                [path, filename, ext] = fileparts(splitRow(2));
                shortenedCommitID = extractBetween(ancestorRevision, 1, 8);
                extractedFileName = fullfile(path, filename + "_" + shortenedCommitID + ext);
                system(sprintf('git show %s:%s > %s', ancestorRevision, splitRow(2), extractedFileName));
                modelsToCleanup(end+1) = extractedFileName;

                diffData(end).Left = extractedFileName;
                diffData(end).Right = splitRow(3);
                diffData(end).Summary = splitRow(3);
            else
                [path, filename, ext] = fileparts(splitRow(2));
                shortenedCommitID = extractBetween(ancestorRevision, 1, 8);
                extractedFileName = fullfile(path, filename + "_" + shortenedCommitID + ext);
                system(sprintf('git show %s:%s > %s', ancestorRevision, splitRow(2), extractedFileName));
                modelsToCleanup(end+1) = extractedFileName;

                diffData(end).Left = extractedFileName;
                diffData(end).Right = splitRow(2);
                diffData(end).Summary = splitRow(2);
            end
        end
    end
end

% Create ZIP file containing modified models and list of changes
modelName = 'emptyModel';
new_system(modelName);
save_system(modelName);
close_system(modelName);
cleanupModel = onCleanup(@() delete("emptyModel.slx"));

save("diffData", "diffData");
cleanupMat = onCleanup(@() delete("diffData.mat"));

filesToZip = [[diffData.Left], [diffData.Right], "diffData.mat", "summarizeDiffs.m", "showDiffs.bat"];
filesToZip = unique(filesToZip, 'stable');
zip('modifiedModels.zip', filesToZip);

% Cleanup
arrayfun(@(model) delete(model), modelsToCleanup)
clear