% demo 1 : Basic usage

rng(31)
rX = @()[normrnd(rand*20, rand*5 + 1, 1, 50), normrnd(rand*20, rand*5 + 1, 1, 50)];
% Generate 9 datasets with random bimodal distributions
Data = {rX(), rX(), rX(), rX(), rX(), rX(), rX(), rX(), rX()};
% save demoData.mat Data
% Data =
% 1×9 cell array
% {1×100 double} {1×100 double} {1×100 double} {1×100 double} {1×100 double} 
% {1×100 double} {1×100 double} {1×100 double} {1×100 double}


%% Basic usage
figure()
% Create joyplot object and draw.
JP = joyPlot(Data, 'ColorMode','Order');
JP = JP.draw();

% Create handles for legend and display.
lgdHdl = JP.getLegendHdl();
legend(lgdHdl)


%% Change color
figure()
% Create joyplot object, change color and draw.
JP = joyPlot(Data, 'ColorMode','Order');
JP.ColorList = [.88 .57 .26; 1.0 .66 0.0; .83 .43 .06;
                .29 .64 .61; .41 .72 .98; .34 .63 .97;
                .29 .56 .96; .35 .49 .79; .41 .42 .62];
JP = JP.draw();

% Create handles for legend and display.
lgdHdl = JP.getLegendHdl();
legend(lgdHdl)


%% larger ridge separation
figure()
% Create joyplot object with larger ridge separation and draw.
JP = joyPlot(Data, 'ColorMode','Order', 'Sep', 1/5);
JP = JP.draw();

% Create handles for legend and display.
lgdHdl = JP.getLegendHdl();
legend(lgdHdl)