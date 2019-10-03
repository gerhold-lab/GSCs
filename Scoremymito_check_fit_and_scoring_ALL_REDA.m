% Plot each spindle length versus time (frames) for each cell
% Plot corresponding Fs and Fe scored in Scoremymito_scoremitosisALL.m
% Plot fitted curves obtained by Scoremymito_scoremitosisALL.m

A = exist('Celloutput');
if A ~= 1
    error('No Celloutput variable in the work space');
else
    [~,kk] = size(Celloutput);
    for j = 1:1:kk
        % Define limits of x-axis
        xstart = min(Celloutput(j).meas(:,1));
        firstframe = xstart;
        xstop = max(Celloutput(j).meas(:,1));
        % Ideally the x-axis would be roughly the same scale for all graphs
        % (i.e. the same number of time points, since spreading different
        % numbers of time points over the same length x-axis can distort the curves
        % and bias/complicate the scoring)
        xrange = xstop - xstart;
        if xrange < 79
            xstart = round(xstart + xrange/2) - 40;
            xstop = round(xstop - xrange/2) + 40;
        end
        % Create figure full screen
        figure1 = figure('units','normalized','outerposition',[0 0 1 1]);
        % Create axes
        % sets the x-axis tick values 
        axes1 = axes('Parent',figure1,'XTick',[xstart:2:xstop],'XGrid','on');
        box(axes1,'on');
        hold(axes1,'all');
        % Create plot - frames/spindle length
        X1 = Celloutput(j).meas(:,1);
        Y1 = Celloutput(j).meas(:,3);
        plot(X1,Y1,'Marker','o','Color',[0 0 1]);
        % Add title
        title({Celloutput(j).gonad;Celloutput(j).cell},'Interpreter','none');
        axis([xstart xstop 1 11]);
        % Add vertical lines corresponding to scoring
        Frs = Celloutput(j).scoring(1,1);
        Fre = Celloutput(j).scoring(1,2);
        FrNEBD = Celloutput(j).scoring(1,3);
        yL = get(gca,'YLim');
        line([Frs Frs],yL,'Color','k');
        line([Fre Fre],yL,'Color','k');
        line([FrNEBD FrNEBD],yL,'Color','b');
        line([0 0],yL,'Color','g','LineWidth',2);
        % Add linear curve fit (using frames not seconds)
        if ~isnan(Frs) && ~isnan(Fre) && Fre ~= -5000 && Frs ~= 5000
            % frames
            Frsnebd = [Frs-3:1:Frs]';  
            Frscong = [Frs:1:Fre]'; 
            Frsana = [Fre:1:Fre+3]';
            % frames adjusted
            Frsnebd = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frsnebd) & Celloutput(j).meas(:,1)<=max(Frsnebd),1);
            Frscong = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frscong) & Celloutput(j).meas(:,1)<=max(Frscong),1);
            Frsana = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frsana) & Celloutput(j).meas(:,1)<=max(Frsana),1);
            % spindle length
            SrLnebd = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frsnebd) & Celloutput(j).meas(:,1)<=max(Frsnebd),3);
            SrLcong = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frscong) & Celloutput(j).meas(:,1)<=max(Frscong),3);
            SrLana = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Frsana) & Celloutput(j).meas(:,1)<=max(Frsana),3);
            %poly1 => Linear polynomial curve
            Nr = fit(Frsnebd,SrLnebd,'poly1');
            hold on;
            Cr = fit(Frscong,SrLcong,'poly1');
            hold on;
            Ar = fit(Frsana,SrLana,'poly1');
            plot(Nr);
            plot(Cr);
            plot(Ar);
        end
        %Show most recent graph window
        shg;
        % If fits are an accurate representation of data, click a mouse button
        % Otherwise, press any key and you can modify your scoring
        w = waitforbuttonpress;
        if w == 0   
            close(figure1);
        else
            gonad = Celloutput(j).gonad;
            cellID = Celloutput(j).cell;
            id = strcat(gonad,'_',cellID);
            boo = strfind(Tiff_fileList,id);
            foo = find(~cellfun('isempty', boo));
            file = Tiff_fileList{foo};
            [stack, img_read] = tiffread2(file); % stack is a structure with the px values for each tiff in stack.data. img_read = number of images in stack
            % Convert stack.date into multidimensional array
            [~, n] = size(stack);
            [aa, bb] = size(stack(1).data);
            stack_dbl = NaN(aa,bb,n);
            for m = 1:1:n
                stack_dbl(:,:,m) = double(stack(m).data);
            end
            max_val = max(max(max(stack_dbl)));
            min_val = min(min(min(stack_dbl)));
            stack_dbl = stack_dbl-min_val;
            outstack = uint16(65535*stack_dbl/max_val);
            Hh = implay(outstack);
            moo = Hh.Parent.CurrentAxes.Position;
            noo = [moo(1)-moo(3) moo(2)-moo(4) 3*moo(3) 3*moo(4)];
            Hh.Parent.CurrentAxes.Position = noo;
            % User inputs frame value corresponding to congression start
            % and stop, as assessed from image file. If not possible to
            % score --> enter NaN;
            figure(Hh.Parent) % Brings implay window to front
            CongS = input('Enter frame corresponding to congression start');
            %figure(Hh.Parent) % Brings implay window to front
            CongE = input('Enter frame corresponding to congression end');
            close(Hh);
            CongS = CongS + firstframe - 1;
            CongE = CongE + firstframe - 1;
            figure(figure1)
            if ~isnan(CongS)
                line([CongS CongS],yL,'Color','b');
            end
            if ~isnan(CongE)
                line([CongE CongE],yL,'Color','b');
            end
            % repeats scoring script from Scoremymito_scoremitosisALL
          
            [x1,y1] = ginput(1);
            text(x1,y1,'NEBD');%Add text after click
            x(1) = round(x1);
            [x2,y2] = ginput(1);
            text(x2,y2,'start');
            x(2) = round(x2);
            [x3,y3] = ginput(1);
            text(x3,y3,'end');
            x(3) = round(x3);
        
            % x(1) = NEBD, if possible to discern from spindle length plot
            % x(2) = start of congression
            % x(3) = end of congression
   
        
            % If the start of congression occurred before the first frame of
            % the image acquisition and the end of congression occurred after
            % the last frame of the image acquisition (i.e. the cell was
            % arrested in mitosis for the entire image acquisition), click
            % outside of the figure plot to the left, first, and then to the
            % right.
        
            % If the start of congression occurred before the first frame of the
            % image acquisition, click outside of the figure plot to the left.

            % If the end of congression occurred after the last frame of the
            % image acquisition, click outside of the figure plot to the right.
        
            % If both the start of congression and the end of congression
            % occurred before the first frame of the image acquisition (i.e.
            % the cell was in anaphase or later at time = 0), click 2x outside 
            % of the figure plot to the left.

            % If both the start of congression and the end of congression
            % occurred after the last frame of the image acquisition (i.e.
            % the cell was still in prophase at last image frame), click 2x outside 
            % of the figure plot to the right.
        
            if x(2) < xstart
                x(2) = NaN;
            end
            if x(2) > xstop
                x(2) = 5000;
            end
            if x(3) > xstop
                x(3)=NaN;
            end
            if x(3) < xstart
                x(3) = -5000;
            end
            if x(1) < xstart || x(1) > xstop
                x(1) = NaN;
            end
        
            % This will give 6 possible configurations for x: 
            % [x(2) x(3)] = full congression
            % [NaN, x(3)] = no start, end OK
            % [5000, NaN] = start and end after acquisition end/cell in
            % prophase
            % [x(2), NaN] = start OK, no end
            % [NaN, -5000] = start and end before acquisition start/cell in
            % anaphase/telophase
            % [NaN, NaN] = start before acquisition start and end after
            % acquisition end/cell arrested for entire acquisition
  
            % add congression end/start values to Celloutput
            Fs = x(2);
            Fe = x(3);
            nebd = x(1);
            Celloutput(j).scoring(1,1) = Fs;
            Celloutput(j).scoring(1,2) = Fe;
            Celloutput(j).scoring(1,3) = nebd;
            close(figure1);
        end
    end
    for j = 1:1:kk
        [row, col] = size(Celloutput(j).meas);
        Fs = Celloutput(j).scoring(1,1);
        Fe = Celloutput(j).scoring(1,2);
        % excludes cells where first or last frame of congression did not occur
        % during the image acquisition
        if ~isnan(Fs) && ~isnan(Fe) && Fe ~= -5000 && Fs ~= 5000
            % nebd = nuclear envelop breakdown
            % cong = CONGRESSION
            % ana = ANAPHASE
            % Identify the frames used to calculate the regression lines
            % that will be used to calculate the duration of congression by their
            % intersection points
            Fsnebd = [Fs-3:1:Fs]';  
            Fscong = [Fs:1:Fe]'; 
            Fsana = [Fe:1:Fe+3]';
            % converts frames to time in seconds by pulling 
            
            % corresponding time values from column 2 of Celloutput.meas
            Tnebd = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fsnebd) & Celloutput(j).meas(:,1)<=max(Fsnebd),2);
            Tcong = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fscong) & Celloutput(j).meas(:,1)<=max(Fscong),2);
            Tana = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fsana) & Celloutput(j).meas(:,1)<=max(Fsana),2);
            % Identifies the spindle length for the frames of interest by pulling out
            % corresponding spindle length values from column 3 of Celloutput.meas
            SLnebd = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fsnebd) & Celloutput(j).meas(:,1)<=max(Fsnebd),3);
            SLcong = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fscong) & Celloutput(j).meas(:,1)<=max(Fscong),3);
            SLana = Celloutput(j).meas(Celloutput(j).meas(:,1)>=min(Fsana) & Celloutput(j).meas(:,1)<=max(Fsana),3);
            
            % Fit nebd time points with a linear polynomial curve
            N = fit(Tnebd,SLnebd,'poly1');
            % Pull out the values of the coefficients for the nebd fit
            CoefN = coeffvalues(N);
            
            % Fit congression time points with a linear polynomial curve
            C = fit(Tcong,SLcong,'poly1');
            % Pull out the values of the coefficients for the congression fit
            CoefC = coeffvalues(C);
            
            % Fit anaphase time points with a linear polynomial curve
            A = fit(Tana,SLana,'poly1');
            % Pull out the values of the coefficients for the anaphase fit
            CoefA = coeffvalues(A);
            
            % find the x-position of the intersection points of the nebd and congression
            % and the congression and anaphase lines by => ax+b=cx+d <=> x(a-c)=d-b <=> x=(d-b)/c-a) 
            NCx = (CoefC(1,2)-CoefN(1,2))/(CoefN(1,1)-CoefC(1,1));
            CAx = (CoefA(1,2)-CoefC(1,2))/(CoefC(1,1)-CoefA(1,1));
            DurC = CAx-NCx;
            Celloutput(j).scoring(2,1:2) = CoefN;
            Celloutput(j).scoring(3,1:2) = CoefC;
            Celloutput(j).scoring(4,1:2) = CoefA;
            % To save the calculated congression start and end points:
            Celloutput(j).scoring(5,1) = NCx;
            Celloutput(j).scoring(5,2) = CAx;
            Celloutput(j).out(1,1) = DurC; % duration of mitosis/congression in seconds
            Celloutput(j).out(1,2) = nanmean(SLcong); % mean spindle length during mitosis/congression
            Celloutput(j).out(1,3) = nanstd(SLcong); % standard deviation of spindle length during mitosis/congression
        else
            Celloutput(j).out(1,1:3) = NaN; 
        end
        % removed script for spindle and rachis angle calculations and this
        % should be included in a separate script.
    end
    
    % You will want to change this to extract the values that you are
    % interested in, i.e. expand it to include spindle angle etc.
    
    [~,kk] = size(Celloutput); % in case kk was reassigned
    
    % Compile all the measurements that you want to split by gonad/worm by
    % looping through the Celloutput structure and pulling out the
    % following:
    NEBD = NaN(kk,1);
    NEBD = NaN(kk,1);
    CongStart = NaN(kk,1);
    CongEnd = NaN(kk,1);
    NEBDtoAna = NaN(kk,1);
