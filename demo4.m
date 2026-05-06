% demo 4 : ColorMode : 'Qt' with custom quantile boundaries 
Data = load("demoData.mat");
Data = Data.Data;

%% demo 4 - 1 : Quantile coloring with 3 intervals (IQR: 25%-75%)
figure()
JP = joyPlot(Data, 'ColorMode','Qt', 'MedLine','on', 'Quantiles',[.25,.75], 'QtLine','on');
JP = JP.draw();

% Create handles for legend and display.
lgdHdl = JP.getLegendHdl();
legend(lgdHdl, {'Low', 'Mid', 'High'})



%% demo 4 - 2 : Quantile coloring with 5 intervals (10%, 25%, 75%, 90%)
figure()
JP = joyPlot(Data, 'ColorMode','Qt', 'MedLine','on', 'Quantiles',[.1,.25,.75,.9], 'QtLine','on');
JP = JP.draw();

% Create handles for legend and display.
lgdHdl = JP.getLegendHdl();
legend(lgdHdl, {'0~0.1','0.1~0.25','0.25~0.75','0.75~0.9','0.9~1'})

% Change colors/colormap.
JP.setPatchColor(bone(6));
% JP.setPatchColor(turbo(6));