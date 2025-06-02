load("diffData.mat");

[selectedIdx, ok] = listdlg( ...
    'PromptString', 'Choose which models to generate diffs for', ...
    'SelectionMode', 'multiple', ...
    'ListString', [diffData.FileName]);

for model = diffData(selectedIdx)
    if model.ChangeType == "A"
        visdiff(model.Left, model.Right);
    elseif model.ChangeType == "D"
        % This doesn't work either - oopsie!
    else
        % Don't know how to handle this yet!
    end
end