% % %     
    DurCong = NaN(kk,1);%%% duration of congression,values corresponds to the group cells belong to 
    DurCong2 = NaN(kk,1);%%% duration of congression 
% % %     
    meanSpinLength = NaN(kk,1);
    STdevSpinLength = NaN(kk,1);
    SpinElongationRate = NaN(kk,1);
% % %     
    NEBDbin = NaN(kk,1);%%% Start of NEBD, values corresponds to the group cells belong to


    Framerate = NaN(kk,1);
    Gonads = cell(kk,1);
    Cells = cell(kk,1);
    
    % Germlineoutput should be a structure with a size (BB) equal the number
    % of original Trackmate files, i.e. the number of gonads with tracked
    % cells. Germlineoutput is generated by the script
    % Scoremymito_import_and_align_cent_tracks.m. Use the values in
    % Germlineoutput.gonad and Germlineoutput.lastframe to determine
    % whether cells with either the start or end of congression missing
    % (i.e. before t0 or after tlast, respectively) are delayed.    B = exist('Germlineoutput');
    if B ~= 1
        error('No Germlineoutput variable in the work space');
    else 
        [~, BB] = size(Germlineoutput);
        gonadIDs = cell(BB,1);
        TotalFrames = NaN(BB,1);
        for i = 1:1:BB
            gonadIDs{i,1} = Germlineoutput(i).gonad;
            TotalFrames(i,1) = Germlineoutput(i).lastframe;
        end
    
        for i = 1:1:kk
            Framerate(i,1) = Celloutput(i).meas(2,2) - Celloutput(i).meas(1,2);
            Gonads{i,1} = Celloutput(i).gonad;
            Cells{i,1} = Celloutput(i).cell;
        
            NEBD(i,1) = Celloutput(i).scoring(1,3) * Framerate(i,1);
        
