SISTEMA DE RECONOCIMIENTO DE GESTOS
GU�A R�PIDA


********************************************************
INSTALACI�N PREVIA
Para el funcionamiento del actual sistema se require que:
* librer�a Windows SDK se encuentre instala, y que se encuentre como una variable de entorno,
* Myo Armband est� conectado a trav�s de MYO Connect
https://developer.thalmic.com/downloads

********************************************************
PASOS A SEGUIR
Por favor, ejecute el script gestureRecognition.
Este script ejecuta la interfaz de usuario. Esta interfaz consta de 4 opciones:

* New User
Al presionar esta opci�n se inicia la rutina de entrenamiento necesaria para un nuevo usuario. Se requiere al usuario que ingrese 2 valores, el tiempo a grabar de cada gesto, y el n�mero de repeticiones para cada gesto. Los valores por defecto son 2 segundos y 5 repeticiones por gesto.

* Recognition
Esta opci�n ejecuta una funci�n recognitionScript que realiza la lectura y clasificaci�n de gestos en tiempo real por un tiempo definido. Varios par�metros son necesarios para ello (timeSeries,database,windowTime,Fb,Fa,numTry,numGestures,timeShiftWindow,kNN,probabilidadkNNUmbral,nameGestures).
Al usuario no se le piden settear estos par�metros, pero pueden ser modificados f�cilmente pues se encuentran en la parte superior del script "gestureRecognition".
El gesto resultante de la clasificaci�n pueden ser accedidos como variable global "gesto".

* Plot EMG
Plotea en tiempo real las se�ales EMG crudas.

* Testing
Rutina de entrenamiento para las pruebas. En este caso, las repeticiones son 30 y el tiempo es 5 segundos. Para realizar la comprobaci�n de resultados, existe el script "comprobacionTest".


********************************************************
Para mayores detalles del sistema, acceder al "Manual de usuario"