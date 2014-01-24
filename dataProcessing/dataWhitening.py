"""
Whitening of the data
"""

import numpy as np
from csv import reader, writer

def withoutBlanks(elements):
    """
    For each variable (column of the csv file) returns the list of elements that are not blanks
    """
    result = []
    for k in elements:
        if k != '':
            result.append(float(k))
    return result


def treatCol(col):
    """
    Compute the mean and the standard deviation of the column 'col'
    if std != 0: replace the elements of the column by:
    (element-mean)/std
    Otherwise, write 'NaN' in the entire column 
    """
    res = []
    inp = [k for k in col[1:]] # Create a list containing the elements
                            # of the column
    mean = np.mean(withoutBlanks(inp))
    std = np.std(withoutBlanks(inp))
    for k in inp:
        if k != '': 
            if std != 0:
                res.append((float(k)-mean)/std)
            else:
                res.append('NaN')
        elif k == '':
            res.append('')
            
    return [col[0]]+ res


def whitening(csvFile = 'filteredW1nesarc.csv', output = 'data.csv', deli = ','):
    """
    Whitening of the data
    Replaces the elements of the column by (element-mean)/std
    """
    with open(csvFile) as src, open(output, 'w') as dst:
        rdr = reader(src, delimiter = deli)
        wrt = writer(dst, delimiter = deli)
        to_write = [treatCol(col) for col in zip(*rdr)]
        wrt.writerows(zip(*to_write))


if __name__ == '__main__':
    from sys import argv
    whitening()

