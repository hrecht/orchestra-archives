# -*- coding: utf-8 -*-
"""
Author: Hannah Recht
Save NY Phil archives data XML as JSON
Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml
"""

#import modules
import xmltodict
import json

# Import XML data and parse as dictionary
with open('../data/complete.xml', encoding='utf8') as fd:
    complete = xmltodict.parse(fd.read())
 
# Just keep the programs
progs = complete["programs"]
pr = progs["program"]

# programID = integer, make season = integer of the starting year by keeping only the first four dgits
for i in pr:
    i["programID"] = int(i["programID"])
    i["season"] = int(((i["season"])[:4]))
   
# Save as json
with open('../data/complete.json', 'w', encoding='utf8') as f:
    json.dump(pr, f, ensure_ascii=False)    