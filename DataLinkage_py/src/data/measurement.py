"""
Created on 1 May 2020

@author: shree

Modified by Zijian on Aug 2022
"""


def load_benchmark(path):
    try:
        with open(path, 'r') as f:
            benchmark = f.read().splitlines()
        if benchmark is None:
            print("no file.")
        return benchmark
    except:
        print("Error occurred. Check if file exists")

def calc_measure(results, benchmark):
    if len(results) == 0:
        print('Precision = 0, Recall = 0, Fmeasure = 0')
        return
    count = 0
    for pair in results:

        if pair in benchmark:
            count = count + 1
    if count == 0:
        print('Precision=0, Recall=0, Fmeasure=0')
        return
    precision = count / len(results)
    recall = count / len(benchmark)
    f_measure = 2 * precision * recall / (precision + recall)
    print("Precision=", precision, ", Recall=", recall, ", Fmeasure=", f_measure)
    return