% % %             
            
            if NEBD(i,1) <300 %%% 300 seconds
            NEBDbin(i,1) = 1;
            elseif NEBD(i,1) <600
            NEBDbin(i,1) = 2;    
            elseif NEBD(i,1) <900
            NEBDbin(i,1) = 3;    
            elseif NEBD(i,1) <1200
            NEBDbin(i,1) = 4;
            elseif NEBD(i,1) <1500
            NEBDbin(i,1) = 5;
            elseif NEBD(i,1) <1800
            NEBDbin(i,1) = 6;
            elseif NEBD(i,1) <2100
            NEBDbin(i,1) = 7;
            elseif NEBD(i,1) <2400
            NEBDbin(i,1) = 8;
            elseif NEBD(i,1) <2700
            NEBDbin(i,1) = 9;
            elseif NEBD(i,1) <3000
            NEBDbin(i,1) = 10;
            elseif NEBD(i,1) <3300
            NEBDbin(i,1) = 11;
            elseif NEBD(i,1) <3600
            NEBDbin(i,1) = 12;
            elseif NEBD(i,1) <3900
            NEBDbin(i,1) = 13;
            elseif NEBD(i,1) <4200
            NEBDbin(i,1) = 14;
            elseif NEBD(i,1) <4500
            NEBDbin(i,1) = 15;
            elseif NEBD(i,1) <4800
            NEBDbin(i,1) = 16;
            elseif NEBD(i,1) <5100
            NEBDbin(i,1) = 17;
            elseif NEBD(i,1) <5400 %%%5400 seconds=> 90 minutes
            NEBDbin(i,1) = 18;
            else
            NEBDbin(i,1) = NaN;
            end
         
         
            
