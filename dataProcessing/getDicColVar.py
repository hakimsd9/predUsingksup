"""
This code generates the dictionary {column number: corresponding variable}
where column number is the column number in the csv file with the new encoding

input: csv with the selected variables only and with headers
       dictionary of the number of classes
       dictionary of the number of classes with no BLU
       dictionary of the continuous variables
output: dictionary {column number: corresponding variable}
"""

from csv import reader, writer
import pickle

dicNumClasses = pickle.load(open('dictIDNumClasses','rb'))
dicNumClassesNoBLU = pickle.load(open('numberNoBLU' ,'rb')) 
dicContVar = pickle.load(open('listContinuousVariables','rb'))

def getDicColVar(csvFile = 'data.csv', deli = ','):
    position = 0
    dicColNum = {}
    with open(csvFile) as src:
        rdr = reader(src, delimiter = deli)
        headers = next(rdr)

        for k in range(len(headers)):
            if headers[k] in dicContVar:
                position += 1
                dicColNum[position] = headers[k]
            else:
                numClasses = dicNumClasses[headers[k]]
                numClassesNoBLU = dicNumClassesNoBLU[headers[k]]
                if numClassesNoBLU > 2:
                    for j in range(numClasses):
                        position += 1
                        dicColNum[position] = headers[k]
                elif numClassesNoBLU == 2:
                    for j in range(numClasses - 1):
                        position += 1
                        dicColNum[position] = headers[k]
    output = open('dictionaryColumnVariable', 'wb')
    pickle.dump(dicColNum, output)


if __name__ == '__main__':
    from sys import argv
    getDicColVar()
        

