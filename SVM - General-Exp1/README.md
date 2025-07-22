# Introduction

> This code is based on the paper entitled "An Energy-based Method for Orientation Correction of EMG Bracelet Sensors in Hand Gesture Recognition Systems" by Laboratorio de Investigación en Inteligencia y Visión Artificial “Alan Turing”
Escuela Politecnica Nacional
(C) Copyright 2020
## Data-set can be found in the following link:
https://laboratorio-ia.epn.edu.ec/es/recursos/dataset/2020_emg_dataset_612

## Data conversion from .json to .mat 
* Download the Training users dataset and paste it into the folder "trainingJSON".

* Download the Testing users dataset and paste it into the folder "testingJSON".

> Run jsontomat.m

* After executing jsontomat.m two folders will be generated:
   * TrainingData 
   * TestingData 
* Copy the user folders generated in "TrainingData"(*.mat format) and paste them in the "Data\General\training" folder.

* Copy the user folders generated in "TestingData"(*.mat format) and paste them in the "Data\General\testing" and "Data\Specific" folders.

## Instructions for Matlab:

> Run Main.m

> Select the experiment to run
## Parameters:
* Syncro: number of synchronization signals to test (1-4).

## Menu:

* Gesture Recognition
  * [1] Experiment 1       : This option runs the experiment 1
  * [2] Experiment 2       : This option runs the experiment 2
  * [3] Experiment 3       : This option runs the experiment 3
  * [4] Experiment 4       : This option runs the experiment 4
  * [5] Exit
 
      ## Select an option to run: 

      * Classification Models
        * [1] General       : This option runs the general model in the current experiment 
        * [2] Especific     : This option runs the specific model in the current experiment 
        * [3] Exit
## Evaluation
The result obtained in json format must be evaluated in the following link:

https://aplicaciones-ia.epn.edu.ec/webapps/home/session.html?app=EMG%20Gesture%20Recognition%20Evaluator
