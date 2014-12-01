"""
read dictionary column variables and list of highest reanked variables
filter processed.csv to keep the first column of each of these variables only
"""

import pickle
from csv import reader, writer

def selectedColumns(listVars, dictionaryColVar):
    """
    read the indices of top variables
    save the first column number they correspond to
    """
    content = []
    with open(listVars) as lV:
        Acontent = lV.readlines()

    for a in Acontent:
        content.append(a[:len(a)-1].lower())

    selectedCols = []
    
    dic = pickle.load(open(dictionaryColVar,'rb'))
    for var in content:
        for col in dic.keys():
            if dic[col] == var:
#                print(var + ' col ' + str(col))
                selectedCols.append(col)
                break

    return selectedCols

def generateFilteredCSV(originalCsv, selectedCol, newCsv = 'topVarsOneCol.csv', delim = ','):
    """
    Generate the filtered csv
    """
    i = 0
    to_write = []
    
    with open(originalCsv) as src, open(newCsv, 'w', newline ='') as dst:
        rdr = reader(src, delimiter = delim)
        wrt = writer(dst, delimiter = delim)

        for i in selectedCol:
            j = 0
            for col in zip(*rdr):
                j+=1
                if j == i:
                    src.seek(0)
                    to_write.append(col)
        wrt.writerows(zip(*to_write))

            
#        for col in zip(*rdr):
#            i += 1
#            if i in selectedCol:
#                print('appending column ' + str(i))
#                src.seek(0)
#                to_write.append(col)
#        wrt.writerows(zip(*to_write))

    
if __name__ == '__main__':
    from sys import argv
    if len(argv) == 4:
        selCols = selectedColumns(argv[1], argv[2])
        generateFilteredCSV(argv[3], selCols)

    else:
        print("USAGE: fileContainingVariablesNames dictionaryVarCol processedCSV.csv".format(argv[0]))
