% demo 6 : Two groups of joyplot drawn in the same axes for comparison.
Data = load("demoData2.mat");
Data1 = Data.Data1;
Data2 = Data.Data2;


%% Plot Group 1 and Group 2
JP1 = joyPlot(Data1, 'ColorMode','Order', 'ColorList',[12,165,154]./255, 'MedLine','on', 'Scatter','on');
JP1 = JP1.draw();

JP2 = joyPlot(Data2, 'ColorMode','Order', 'ColorList',[151,220,71]./255, 'MedLine','on', 'Scatter','on');
JP2 = JP2.draw();


%% Change the colors of medlines.
for i = 1:length(Data1)
    JP1.setMedLine(i, 'Color',[12,165,154]./255)
end
for i = 1:length(Data2)
    JP2.setMedLine(i, 'Color',[151,220,71]./255)
end


%% Get legend handles (one dummy patch per group) and show legend.
lgdHdl1 = JP1.getLegendHdl();
lgdHdl2 = JP2.getLegendHdl();
legend([lgdHdl1(1), lgdHdl2(1)], {'AAAAA', 'BBBBB'})