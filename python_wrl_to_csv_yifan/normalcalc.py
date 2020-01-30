#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug  5 11:43:22 2019

@author: yifan
"""

#normalcalc
from numpy import genfromtxt,savetxt, subtract,cross

def normal(v0, v1, v2, ccw = True):
    if ccw == True: 
        return cross(subtract(v1,v0),subtract(v2,v1)).astype(float)
    elif ccw == False:
        return cross(subtract(v1,v0),subtract(v2,v0)).astype(float)

def getFaceNormal(root, nodeCount, CCW = True):
    coord = genfromtxt(root+'_coord_'+str(nodeCount)+'.csv', delimiter=',')
    index = genfromtxt(root+'_index_'+str(nodeCount)+'.csv', delimiter=',')
    faceNormal = []
    for face in index:
        v0 = coord[int(face[0])]
        v1 = coord[int(face[1])]
        v2 = coord[int(face[2])]
        n = normal(v0, v1, v2, ccw=CCW)
        faceNormal.append(n)
    savetxt(root+'_faceNormal_'+str(nodeCount)+'.csv',
               faceNormal,fmt = '%.6f', delimiter=',')
