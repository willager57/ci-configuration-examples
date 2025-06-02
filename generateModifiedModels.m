% Generate diff between currrent and ancestor commit
[~, currentRevision] = system('git rev-parse HEAD');
[~, ancestorRevision] = system('git rev-parse HEAD~');
currentRevision = replace(currentRevision, newline, "");
ancestorRevision = replace(ancestorRevision, newline, "");

[~, diff] = system(sprintf('git diff %s %s --name-status', ancestorRevision, currentRevision));

% Summarize diff results
rows = string(strsplit(diff, "\n"));
diffData = struct([]);
for row = rows
    splitRow = strsplit(row, char(9));
    if length(splitRow) == 2
        [folder, name, ext] = fileparts(splitRow(2));
        if ext == ".slx" || ext == ".mdl"
            changeType = splitRow(1);
            diffData(end+1).ChangeType = changeType;
            if changeType == "A"
                diffData(end).Left = "emptyModel.slx";
                diffData(end).Right = splitRow(2);
            elseif changeType == "D"
                % Need to implement
            else
                % Need to implement
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

filesToZip = [[diffData.Left], [diffData.Right], "diffData.mat", "summarizeDiffs.m"];
filesToZip = unique(filesToZip, 'stable');
zip('modifiedModels.zip', filesToZip);

clear