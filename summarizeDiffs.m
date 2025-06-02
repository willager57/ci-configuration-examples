load("diffData.mat");

[selectedIdx, ok] = listdlg( ...
    'PromptString', 'Choose which models to generate diffs for', ...
    'SelectionMode', 'multiple', ...
    'ListString', [diffData.Summary]);

for model = diffData(selectedIdx)
    if model.ChangeType == "A"
        visdiff(model.Left, model.Right);
    elseif model.ChangeType == "D"
        % Need to implement
    else
        % Need to implement
    end
end