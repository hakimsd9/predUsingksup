"""
Dictionary {id: (elements)}
id: identifier of the variable
elements: distinct elements present

Blanks are kept blanks
"""


import pickle
from csv import reader, writer
import numpy as np

def withoutBlanks(elements):
    result = []
    for k in elements:
        if k != '':
            result.append(k)
    return result
        
    

def content(csvFile = 'data.csv', destination = 'contentOfTheVariables'):
    content = dict()
    with open(csvFile, newline = '') as src:
        rdr = reader(src, delimiter = ',')
        for column in zip(*rdr):
            content[column[0]] = l = []
            found = set()
            elements = []
            
            for m in range(len(column[1:])):
                if column[1:][m] != '':
                    elements.append(float(column[1:][m]))
                else:
                    elements.append(column[1:][m])
        
            for k in column[1:]:
                if k == '' and k not in found:
                    l.append('')
                    found.add('')
                elif k not in found:
                    l.append(float(k))
                    found.add(k)
            print(column[0],len(content[column[0]]))      
    
    with open(destination, 'wb') as dst:
        pickle.dump(content, dst)
        

if __name__ == '__main__':
    from sys import argv
    content()
