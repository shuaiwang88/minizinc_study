import pymzn

pymzn.dict2dzn({'a': 2, 'b': {4, 6}, 'c': {1, 2, 3}, 'd': {3: 4.5, 4: 1.3}, 'e': [[1, 2], [3, 4], [5, 6]]})
data = {'a': 2, 'b': {4, 6}, 'c': {1, 2, 3}, 'd': {3: 4.5, 4: 1.3}, 'e': [[1, 2], [3, 4], [5, 6]]}

data["set_a"] = {"f1", "f2"}
pymzn.dict2dzn(data, fout='../../minizinc_labor/pymzn_test_data.dzn')

print(type(data))



