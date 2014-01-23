"""
Generates the dictionary {parameter_id: name_associated} and
stocks the result in a file 'output'
"""

import csv
import re
import pickle


def splitLine(line):
    """
    Reads a line in a file and returns a list of the words contained in this line
    """
    return [w for w in re.split('\W+', line) if w]

def searchName(lst, target):
    """
    Looks for the string "target" in the list of strings lst

    Parameters
        lst - list: list of strings
        target - str: string we are searching for
    Result
        lst[:idx] - str: The text after target, which corresponds to the name
    """
    idx = lst.index(target)
    return lst[idx:]


def getDictionary(textFile, csvFile, output, delim = ','):
    """
    Generates the dictionary {parameter_id: name_associated} and
    stocks the result in a file 'output'

    Parameters
        textFile - text file: the Codebook
        csvFile - csv: w1nesarc.csv
        output - text file: the file in which the dictionary will be dumped
        target - str: the word we are tracking
        delim - str: delimiter

    Result
        None
    """
    idNameLink = dict() # Dictionary giving the name
                    # associated with id            
                         
    with open(textFile, newline = '') as text, open(csvFile, newline = '') as src:
        dst = open(output, 'wb')
        
        my_reader = csv.DictReader(src)
        headers = my_reader.fieldnames

        for line in text.readlines():
            for idn in headers:
                if idn.upper() in splitLine(line):
                    name = searchName(splitLine(line), idn.upper())
                    n = ''
                    for i in name[1:]:
                        n = n + ' ' + i
                    idNameLink[idn] = n

        pickle.dump(idNameLink, dst)


if __name__ == '__main__':
    from sys import argv
    if 4 <= len(argv) <=5:
        getDictionary(*argv[1:])
    else:
        print("Invalid number of arguments")
    print("Done")


                
