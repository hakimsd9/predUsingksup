"""
This code generates the dictionary
{Id (if contains 'Unknown'): number corresponding to 'unknown'}
It goes through the file 'w1codebook.txt' to find 'Unknown' and retrieves
the corresponding number
"""


import pickle
from csv import reader
import re

def selectedVariables(blocksCsv, delim = ','):
    listSelectedVar = []

    with open(blocksCsv) as src:
        rdr = reader(src, delimiter = delim)
        for row in rdr:
            if len(row) != 0:
                listSelectedVar.append(row[0])

    return listSelectedVar


def splitLine(line):
    """
    Stock each element of the string 'line' in a list

    Input
        line - str: The line we want to split
    Output
        list of the elements contained in the line    
    """
    return [w for w in re.split('\W+', line) if w]

def searchNumber(lst, target):
    """
    Looks for the number preceding 'target'
    In 'w1codebook.txt', the lines containing 'Unknowns' are written like:
    number_of_respondants_who_answered_'Unknown'    number_looked_for     'Unknown'
    """
    idx = lst.index(target) # find the index of 'target' in the list lst
    return lst[idx-1]  # retrieve the preceding element
                       # (containing the number we are looking for)


def idNumber(textFile, variablesOfInterest = 'selectedVariables.csv', destination = 'dictUnknownNumbers', target = 'Unknown'):
    """
    input
        textfile: 'w1codebook.txt' 
        variablesOfInterest - csv: IDs of the variables we chose to keep
        target - str: the value we are looking for ('Unknown')
        destination: the file where we will write the dictionary
        
    output
        dictUnknownNumbers - dict: dictionary {id: number_for_unknown}
        
    """
    idNumberLink = dict()
    ids = selectedVariables(variablesOfInterest) # list of all the ids
    
    with open(textFile, 'r') as src:
        for line in src:    # for each line in the text file
            for idn in ids:    # look for each id in the list of ids
                if idn in line: # if the line contains an id
                    temp = idn    # we stock it in the variable temp
            if target in line:    # if the target is in the same line
                num = searchNumber(splitLine(line), target) # we retrieve the
                            # corresponding number
                idNumberLink[temp] = num # and this number is stocked in the
                    # dictionary

    with open(destination, 'wb') as dst:  # we then stock this dictionary
        pickle.dump(idNumberLink, dst)  # in the destination file


if __name__ == '__main__':
    from sys import argv
    
    if len(argv) == 2:
        idNumber(argv[1])
        
    else:
        print("USAGE: {} w1codebook.txt".format())     
                
