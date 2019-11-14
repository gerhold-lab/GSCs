#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 12 19:35:38 2019

@author: yifan
"""

# merge spots coords and intensity data

import pandas as pd
import os
from scipy.spatial import distance



# step 1: merge
os.chdir("/Users/yifan/Dropbox/ZYF/cpv2/0716/")
label_coords_df = pd.read_csv("2018-07-16_GSC_L4_L4440_RNAi_T0.xml_spots_parsed.csv",
                       usecols = ['ID', 'name' ,'POSITION_X','POSITION_Y', 'POSITION_Z', 
                                  'POSITION_T', 'FRAME'
                                 ])
label_intensity_df = pd.read_csv("2018-07-16_GSC_L4_L4440_RNAi_T0_IntensityMeasurements.csv", 
                          usecols = ['RawIntDen'])
label_spots_merged_df = pd.concat([label_coords_df, label_intensity_df], sort=False, axis = 1)



unlab_coords_df = pd.read_csv("2018-07-16_GSC_L4_L4440_RNAi_T0_unlab.xml_spots_parsed.csv",
                       usecols = ['ID', 'name' ,'POSITION_X','POSITION_Y', 'POSITION_Z', 
                                  'POSITION_T', 'FRAME'
                                 ])
unlab_intensity_df = pd.read_csv("2018-07-16_GSC_L4_L4440_RNAi_T0_unlab_IntensityMeasurements.csv", 
                          usecols = ['RawIntDen'])
unlab_spots_merged_df = pd.concat([unlab_coords_df, unlab_intensity_df], sort=False, axis = 1)

#merge label and unlabel
spots_merged_df = pd.concat([label_spots_merged_df,unlab_spots_merged_df], 
                            sort=False, axis = 0)


# step 2: neighbors_list based on euclidean distance
spotFields = ['ID', 'POSITION_X', 'POSITION_Y', 'POSITION_Z', 
              'POSITION_T', 'FRAME', 'RawIntDen']
time_dict = {}
for index, row in spots_merged_df.iterrows():
    if row['FRAME'] in time_dict:
        time_dict[row['FRAME']].append(row)
    else:
        time_dict[row['FRAME']] = [row]
        
neighbors_list_dict = {}
dist_inten_data_minIntDiff = []

for t, all_spots_at_t in time_dict.items():
    for spot in all_spots_at_t:
        # need labelled spot_i only
        spot_name = spot['name']
        if spot_name[0:2] == 'ID':
            continue
        spot_x = spot['POSITION_X']
        spot_y = spot['POSITION_Y']
        spot_z = spot['POSITION_Z']
        spot_id = spot['ID']
        
        spot_int = spot['RawIntDen']
        neighbors_list = []
        for neighbor in all_spots_at_t:
        #spot is a series object
            nbr_id = neighbor['ID']
            if spot_id == nbr_id: # self in labelled set
                continue
            nbr_x = neighbor['POSITION_X']
            nbr_y = neighbor['POSITION_Y']
            nbr_z = neighbor['POSITION_Z']
            nbr_int = neighbor['RawIntDen']
            dist = distance.euclidean((spot_x, spot_y, spot_z), 
                                      (nbr_x, nbr_y, nbr_z))
            if dist < 0.5: # most likely to be self in unlab
                continue
            if dist < 6: # aim is to identify centromsome pairs at congression
                int_diff = abs(spot_int - nbr_int)
                neighbors_list.append([
                        spot['name'], neighbor['name'],
                        dist, int_diff,nbr_x, nbr_y, nbr_z, nbr_int,
                        spot_x, spot_y, spot_z, spot_int,
                         t])
       
        if len(neighbors_list)==0:
            continue
         # append ground truth
        for nbr in neighbors_list:
            if nbr[1][:-2] == nbr[0][:-2]:
                dist_inten_data_minIntDiff.append(nbr)
                minIntDiff = nbr[3] + 1000
      
        # comment out below to get ref containing only ground truth
        for nbr in neighbors_list:
            if nbr[1][0:4] == 'Cent':
                continue
            if nbr[3] < minIntDiff:
#                minIntDiff = nbr[3]
                dist_inten_data_minIntDiff.append(nbr)
   
                
         
dist_inten_minIntDiff_df = pd.DataFrame(dist_inten_data_minIntDiff, 
                             columns = ['I_NAME', 'J_NAME',
                                        'DIST_IJ', 'DIFF_INTEN',
                                        'J_POS_X', 'J_POS_Y', 'J_POS_Z','J_INT',
                                        'I_POS_X', 'I_POS_Y', 'I_POS_Z','I_INT',
                                          'FRAME']) 


        
    
dist_inten_minIntDiff_df.to_csv ('dist_inten_minIntDiff.csv', index = None,
                                 header=True, float_format='%.5f')
    
    