% % %                      
           
            
            
            if isnan(Celloutput(i).scoring(1,1)) || Celloutput(i).scoring(1,1) == 5000 || isnan(Celloutput(i).scoring(1,2)) || Celloutput(i).scoring(1,2) == -5000
                CongStart(i,1) = Celloutput(i).scoring(1,1);
                CongEnd(i,1) = Celloutput(i).scoring(1,2);
                % Converts scored frames, i.e. not NaN or +/-5000, into seconds
                if CongStart(i,1) ~= 5000 && ~isnan(CongStart(i,1))
                    CongStart(i,1) = CongStart(i,1) * Framerate(i,1);
                end
                if CongEnd(i,1) ~= -5000 && ~isnan(CongEnd(i,1))
                    CongEnd(i,1) = CongEnd(i,1) * Framerate(i,1);
                end
            else
                CongStart(i,1) = Celloutput(i).scoring(5,1);
                CongEnd(i,1) = Celloutput(i).scoring(5,2);
            end
            
            CongEnd2(i,1)=CongEnd(i,1); 
            
            if CongEnd2(i,1)== -5000
                CongEnd2(i,1)= NaN;
            end
            
            if CongEnd2(i,1) <300 %%% 300 seconds
            CongEndbin(i,1) = 1;
            elseif CongEnd2(i,1) <600
            CongEndbin(i,1) = 2;    
            elseif CongEnd2(i,1) <900
            CongEndbin(i,1) = 3;    
            elseif CongEnd2(i,1) <1200
            CongEndbin(i,1) = 4;
            elseif CongEnd2(i,1) <1500
            CongEndbin(i,1) = 5;
            elseif CongEnd2(i,1) <1800
            CongEndbin(i,1) = 6;
            elseif CongEnd2(i,1) <2100
            CongEndbin(i,1) = 7;
            elseif CongEnd2(i,1) <2400
            CongEndbin(i,1) = 8;
            elseif CongEnd2(i,1) <2700
            CongEndbin(i,1) = 9;
            elseif CongEnd2(i,1) <3000
            CongEndbin(i,1) = 10;
            elseif CongEnd2(i,1) <3300
            CongEndbin(i,1) = 11;
            elseif CongEnd2(i,1) <3600
            CongEndbin(i,1) = 12;
            elseif CongEnd2(i,1) <3900
            CongEndbin(i,1) = 13;
            elseif CongEnd2(i,1) <4200
            CongEndbin(i,1) = 14;
            elseif CongEnd2(i,1) <4500
            CongEndbin(i,1) = 15;
            elseif CongEnd2(i,1) <4800
            CongEndbin(i,1) = 16;
            elseif CongEnd2(i,1) <5100
            CongEndbin(i,1) = 17;
            elseif CongEnd2(i,1) <5400 %%%5400 seconds=> 90 minutes
            CongEndbin(i,1) = 18;
            else
            CongEndbin(i,1) = NaN;
            end
        
            NEBDtoAna(i,1) = CongEnd(i,1) - NEBD(i,1);
           
            %%% Group cells into bins depending on congression duration
             % 1= in congression during entire movie aka arrested
             % 2= in congression between 95th percentiles of
             % controls dataset) and 99th percentiles of
             % controls dataset aka delayed
             % 3=in congression for more than 99th percentiles of controls dataset aka strongly
             % delayed
             % 4=in congression for less than  95th percentiles of
             % controls dataset considered not delayed
        
             if isnan(CongStart(i,1)) && isnan(CongEnd(i,1))
                DurCong(i,1) = 1; %%%arrested
            elseif CongStart(i,1) == -5000 || CongEnd(i,1) == 5000
                DurCong(i,1) = NaN; 
            elseif ~isnan(CongStart(i,1)) && CongStart(i,1) ~= -5000 && isnan(CongEnd(i,1))
                 gonad = Gonads{i,1};
                boo = find(strcmp(gonadIDs, gonad));
                LT = TotalFrames(boo) * Framerate(i,1);
                if LT - CongStart(i,1) > perc95 && LT - CongStart(i,1) <= perc99
                    DurCong(i,1) = 2;  %%%delayed 
                elseif LT - CongStart(i,1) > perc99
                    DurCong(i,1) = 3;  %%%strongly delayed
                else
                    DurCong(i,1) = NaN;
                end
            elseif isnan(CongStart(i,1)) && CongEnd(i,1) ~= 5000 && ~isnan(CongEnd(i,1))
                if CongEnd(i,1) > perc95 && CongEnd(i,1) <= perc99
                    DurCong(i,1) = 2; %%%delayed
                elseif CongEnd(i,1) > perc99
                    DurCong(i,1) = 3; %%%strongly delayed
                else
                    DurCong(i,1) = NaN;
                end
            else
                DurCong(i,1) = CongEnd(i,1) - CongStart(i,1);
                if DurCong(i,1)> perc95 && DurCong(i,1)<= perc99
                    DurCong(i,1) = 2;  %%%delayed
                elseif DurCong(i,1) > perc99
                    DurCong(i,1) = 3;  %%%strongly delayed
                else
                    DurCong(i,1) = 4;  %%%not delayed
                end
             end 

             %%% Duration of congression raw
            if isnan(CongStart(i,1)) || isnan(CongEnd(i,1)) || CongStart(i,1) == -5000 || CongEnd(i,1) == 5000             
                DurCong2(i,1) = NaN;
            else
                DurCong2(i,1) = CongEnd(i,1) - CongStart(i,1);
            end
           
           
             
            meanSpinLength(i,1) = Celloutput(i).out(1,2);
            STdevSpinLength(i,1) = Celloutput(i).out(1,3);
            if ~isnan(DurCong2(i,1))
                SpinElongationRate(i,1) =  Celloutput(i).scoring(4,1);
            else
                SpinElongationRate(i,1) = NaN;
            end
 % If the start/end of congression was defined by the fit, it takes
 % the fitted value, otherwise the scored values are used. CongStart
 % and CongEnd will have time in seconds or NaNs, if occured before or
 % after start of acquisition. CongStart will have NaNs for cells where 
 % congression started before or after the start/end of image acquisition
        end
               for j = 1:1:BB
            worm = Germlineoutput(j).gonad;
            boo = strcmp(Gonads, worm);
           
            %%% reconvert the table to an array to permit refreshing
