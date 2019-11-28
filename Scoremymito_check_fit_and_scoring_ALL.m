% Plot each spindle length versus time (frames) for each cell
% Plot corresponding Fs and Fe scored in Scoremymito_scoremitosisALL.m
% Plot fitted curves obtained by Scoremymito_scoremitosisALL.m

A = exist('Celloutput');
if A ~= 1
    error('No Celloutput variable in the work space');
else
    [~,kk] = size(Celloutput);
    scoreORfiterrors = {};
    for j = 1:1:kk
        % Define limits of x-axis
        xstart = min(Celloutput(j).meas(:,2));
        firstframe = xstart;
        xstop = max(Celloutput(j).meas(:,2));
        Frate = abs(nanmean(Celloutput(j).meas(1:end-1,2)-Celloutput(j).meas(2:end,2)));
        % Ideally the x-axis would be roughly the same scale for all graphs
        % (i.e. the same number of time points, since spreading different
        % numbers of time points over the same length x-axis can distort the curves
        % and bias/complicate the scoring)
        xrange = xstop - xstart;
        if xrange < 2370
            xstart = round(xstart + xrange/2) - 1185;
            xstop = round(xstop - xrange/2) + 1185;
        end
        % Create figure full screen
        figure1 = figure('units','normalized','outerposition',[0 0 1 1]);
        % Create axes
        % sets the x-axis tick values 
        axes1 = axes('Parent',figure1,'XTick',[xstart:round(Frate*2):xstop],'XGrid','on');
        box(axes1,'on');
        hold(axes1,'all');
        % Create plot - frames/spindle length
        X1 = Celloutput(j).meas(:,2);
        Y1 = Celloutput(j).meas(:,3);
        plot(X1,Y1,'Marker','o','Color',[0 0 1]);
        % Add title
        title({Celloutput(j).gonad;Celloutput(j).cell},'Interpreter','none');
        xlabel('Time (sec)')
        ylabel('Mitotic spindle length')
        axis([xstart xstop 1 11]);
        % Add vertical lines corresponding to scoring
        Frs = Celloutput(j).scoring(1,1);
        Fre = Celloutput(j).scoring(1,2);
        FrNEBD = Celloutput(j).scoring(1,3);
        Ts = (Frs-1)*Frate;
        Te = (Fre-1)*Frate;
        TNEBD = (FrNEBD-1)*Frate;
        yL = get(gca,'YLim');
        line([Ts Ts],yL,'Color','m');
        line([Te Te],yL,'Color','g');
        line([TNEBD TNEBD],yL,'Color','b');
        line([0 0],yL,'Color','k','LineWidth',2);
        annotation(figure1,'textbox',...
            [0.15 0.8 0.2 0.04],...
            'String',['Celloutput index ' num2str(j) '/' num2str(kk)],...
            'FontSize',16,...
            'FitBoxToText','off');
        % create values to plot the fitted lines using the
        % coefficients from the 'fit' function
        % for NEBD to CongS (N):
        if ~isnan(Frs) && ~isnan(Fre)
            CoefN = Celloutput(j).scoring(2,1:2);
            CoefC = Celloutput(j).scoring(3,1:2);
            CoefA = Celloutput(j).scoring(4,1:2);
            xN = [Ts-240:30:Ts+120]';
            yN = CoefN(1,1)*xN+CoefN(1,2);
            % for congression (C):
            xC = [Ts-120:30:Te+120]';
            yC = CoefC(1,1)*xC+CoefC(1,2);
            % for CongE through anaphase (A):
            xA = [Te-120:30:Te+240]';
            yA = CoefA(1,1)*xA+CoefA(1,2);
            hold on
            plot(xN,yN,'r');
            plot(xC,yC,'r');
            plot(xA,yA,'r');
        end
        %Show most recent graph window
        shg;
        % If fits are an accurate representation of data, click a mouse button
        % Otherwise, press any key and you can modify your scoring
        w = waitforbuttonpress;
        if w == 0   
            close(figure1);
        else
            [m, ~] = size(scoreORfiterrors);
            scoreORfiterrors{m+1,1} = j;
            scoreORfiterrors{m+1,2} = Celloutput(j).gonad;
            scoreORfiterrors{m+1,3} = Celloutput(j).cell;
            close(figure1);
        end
    end
end


 clearvars -except Celloutput Germlineoutput Tiff_fileList scoreORfiterrors