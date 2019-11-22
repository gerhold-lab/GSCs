% Plot each spindle length versus time (frames) for each cell and record
% the first and last frame of congression (i.e. first frame where spindle
% length hits ~mean length during congression and last frame before
% anaphase spindle elongation. Using these frames, calculate the duration
% of congression and the average spindle length during congression. Using
% the output structure from justcentrosometracks.m as input.


A = exist('output');
if A ~= 1
    error('No output variable in the work space');
else
    [~,kk] = size(output);
    for j = 1:1:kk
        xstart = min(output(j).meas(:,1));
        xstop = max(output(j).meas(:,1));
        % Create figure
        figure1 = figure('units','normalized','outerposition',[0 0 1 1]);
        % Create axes
        axes1 = axes('Parent',figure1,'XTick',[xstart:2:xstop],'XGrid','on');
        box(axes1,'on');
        hold(axes1,'all');
        % Create plot
        X1 = output(j).meas(:,1);
        Y1 = output(j).meas(:,3);
        plot(X1,Y1,'Marker','o','Color',[0 0 1]);
        %SLfig = figure;
        %plot(output(j).meas(:,1),output(j).meas(:,3),'-ob');
        axis([xstart xstop 1 9]);
        shg;
        Fs = input('enter first frame where spindle length <= mean length during congression or NaN if track starts after NEBD');
        Fe = input('enter last frame of congression prior to rapid/anaphase spindle elongation');
        close(figure1);
        output(j).scoring(1,1) = Fs;
        output(j).scoring(1,2) = Fe;
    end
    for j = 1:1:kk
        [row, col] = size(output(j).meas);
        Fs = output(j).scoring(1,1);
        Fe = output(j).scoring(1,2);
        if ~isnan(Fs)
            Fsnebd = [Fs-3:1:Fs]';
            Fscong = [Fs:1:Fe]';
            Fsana = [Fe:1:Fe+3]';
            Tnebd = output(j).meas(output(j).meas(:,1)>=min(Fsnebd) & output(j).meas(:,1)<=max(Fsnebd),2);
            Tcong = output(j).meas(output(j).meas(:,1)>=min(Fscong) & output(j).meas(:,1)<=max(Fscong),2);
            Tana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),2);
            SLnebd = output(j).meas(output(j).meas(:,1)>=min(Fsnebd) & output(j).meas(:,1)<=max(Fsnebd),3);
            SLcong = output(j).meas(output(j).meas(:,1)>=min(Fscong) & output(j).meas(:,1)<=max(Fscong),3);
            SLana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),3);
            N = fit(Tnebd,SLnebd,'poly1');
            CoefN = coeffvalues(N);
            C = fit(Tcong,SLcong,'poly1');
            CoefC = coeffvalues(C);
            A = fit(Tana,SLana,'poly1');
            CoefA = coeffvalues(A);
            NCx = (CoefC(1,2)-CoefN(1,2))/(CoefN(1,1)-CoefC(1,1));
            CAx = (CoefA(1,2)-CoefC(1,2))/(CoefC(1,1)-CoefA(1,1));
            DurC = CAx-NCx;
            output(j).scoring(2,1:2) = CoefN;
            output(j).scoring(3,1:2) = CoefC;
            output(j).scoring(4,1:2) = CoefA;
            output(j).out(1,1) = DurC; %duration of mitosis/congression in seconds
            output(j).out(1,2) = nanmean(SLcong); %mean spindle length during mitosis/congression
            output(j).out(1,3) = nanstd(SLcong); %standard deviation of spindle length during mitosis/congression
        else
            output(j).out(1,1:3) = NaN;
        end
        if col > 9
            Fsana = [Fe+1:Fe+3]';
            Aana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),10);
            SAana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),11);
            nFacesana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),12);
            DisttoSpinMidana = output(j).meas(output(j).meas(:,1)>=min(Fsana) & output(j).meas(:,1)<=max(Fsana),13);
            output(j).out(1,4) = nanmean(Aana); %mean angle relative to the rachis during anaphase (3 frames)
            output(j).out(1,5) = nanmean(SAana); %mean surface area of rachis used to calculate angle during anaphase (3 frames)
            output(j).out(1,6) = nanmean(nFacesana); %mean number of faces of rachis used to calculate angle during anaphase (3 frames)
            output(j).out(1,7) = nanmean(DisttoSpinMidana); %means distance between all faces and spindle midpoint during anaphase (3 frames)
        else
            output(j).out(1,4:7) = NaN;
        end
    end
    
    % You will want to change this to extract the values that you are
    % interested in, i.e. expand it to include spindle angle etc.
    Tmito = NaN(kk,1);
    Lspin = NaN(kk,1);
    start = NaN(kk,1);
    Gonads = cell(kk,1);
    Cells = cell(kk,1);
    AngleAn = NaN(kk,1);
    
    for i = 1:1:kk
        Tmito(i,1) = output(i).out(1,1);
        Lspin(i,1) = output(i).out(1,2);
        AngleAn(i,1) = output(i).out(1,4);
        AngleAnNor(i,1) = output(i).out(1,4);
        if ~isnan(output(i).scoring(1,1))
            start(i,1) = output(i).meas(output(i).meas(:,1)==output(i).scoring(1,1),2);
        else
            start(i,1) = NaN;
        end
        
        Gonads{i,1} = output(i).gonad;
        Cells{i,1} = output(i).cell;
    end
    Tmitomins = Tmito./60;
    %plotSpread(Tmitomins)
    AngleAnNor = NaN(kk,1);
    for i = 1:1:kk

        if  AngleAn(i,:) < 90

   
            AngleAnNor(i,:) = AngleAn(i,:)

        else AngleAnNor(i,:) = 180-AngleAn(i,:)
               

        end
    end
    
end
 % plot(start,Tmitomins,'o')
 % plot(start,Tmito,'o')
 % plot(output(xx).meas(:,1),output(xx).meas(:,3),'-o')