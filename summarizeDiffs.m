load("diffData.mat");

[selectedIdx, ok] = listdlg( ...
    'PromptString', 'Choose which models to generate diffs for', ...
    'SelectionMode', 'multiple', ...
    'ListString', [diffData.Summary]);

for model = diffData(selectedIdx)
    visdiff(model.Left, model.Right);
end