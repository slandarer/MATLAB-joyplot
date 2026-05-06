% demo 2 : ColorMode : 'X' and 'GlobalX', with midline
Data = load("demoData.mat");
Data = Data.Data;


%% ColorMode : 'X'
figure()
% Create joyplot object with 'X' ColorMode and median line.
JP = joyPlot(Data, 'ColorMode','X', 'MedLine','on');
% JP.ColorList = pink(20); % Change colormap.
JP.draw();
colorbar()


%% ColorMode : 'GlobalX
figure()
% Create joyplot object with 'GlobalX' ColorMode and median line.
JP = joyPlot(Data, 'ColorMode','GlobalX', 'MedLine','on');
% JP.ColorList = pink(20); % Change colormap.
JP.draw();
colorbar()

