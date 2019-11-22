

ennd=0;


    while ennd~=1
        choice=menu({'Hello, welcome to MitoPack(R)';'A matlab tool to analysis mitosis using mitotic spindle poles position tracked by Trackmate(R)';'Developped by Labbe Lab-UdeM & Gerhold Lab-McGill';'please select a task'},'Import your Trackmate tracking and write coordinates for CropCells.ijm','Score NEBD and congression timepoints','Fit and process your scoring','check your fit and scoring','add variables containing the duration of congression (sec), its 95th+99th percentiles and start of congression of all your cells ','Refresh after manual modification','refresh after folder modification','Add new tracked samples to an old workspace','Score NEBD and congression timepoints of the data newly added','Fit and process the scoring of the data newly added','exit');
    if choice==1
   run('Scoremymito_import_and_align_cent_tracks.m');
    end
    if choice==2
   run('Scoremymito_score_mitosis_ALL_wtiffs.m');
    end
    if choice==3
   run('Scoremymito_calc_fits.m');
    end
    if choice==4
   run('Scoremymito_check_fit_and_scoring_ALL.m');
    end
   if choice==5
   run('Scoremymito_refresh_keepvarcongminute.m');
   end
   if choice==6
   run('Scoremymito_refresh.m');
    end
    if choice==7
   run('Scoremymito_refreshfoldertif.m');
    end
    if choice==8
   answer = questdlg({'in order to add new data to a saved workspace';
          'The next window will ask you to load your old workspace';
             },'Welcome to ScoreMymito','continue','cancel');
                %load old worspace
                    uiopen('*.mat');
   run('Scoremymito_addnewdata.m');
    end
    if choice==9
   run('Scoremymito_score_mitosis_ALL_wtiffs_addData.m');
    end
    if choice==10
   run('Scoremymito_calc_fits_newdata.m');
    end
     if choice==11
   ennd=1;
    end   
   end
clearvars choice ennd
                
                
    