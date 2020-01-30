#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug  1 16:49:13 2019

@author: yifan
"""

# vrml2csv converter
# There is no support for features other than vertex coordinate, 
#   vertex normals, and coordinate indices.
# The script has been tested on a large vrml file created by Imaris, 
#   and running with python 3 under macOS10.14 



from numpy import matrix, savetxt
from normalcalc import getFaceNormal


def list2csv(myList, fname, FMT = '%.6f'):
    '''
    *************************************************************************
    *myList*: a 2D list of floating point numbers                           *
    *fname*: name of the output csv file                                    *
    *************************************************************************
    *This function converts a 2D list to a csv (with index and no header)   *
    *************************************************************************
    '''
    mat = matrix(myList) #list to matrix
    savetxt(fname, mat.astype(float),fmt = FMT, delimiter=',')
   

 
def vrml2csv(f, root, calculateFaceNormal = False):
    '''
    **************************************************************************
    *f*: file pointer, to a vrml file                                        * 
    *root*: string of the root name of vrml                                  *
    * (all csv files will be written in the same directory)                  *
    * e.g., 'root = '/Users/username/mydir/2018-01-24_GSC_L4_L4440RNAi_reg'  *
    **************************************************************************
    *This function reads a vrml file line by line,                           *
    * parses vertex coordinate, vertex normal, and coordinate index per node.*
    *The output is a set of csv files in the same directory as the vrml file:* 
    * e.g. suffix '_normal_2': vertex normal of the second geometry node     *
    **************************************************************************
    '''
    nodeCount = 0
    while 1 :   # skip initial parameters    
      ln=f.readline().split() #python3
      # termination condition:
      eof = 0
      while ln == []:
             ln=f.readline().split()
             eof += 1
             if eof > 10:
                 return

      if (ln !=[]) and (ln[0] == 'point'):
          nodeCount+=1
          coord = []
          print('Reading vertex coordinates.')      
          ln[4] = ln[4][:-1] 
          coord.append(ln[2:5]) #first coordinate
          while 1:
              ln = f.readline().split()
              if len(ln) > 2:
                  ln[2] = ln[2][:-1] #remove comma
                  coord.append(ln[0:3])
              if ln == ['}']:
                  list2csv(coord, root+'_coord_'+str(nodeCount)+'.csv')
                  break
                
          # get normal
          print('Reading normal vectors.')
          normalVector = []
          f.readline() #normal
          f.readline() #Normal {
          ln = f.readline().split()
          ln[4] = ln[4][:-1] #remove comma
          normalVector.append(ln[2:5])
          while 1:
              ln = f.readline().split()
              if len(ln)>2:
                  ln[2] = ln[2][:-1] 
                  normalVector.append(ln[0:3])
              if ln == ['}']:
                  list2csv(normalVector, root+'_normal_'+str(nodeCount)+'.csv')
                  break
          # then get coordIndex
          print('Reading coordinate indices.')
          coordIndex = []
          ln = f.readline().split() #first coordIndex 
          coordIndex.append([ln[2][:-1],ln[3][:-1],ln[4][:-1]])
          coordIndex.append([ln[6][:-1],ln[7][:-1],ln[8][:-1]])
          while 1:
              ln = f.readline().split()
              if len(ln) > 7:
                  coordIndex.append([ln[0][:-1],ln[1][:-1],ln[2][:-1]])
                  coordIndex.append([ln[4][:-1],ln[5][:-1],ln[6][:-1]])
              if len(ln) == 9:
                  list2csv(coordIndex, root+'_index_'+str(nodeCount)+'.csv',
                                                                  FMT = '%.0f') 
                  break
          # calculate face normal
          print('Calculating face normals.')
          if calculateFaceNormal == True:
              getFaceNormal(root, nodeCount)
         
if __name__ == "__main__":                
#    root = '/Users/yifan/worms/vrml2csv/2018-01-24_GSC_L4_L4440RNAi_reg'
    root=input('Please enter the root of your vrml file:')
    print('Converting ',root+'.wrl...')
    f=open(root+'.wrl')
    vrml2csv(f,root, calculateFaceNormal = True)
