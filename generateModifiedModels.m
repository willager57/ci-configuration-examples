% Generate diff between currrent and ancestor commit
[~, currentRevision] = system('git rev-parse HEAD');
[~, ancestorRevision] = system('git rev-parse HEAD~');
currentRevision = replace(currentRevision, newline, "");
ancestorRevision = replace(ancestorRevision, newline, "");

[~, diff] = system(sprintf('git diff %s %s --name-status', ancestorRevision, currentRevision));

function extractedFileName = copyAncestorModel(model, ancestorRevision)
[path, filename, ext] = fileparts(model);
shortenedCommitID = extractBetween(ancestorRevision, 1, 8);
extractedFileName = fullfile(path, filename + "_" + shortenedCommitID + ext);
system(sprintf('git show %s:%s > %s', ancestorRevision, model, extractedFileName));
end

modelsToCleanup = strings(0);

% Summarize diff results
rows = string(strsplit(diff, "\n"));
diffData = struct([]);
for row = rows
    splitRow = strsplit(row, char(9));
    if splitRow ~= "" && length(splitRow) >= 2
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

% Create ZIP file containing modified models and list of changes
save("diffData", "diffData");
cleanupMat = onCleanup(@() delete("diffData.mat"));

filesToZip = [[diffData.Left], [diffData.Right], "diffData.mat", "summarizeDiffs.m", "showDiffs.bat"];
filesToZip = unique(filesToZip, 'stable');
zip('modifiedModels.zip', filesToZip);

% Cleanup
arrayfun(@(model) delete(model), modelsToCleanup)
clear