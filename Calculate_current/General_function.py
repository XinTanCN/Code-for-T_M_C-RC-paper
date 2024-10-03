# -*- coding: utf-8 -*-
"""
Created on Mon Nov 27 09:38:15 2023

@author: Tan Xin  tanxin@buaa.edu.cn
"""

import os
import fnmatch

#%% Search files and return path

def search_files(folder_path, keyword):

    matching_files = []

    for root, dirs, files in os.walk(folder_path):
        for file in files:

            if fnmatch.fnmatch(file, keyword):

                file_path = os.path.join(root, file)
                matching_files.append(file_path)

    return matching_files