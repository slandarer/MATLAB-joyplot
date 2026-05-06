% demo 5 : Properties seting
Data = load("demoData.mat");
Data = Data.Data;

JP = joyPlot(Data, 'MedLine','on', 'Quantiles',[.1,.9], 'QtLine','on', 'Scatter','on');
JP = JP.draw();

% Customize appearance for each ridge.
for i = 1:length(Data)
    JP.setRidgePatch(i, 'FaceColor', [0.8, 0.8, 1], 'FaceAlpha', 0.9)            
    JP.setRidgeLine(i, 'LineWidth', 2, 'Color', [0.4, 0.4, 1])                   
    JP.setScatter(i, 'Color', [0.8, 0.8, 1, 0.7])                                
    JP.setMedLine(i, 'Color', [0.4, 0.4, 1], 'LineWidth', 5, 'LineStyle', '-')   
    JP.setQtLine(i, 'Color', [0.4, 0.4, 1])                                      
end