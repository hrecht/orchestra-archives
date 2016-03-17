# -*- coding: utf-8 -*-
"""
Author: Hannah Recht
Save main NY Phil archives data as CSVs - program header info, works info, concerts info
Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml
"""

import csv
from lxml import etree
import datetime

parser = etree.XMLParser(encoding="utf-8")
tree = etree.parse('../data/complete.xml', parser = parser)
root = tree.getroot()

# header info for each program
def headers():
    with open('../data/programs_main.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["programid","orchestra", "id", "season", "nconcerts", "nworks"])
        for program in root.iter('program'):
            programID = int(program.find('programID').text)
            orchestra = program.find('orchestra').text
            id = program.find('id').text
            season = int((program.find('season').text)[:4])
            # Count number of concerts given and works
            nconcerts = 0
            nworks = 0
            for concert in program.iter('concertInfo'):
                nconcerts += 1
            for work in program.iter('work'):
                # Don't count intermissions
                if (work.find('interval')) == None:
                    nworks += 1
            writer.writerow([programID, orchestra, id, season, nconcerts, nworks])
headers()

# work info for each work performed - programID, # in program, composer, title, conductor
def works():
    with open('../data/programs_works.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["programid", "workid", "worknumber", "composer", "work", "conductor", "movement", "movementid"])
        for program in root.iter('program'):
            programID = int(program.find('programID').text)
            worknumber = 0
            for work in program.iter('work'):
                # Only do non-intermissions
                if (work.find('interval')) == None:
                    worknumber += 1
                    workID = work.get('ID')
                    row = [programID, workID, worknumber]
                    # Add work-level data
                    for var in ["composerName", "workTitle", "conductorName", "movement"]:
                        if work.find(var) != None:
                            lvar = work.find(var).text
                        elif work.find(var) == None:
                            lvar = ""
                        row.append(lvar)
                    # Movement ID if it exists
                    if work.find('movement') != None:
                        movementID = work.find('movement').get('ID')
                    elif work.find('movement') == None:
                         movementID = ""
                    row.append(movementID)
                    writer.writerow(row)
works()

# programID, concert info for each concert
def concerts():
    with open('../data/programs_concerts.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["programid", "concertnumber", "eventtype", "location", "venue", "date", "time"])
        for program in root.iter('program'):
            programID = int(program.find('programID').text)
            concertnumber = 0
            for concert in program.iter('concertInfo'):
                eventType = concert.find('eventType').text
                concertnumber += 1
                location = concert.find('Location').text
                venue = concert.find('Venue').text
                # Date field time component is inaccurate, per data documentation
                date = (concert.find('Date').text)[:10]
                # Format 12 hour + AM/PM string into 24 hour time
                rawtime = concert.find('Time').text
                if rawtime != "None":
                    formattime = datetime.datetime.strptime(rawtime, '%I:%M%p').strftime('%H:%M')
                elif rawtime=="None":
                    formattime = ""
                writer.writerow([programID, concertnumber, eventType, location, venue, date, formattime])
concerts()