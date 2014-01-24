"""
Number of Blanks and Unknowns
"""

import pickle

def numberOfBLU(destination = 'numberBLU'):
    numberClassesNoBLU = pickle.load(open('numberNoBLU','rb'))
    numberClasses = pickle.load(open('dictIDNumClasses','rb'))
    numberBLU = dict()
    for i in numberClassesNoBLU:
        numberBLU[i] = numberClasses[i] - numberClassesNoBLU[i]
    with open(destination, 'wb') as dst:
        pickle.dump(numberBLU, dst)


if __name__ == '__main__':
    from sys import argv
    numberOfBLU()
