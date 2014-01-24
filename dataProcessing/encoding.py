"""
Encode the csv file
"""

import pickle
import numpy as np
from csv import reader, writer

continuousVar = pickle.load(open('listContinuousVariables','rb'))
numberClassesNoBLU = pickle.load(open('numberNoBLU','rb'))
numberBLU = pickle.load(open('numberBLU','rb'))
numberClasses = dict()

for k in numberClassesNoBLU:
    numberClasses[k] = numberClassesNoBLU[k] + numberBLU[k]


# dictionary {idSelectedVariable: numberClasses}

contentVar = pickle.load(open('contentOfTheVariables', 'rb'))

categoricalVar = {}

for k in numberClasses:
    if k not in continuousVar:
        categoricalVar[k] = numberClasses[k]

# have the dictionary of the categorical variables and their number of classes

def trunc(f, n):
    '''Truncates/pads a float f to n decimal places without rounding'''
    slen = len('%.*f' % (n, f))
    return str(f)[:slen]

def findIndex(myList, number):
    n = str(number)
    m = len(n)
    for elt in myList:
        e = str(elt)
        l = len(e)
        mi = min(m,l)
        if e[:mi-1] == n[:mi-1]:
            return myList.index(elt)

def sortContent (myList):
    loc_list = [ item for item in myList ]
    if '' in loc_list:
        loc_list.remove('')
        return sorted(loc_list) + ['']
    else:
        return sorted(loc_list)

def treatCsv(csvFile = 'data.csv', destination = 'processedData.csv'):
    """
    Create the new csv file taking into account the new encoding
    of the categorical variables
    """

    with open(csvFile, newline = '') as src, open(destination, 'w') as dst:
        rdr = reader(src, delimiter  = ',')
        wrt = writer(dst, delimiter = ',')
        headers = next(rdr)

        for row in rdr:
            to_write = []
            for k in range(len(row)):
                if headers[k] in categoricalVar:
                    content = contentVar[headers[k]]
                    for n in range(len(content)):
                        if content[n] == '':
                            content[n] = content[n]
                        elif type(content[n]) == float:
                            content[n] = content[n]
                        else:
                            content[n] = np.asscalar(content[n])
                    print('CONTENT', content)
                    content = sortContent(content)
                    
                    numClasses = numberClasses[headers[k]]
                    numClassesNoBLU = numberClassesNoBLU[headers[k]]
                    print('headers[k]',headers[k])
                    for n in range(len(content)):
                        # problem with sign -
                        if len(row[k]) <= 3:
                            content[n] = content[n]
                        elif content[n] == '':
                            content[n] = content[n]
                        elif content[n] <=0:    
                        #elif content[n][0] == '-':
                            content[n] = float(round(content[n], len(row[k])-3))
                        elif content[n] >=10:    
                            content[n] = float(round(content[n], len(row[k])-4))
                        else:
                            content[n] = float(round(content[n], len(row[k])-2))

                    
                    print('content',content)
                    print('row[k]',row[k])

                    ind = findIndex(content, row[k])
                    print('ind', ind)
                    if numClassesNoBLU > 2:
                        to_add = [0]*numClasses
                        to_add[ind] = 1

                    elif numClassesNoBLU == 2:
                        to_add = [0]*(numClasses - 1)
                        if ind == 0:
                            to_add[0] = 1
                        elif ind == 1:
                            to_add[0] = -1
                        else:
                            to_add[ind-1] = 1
                    to_write += to_add
                    
                    print(to_add)
                else:
                    to_write.append(float(row[k]))
            print(to_write)
            wrt.writerow(to_write)
            #output = open('dicVarColNum', 'wb')
            #pickle.dump(varDic,output)

if __name__ == '__main__':
    from sys import argv
    treatCsv()
