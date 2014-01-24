"""
Generates the dictionary {ID: Number of classes}

Blanks and Unknowns are counted as classes

Input
    csvFile - csv: filteredW1nesarc.csv

Output
    dictIDNumClasses - binary: dictionary {ID: Number of distinct classes}
"""

import pickle
import csv

def generateDictionary(csvFile, destination = 'dictIDNumClasses', delim = ','):
    idNumClasses = dict()
    with open(csvFile) as src, open(destination, 'wb') as dst:
        data = csv.reader(src, delimiter = delim)
        for column in zip(*data):
            classes = []
            for k in column[1:]:
                if k not in classes:
                    classes.append(k)
            print(column[0],len(classes))
            idNumClasses[column[0]] = len(classes)
        pickle.dump(idNumClasses, dst)


if __name__ == '__main__':
    from sys import argv
    generateDictionary(argv[1])
            
