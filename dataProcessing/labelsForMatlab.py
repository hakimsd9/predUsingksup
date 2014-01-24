"""
Read data.csv file
Write the list of parameters as a numpy vector
Save this vector in a format readable by matlab
"""

import numpy as np
from csv import reader, writer
import scipy.io as sio
import pickle

dicNumClasses = pickle.load(open('dictIDNumClasses','rb'))
dicNumClassesNoBLU = pickle.load(open('numberNoBLU' ,'rb')) 
dicContVar = pickle.load(open('listContinuousVariables','rb'))

def getListVar(csvFile = 'data.csv', deli = ','):
    position = -1
    listColName = []
    with open(csvFile) as src:
        rdr = reader(src, delimiter = deli)
        headers = next(rdr)
        for k in range(len(headers)):
            if headers[k] in dicContVar:
                position += 1
                listColName.append(0)
                listColName[position] = headers[k]
            else:
                numClasses = dicNumClasses[headers[k]]
                numClassesNoBLU = dicNumClassesNoBLU[headers[k]]
                if numClassesNoBLU > 2:
                    for j in range(numClasses):
                        position += 1
                        listColName.append(0)
                        listColName[position] = headers[k]
                elif numClassesNoBLU == 2:
                    for j in range(numClasses - 1):
                        position += 1
                        listColName.append(0)
                        listColName[position] = headers[k]
    listColName = np.array(listColName)    
    sio.savemat('np_labels.mat',{'labels':listColName})

if __name__ == '__main__':
    from sys import argv
    getListVar()

