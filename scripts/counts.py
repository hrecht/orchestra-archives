# -*- coding: utf-8 -*-
"""
Author: Hannah Recht
Analyze NY Phil archives data
Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml
"""

#import modules
import json
import re
from collections import Counter
from collections import OrderedDict
from lxml import etree
import operator

parser = etree.XMLParser(encoding="utf-8")
tree = etree.parse('../data/complete.xml', parser = parser)
root = tree.getroot()

# Count appearances by composers in dataset
def countcomposers():
    cnt = Counter()
    for composer in root.iter('composerName'):
        composerName = composer.text
        cnt[composerName] += 1
    result = dict(cnt)
    sorted_result = OrderedDict(sorted(result.items(), key=operator.itemgetter(1), reverse=True))
    with open('../data/composers.json', 'w', encoding='utf8') as f:
        json.dump(sorted_result, f, ensure_ascii=False)
countcomposers()

jsonfile = open('../data/complete.json', encoding='utf8')
programs = json.load(jsonfile)

# Count unique programs by season
def progsbyseason():
    c = Counter(i['season'] for i in programs)
    c = dict(c)
    print(c)
#progsbyseason()

# Count unique programs by orchestra by year
def orchsbyyear():
    out = []
    seasons = []
    for x in range(1842,2016):
        seasons.append({
            'num': x,
        })
        cnt = Counter(i['orchestra'] for i in programs if i['season']==x)
        result = dict(cnt)
        out.append({
            'season': x,
            'orchestras': result,
            })
    with open('../data/orchestrasbyyear.json', 'w') as f:
            json.dump(out, f)
#orchsbyyear()
