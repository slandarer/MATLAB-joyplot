% demo 3 : ColorMode : 'Kdensity' with midline and vertical scatter points(rug)
Data = load("demoData.mat");
Data = Data.Data;

% Create joyplot object with 'Kdensity' ColorMode and vertical scatter points.
JP = joyPlot(Data, 'ColorMode','Kdensity', 'Scatter','on');
JP = JP.draw();

colorbar()

% Another way of changing colors/colormap.
JP.setPatchColor(pink);