%             if isa(Germlineoutput(j).meas,'table')==1
%                 Germlineoutput(j).meas=table2array(Germlineoutput(j).meas);
%             end
            Germlineoutput(j).Framerate = max(Framerate(boo,1));
            Germlineoutput(j).meas(:,1) = NEBD(boo,1);%raw
            Germlineoutput(j).meas(:,2) = CongStart(boo,1);
            Germlineoutput(j).meas(:,3) = CongEnd(boo,1);
            Germlineoutput(j).meas(:,4) = NEBDtoAna(boo,1);
            Germlineoutput(j).meas(:,5) = DurCong2(boo,1); %raw
            Germlineoutput(j).meas(:,6) = meanSpinLength(boo,1);
            Germlineoutput(j).meas(:,7) = STdevSpinLength(boo,1);
            Germlineoutput(j).meas(:,8) = SpinElongationRate(boo,1);
            Germlineoutput(j).meas(:,9) = DurCong(boo,1);%binned
            Germlineoutput(j).meas(:,10) = NEBDbin(boo,1);%binned
            Germlineoutput(j).meas(:,11) = CongEndbin(boo,1);%binned
            
            
            arrested=0;
            delayed=0;
            strongdelayed=0;
            notdelayed=0;
            %%% add 4 fields to Germlineoutput
            % arrested= in congression during entire movie aka arrested
            % delayed= in congression between 95th percentiles of
            % controls dataset 99th percentiles of
            % controls dataset aka delayed
            % strongdelayed=in congression for more than 99th percentiles of
            % controls dataset aka strongly delayed
            % notdelayed=in congression for less than 95th percentiles of 
            % controls dataset considered not delayed
            
            for del=1:1:Germlineoutput(j).numdivs
                if Germlineoutput(j).meas(del,9)==1
                    arrested=arrested+1;
                elseif Germlineoutput(j).meas(del,9)==2
                    delayed=delayed+1;
                elseif Germlineoutput(j).meas(del,9)==3
                    strongdelayed=strongdelayed+1;
                elseif Germlineoutput(j).meas(del,9)==4
                    notdelayed=notdelayed+1;
                end
            end
           Germlineoutput(j).arrested = arrested;
           Germlineoutput(j).delayed = delayed;
           Germlineoutput(j).strongdelayed = strongdelayed;
           Germlineoutput(j).notdelayed = notdelayed;
           
           
           %%% add a field to Germlineoutput
           % number of cells in each bin depending on when NEBD starts
           Germlineoutput(j).NEBDbins = zeros(18,1);% 18 bins => 0-90 minutes
                     
           
           Germlineoutput(j).CongEndbins = zeros(18,1);% 18 bins => 0-90 minutes
            
           for del=1:1:Germlineoutput(j).numdivs
           if Germlineoutput(j).meas(del,10) == 1
              Germlineoutput(j).NEBDbins(1,1)=Germlineoutput(j).NEBDbins(1,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 2
              Germlineoutput(j).NEBDbins(2,1)=Germlineoutput(j).NEBDbins(2,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 3
              Germlineoutput(j).NEBDbins(3,1)=Germlineoutput(j).NEBDbins(3,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 4
              Germlineoutput(j).NEBDbins(4,1)=Germlineoutput(j).NEBDbins(4,1)+1;   
           elseif Germlineoutput(j).meas(del,10) == 5
              Germlineoutput(j).NEBDbins(5,1)=Germlineoutput(j).NEBDbins(5,1)+1;    
           elseif Germlineoutput(j).meas(del,10) == 6
              Germlineoutput(j).NEBDbins(6,1)=Germlineoutput(j).NEBDbins(6,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 7
              Germlineoutput(j).NEBDbins(7,1)=Germlineoutput(j).NEBDbins(7,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 8
              Germlineoutput(j).NEBDbins(8,1)=Germlineoutput(j).NEBDbins(8,1)+1;   
           elseif Germlineoutput(j).meas(del,10) == 9
              Germlineoutput(j).NEBDbins(9,1)=Germlineoutput(j).NEBDbins(9,1)+1;     
           elseif Germlineoutput(j).meas(del,10) == 10
              Germlineoutput(j).NEBDbins(10,1)=Germlineoutput(j).NEBDbins(10,1)+1;     
           elseif Germlineoutput(j).meas(del,10) == 11
              Germlineoutput(j).NEBDbins(11,1)=Germlineoutput(j).NEBDbins(11,1)+1;     
           elseif Germlineoutput(j).meas(del,10) == 12
              Germlineoutput(j).NEBDbins(12,1)=Germlineoutput(j).NEBDbins(12,1)+1;
           elseif Germlineoutput(j).meas(del,10) == 13
              Germlineoutput(j).NEBDbins(13,1)=Germlineoutput(j).NEBDbins(13,1)+1; 
           elseif Germlineoutput(j).meas(del,10) == 14
              Germlineoutput(j).NEBDbins(14,1)=Germlineoutput(j).NEBDbins(14,1)+1;    
           elseif Germlineoutput(j).meas(del,10) == 15
              Germlineoutput(j).NEBDbins(15,1)=Germlineoutput(j).NEBDbins(15,1)+1; 
           elseif Germlineoutput(j).meas(del,10) == 16
              Germlineoutput(j).NEBDbins(16,1)=Germlineoutput(j).NEBDbins(16,1)+1;    
           elseif Germlineoutput(j).meas(del,10) == 17
              Germlineoutput(j).NEBDbins(17,1)=Germlineoutput(j).NEBDbins(17,1)+1;       
           elseif Germlineoutput(j).meas(del,10) == 18
              Germlineoutput(j).NEBDbins(18,1)=Germlineoutput(j).NEBDbins(18,1)+1;    
           end
           end
             
           for del=1:1:Germlineoutput(j).numdivs
           if Germlineoutput(j).meas(del,11) == 1
              Germlineoutput(j).CongEndbins(1,1)=Germlineoutput(j).CongEndbins(1,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 2
              Germlineoutput(j).CongEndbins(2,1)=Germlineoutput(j).CongEndbins(2,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 3
              Germlineoutput(j).CongEndbins(3,1)=Germlineoutput(j).CongEndbins(3,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 4
              Germlineoutput(j).CongEndbins(4,1)=Germlineoutput(j).CongEndbins(4,1)+1;   
           elseif Germlineoutput(j).meas(del,11) == 5
              Germlineoutput(j).CongEndbins(5,1)=Germlineoutput(j).CongEndbins(5,1)+1;    
           elseif Germlineoutput(j).meas(del,11) == 6
              Germlineoutput(j).CongEndbins(6,1)=Germlineoutput(j).CongEndbins(6,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 7
              Germlineoutput(j).CongEndbins(7,1)=Germlineoutput(j).CongEndbins(7,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 8
              Germlineoutput(j).CongEndbins(8,1)=Germlineoutput(j).CongEndbins(8,1)+1;   
           elseif Germlineoutput(j).meas(del,11) == 9
              Germlineoutput(j).CongEndbins(9,1)=Germlineoutput(j).CongEndbins(9,1)+1;     
           elseif Germlineoutput(j).meas(del,11) == 10
              Germlineoutput(j).CongEndbins(10,1)=Germlineoutput(j).CongEndbins(10,1)+1;     
           elseif Germlineoutput(j).meas(del,11) == 11
              Germlineoutput(j).CongEndbins(11,1)=Germlineoutput(j).CongEndbins(11,1)+1;     
           elseif Germlineoutput(j).meas(del,11) == 12
              Germlineoutput(j).CongEndbins(12,1)=Germlineoutput(j).CongEndbins(12,1)+1;
           elseif Germlineoutput(j).meas(del,11) == 13
              Germlineoutput(j).CongEndbins(13,1)=Germlineoutput(j).CongEndbins(13,1)+1; 
           elseif Germlineoutput(j).meas(del,11) == 14
              Germlineoutput(j).CongEndbins(14,1)=Germlineoutput(j).CongEndbins(14,1)+1;    
           elseif Germlineoutput(j).meas(del,11) == 15
              Germlineoutput(j).CongEndbins(15,1)=Germlineoutput(j).CongEndbins(15,1)+1; 
           elseif Germlineoutput(j).meas(del,11) == 16
              Germlineoutput(j).CongEndbins(16,1)=Germlineoutput(j).CongEndbins(16,1)+1;    
           elseif Germlineoutput(j).meas(del,11) == 17
              Germlineoutput(j).CongEndbins(17,1)=Germlineoutput(j).CongEndbins(17,1)+1;       
           elseif Germlineoutput(j).meas(del,11) == 18
              Germlineoutput(j).CongEndbins(18,1)=Germlineoutput(j).CongEndbins(18,1)+1;    
           end
           end
              
            % count the number of mitotic cells per frame for each gonad
            maxframe = TotalFrames(j);
            FrameIndx = [1:1:maxframe]';
            gonadIndx = find(boo);
            bob = NaN(length(FrameIndx),length(gonadIndx));
            for cc = 1:1:length(gonadIndx)
                celltoadd = Celloutput(gonadIndx(cc)).meas(:,1);
                for dd = 1:1:length(FrameIndx)
                    if sum(FrameIndx(dd) == celltoadd) == 1
                        bob(dd,cc) = celltoadd(FrameIndx(dd) == celltoadd);
                    end
                end
            end
            cellcountperframe = sum(~isnan(bob),2);
            Germlineoutput(j).mitocounts = cellcountperframe;
        end
        %%% convert array to table in order to name variables and rows
       for j = 1:1:BB 
       Germlineoutput(j).NEBDbins = table(Germlineoutput(j).NEBDbins,'RowNames',{'>5min','>10min','>15min','>20min','>25min','>30min','>35min','>40min','>45min','>50min','>55min','>60min','>65min','>70min','>75min','>80min','>85min','>90min'});
       Germlineoutput(j).CongEndbins = table(Germlineoutput(j).CongEndbins,'RowNames',{'>5min','>10min','>15min','>20min','>25min','>30min','>35min','>40min','>45min','>50min','>55min','>60min','>65min','>70min','>75min','>80min','>85min','>90min'});
       Germlineoutput(j).meas= table(Germlineoutput(j).meas(:,1),Germlineoutput(j).meas(:,2),Germlineoutput(j).meas(:,3),Germlineoutput(j).meas(:,4),Germlineoutput(j).meas(:,5),Germlineoutput(j).meas(:,6),Germlineoutput(j).meas(:,7),Germlineoutput(j).meas(:,8),Germlineoutput(j).meas(:,9),Germlineoutput(j).meas(:,10),Germlineoutput(j).meas(:,11),'VariableNames',{'NEBD','CongressionStart','CongressionEnd','NEBDtoAO','CongressionDuration','MeanSpindleLength'...
                ,'SpindleLengthStDev','AnaphaseElongation_um_per_s','CongressionDurationBinned','NEBDbinned','CongEndbinned'});
       end
       %%% order fields of the Germlineoutput Structure
        cd={'gonad','numdivs','arrested','delayed','strongdelayed','notdelayed','NEBDbins','CongEndbins','meas','mitocounts','lastframe','cells','IJcells','IJcoords','Framerate'};
        Germlineoutput = orderfields(Germlineoutput,cd);

    end

        clearvars -except Celloutput Germlineoutput Tiff_fileList
end