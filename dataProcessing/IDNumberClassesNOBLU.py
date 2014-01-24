"""
Generates the dictionary {ID: Number of classes}

Blanks and Unknowns are NOT considered as classes

csvFile: filteredW1nesarc.csv
"""

import pickle
import csv

unknownNumbers = pickle.load(open('dictUnknownNumbers', 'rb'))

def generateDictionary(csvFile, destination = 'numberNoBLU', delim = ','):
    idNumClasses = dict()
    
    with open(csvFile) as src, open(destination, 'wb') as dst:
        data = csv.reader(src, delimiter = delim)
        for column in zip(*data):
            if column[0].upper() in unknownNumbers:
                classes = []
                for k in column[1:]:
                    if k not in classes:
                        if k != unknownNumbers[column[0].upper()]:
                            if k != '':
                                classes.append(k)
                idNumClasses[column[0]] = len(classes)
            else:
                idNumClasses[column[0]] = 0
        pickle.dump(idNumClasses, dst)


if __name__ == '__main__':
    from sys import argv
    generateDictionary(argv[1])
                
