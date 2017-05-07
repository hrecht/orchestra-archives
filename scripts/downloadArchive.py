# Download the latest New York Philharmonic Performance History metadata
# Source: https://github.com/nyphilarchive/PerformanceHistory)

from urllib.request import urlretrieve

urlretrieve("https://github.com/nyphilarchive/PerformanceHistory/raw/master/Programs/xml/complete.xml", "data/original/complete.xml")