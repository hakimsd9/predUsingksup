"""
List of continuous variables
The continuous variables are those different from ['psu', 'stratum', 'weight', 'age'] 
"""

import pickle

def continuousVariables(fileName = 'listContinuousVariables'):
    continuousVar = ['psu', 'stratum', 'weight', 'age']
    with open(fileName, 'wb') as dst:
        pickle.dump(continuousVar, dst)

if __name__ == '__main__':
    from sys import argv
    continuousVariables()
