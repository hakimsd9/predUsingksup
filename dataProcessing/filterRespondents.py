"""
Filter the csv file so as to keep only the respondents  who answered 3 to ALCABDEP12DX or 3 to ALCABDEPP12DX 
"""

from csv import reader, writer


def createCsv(csvInput, csvOutput = 'filteredW1nesarc.csv', delim = ','):
    with open(csvInput) as src, open(csvOutput, 'w', newline = '') as dst:
        rdr = reader(src, delimiter = delim)
        wrt = writer(dst, delimiter = delim)
        headers = next(rdr)
        wrt.writerow(headers)
        
        for k in range(len(headers)):
            if headers[k] == 'ALCABDEP12DX'.lower():
                ind1 = k

        for k in range(len(headers)):
            if headers[k] == 'ALCABDEPP12DX'.lower():
                ind2 = k
        to_write = [row for row in rdr if row[ind1] == '3' or row[ind2] == '3']
        wrt.writerows(to_write)



if __name__ == '__main__':
    from sys import argv
    createCsv(argv[1])
