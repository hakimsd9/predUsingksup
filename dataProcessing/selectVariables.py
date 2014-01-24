"""
Generate csv file containing the selected parameters

blocksCsv: IDsOfTheSelectedVariables

usage: python3 selectVariables.py selectedVariables.csv w1nesarc.csv 
"""

from csv import reader, writer


def selectedVariables(blocksCsv, delim = ','):
    listSelectedVar = []
    
    with open(blocksCsv) as src:
        rdr = reader(src, delimiter = delim)
        for row in rdr:
            if len(row) != 0:
                listSelectedVar.append(row[0])
    
    return listSelectedVar


def generateCsvBlocks(blocksCsv, originalCsv, newCsv = 'filteredVariablesW1nesarc.csv', delim = ','):
    selectedVar = selectedVariables(blocksCsv)
   
    i = 0
    m = len(selectedVar)
    to_write = []
    
    with open(originalCsv) as src, open(newCsv, 'w', newline ='') as dst:
        rdr = reader(src, delimiter = delim)
        wrt = writer(dst, delimiter = delim)
        
        while i < m:
            print(i+1,'/', m)
            var = selectedVar[i]

            for col in zip(*rdr):
                src.seek(0)
                if col[0] == var.lower():
                    print(col[0])
                    to_write.append(col)
        
            i += 1
        wrt.writerows(zip(*to_write))

if __name__ == '__main__':
    from sys import argv
    if len(argv) == 3:
        generateCsvBlocks(argv[1], argv[2])

    else:
        print("USAGE: csvfile_containing_the_blocks w1nesarc.csv".format(argv[0]))
    
