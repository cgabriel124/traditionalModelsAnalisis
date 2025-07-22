function myoTimerFunction()
% timer function for reading MYO. Data is transfered as global variables

global  emg  leido myoObject kAux

emg= myoObject.myoData.emg_log;
myoObject.myoData.clearLogs();
leido=1;
kAux=kAux+1;
end