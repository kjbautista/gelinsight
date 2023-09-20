classdef GelInsight < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        ImageProcessingTab              matlab.ui.container.Tab
        GridLayout                      matlab.ui.container.GridLayout
        SelectNewRegionButton           matlab.ui.control.Button
        CurrentFile                     matlab.ui.control.EditField
        ConfirmRegionButton             matlab.ui.control.Button
        SelectRegionCommand             matlab.ui.control.Label
        LoadImageButton                 matlab.ui.control.Button
        MoveLineInstructions            matlab.ui.control.Label
        ParametersPanel                 matlab.ui.container.Panel
        GridLayout3                     matlab.ui.container.GridLayout
        ResetLaneLadderDetectionButton  matlab.ui.control.Button
        LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel  matlab.ui.control.Label
        LadderValuesInput               matlab.ui.control.EditField
        DetectLanesButton               matlab.ui.control.Button
        SmoothingFactorInput            matlab.ui.control.Spinner
        SmoothingfactorSpinnerLabel     matlab.ui.control.Label
        TargetFragmentSizeRangePanel    matlab.ui.container.Panel
        GridLayout4                     matlab.ui.container.GridLayout
        UpperLimitbpLabel_2             matlab.ui.control.Label
        BandPercHighLimInput            matlab.ui.control.NumericEditField
        BandPercLowLimInput             matlab.ui.control.NumericEditField
        LowerlimitbpEditFieldLabel_2    matlab.ui.control.Label
        DetectLadderButton              matlab.ui.control.Button
        LadderpositionLabel             matlab.ui.control.Label
        LadderPosInput                  matlab.ui.control.Spinner
        NumLanesInput                   matlab.ui.control.Spinner
        NumberoflanesincludingladderLabel  matlab.ui.control.Label
        AnalyzeButton                   matlab.ui.control.Button
        ROI                             matlab.ui.control.UIAxes
        Image                           matlab.ui.control.UIAxes
        ResultsTab                      matlab.ui.container.Tab
        GridLayout2                     matlab.ui.container.GridLayout
        LanePanel                       matlab.ui.container.Panel
        GridLayout10                    matlab.ui.container.GridLayout
        RightButton                     matlab.ui.control.Button
        LeftButton                      matlab.ui.control.Button
        LaneImage                       matlab.ui.control.UIAxes
        BpDistribution                  matlab.ui.control.UIAxes
        Panel_4                         matlab.ui.container.Panel
        GridLayout9                     matlab.ui.container.GridLayout
        BandPercPlot                    matlab.ui.control.UIAxes
        Panel_3                         matlab.ui.container.Panel
        GridLayout8                     matlab.ui.container.GridLayout
        UpperLimitbpLabel               matlab.ui.control.Label
        WfBpHighLimInput                matlab.ui.control.NumericEditField
        LowerlimitbpEditFieldLabel      matlab.ui.control.Label
        WfBpLowLimInput                 matlab.ui.control.NumericEditField
        WaterfallPlot                   matlab.ui.control.UIAxes
        Panel                           matlab.ui.container.Panel
        GridLayout6                     matlab.ui.container.GridLayout
        ExportButton                    matlab.ui.control.Button
        SaveWFPlotCheck                 matlab.ui.control.CheckBox
        SaveBandPercCheck               matlab.ui.control.CheckBox
        SavePeaksCheck                  matlab.ui.control.CheckBox
        SaveRawIntCheck                 matlab.ui.control.CheckBox
        DataTable                       matlab.ui.control.Table
        NormalizeSwitch                 matlab.ui.control.Switch
        NormalizeSwitchLabel            matlab.ui.control.Label
    end

    
    properties (Access = private)
        % Declare properties:
        
        % User defined parameters
        LadderBp % base pairs in ladder
        BandPercRange % desired bp range for band fraction
        LaneNum % number of lanes
        LadderPos % position of ladder lane relative to all lanes
        
        % Base pair axes
        BpInd
        BpVal
        BpVal_log
        BpVal_im
        
        % Image arrays
        RawIm
        Im
        CeIm
        ImROI
        LadderIm
        LaneIm
        ExternalFig
        
        % Lane edge detection
        Edges
        LeftLaneEdges
        RightLaneEdges
        
        % Ladder detection
        LadderLines
        LaneSelect = 1;
        
        % Data arrays
        RawData
        NormRawData
        SmData
        NormSmData
        BandPercentage 
        BpPeaks 
        BpArea
        PlotRawData
        PlotSmData
        TData
        
        % Files
        FileName
        FilePath
        SavePath
    end
    
    methods (Access = private)
        
        function LoadDefaults(app)
            % load default parameters
            if isdeployed
                Defaults = readstruct(fullfile(ctfroot,"defaults.xml"));
            else
                Defaults = readstruct("defaults.xml");
            end
            app.NumLanesInput.Value = Defaults.NumberOfLanes;
            app.LadderPosInput.Value = Defaults.LadderPosition;
            app.LadderValuesInput.Value = Defaults.LadderValues;
            app.BandPercLowLimInput.Value = Defaults.BandPercentageLowLim;
            app.BandPercHighLimInput.Value = Defaults.BandPercentageHighLim;
            app.SmoothingFactorInput.Value = Defaults.SmoothingFactor;
            app.WfBpLowLimInput.Value = Defaults.WFPlotLowLim;
            app.WfBpHighLimInput.Value = Defaults.WFPlotHighLim;
            app.SavePeaksCheck.Value = strcmp(Defaults.Save.PksAndRelArea,"true");
            app.SaveBandPercCheck.Value = strcmp(Defaults.Save.BandPercentage,"true");
            app.SaveWFPlotCheck.Value = strcmp(Defaults.Save.WFPlot,"true");
            app.SaveRawIntCheck.Value = strcmp(Defaults.Save.RawIntensity,"true");
        end
        
        function Param = ReadParameters(app)
            % read current parameters
            Param.NumberOfLanes = app.NumLanesInput.Value;
            Param.LadderPosition = app.LadderPosInput.Value;
            Param.LadderValues = string(app.LadderValuesInput.Value);
            Param.BandPercentageLowLim = app.BandPercLowLimInput.Value;
            Param.BandPercentageHighLim = app.BandPercHighLimInput.Value;
            Param.SmoothingFactor = app.SmoothingFactorInput.Value;
            Param.WFPlotLowLim = app.WfBpLowLimInput.Value;
            Param.WFPlotHighLim = app.WfBpHighLimInput.Value;
            Param.Save.PksAndRelArea = string(app.SavePeaksCheck.Value);
            Param.Save.BandPercentage = string(app.SaveBandPercCheck.Value);
            Param.Save.WFPlot = string(app.SaveWFPlotCheck.Value);
            Param.Save.RawIntensity = string(app.SaveRawIntCheck.Value);
        end
        
        function SaveDefaults(app)
            % save current parameters as default
            Defaults = ReadParameters(app);
            if isdeployed
                writestruct(Defaults,fullfile(ctfroot,"defaults.xml"))
            else
                writestruct(Defaults,"defaults.xml")
            end
        end
        
        function ClearVals(app)
            % clear base pair axes
            app.BpInd = []; app.BpVal = []; 
            app.BpVal_log = []; app.BpVal_im = [];  

            % restart lane selection to 1 and reset buttons
            app.LaneSelect = 1; 
            app.LeftButton.Enable = 'off';
            app.RightButton.Enable = 'on';
 
            % clear data arrays
            app.RawData = []; app.NormRawData = [];
            app.SmData = []; app.NormSmData = [];
            app.BandPercentage = []; 
            app.BpPeaks = []; app.BpArea = [];
            app.PlotRawData = []; app.PlotSmData = [];
            app.TData = [];
        end
        
        function ClearPlots(app)
            % clear plots
            cla(app.ROI)
            cla(app.LaneImage)
            cla(app.BpDistribution)
            cla(app.BandPercPlot)
            cla(app.WaterfallPlot)
            
            % clear image arrays
            app.Im = []; app.LadderIm = []; app.LaneIm = {}; app.CeIm = []; 
            
            % clear lane and ladder edge arrays
            app.Edges = {}; app.LeftLaneEdges = []; app.RightLaneEdges = [];
            app.LadderLines = {};
        end

        function PreviewImage(app)
            % get roi coordinates
            ROIPos = app.ImROI.Position;
            yCoords = round(ROIPos(1): ROIPos(1)+ROIPos(3));
            xCoords = round(ROIPos(2): ROIPos(2)+ROIPos(4));
            app.Im = app.RawIm(xCoords,yCoords);
            
            % show preview of roi
            imagesc(app.ROI,app.Im)
            colormap(app.ROI,"gray")
            axis(app.ROI,"image")
            title(app.ROI,"Region of Interest Preview")
        end
        
        function PlotLaneData(app)
            % check for normalization - select data to plot accordingly
            if contains(app.NormalizeSwitch.Value,'On')
                app.PlotRawData = app.NormRawData;
                app.PlotSmData = app.NormSmData;
            else 
                app.PlotRawData = app.RawData;
                app.PlotSmData = app.SmData;
            end
            % find max value across all data
            max_val = max([max(app.PlotRawData,[],'all'),max(app.PlotSmData,[],'all')]);
            
            % display lane image against ladder
            ladderlaneim = [app.LadderIm,imadjust(app.LaneIm{app.LaneSelect})];
            ticks = interp1(app.BpVal_log,1:length(app.BpVal_log),app.LadderBp,'nearest');
            imagesc(app.LaneImage, ...
                1:size(ladderlaneim,2),fliplr(1:size(ladderlaneim,1)),ladderlaneim);
            set(app.LaneImage,'YDir',"normal")
            yticks(app.LaneImage,sort(ticks(1:2:end)))
            yticklabels(app.LaneImage,sort(app.LadderBp(1:2:end)))
            axis(app.LaneImage,"normal")
            axis(app.LaneImage,"padded")
            colormap(app.LaneImage,"gray")
            xlabel(app.LaneImage,['Lane ',num2str(app.LaneSelect)],'FontWeight',"bold")
            
            % plot base pair intensity distribution 
            areaInd = app.BpVal >= app.BandPercRange(1) & app.BpVal <= app.BandPercRange(2);
            area(app.BpDistribution,app.BpVal(areaInd),app.PlotSmData(areaInd,app.LaneSelect),... % shade band percentage range
                'FaceColor',[187 204 238]./255,...
                'EdgeColor',[1 1 1])
            set(app.BpDistribution,'Xscale','log') % set base pair axis to log scale
            hold(app.BpDistribution,'on')
            plot(app.BpDistribution,app.BpVal,app.PlotRawData(:,app.LaneSelect),... % plot raw data
                'LineWidth',5,...
                'Color',[0.85 0.85 0.85])
            plot(app.BpDistribution,app.BpVal,app.PlotSmData(:,app.LaneSelect),... % plot smoothed data
                'LineWidth',2,...
                'Color',[102 153 204]./255)
            for jj = 1:length(app.BpPeaks(app.LaneSelect,:))
                xline(app.BpDistribution,app.BpPeaks(app.LaneSelect,jj),'-',[num2str(round(app.BpPeaks(app.LaneSelect,jj))),' bp'],... % identify peaks
                    'LabelVerticalAlignment','middle',...
                    'LabelHorizontalAlignment','center',...
                    'Color','k',...
                    'FontWeight','bold',...
                    'Alpha',1)
            end
            xticks(app.BpDistribution,sort(app.LadderBp(1:2:end)))
            xtickangle(app.BpDistribution,90)
            axis(app.BpDistribution,"normal")
            app.BpDistribution.YLim = [0,max_val];
            app.BpDistribution.XLim = round([app.LadderBp(end).*0.5,app.BpVal(end)]);
            legend(app.BpDistribution,'Target BP Range','Raw Data','Smoothed Data','Location',"NorthOutside",'Orientation',"Horizontal")
            hold(app.BpDistribution,'off')
        end
        
        function PlotWaterfall(app)
            % check for normalization - select data to plot accordingly
            if contains(app.NormalizeSwitch.Value,'On')
                wfPlotData = app.NormSmData;
            else 
                wfPlotData = app.SmData;
            end
            
            % plot waterfall distribution of base pair intensities over all the lanes
            w = waterfall(app.WaterfallPlot,app.BpVal,1:app.NumLanesInput.Value-1,wfPlotData');
            w.LineWidth = 1.5;
            view(app.WaterfallPlot,45,35) % set view
            app.WaterfallPlot.YTick = 1:round((app.NumLanesInput.Value-1)/5):app.NumLanesInput.Value;
            app.WaterfallPlot.XTick = round(app.WfBpLowLimInput.Value,-2):...
                round((app.WfBpHighLimInput.Value-app.WfBpLowLimInput.Value)/10,-2):...
                round(app.WfBpHighLimInput.Value,-2);
            app.WaterfallPlot.XLim = [app.WfBpLowLimInput.Value app.WfBpHighLimInput.Value];
        end
        
        function PlotBarGraph(app)
            % plot band percentage bar graph
            b = bar(app.BandPercPlot,app.BandPercentage,0.8,...
                'FaceColor',[187 204 238]./255,...
                'EdgeColor',[187 204 238]./255);
            ylim(app.BandPercPlot,[0,100])
            xlim(app.BandPercPlot,[0,app.NumLanesInput.Value])
            xticks(app.BandPercPlot,1:round((app.NumLanesInput.Value-1)/5):app.NumLanesInput.Value-1)
            colLabels = {};
            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            
            % annotate each bar with percentage value
            for ii = 1:app.NumLanesInput.Value-1
                colLabels{ii} = num2str(ii);
                text(app.BandPercPlot,xtips(ii),5,num2str(app.BandPercentage(ii),'%2.2f'),...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle',...
                    'Rotation',90)
            end
            xticklabels(app.BandPercPlot,colLabels(1:round((app.NumLanesInput.Value-1)/5):app.NumLanesInput.Value-1))
        end
        
        function UpdateTable(app)
            removeStyle(app.DataTable) % remove formatting from table, if any
            varNames = {'Lane'}; % variable names for table
            for ii = 1:size(app.BpPeaks,2)
                varNames = vertcat(varNames,{['Peak ',num2str(ii),' (bp)']},{['Rel. Area ',num2str(ii),' (%)']}); %#ok<AGROW> 
            end
            app.TData = table((1:app.NumLanesInput.Value-1)'); % create table for storing data
            count = 2;
            ind = zeros(size(app.BpPeaks,1),1); 
            for ii = 1:size(app.BpPeaks,2) % iterate through adding peaks and relative area to table
                temp = num2cell(app.BpPeaks(:,ii));
                temp(cellfun(@isnan,temp)) = {0};
                ind = horzcat(ind,cellfun(@(x) x == 0,temp));
                app.TData(:,count) = table(app.BpPeaks(:,ii));
                count = count + 1;
                
                temp = num2cell(app.BpArea(:,ii));
                temp(cellfun(@isnan,temp)) = {0};
                ind = horzcat(ind,cellfun(@(x) x == 0,temp));
                app.TData(:,count) = table(app.BpArea(:,ii));
                count = count + 1;
            end
            app.DataTable.Data = app.TData; % add to table
            app.DataTable.ColumnName = varNames;
            
            % bold bp peak columns
            boldText = uistyle('FontWeight','bold');
            addStyle(app.DataTable,boldText,'column',2:2:length(varNames))
            
            % gray out zeros
            grayCell = uistyle('BackgroundColor',[0.8, 0.8, 0.8],'FontWeight','normal');
            [rows,vars]=ind2sub(size(ind),find(ind));
            if ~isempty(rows)
                addStyle(app.DataTable,grayCell,'cell',[rows,vars])
            end
            
            % add variable names to TData for export later
            app.TData.Properties.VariableNames = varNames;
        end
        
        function SaveWaterfallPlot(app,exportName)
            if strcmpi(app.NormalizeSwitch.Value,'Off')
                % create a temporary figure with axes
                fig = figure;
                fig.Visible = 'off';
                figAxes = axes(fig);
                
                % plot waterfall data 
                w = waterfall(figAxes,app.BpVal,1:app.NumLanesInput.Value-1,app.SmData');
                w.LineWidth = 2;  
                xlabel(app.WaterfallPlot.XLabel.String)
                xlim([app.WfBpLowLimInput.Value,app.WfBpHighLimInput.Value])
                ylabel(app.WaterfallPlot.YLabel.String)
                zlabel(app.WaterfallPlot.ZLabel.String)
                figAxes.View = app.WaterfallPlot.View;
                
                % save as png file
                saveas(fig, exportName);
                
                % delete the temporary figure.
                delete(fig);
            else 
                % create a temporary figure with axes
                fig = figure;
                fig.Visible = 'off';
                figAxes = axes(fig);
                
                % plot normalized waterfall
                w = waterfall(figAxes,app.BpVal,1:app.NumLanesInput.Value-1,app.NormSmData');
                w.LineWidth = 1.5;  
                xlabel(app.WaterfallPlot.XLabel.String)
                xlim([app.WfBpLowLimInput.Value,app.WfBpHighLimInput.Value])
                ylabel(app.WaterfallPlot.YLabel.String)
                zlabel(app.WaterfallPlot.ZLabel.String)
                figAxes.View = app.WaterfallPlot.View;
    
                % save as png file
                saveas(fig, [exportName(1:end-4) '-norm.png']);
                
                % delete the temporary figure
                delete(fig);
            end
        end  
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            app.UIFigure.Visible = "off";
            movegui(app.UIFigure,"center")
            app.UIFigure.Visible = "on";

            d = uiprogressdlg(app.UIFigure,'Title','Please wait','Message','Starting up...');
            disableDefaultInteractivity(app.Image)
            disableDefaultInteractivity(app.ROI)
            disableDefaultInteractivity(app.BandPercPlot)
            d.Value = 0.3;
            
            try
                % load default user parameters
                app.LoadDefaults;
            catch 
                % if no default values are set, set default values
                app.SaveDefaults;
            end
            d.Value = 0.6;
            
            % User defined parameters
            app.LadderBp = str2double(strsplit(app.LadderValuesInput.Value,',')); % ladder
            app.BandPercRange  = [app.BandPercLowLimInput.Value, app.BandPercHighLimInput.Value]; % desired bp range for band fraction
            app.LaneNum = app.NumLanesInput.Value; % number of lanes
            app.LadderPos = app.LadderPosInput.Value; % position of ladder lane relative to all lanes
            d.Value = 0.9;
            
            pause(2)
            app.UIFigure.WindowState = "maximized";
            pause(2)
            close(d)
            
        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)
            app.ClearVals;
            app.ClearPlots;
            
            % get file for analysis
            [name,path] = uigetfile(...
                {'*.jpg; *.jpeg; *.tif; *.tiff; *.png; *.bmp','Supported Files (*.jpg,*.jpeg,*.tif,*.tiff,*.png,*.bmp)';...
                '*.*',  'All Files (*.*)'}, ...
                'Select image file to analyze.');
            figure(app.UIFigure)
            if path == 0
                uialert(app.UIFigure,'No file selected.','Error')
            return
            end
            app.FileName = name;
            app.FilePath = path;
            
            % display current file
            app.CurrentFile.Value = fullfile(app.FilePath,app.FileName);
            
            % load image
            app.RawIm = imread([app.FilePath,app.FileName]);
            if size(app.RawIm,3) >= 3
                app.RawIm = rgb2gray(app.RawIm(:,:,1:3)); % if rgb, convert to grayscale
            end
            app.RawIm = im2double(app.RawIm);           % convert to double
            
            % check to make sure dark lanes on light background
            if mean(app.RawIm(:)) < 0.5
                app.RawIm = imcomplement(app.RawIm); 
            end 

            % display Image
            imagesc(app.Image,app.RawIm)
            axis(app.Image,'image')
            colormap(app.Image,'gray')
            
            app.SelectNewRegionButton.Enable = 'on';
            app.SelectRegionCommand.Enable = 'off';
            app.ConfirmRegionButton.Enable = 'off';
            app.NumLanesInput.Enable = 'off';
            app.LadderPosInput.Enable = 'off';
            app.DetectLanesButton.Enable = 'off';
            app.LadderValuesInput.Enable = 'off';
            app.DetectLadderButton.Enable = 'off';
            app.MoveLineInstructions.Enable = 'off';
            app.BandPercLowLimInput.Enable = 'off';
            app.BandPercHighLimInput.Enable = 'off';
            app.SmoothingFactorInput.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
        end

        % Button pushed function: SelectNewRegionButton
        function SelectNewRegionButtonPushed(app, event)
            app.ClearVals;
            app.ClearPlots;
            app.SelectRegionCommand.Enable = 'on';
            app.ConfirmRegionButton.Enable = 'off';
            app.NumLanesInput.Enable = 'off';
            app.LadderPosInput.Enable = 'off';
            app.DetectLanesButton.Enable = 'off';
            app.LadderValuesInput.Enable = 'off';
            app.DetectLadderButton.Enable = 'off';
            app.MoveLineInstructions.Enable = 'off';
            app.BandPercLowLimInput.Enable = 'off';
            app.BandPercHighLimInput.Enable = 'off';
            app.SmoothingFactorInput.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
            
            if ~isempty(app.ImROI) % delete existing roi
                delete(app.ImROI);
            end
            
            % enable drawing Region
            app.ImROI = drawrectangle(app.Image);
            addlistener(app.ImROI,'ROIMoved',@(varargin)PreviewImage(app));
            app.PreviewImage; % change preview as Region is adjusted
            addlistener(app.ImROI,'DeletingROI',@(varargin)SelectNewRegionButtonPushed(app))
            
            app.ConfirmRegionButton.Enable = 'on';         
        end

        % Button pushed function: ConfirmRegionButton
        function ConfirmRegionButtonPushed(app, event)
            try
                app.ImROI.InteractionsAllowed = 'none';
                sz = size(app.Im);
                
                % pre-process image to improve visualization
                if sz(1) < 1600
                    app.Im = imresize(app.Im,[1600,1600/sz(1)*sz(2)]);
                end
                app.Im = imcomplement(imfill(imcomplement(app.Im))); % fill holes
                app.Im = wiener2(app.Im); % denoise
                app.CeIm = adapthisteq(app.Im); % adjust contrast 
                
                % display contrast adjusted Region
                imagesc(app.ROI,app.CeIm)
                colormap(app.ROI,"gray")
                title(app.ROI,'Region of Interest')
                
                app.SelectRegionCommand.Enable = 'off';
                app.ConfirmRegionButton.Enable = 'off';
                app.NumLanesInput.Enable = 'on';
                app.LadderPosInput.Enable = 'on';
                app.DetectLanesButton.Enable = 'on';
            catch
                uialert(app.UIFigure,'Please re-select region of interest.','Software error')
            end
        end

        % Value changed function: NumLanesInput
        function NumLanesInputValueChanged(app, event)
            value = app.NumLanesInput.Value;
            app.LaneNum = value;
            app.LadderPosInput.Limits = [1,value];
        end

        % Value changed function: LadderPosInput
        function LadderPosInputValueChanged(app, event)
            value = app.LadderPosInput.Value;
            if value > app.LaneNum || value < 1
                app.LadderPosInput.Value = 1;
                uialert(app.UIFigure,'Ladder number cannot be less than 1 or greater than the number of lanes.','Error')
                return
            else
                app.LadderPos = value;
            end
        end

        % Button pushed function: DetectLanesButton
        function DetectLanesButtonPushed(app, event)
            if ~isempty(app.Edges) % delete any existing lane lines
                for ii = 1:length(app.Edges)
                    delete(app.Edges{ii})
                end
            end
            
            % detect lane edges
            edgeDetection = edge(app.Im,'Canny'); % detect edges in denoised image
            edgeDetection = edge(edgeDetection,'vertical'); % detect only in vertical direction
            edgeDetection = smoothdata(mean(edgeDetection,1)); % smooth and sum to remove noise
            edgeDetection = edgeDetection/max(edgeDetection); % normalize
            
            minPeakDist = round(size(app.Im,2)/(app.LaneNum*2)*0.4); % min peak distance
            [~, locs, ~, ~] = findpeaks(edgeDetection,... % use peak detection to find lane edges
                'MinPeakProminence',.1,...
                'MinPeakDistance',minPeakDist); 
            
            % if too many peaks detected, increase peak distance (max out at 50 iterations)
            iter = 1;
            while length(locs) > app.LaneNum*2 && iter < 50 
                [~, locs, ~, ~] = findpeaks(edgeDetection,...
                'MinPeakProminence',.1,...
                'MinPeakDistance',minPeakDist+iter*1); % increase min peak distance
            iter = iter + 1;
            end
            
            % if too many peaks detected, increase peak prominence (max out at 50 iterations)
            iter = 1;
            while length(locs) > app.LaneNum*2 && iter < 50 
                [~, locs, ~, ~] = findpeaks(edgeDetection,...
                'MinPeakProminence',.1+iter*1,... % increase min peak prominence
                'MinPeakDistance',minPeakDist); 
            iter = iter + 1;
            end
            
            % if not enough peaks detected, decrease peak distance
            iter = 1;
            while length(locs) < app.LaneNum*2 && iter < minPeakDist 
                [~, locs, ~, ~] = findpeaks(edgeDetection,...
                'MinPeakProminence',.1,...
                'MinPeakDistance',minPeakDist-iter*1); % decrease min peak distance
            iter = iter + 1;
            end
            
            % if not enough peaks detected, decrease peak prominence
            iter = 1;
            while length(locs) < app.LaneNum*2 && iter < 20 
                [~, locs, ~, ~] = findpeaks(edgeDetection,...
                'MinPeakProminence',.1-iter*0.005,... % decrease min peak prominence
                'MinPeakDistance',minPeakDist); 
            iter = iter + 1;
            end
            
            % color code lane lines
            for ii = 1:min([app.LaneNum*2,length(locs)])
                if ii == (app.LadderPos*2-1) || ii == (app.LadderPos*2)
                    app.Edges{ii} = drawline(app.ROI,...
                    'Position',[locs(ii) 1; locs(ii) size(app.Im,1)],...
                    'InteractionsAllowed','translate',...
                    'Deletable',false,...
                    'LineWidth',1,...
                    'Color',[220, 50, 32]./255);
                else
                    app.Edges{ii} = drawline(app.ROI,...
                    'Position',[locs(ii) 1; locs(ii) size(app.Im,1)],...
                    'InteractionsAllowed','translate',...
                    'Deletable',false,...
                    'LineWidth',1,...
                    'Color',[0, 90, 181]./255);
                end
            end
            
            % if too many lane lines detected, give warning
            if length(locs) > app.LaneNum*2
                uialert(app.UIFigure,'Some lane lines may be in the wrong place.','Warning')
            end
            
            % if still not enough lines, manually add lines and give warning
            if length(locs) < app.LaneNum*2
                for ii = 1:app.LaneNum*2-length(locs)
                   app.Edges{length(locs)+ii} = drawline(app.ROI,...
                    'Position',[locs(1)+5*ii 1; locs(1)+5*ii size(app.Im,1)],...
                    'InteractionsAllowed','translate',...
                    'Deletable',false,...
                    'LineWidth',1,...
                    'Color',[0, 90, 181]./255);
                end
                uialert(app.UIFigure,'Some lane lines may be in the wrong place.','Warning') 
            end

            app.MoveLineInstructions.Enable = 'on';
            app.LadderValuesInput.Enable = 'on';
            app.DetectLadderButton.Enable = 'on';
            app.ResetLaneLadderDetectionButton.Enable = 'on';
            app.NumLanesInput.Enable = 'off';
            app.LadderPosInput.Enable = 'off';
            app.DetectLanesButton.Enable = 'off';
        end

        % Button pushed function: ResetLaneLadderDetectionButton
        function ResetLaneLadderDetectionButtonPushed(app, event)
            if ~isempty(app.Edges) % delete any existing lane lines
                for ii = 1:length(app.Edges)
                    delete(app.Edges{ii})
                end
                app.Edges = {}; % clear cell array
            end
            if ~isempty(app.LadderLines) % delete existing ladder lines
                for ii = 1:length(app.LadderLines)
                    delete(app.LadderLines{ii})
                end
                app.LadderLines = {}; % clear cell array
            end
            
            app.NumLanesInput.Enable = 'on';
            app.LadderPosInput.Enable = 'on';
            app.DetectLanesButton.Enable = 'on';
            app.MoveLineInstructions.Enable = 'off';
            app.LadderValuesInput.Enable = 'off';
            app.DetectLadderButton.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.BandPercLowLimInput.Enable = 'off';
            app.BandPercHighLimInput.Enable = 'off';
            app.SmoothingFactorInput.Enable = 'off';
            app.ResetLaneLadderDetectionButton.Enable = 'off';
        end

        % Value changed function: LadderValuesInput
        function LadderValuesInputValueChanged(app, event)
            value = str2double(strsplit(app.LadderValuesInput.Value,','));  % convert comma-delimited string to array
            if isempty(value)
                uialert(app.UIFigure,'Ladder values cannot be empty.','Error')
                app.LadderValuesInput.Value = sprintf('%.0f,' , app.LadderBp); 
                app.LadderValuesInput.Value = value(1:end-1); % change back to default values if empty
                return
            else
                app.LadderBp = value; % update app.LadderBp
            end
        end

        % Button pushed function: DetectLadderButton
        function DetectLadderButtonPushed(app, event)
            if ~isempty(app.LadderLines) % delete existing ladder lines
                for ii = 1:length(app.LadderLines)
                    delete(app.LadderLines{ii})
                end
            end
            
            for ii = 1:length(app.Edges) % turn off interactions for lane lines
                app.Edges{ii}.InteractionsAllowed = 'none';
            end
            
            laneLocs = zeros(1,length(app.Edges));
            for ii = 1:length(app.Edges)
                laneLocs(ii) = app.Edges{ii}.Position(1);
            end
            laneLocs = sort(round(laneLocs));
            app.LeftLaneEdges = laneLocs(1:2:end);
            app.RightLaneEdges = laneLocs(2:2:end);
            
            % detect ladder locations
            ladder = mean(app.CeIm(:,app.LeftLaneEdges(app.LadderPos):app.RightLaneEdges(app.LadderPos)),2);
            ladder = -ladder - min(-ladder); % flip ladder intensity plot
            ladder = ladder/max(ladder); % normalize
            
            minPeakDist = round(length(ladder)/length(app.LadderBp)*.20); % min peak distance
            
            % use find peaks for find ladder location
            [~,bpLocs,~,~] = findpeaks(ladder,'MinPeakDistance',minPeakDist,'MinPeakProminence',0.01);
            
            % if not enough bp ladder locations, decrease min peak distance
            iter = 1;
            while length(bpLocs) < length(app.LadderBp) 
                if iter == minPeakDist 
                    break
                end
                [~,bpLocs,~,~] = findpeaks(ladder,'MinPeakDistance',minPeakDist-iter,'MinPeakProminence',0.01);
                iter = iter + 1;
            end
            
            % if too many bp ladder locations, increase min peak prominence
            iter = 1;
            while length(bpLocs) > length(app.LadderBp) 
                if iter == 50 % break while loop after 50 iterations
                    break
                end
                [~,bpLocs,~,~] = findpeaks(ladder,'MinPeakDistance',minPeakDist,'MinPeakProminence',0.01+iter*0.01);
                iter = iter + 1;
            end
            
            % draw ladder lines
            for ii = 1:min([length(app.LadderBp),length(bpLocs)])
                app.LadderLines{ii} = drawline(app.ROI,...
                    'Position',[1 bpLocs(ii); size(app.Im,2) bpLocs(ii); ],...
                    'Color','k',...
                    'StripeColor',[220, 50, 32]./255,...
                    'InteractionsAllowed','translate',...
                    'Deletable',false,...
                    'LineWidth',1);
            end
            
            % if too many lines detected, give warning
            if length(bpLocs) > length(app.LadderBp)
                uialert(app.UIFigure,'Some ladder lines may be in the wrong place.','Warning')
            end
            
            % if still not enough lines, manually add and give warning
            if length(bpLocs) < length(app.LadderBp)
                for ii = 1:length(app.LadderBp)-length(bpLocs)
                   app.LadderLines{length(bpLocs)+ii} = drawline(app.ROI,...
                    'Position',[1 bpLocs(1)+5*ii; size(app.Im,2) bpLocs(1)+5*ii; ],...
                    'Color','k',...
                    'StripeColor',[220, 50, 32]./255,...
                    'InteractionsAllowed','translate',...
                    'Deletable',false,...
                    'LineWidth',1);
                end
                uialert(app.UIFigure,'Some ladder lines may be in the wrong place.','Warning') % include warning to make sure 
            end
            
            app.MoveLineInstructions.Enable = 'off';
            app.LadderValuesInput.Enable = 'off';
            app.DetectLadderButton.Enable = 'off';
            app.AnalyzeButton.Enable = 'on';
            app.BandPercLowLimInput.Enable = 'on';
            app.BandPercHighLimInput.Enable = 'on';
            app.SmoothingFactorInput.Enable = 'on';
        end

        % Value changed function: BandPercLowLimInput
        function BandPercLowLimInputValueChanged(app, event)
            value = app.BandPercLowLimInput.Value;
            app.BandPercRange(1) = value;
            app.BandPercHighLimInput.Limits = [value+1,app.LadderBp(1)];
            title(app.BandPercPlot, ['Fragments between ',num2str(value),'-',num2str(app.BandPercHighLimInput.Value),' bp'])
        end

        % Value changed function: BandPercHighLimInput
        function BandPercHighLimInputValueChanged(app, event)
            value = app.BandPercHighLimInput.Value;
            app.BandPercRange(2) = value;
            app.BandPercLowLimInput.Limits = [75,value-1];
            title(app.BandPercPlot, ['Fragments between ',num2str(app.BandPercLowLimInput.Value),'-',num2str(value),' bp'])
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
            ClearVals(app)
            
            % open wait dialog box
            d = uiprogressdlg(app.UIFigure,'Title','Please wait','Message','Analyzing data...');
            
            % grab locations of ladder lines
            for ii = 1:length(app.LadderLines)
                bpLocs(ii) = app.LadderLines{ii}.Position(3);
            end
            app.BpInd = sort(bpLocs);
            
            % interpolate pixel locations to base pair value based on ladder
            app.BpVal_log = interp1(app.BpInd,app.LadderBp,1:size(app.Im,1),'linear','extrap'); 
            ind = find(app.BpVal_log > 0 & app.BpVal_log< app.LadderBp(1)*10); % exclude negative values and add padding at highest base pair
            [app.BpVal_log,bpSort] = sort(app.BpVal_log(ind));

            app.BpVal = logspace((log10(app.BpVal_log(1))),(log10(app.BpVal_log(end))),length(app.BpVal_log)*10); % logarithmic sampling
            ladderInd = find(app.BpVal >= app.LadderBp(end) & app.BpVal <= app.LadderBp(1)*10);
            
            for ii = 1:length(app.LeftLaneEdges) % iterate through each lane
                d.Value = ii/length(app.LeftLaneEdges); % update wait progress bar
                d.Message = ['Analyzing data... (',num2str(ii),'/',num2str(length(app.LeftLaneEdges)),')'];
                if ii == app.LadderPos
                    app.LadderIm = app.Im(ind,app.LeftLaneEdges(ii):app.RightLaneEdges(ii));
                else
                    ImTemp = app.Im(ind,app.LeftLaneEdges(ii):app.RightLaneEdges(ii));
                    app.LaneIm{ii} = ImTemp;
                    meanInt_raw = mean(1-ImTemp,2); % flip intensity
                    meanInt_raw = meanInt_raw(bpSort); % sort axes according to BpVal 
                    meanInt_raw(meanInt_raw < 0) = 0; % negative numbers --> 0
                    meanInt = interp1(app.BpVal_log,meanInt_raw,app.BpVal,'linear','extrap');
                    
                    % save raw intensity
                    app.RawData(:,ii) = meanInt;
                    app.NormRawData(:,ii) = meanInt/max(meanInt);
                    
                    % smooth data to improve peak detection (based on smoothing factor)
                    smoothData = smoothdata(meanInt,'gaussian');  % gaussian-weighted moving average filter
                    smoothfactor = app.SmoothingFactorInput.Value; % get smoothing factor
                    smInt = ((smoothfactor)*smoothData+(1-smoothfactor)*meanInt); % take the weighted average of gaussian fit and raw data to maintains any slight skewness
                    smInt(smInt < 0) = 0;
                    
                    % save smoothed intensity
                    app.SmData(:,ii) = smInt;
                    normSmInt = smInt/max(smInt);
                    app.NormSmData(:,ii) = normSmInt;
                    
                    % calculate 
                    normIm = imcomplement(app.Im);
                    normIm = normIm/max(normIm(:));
                    baseline = median(normIm(:)); % calculate baseline intensity (i.e. the background)
                    
                    % find the peaks in the normalized smoothed data
                    [pks,pklocs,~,~] = findpeaks(...
                        normSmInt,...                       
                        'MinPeakDistance',10,...            % peaks are at least 10 base pairs apart
                        'MinPeakHeight',baseline,...   % excludes noise peaks
                        'MinPeakProminence',0.001,...
                        'MinPeakWidth',5);                  % excludes noise peaks
                    [pklocs,pklocsorder] = sort(pklocs); % sort by location
                    pks = pks(pklocsorder); 
                    pks = pks(ceil(pklocs)>=1 & pklocs <= ladderInd(end)); % exclude peaks not inside the ladder
                    pklocs = pklocs(ceil(pklocs)>=1 & pklocs <= ladderInd(end));
                    for jj = 1:length(pks)
                        app.BpPeaks(ii,jj) = round(app.BpVal(pklocs(jj)));  % save peak values
                    end
                    
                    % find extent of each peak for relative area calculation
                    pklocs = [1, pklocs, length(normSmInt)]; % add first and last indices to pklocs array
                    borderind = [];
                    for jj = 2:length(pklocs)-1
                        border_left = find(normSmInt==min(normSmInt(pklocs(jj-1):pklocs(jj))));
                        border_left = border_left(border_left < pklocs(jj));
                        borderind(jj-1,1) = border_left(end);
                        border_right = find(normSmInt==min(normSmInt(pklocs(jj):pklocs(jj+1))));
                        border_right = border_right(border_right > pklocs(jj));
                        borderind(jj-1,2) = border_right(1);
                    end
                    
                    % calculate relative area for each peak
                    totalArea = trapz(normSmInt(borderind(1):borderind(end)));
                    for jj = 2:length(pklocs)-1
                        pkind = borderind(jj-1,1):borderind(jj-1,2); % peak indices
                        app.BpArea(ii,jj-1) = trapz(normSmInt(pkind))./totalArea*100; 
                    end    
                    
                    % calculate band percentage in desired bp range
                    x = find(app.BpVal >= app.BandPercRange(1) & app.BpVal <= app.BandPercRange(2));
                    app.BandPercentage(ii) = trapz(x,app.NormSmData(x,ii))/totalArea*100;
                end
                
            end
            
            % remove columns corresponding to ladder
            if app.LadderPos ~= app.NumLanesInput.Value
                app.LaneIm(app.LadderPos) = [];
                app.RawData(:,app.LadderPos) = [];
                app.NormRawData(:,app.LadderPos) = [];
                app.SmData(:,app.LadderPos) = [];
                app.NormSmData(:,app.LadderPos) = [];
                app.BpPeaks(app.LadderPos,:) = [];
                app.BpArea(app.LadderPos,:) = [];
                app.BandPercentage(app.LadderPos) = [];
            end
            
            % update plots an tables
            PlotLaneData(app)
            PlotBarGraph(app)
            PlotWaterfall(app)
            UpdateTable(app)
            
            app.TabGroup.SelectedTab = app.ResultsTab;
            app.ExportButton.Enable = 'on';
            
            % close wait dialog box
            close(d)
        end

        % Button pushed function: RightButton
        function RightButtonPushed(app, event)
            app.LaneSelect = app.LaneSelect + 1;
            if app.LaneSelect ~= 1
                app.LeftButton.Enable = 'on';
            end
            if app.LaneSelect == app.NumLanesInput.Value-1
                app.RightButton.Enable = 'off';
            end
            if app.LaneSelect > app.NumLanesInput.Value-1
                app.LaneSelect = app.NumLanesInput.Value-1;
            end
            PlotLaneData(app)
        end

        % Button pushed function: LeftButton
        function LeftButtonPushed(app, event)
            app.LaneSelect = app.LaneSelect - 1;
            if app.LaneSelect == 1 
                app.LeftButton.Enable = 'off';
            end
            if app.LaneSelect ~= app.NumLanesInput.Value-1
                app.RightButton.Enable = 'on';
            end
            if app.LaneSelect < 1
                app.LaneSelect = 1;
            end
            PlotLaneData(app)
        end

        % Value changed function: NormalizeSwitch
        function NormalizeSwitchValueChanged(app, event)
            PlotLaneData(app)
            PlotWaterfall(app)
        end

        % Value changed function: WfBpHighLimInput
        function WfBpHighLimInputValueChanged(app, event)
            value = app.WfBpHighLimInput.Value;
            app.WfBpLowLimInput.Limits = [0 value];
            PlotWaterfall(app)
        end

        % Value changed function: WfBpLowLimInput
        function WfBpLowLimInputValueChanged(app, event)
            value = app.WfBpLowLimInput.Value;
            app.WfBpHighLimInput.Limits = [value+1 Inf];
            PlotWaterfall(app)
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            d = uiprogressdlg(app.UIFigure,'Title','Please wait','Message','Exporting data...');
            try
                [~,name,~] = fileparts(app.FileName);
                if isempty(app.SavePath)
                    [SaveFile,app.SavePath] = uiputfile(fullfile(app.FilePath,'.xlsx'),'Save file',name);
                else
                    [SaveFile,app.SavePath] = uiputfile(fullfile(app.SavePath,'.xlsx'),'Save file',name);
                end
                figure(app.UIFigure)
                
                % save raw data if desired
                if app.SaveRawIntCheck.Value == true
                    temp = array2table(app.RawData);
                    bp = table(app.BpVal','VariableNames',{'Base_pairs'});
                    T = [bp,temp];
                    writetable(T,fullfile(app.SavePath,[SaveFile(1:end-5) '-raw_data.xlsx']));
                end
                d.Value = 0.25;
                
                if app.SavePeaksCheck.Value == true
                    % write peak and rel. area into a sheet in excel file
                    writetable(app.TData,fullfile(app.SavePath,SaveFile),'Sheet','Band Peaks');
                end
                d.Value = 0.5;
                
                if app.SaveBandPercCheck.Value == true
                    % write band percentage into a sheet in excel file
                    T = table((1:app.NumLanesInput.Value-1)',app.BandPercentage',...
                        'VariableNames',{'Lanes','Band Percentage (%)'});
                    writetable(T,fullfile(app.SavePath,SaveFile),'Sheet','Band Percentage');
                end
                d.Value = 0.75;
                
                if app.SaveWFPlotCheck.Value == true
                    % generate waterfall plot images
                    exportName = fullfile(app.SavePath,[SaveFile(1:end-5) '-wf.png']);
                    SaveWaterfallPlot(app,exportName)
                end
                d.Value = 1;
                
                close(d) % close wait dialogue box
                uialert(app.UIFigure,'Export successful.','Success','Icon','success')
            catch
                close(d) % close wait dialogue box
                uialert(app.UIFigure,'File(s) failed to export.','Error') % indicate error if anything fails to save
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            YN = uiconfirm(app.UIFigure,'Do you want to close the app?', 'Close','Icon','warning');
            if strcmpi(YN,'OK')
                if isdeployed
                    currDefaults = readstruct(fullfile(ctfroot,"defaults.xml"));
                else
                    currDefaults = readstruct("defaults.xml");
                end
                newParam = ReadParameters(app);
                % check if parameters are different from default
                if ~isequal(currDefaults,newParam)
                    UpdateDefaults = uiconfirm(app.UIFigure,'Current input parameters are different from the default. Update default parameters?', 'Change defaults');
                    if strcmpi(UpdateDefaults,'OK')
                        % update defaults
                        SaveDefaults(app);
                    end
                end
                delete(app);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [50 50 1300 750];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.Interruptible = 'off';
            app.UIFigure.Scrollable = 'on';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1300 750];

            % Create ImageProcessingTab
            app.ImageProcessingTab = uitab(app.TabGroup);
            app.ImageProcessingTab.Title = 'Image Processing';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.ImageProcessingTab);
            app.GridLayout.ColumnWidth = {4, '20x', '20x', '1x', 2, '50x', 4};
            app.GridLayout.RowHeight = {4, 35, 25, 25, '1x', 25, 300, 60, 4};
            app.GridLayout.ColumnSpacing = 3.9;
            app.GridLayout.RowSpacing = 5.5;
            app.GridLayout.Padding = [0 0 0 0];

            % Create Image
            app.Image = uiaxes(app.GridLayout);
            app.Image.Toolbar.Visible = 'off';
            app.Image.XTick = [];
            app.Image.YTick = [];
            app.Image.ZTick = [];
            app.Image.BoxStyle = 'full';
            app.Image.FontSize = 14;
            app.Image.GridAlpha = 0.15;
            app.Image.Box = 'on';
            app.Image.Layout.Row = [5 7];
            app.Image.Layout.Column = [2 3];

            % Create ROI
            app.ROI = uiaxes(app.GridLayout);
            app.ROI.Toolbar.Visible = 'off';
            app.ROI.AmbientLightColor = [0.8 0.8 0.8];
            app.ROI.PlotBoxAspectRatio = [2.0757180156658 1 1];
            app.ROI.XTick = [];
            app.ROI.YTick = [];
            app.ROI.ZTick = [];
            app.ROI.ClippingStyle = 'rectangle';
            app.ROI.FontSize = 14;
            app.ROI.Box = 'on';
            app.ROI.Layout.Row = [2 5];
            app.ROI.Layout.Column = 6;

            % Create AnalyzeButton
            app.AnalyzeButton = uibutton(app.GridLayout, 'push');
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            app.AnalyzeButton.FontSize = 14;
            app.AnalyzeButton.FontWeight = 'bold';
            app.AnalyzeButton.Enable = 'off';
            app.AnalyzeButton.Layout.Row = 8;
            app.AnalyzeButton.Layout.Column = 6;
            app.AnalyzeButton.Text = 'Analyze';

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout);
            app.ParametersPanel.Layout.Row = 7;
            app.ParametersPanel.Layout.Column = 6;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ParametersPanel);
            app.GridLayout3.ColumnWidth = {'50x', '50x', '50x', '50x'};
            app.GridLayout3.RowHeight = {'1x', '0.5x', '0.5x', '0.75x', '1x', '1x', 50};
            app.GridLayout3.ColumnSpacing = 6;
            app.GridLayout3.Padding = [6 10 6 10];

            % Create NumberoflanesincludingladderLabel
            app.NumberoflanesincludingladderLabel = uilabel(app.GridLayout3);
            app.NumberoflanesincludingladderLabel.HorizontalAlignment = 'right';
            app.NumberoflanesincludingladderLabel.WordWrap = 'on';
            app.NumberoflanesincludingladderLabel.FontSize = 14;
            app.NumberoflanesincludingladderLabel.Layout.Row = 1;
            app.NumberoflanesincludingladderLabel.Layout.Column = 1;
            app.NumberoflanesincludingladderLabel.Text = 'Number of lanes (including ladder)';

            % Create NumLanesInput
            app.NumLanesInput = uispinner(app.GridLayout3);
            app.NumLanesInput.Limits = [2 Inf];
            app.NumLanesInput.RoundFractionalValues = 'on';
            app.NumLanesInput.ValueDisplayFormat = '%11g';
            app.NumLanesInput.ValueChangedFcn = createCallbackFcn(app, @NumLanesInputValueChanged, true);
            app.NumLanesInput.FontSize = 14;
            app.NumLanesInput.Enable = 'off';
            app.NumLanesInput.Layout.Row = 1;
            app.NumLanesInput.Layout.Column = 2;
            app.NumLanesInput.Value = 13;

            % Create LadderPosInput
            app.LadderPosInput = uispinner(app.GridLayout3);
            app.LadderPosInput.Limits = [1 13];
            app.LadderPosInput.RoundFractionalValues = 'on';
            app.LadderPosInput.ValueDisplayFormat = '%11g';
            app.LadderPosInput.ValueChangedFcn = createCallbackFcn(app, @LadderPosInputValueChanged, true);
            app.LadderPosInput.FontSize = 14;
            app.LadderPosInput.Enable = 'off';
            app.LadderPosInput.Layout.Row = 2;
            app.LadderPosInput.Layout.Column = 2;
            app.LadderPosInput.Value = 1;

            % Create LadderpositionLabel
            app.LadderpositionLabel = uilabel(app.GridLayout3);
            app.LadderpositionLabel.HorizontalAlignment = 'right';
            app.LadderpositionLabel.WordWrap = 'on';
            app.LadderpositionLabel.FontSize = 14;
            app.LadderpositionLabel.Layout.Row = 2;
            app.LadderpositionLabel.Layout.Column = 1;
            app.LadderpositionLabel.Text = 'Ladder position';

            % Create DetectLadderButton
            app.DetectLadderButton = uibutton(app.GridLayout3, 'push');
            app.DetectLadderButton.ButtonPushedFcn = createCallbackFcn(app, @DetectLadderButtonPushed, true);
            app.DetectLadderButton.FontSize = 14;
            app.DetectLadderButton.FontWeight = 'bold';
            app.DetectLadderButton.Enable = 'off';
            app.DetectLadderButton.Layout.Row = 5;
            app.DetectLadderButton.Layout.Column = [2 3];
            app.DetectLadderButton.Text = 'Detect Ladder';

            % Create TargetFragmentSizeRangePanel
            app.TargetFragmentSizeRangePanel = uipanel(app.GridLayout3);
            app.TargetFragmentSizeRangePanel.Title = 'Target Fragment Size Range';
            app.TargetFragmentSizeRangePanel.Layout.Row = [6 7];
            app.TargetFragmentSizeRangePanel.Layout.Column = [1 2];
            app.TargetFragmentSizeRangePanel.FontSize = 14;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.TargetFragmentSizeRangePanel);

            % Create LowerlimitbpEditFieldLabel_2
            app.LowerlimitbpEditFieldLabel_2 = uilabel(app.GridLayout4);
            app.LowerlimitbpEditFieldLabel_2.HorizontalAlignment = 'right';
            app.LowerlimitbpEditFieldLabel_2.FontSize = 14;
            app.LowerlimitbpEditFieldLabel_2.Layout.Row = 1;
            app.LowerlimitbpEditFieldLabel_2.Layout.Column = 1;
            app.LowerlimitbpEditFieldLabel_2.Text = 'Lower limit (bp)';

            % Create BandPercLowLimInput
            app.BandPercLowLimInput = uieditfield(app.GridLayout4, 'numeric');
            app.BandPercLowLimInput.Limits = [75 299];
            app.BandPercLowLimInput.RoundFractionalValues = 'on';
            app.BandPercLowLimInput.ValueChangedFcn = createCallbackFcn(app, @BandPercLowLimInputValueChanged, true);
            app.BandPercLowLimInput.FontSize = 14;
            app.BandPercLowLimInput.Enable = 'off';
            app.BandPercLowLimInput.Layout.Row = 1;
            app.BandPercLowLimInput.Layout.Column = 2;
            app.BandPercLowLimInput.Value = 150;

            % Create BandPercHighLimInput
            app.BandPercHighLimInput = uieditfield(app.GridLayout4, 'numeric');
            app.BandPercHighLimInput.Limits = [150 20000];
            app.BandPercHighLimInput.RoundFractionalValues = 'on';
            app.BandPercHighLimInput.ValueChangedFcn = createCallbackFcn(app, @BandPercHighLimInputValueChanged, true);
            app.BandPercHighLimInput.FontSize = 14;
            app.BandPercHighLimInput.Enable = 'off';
            app.BandPercHighLimInput.Layout.Row = 2;
            app.BandPercHighLimInput.Layout.Column = 2;
            app.BandPercHighLimInput.Value = 300;

            % Create UpperLimitbpLabel_2
            app.UpperLimitbpLabel_2 = uilabel(app.GridLayout4);
            app.UpperLimitbpLabel_2.HorizontalAlignment = 'right';
            app.UpperLimitbpLabel_2.WordWrap = 'on';
            app.UpperLimitbpLabel_2.FontSize = 14;
            app.UpperLimitbpLabel_2.Layout.Row = 2;
            app.UpperLimitbpLabel_2.Layout.Column = 1;
            app.UpperLimitbpLabel_2.Text = 'Upper Limit (bp)';

            % Create SmoothingfactorSpinnerLabel
            app.SmoothingfactorSpinnerLabel = uilabel(app.GridLayout3);
            app.SmoothingfactorSpinnerLabel.HorizontalAlignment = 'right';
            app.SmoothingfactorSpinnerLabel.FontSize = 14;
            app.SmoothingfactorSpinnerLabel.Layout.Row = 6;
            app.SmoothingfactorSpinnerLabel.Layout.Column = 3;
            app.SmoothingfactorSpinnerLabel.Text = 'Smoothing factor';

            % Create SmoothingFactorInput
            app.SmoothingFactorInput = uispinner(app.GridLayout3);
            app.SmoothingFactorInput.Step = 0.05;
            app.SmoothingFactorInput.Limits = [0 1];
            app.SmoothingFactorInput.FontSize = 14;
            app.SmoothingFactorInput.Enable = 'off';
            app.SmoothingFactorInput.Layout.Row = 6;
            app.SmoothingFactorInput.Layout.Column = 4;
            app.SmoothingFactorInput.Value = 0.3;

            % Create DetectLanesButton
            app.DetectLanesButton = uibutton(app.GridLayout3, 'push');
            app.DetectLanesButton.ButtonPushedFcn = createCallbackFcn(app, @DetectLanesButtonPushed, true);
            app.DetectLanesButton.FontSize = 14;
            app.DetectLanesButton.FontWeight = 'bold';
            app.DetectLanesButton.Enable = 'off';
            app.DetectLanesButton.Layout.Row = [1 2];
            app.DetectLanesButton.Layout.Column = [3 4];
            app.DetectLanesButton.Text = 'Detect Lanes';

            % Create LadderValuesInput
            app.LadderValuesInput = uieditfield(app.GridLayout3, 'text');
            app.LadderValuesInput.ValueChangedFcn = createCallbackFcn(app, @LadderValuesInputValueChanged, true);
            app.LadderValuesInput.FontSize = 14;
            app.LadderValuesInput.Enable = 'off';
            app.LadderValuesInput.Layout.Row = 4;
            app.LadderValuesInput.Layout.Column = [1 4];
            app.LadderValuesInput.Value = '20000,10000,7000,5000,4000,3000,2000,1500,1000,700,500,400,300,200,75';

            % Create LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel = uilabel(app.GridLayout3);
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel.HorizontalAlignment = 'center';
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel.FontSize = 14;
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel.Layout.Row = 3;
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel.Layout.Column = [1 4];
            app.LaddervalueshighesttolowestseparatedbyacommaEditFieldLabel.Text = 'Ladder values (highest to lowest, separated by a comma)';

            % Create ResetLaneLadderDetectionButton
            app.ResetLaneLadderDetectionButton = uibutton(app.GridLayout3, 'push');
            app.ResetLaneLadderDetectionButton.ButtonPushedFcn = createCallbackFcn(app, @ResetLaneLadderDetectionButtonPushed, true);
            app.ResetLaneLadderDetectionButton.FontWeight = 'bold';
            app.ResetLaneLadderDetectionButton.Enable = 'off';
            app.ResetLaneLadderDetectionButton.Layout.Row = 7;
            app.ResetLaneLadderDetectionButton.Layout.Column = [3 4];
            app.ResetLaneLadderDetectionButton.Text = 'Reset Lane/Ladder Detection';

            % Create MoveLineInstructions
            app.MoveLineInstructions = uilabel(app.GridLayout);
            app.MoveLineInstructions.HorizontalAlignment = 'center';
            app.MoveLineInstructions.WordWrap = 'on';
            app.MoveLineInstructions.FontSize = 14;
            app.MoveLineInstructions.FontWeight = 'bold';
            app.MoveLineInstructions.FontAngle = 'italic';
            app.MoveLineInstructions.Enable = 'off';
            app.MoveLineInstructions.Layout.Row = 6;
            app.MoveLineInstructions.Layout.Column = 6;
            app.MoveLineInstructions.Text = 'Double-check lane (blue) and ladder (red) lines. Click and drag to move any lines.';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.GridLayout, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.FontSize = 14;
            app.LoadImageButton.Layout.Row = 2;
            app.LoadImageButton.Layout.Column = 2;
            app.LoadImageButton.Text = 'Load Image';

            % Create SelectRegionCommand
            app.SelectRegionCommand = uilabel(app.GridLayout);
            app.SelectRegionCommand.HorizontalAlignment = 'center';
            app.SelectRegionCommand.FontSize = 14;
            app.SelectRegionCommand.FontWeight = 'bold';
            app.SelectRegionCommand.FontAngle = 'italic';
            app.SelectRegionCommand.Enable = 'off';
            app.SelectRegionCommand.Layout.Row = 4;
            app.SelectRegionCommand.Layout.Column = [2 3];
            app.SelectRegionCommand.Text = 'Click and drag to draw a rectangle around the region of interest. ';

            % Create ConfirmRegionButton
            app.ConfirmRegionButton = uibutton(app.GridLayout, 'push');
            app.ConfirmRegionButton.ButtonPushedFcn = createCallbackFcn(app, @ConfirmRegionButtonPushed, true);
            app.ConfirmRegionButton.FontSize = 14;
            app.ConfirmRegionButton.Enable = 'off';
            app.ConfirmRegionButton.Layout.Row = 8;
            app.ConfirmRegionButton.Layout.Column = [2 3];
            app.ConfirmRegionButton.Text = 'Confirm Region';

            % Create CurrentFile
            app.CurrentFile = uieditfield(app.GridLayout, 'text');
            app.CurrentFile.Editable = 'off';
            app.CurrentFile.Layout.Row = 3;
            app.CurrentFile.Layout.Column = [2 3];

            % Create SelectNewRegionButton
            app.SelectNewRegionButton = uibutton(app.GridLayout, 'push');
            app.SelectNewRegionButton.ButtonPushedFcn = createCallbackFcn(app, @SelectNewRegionButtonPushed, true);
            app.SelectNewRegionButton.FontSize = 14;
            app.SelectNewRegionButton.Enable = 'off';
            app.SelectNewRegionButton.Layout.Row = 2;
            app.SelectNewRegionButton.Layout.Column = 3;
            app.SelectNewRegionButton.Text = 'Select New Region';

            % Create ResultsTab
            app.ResultsTab = uitab(app.TabGroup);
            app.ResultsTab.Title = 'Results';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ResultsTab);
            app.GridLayout2.ColumnWidth = {4, '75x', '100x', '100x', '100x', '75x', '75x', '75x', '75x', 4};
            app.GridLayout2.RowHeight = {4, 35, '10x', '7x', 150, 4};
            app.GridLayout2.ColumnSpacing = 9.75;
            app.GridLayout2.RowSpacing = 5.9;
            app.GridLayout2.Padding = [0 0 0 0];

            % Create NormalizeSwitchLabel
            app.NormalizeSwitchLabel = uilabel(app.GridLayout2);
            app.NormalizeSwitchLabel.HorizontalAlignment = 'right';
            app.NormalizeSwitchLabel.Layout.Row = 2;
            app.NormalizeSwitchLabel.Layout.Column = 8;
            app.NormalizeSwitchLabel.Text = 'Normalize';

            % Create NormalizeSwitch
            app.NormalizeSwitch = uiswitch(app.GridLayout2, 'slider');
            app.NormalizeSwitch.ValueChangedFcn = createCallbackFcn(app, @NormalizeSwitchValueChanged, true);
            app.NormalizeSwitch.Layout.Row = 2;
            app.NormalizeSwitch.Layout.Column = 9;

            % Create DataTable
            app.DataTable = uitable(app.GridLayout2);
            app.DataTable.ColumnName = {'Lane'; 'Peak 1'; 'Area 1'; 'Peak 2'; 'Area 2'};
            app.DataTable.RowName = {};
            app.DataTable.Layout.Row = [4 5];
            app.DataTable.Layout.Column = [2 5];

            % Create Panel
            app.Panel = uipanel(app.GridLayout2);
            app.Panel.Layout.Row = 5;
            app.Panel.Layout.Column = [6 9];

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.Panel);
            app.GridLayout6.RowHeight = {35, 35, 35};

            % Create SaveRawIntCheck
            app.SaveRawIntCheck = uicheckbox(app.GridLayout6);
            app.SaveRawIntCheck.Text = 'Raw Intensity (.xlsx)';
            app.SaveRawIntCheck.Layout.Row = 2;
            app.SaveRawIntCheck.Layout.Column = 2;

            % Create SavePeaksCheck
            app.SavePeaksCheck = uicheckbox(app.GridLayout6);
            app.SavePeaksCheck.Text = 'Peaks and relative area (.xlsx)';
            app.SavePeaksCheck.Layout.Row = 1;
            app.SavePeaksCheck.Layout.Column = 1;
            app.SavePeaksCheck.Value = true;

            % Create SaveBandPercCheck
            app.SaveBandPercCheck = uicheckbox(app.GridLayout6);
            app.SaveBandPercCheck.Text = 'Base pair percentages (.xlsx)';
            app.SaveBandPercCheck.Layout.Row = 2;
            app.SaveBandPercCheck.Layout.Column = 1;
            app.SaveBandPercCheck.Value = true;

            % Create SaveWFPlotCheck
            app.SaveWFPlotCheck = uicheckbox(app.GridLayout6);
            app.SaveWFPlotCheck.Text = 'Waterfall Plot (.png)';
            app.SaveWFPlotCheck.Layout.Row = 1;
            app.SaveWFPlotCheck.Layout.Column = 2;
            app.SaveWFPlotCheck.Value = true;

            % Create ExportButton
            app.ExportButton = uibutton(app.GridLayout6, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.FontWeight = 'bold';
            app.ExportButton.Layout.Row = 3;
            app.ExportButton.Layout.Column = [1 2];
            app.ExportButton.Text = 'Export';

            % Create Panel_3
            app.Panel_3 = uipanel(app.GridLayout2);
            app.Panel_3.Layout.Row = 3;
            app.Panel_3.Layout.Column = [6 9];

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.Panel_3);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x', '1x', 35};
            app.GridLayout8.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create WaterfallPlot
            app.WaterfallPlot = uiaxes(app.GridLayout8);
            xlabel(app.WaterfallPlot, 'Base Pair (bp)')
            ylabel(app.WaterfallPlot, 'Lane')
            zlabel(app.WaterfallPlot, 'Intensity')
            app.WaterfallPlot.PlotBoxAspectRatio = [1.35492957746479 1 1];
            app.WaterfallPlot.XGrid = 'on';
            app.WaterfallPlot.YGrid = 'on';
            app.WaterfallPlot.ZGrid = 'on';
            app.WaterfallPlot.Box = 'on';
            app.WaterfallPlot.Layout.Row = [1 4];
            app.WaterfallPlot.Layout.Column = [1 4];

            % Create WfBpLowLimInput
            app.WfBpLowLimInput = uieditfield(app.GridLayout8, 'numeric');
            app.WfBpLowLimInput.Limits = [0 2000];
            app.WfBpLowLimInput.ValueChangedFcn = createCallbackFcn(app, @WfBpLowLimInputValueChanged, true);
            app.WfBpLowLimInput.Layout.Row = 5;
            app.WfBpLowLimInput.Layout.Column = 2;
            app.WfBpLowLimInput.Value = 75;

            % Create LowerlimitbpEditFieldLabel
            app.LowerlimitbpEditFieldLabel = uilabel(app.GridLayout8);
            app.LowerlimitbpEditFieldLabel.HorizontalAlignment = 'right';
            app.LowerlimitbpEditFieldLabel.Layout.Row = 5;
            app.LowerlimitbpEditFieldLabel.Layout.Column = 1;
            app.LowerlimitbpEditFieldLabel.Text = 'Lower limit (bp)';

            % Create WfBpHighLimInput
            app.WfBpHighLimInput = uieditfield(app.GridLayout8, 'numeric');
            app.WfBpHighLimInput.Limits = [76 Inf];
            app.WfBpHighLimInput.RoundFractionalValues = 'on';
            app.WfBpHighLimInput.ValueChangedFcn = createCallbackFcn(app, @WfBpHighLimInputValueChanged, true);
            app.WfBpHighLimInput.Layout.Row = 5;
            app.WfBpHighLimInput.Layout.Column = 4;
            app.WfBpHighLimInput.Value = 2000;

            % Create UpperLimitbpLabel
            app.UpperLimitbpLabel = uilabel(app.GridLayout8);
            app.UpperLimitbpLabel.HorizontalAlignment = 'right';
            app.UpperLimitbpLabel.WordWrap = 'on';
            app.UpperLimitbpLabel.Layout.Row = 5;
            app.UpperLimitbpLabel.Layout.Column = 3;
            app.UpperLimitbpLabel.Text = 'Upper Limit (bp)';

            % Create Panel_4
            app.Panel_4 = uipanel(app.GridLayout2);
            app.Panel_4.Layout.Row = 4;
            app.Panel_4.Layout.Column = [6 9];

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.Panel_4);
            app.GridLayout9.ColumnWidth = {'1x'};
            app.GridLayout9.RowHeight = {'1x'};

            % Create BandPercPlot
            app.BandPercPlot = uiaxes(app.GridLayout9);
            title(app.BandPercPlot, 'Fragments between 150-300 bp')
            xlabel(app.BandPercPlot, 'Column')
            ylabel(app.BandPercPlot, 'Percentage (%)')
            zlabel(app.BandPercPlot, 'Z')
            app.BandPercPlot.PlotBoxAspectRatio = [1.70567375886525 1 1];
            app.BandPercPlot.Box = 'on';
            app.BandPercPlot.Layout.Row = 1;
            app.BandPercPlot.Layout.Column = 1;

            % Create LanePanel
            app.LanePanel = uipanel(app.GridLayout2);
            app.LanePanel.Layout.Row = [2 3];
            app.LanePanel.Layout.Column = [2 5];

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.LanePanel);
            app.GridLayout10.ColumnWidth = {'0.75x', '1x', '1x', '1x'};
            app.GridLayout10.RowHeight = {'1x', 35};

            % Create BpDistribution
            app.BpDistribution = uiaxes(app.GridLayout10);
            title(app.BpDistribution, ' ')
            xlabel(app.BpDistribution, {'Log-scaled Base Pair'; ''})
            ylabel(app.BpDistribution, 'Intensity [A.U.]')
            app.BpDistribution.PlotBoxAspectRatio = [1.07606263982103 1 1];
            app.BpDistribution.Box = 'on';
            app.BpDistribution.Layout.Row = 1;
            app.BpDistribution.Layout.Column = [2 4];

            % Create LaneImage
            app.LaneImage = uiaxes(app.GridLayout10);
            app.LaneImage.PlotBoxAspectRatio = [1 1.91158536585366 1];
            app.LaneImage.XTick = [];
            app.LaneImage.YTick = [];
            app.LaneImage.BoxStyle = 'full';
            app.LaneImage.Box = 'on';
            app.LaneImage.Layout.Row = 1;
            app.LaneImage.Layout.Column = 1;

            % Create LeftButton
            app.LeftButton = uibutton(app.GridLayout10, 'push');
            app.LeftButton.ButtonPushedFcn = createCallbackFcn(app, @LeftButtonPushed, true);
            app.LeftButton.Enable = 'off';
            app.LeftButton.Layout.Row = 2;
            app.LeftButton.Layout.Column = 2;
            app.LeftButton.Text = '<<';

            % Create RightButton
            app.RightButton = uibutton(app.GridLayout10, 'push');
            app.RightButton.ButtonPushedFcn = createCallbackFcn(app, @RightButtonPushed, true);
            app.RightButton.Layout.Row = 2;
            app.RightButton.Layout.Column = 4;
            app.RightButton.Text = '>>';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GelInsight

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end