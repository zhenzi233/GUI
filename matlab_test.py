# import matlab
import matlab.engine
import os
eng = matlab.engine.start_matlab()

path = "D:/py/image/MATLAB-SURF-G2NN"
result = os.path.exists(path)
print(result)

eng.cd(path,nargout=0)


ret = eng.CLAHESURFG2NN()
print(ret)