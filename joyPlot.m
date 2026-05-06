classdef joyPlot < handle
% =========================================================================
% Basic usage
% -------------------------------------------------------------------------
% The input Data is expected to be in the following format: 
% Data = {X1, X2, X3, ...}
% -------------------------------------------------------------------------
%   % Create joyplot object and draw.
%   JP = joyPlot(Data, 'ColorMode','Order');
%   JP = JP.draw();
% 
%   % Create handles for legend and display.
%   lgdHdl = JP.getLegendHdl();
%   legend(lgdHdl)
%
% =========================================================================
% ColorMode Options
% -------------------------------------------------------------------------
% + 'Order'    - Uniform color per ridge (cycles through color list)
% + 'X'        - Gradient based on X position within each ridge (local)
% + 'GlobalX'  - Gradient based on global X position across all ridges
% + 'Kdensity' - Gradient based on kernel density height (Y value)
% + 'Qt'       - Discrete colors based on quantile intervals
% =========================================================================
% Zhaoxu Liu / slandarer (2026). joyplot 
% (https://www.mathworks.com/matlabcentral/fileexchange/125255-joyplot), 
% MATLAB Central File Exchange. Retrieved April 22, 2026.
% =========================================================================
    properties
        ax
        arginList = {'ColorMode', 'ColorList', 'Sep', 'Scatter', 'MedLine', 'Quantiles', 'QtLine'}
        
        ColorMode = 'Order'   % Coloring mode: 'Order' / 'X' / 'GlobalX' / 'Kdensity' / 'Qt'
        ColorList
        
        % Default color schemes
        defaultColorList1 = [0.37, 0.27, 0.56; 0.11, 0.41, 0.58; 0.21, 0.65, 0.64; 0.05, 0.52, 0.32;
                             0.45, 0.68, 0.28; 0.92, 0.67, 0.03; 0.88, 0.48, 0.01; 0.80, 0.31, 0.24;
                             0.58, 0.20, 0.43; 0.43, 0.25, 0.43];
        
        defaultColorList2 = [0.00, 0.00, 0.01; 0.01, 0.01, 0.07; 0.04, 0.03, 0.13; 0.07, 0.05, 0.20;    
                             0.11, 0.06, 0.28; 0.16, 0.06, 0.36; 0.22, 0.06, 0.42; 0.27, 0.06, 0.46;    
                             0.32, 0.07, 0.48; 0.37, 0.09, 0.50; 0.42, 0.11, 0.50; 0.47, 0.13, 0.50;    
                             0.52, 0.15, 0.50; 0.58, 0.17, 0.50; 0.63, 0.18, 0.49; 0.68, 0.20, 0.48;    
                             0.73, 0.22, 0.46; 0.79, 0.24, 0.44; 0.84, 0.26, 0.42; 0.88, 0.30, 0.39;    
                             0.92, 0.34, 0.37; 0.95, 0.39, 0.36; 0.97, 0.45, 0.36; 0.98, 0.51, 0.37;    
                             0.99, 0.57, 0.40; 0.99, 0.63, 0.43; 0.99, 0.69, 0.47; 0.99, 0.75, 0.52;    
                             0.99, 0.81, 0.57; 0.99, 0.87, 0.63; 0.98, 0.93, 0.68; 0.98, 0.99, 0.74];
        
        defaultColorList3 = [0.99, 0.60, 0.60; 0.86, 0.86, 0.86; 0.60, 0.60, 0.99];
        
        Sep        = 1 / 16;      % Distance between adjacent ridges
        Scatter    = 'off';      % Whether to draw vertical scatter points
        MedLine    = 'off';      % Whether to draw median lines
        QtLine     = 'off';      % Whether to draw quantile lines
        Quantiles  = [0.25, 0.75]  % Quantile values (default: 25th and 75th percentiles)
        
        QtX, QtY                 % Quantile X and Y coordinates
        ridgeNum, Data           % Number of ridges and input data
        minX, maxX, maxY         % Data range limits
        XiSet, FSet              % X and density values for each ridge
        
        % Graphics handles
        ridgePatchHdl, ridgeLineHdl
        medLineHdl, scatterHdl
        QtLineHdl, QtLegendHdl
    end

    methods
        function obj = joyPlot(Data, varargin)
            obj.Data = Data;
            obj.ridgeNum = length(obj.Data);

            % Display author information
            % disp(char([64, 97, 117, 116, 104, 111, 114, 32, 58, 32, ...
            %            115, 108, 97, 110, 100, 97, 114, 101, 114]))
            
            % Parse input parameters
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end
            
            % Validate ColorMode
            if isempty(intersect(obj.ColorMode, {'Order', 'X', 'GlobalX', 'Kdensity', 'Qt'}))
                error('The ColorMode should be one of the following: Order \ X \ GlobalX \ Kdensity \ Qt')
            end
            
            % Set default color list based on ColorMode
            switch obj.ColorMode
                case 'Order'
                    obj.ColorList = obj.defaultColorList1;
                case {'X', 'GlobalX', 'Kdensity'}
                    obj.ColorList = obj.defaultColorList2;
                case 'Qt'
                    obj.ColorList = obj.defaultColorList3;
            end
            
            % Re-parse to override defaults with user-specified parameters
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(obj.arginList, varargin{i});
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end
            
            % Calculate global X range across all ridges
            obj.minX = min(obj.Data{1});
            obj.maxX = max(obj.Data{1});
            for i = 1:obj.ridgeNum
                obj.minX = min(obj.minX, min(obj.Data{i}));
                obj.maxX = max(obj.maxX, max(obj.Data{i}));
            end
        end
        
        function obj = draw(obj)
            obj.ax = gca;
            hold on;
            
            % Axes basic settings
            obj.ax.LineWidth = 1;
            obj.ax.YTick = (1:obj.ridgeNum) .* obj.Sep;
            obj.ax.FontName = 'Cambria';
            obj.ax.FontSize = 13;
            obj.ax.YGrid = 'on';
            % obj.ax.Box = 'on';
            obj.ax.TickDir = 'out';
            
            % Set Y-axis labels
            tYLabel{obj.ridgeNum} = '';
            for i = 1:obj.ridgeNum
                tYLabel{i} = ['Class-', num2str(i)];
            end
            obj.ax.YTickLabel = tYLabel;

            % Adjust initial figure size
            fig = obj.ax.Parent;
            fig.Color = [1, 1, 1];
            if max(fig.Position(3:4)) < 690
                fig.Position(3:4) = 1.2 .* fig.Position(3:4);
                fig.Position(1:2) = fig.Position(1:2) ./ 2;
            end

            % Calculate global X and Y ranges for density estimation
            obj.minX = min(obj.Data{1});
            obj.maxX = max(obj.Data{1});
            obj.maxY = 0;
            for i = 1:obj.ridgeNum
                tX = obj.Data{i};
                tX = tX(:)';
                [F, Xi] = ksdensity(tX);
                obj.minX = min(obj.minX, min(Xi));
                obj.maxX = max(obj.maxX, max(Xi));
                obj.maxY = max(obj.maxY, max(F));
            end
            
            % Draw each ridge (from bottom to top)
            for i = obj.ridgeNum:-1:1
                tX = obj.Data{i};
                tX = tX(:)';
                [F, Xi] = ksdensity(tX);
                
                % Interpolate density values to uniform grid
                OXi = Xi;
                Xi = linspace(min(Xi), max(Xi), 1000);
                F  = interp1(OXi, F, Xi);
                obj.XiSet{i} = Xi;
                obj.FSet{i} = F;
                
                % Draw vertical scatter points (jittered lines)
                tXX = [tX; tX; tX .* nan];
                tYY = [tX .* 0 + obj.Sep .* i - obj.Sep ./ 10; ...
                       tX .* 0 + obj.Sep .* i - obj.Sep ./ 2.5; ...
                       tX .* nan];
                if isequal(obj.ColorMode, 'Order')
                    obj.scatterHdl(i) = plot(tXX(:), tYY(:), 'Color', [obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :), 0.5], ...
                                              'LineWidth', 0.8, 'Visible', 'off');
                else
                    obj.scatterHdl(i) = plot(tXX(:), tYY(:), 'Color', [0, 0, 0, 0.5], ...
                                              'LineWidth', 0.8, 'Visible', 'off');
                end
                if isequal(obj.Scatter, 'on')
                    set(obj.scatterHdl(i), 'Visible', 'on');
                end
                
                % Calculate quantile positions
                for j = 1:length(obj.Quantiles)
                    obj.QtX(i, j + 1) = quantile(tX, obj.Quantiles(j));
                    obj.QtY(i, j)     = interp1(Xi, F, quantile(tX, obj.Quantiles(j)));
                end
                obj.QtX(i, 1) = min(Xi) - inf;
                obj.QtX(i, length(obj.Quantiles) + 2) = max(Xi) + inf;
                
                % Draw ridge patch and line based on ColorMode
                switch obj.ColorMode
                    case 'Order'
                        % Uniform color per ridge (cycled through color list)
                        obj.ridgePatchHdl(i) = fill([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :), ...
                            'EdgeColor', 'none', 'FaceAlpha', 0.5);
                        obj.ridgeLineHdl(i) = plot([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            'Color', obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :), 'LineWidth', 0.8);
                        colormap(obj.ColorList);
                        try caxis([1, obj.ridgeNum]); catch; end
                        try clim([1, obj.ridgeNum]); catch; end
                        
                    case 'X'
                        % Color based on X position within each ridge (normalized to [0,1])
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)] - min(Xi);
                        tTi = tTi ./ max(tTi);
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        obj.ridgePatchHdl(i) = fill([Xi(1), Xi, Xi(end), Xi(end:-1:1)], ...
                            [0, F, 0, F .* 0] + obj.Sep .* i, tC, ...
                            'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', 'interp');
                        obj.ridgeLineHdl(i) = plot([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            'Color', [0, 0, 0, 0.9], 'LineWidth', 0.8);
                        colormap(obj.ColorList);
                        try caxis([-1, 1]); catch; end
                        try clim([-1, 1]); catch; end
                        
                    case 'GlobalX'
                        % Color based on global X position across all ridges
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)] - obj.minX;
                        tTi = tTi ./ (obj.maxX - obj.minX);
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        obj.ridgePatchHdl(i) = fill([Xi(1), Xi, Xi(end), Xi(end:-1:1)], ...
                            [0, F, 0, F .* 0] + obj.Sep .* i, tC, ...
                            'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', 'interp');
                        obj.ridgeLineHdl(i) = plot([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            'Color', [0, 0, 0, 0.9], 'LineWidth', 0.8);
                        colormap(obj.ColorList);
                        try caxis([obj.minX, obj.maxX]); catch; end
                        try clim([obj.minX, obj.maxX]); catch; end
                        
                    case 'Kdensity'
                        % Color based on kernel density value (height)
                        tTi = [0, F, 0, F(end:-1:1)];
                        tTi = tTi ./ obj.maxY;
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        obj.ridgePatchHdl(i) = fill([Xi(1), Xi, Xi(end), Xi(end:-1:1)], ...
                            [0, F, 0, F .* 0] + obj.Sep .* i, tC, ...
                            'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', 'interp');
                        obj.ridgeLineHdl(i) = plot([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            'Color', [0, 0, 0, 0.9], 'LineWidth', 0.8);
                        colormap(obj.ColorList);
                        try caxis([0, obj.maxY]); catch; end
                        try clim([0, obj.maxY]); catch; end
                        
                    case 'Qt'
                        % Color based on quantile intervals
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)];
                        tR = tTi .* 0;
                        tG = tTi .* 0;
                        tB = tTi .* 0;
                        for j = 1:size(obj.QtX, 2) - 1
                            idx = tTi >= obj.QtX(i, j) & tTi < obj.QtX(i, j + 1);
                            tR(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 1);
                            tG(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 2);
                            tB(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 3);
                        end
                        tC = cat(3, tR, tG, tB);
                        obj.ridgePatchHdl(i) = fill([Xi(1), Xi, Xi(end), Xi(end:-1:1)], ...
                            [0, F, 0, F .* 0] + obj.Sep .* i, tC, ...
                            'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', 'interp');
                        obj.ridgeLineHdl(i) = plot([Xi(1), Xi, Xi(end)], [0, F, 0] + obj.Sep .* i, ...
                            'Color', [0, 0, 0, 0.9], 'LineWidth', 0.8);
                        colormap(obj.ColorList);
                        try caxis([-1, 1]); catch; end
                        try clim([-1, 1]); catch; end
                end
                
                % Draw median line
                tMedX = median(tX);
                tMedY = interp1(Xi, F, tMedX);
                obj.medLineHdl(i) = plot([tMedX, tMedX], [0, tMedY] + obj.Sep .* [i, i], ...
                    'LineStyle', '--', 'LineWidth', 1, 'Color', [0, 0, 0], 'Visible', 'off');
                if isequal(obj.MedLine, 'on')
                    set(obj.medLineHdl(i), 'Visible', 'on');
                end
                
                % Draw quantile lines
                tQtY = [obj.QtY(i, :); obj.QtY(i, :) .* 0; obj.QtY(i, :) .* nan] + obj.Sep .* i;
                tQtX = [obj.QtX(i, 2:end-1); obj.QtX(i, 2:end-1); obj.QtX(i, 2:end-1) .* nan];
                obj.QtLineHdl(i) = plot(tQtX(:), tQtY(:), 'LineWidth', 1, 'Color', [0, 0, 0, 0.8], 'Visible', 'off');
                if isequal(obj.QtLine, 'on')
                    set(obj.QtLineHdl(i), 'Visible', 'on');
                end
            end
            
            % Final axis adjustments
            axis tight
            obj.ax.YLim(1) = obj.Sep / 2;
            
            % Create dummy legend handles for quantile mode
            for i = 1:size(obj.QtX, 2) - 1
                obj.QtLegendHdl(i) = fill(mean(obj.ax.XLim) .* [1, 1, 1, 1], ...
                                           mean(obj.ax.YLim) .* [1, 1, 1, 1], ...
                                           obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :), ...
                                           'EdgeColor', 'none', 'FaceAlpha', 0.9);
            end
        end
        
        % Get legend handle
        function legendHdl = getLegendHdl(obj)
            if isequal(obj.ColorMode, 'Qt')
                legendHdl = obj.QtLegendHdl;
            else
                legendHdl = obj.ridgePatchHdl;
            end
        end
        
        % Recolor all ridges with new color list
        function obj = setPatchColor(obj, ColorList)
            obj.ColorList = ColorList;
            colormap(obj.ColorList);
            
            for i = obj.ridgeNum:-1:1
                Xi = obj.XiSet{i};
                F  = obj.FSet{i};
                
                switch obj.ColorMode
                    case 'Order'
                        set(obj.ridgePatchHdl(i), 'FaceColor', obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :));
                        
                    case 'X'
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)] - min(Xi);
                        tTi = tTi ./ max(tTi);
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        set(obj.ridgePatchHdl(i), 'CData', tC);
                        
                    case 'GlobalX'
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)] - obj.minX;
                        tTi = tTi ./ (obj.maxX - obj.minX);
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        set(obj.ridgePatchHdl(i), 'CData', tC);
                        
                    case 'Kdensity'
                        tTi = [0, F, 0, F(end:-1:1)];
                        tTi = tTi ./ obj.maxY;
                        tT  = linspace(0, 1, size(obj.ColorList, 1));
                        tC  = cat(3, interp1(tT, obj.ColorList(:, 1), tTi), ...
                                     interp1(tT, obj.ColorList(:, 2), tTi), ...
                                     interp1(tT, obj.ColorList(:, 3), tTi));
                        set(obj.ridgePatchHdl(i), 'CData', tC);
                        
                    case 'Qt'
                        tTi = [Xi(1), Xi, Xi(end), Xi(end:-1:1)];
                        tR = tTi .* 0;
                        tG = tTi .* 0;
                        tB = tTi .* 0;
                        for j = 1:size(obj.QtX, 2) - 1
                            idx = tTi >= obj.QtX(i, j) & tTi < obj.QtX(i, j + 1);
                            tR(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 1);
                            tG(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 2);
                            tB(idx) = obj.ColorList(mod(j - 1, size(obj.ColorList, 1)) + 1, 3);
                        end
                        tC = cat(3, tR, tG, tB);
                        set(obj.ridgePatchHdl(i), 'CData', tC);
                end
            end
            
            % Update legend colors
            for i = 1:size(obj.QtX, 2) - 1
                set(obj.QtLegendHdl(i), 'FaceColor', obj.ColorList(mod(i - 1, size(obj.ColorList, 1)) + 1, :));
            end
        end
        
        % Set properties for ridge patches and lines
        function setRidgePatch(obj, n, varargin)
            set(obj.ridgePatchHdl(n), varargin{:})
        end
        
        function setRidgeLine(obj, n, varargin)
            set(obj.ridgeLineHdl(n), varargin{:})
        end
        
        % Set properties for quantile and median lines
        function setMedLine(obj, n, varargin)
            set(obj.medLineHdl(n), varargin{:})
        end
        
        function setQtLine(obj, n, varargin)
            set(obj.QtLineHdl(n), varargin{:})
        end
        
        % Set properties for scatter points
        function setScatter(obj, n, varargin)
            set(obj.scatterHdl(n), varargin{:})
        end
    end
end