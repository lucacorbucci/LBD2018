# Laboratorio di Basi di dati - Anno accademico 2017/18

Questa repository contiene i files prodotti durante il corso di Laboratorio di Basi di dati.

La cartella operazioni contiene il file .pks e il file .pkb relativi alle operazioni PLSQL da me implementate ovvero:

  - isualizzaListaAmbulatorio
  - visualizzaMediciAmbulatorio
  - viewDettagliAmbulatorio
  - viewSpecializzazioniAmb
  - CONFERMAELIMINAZIONE
  - CONFERMAAMPLIAAMBULATORIO
  - CONFERMAMODIFICARESPONSABILE
  - CONFERMARIAPERTURA
  - addInAmbulatorio
  - insertAmbulatori
  - searchAmbulatorio 
  - CONFERMAMODIFICAAMB 
  - reportStudiEpPatologie
  - reportStudiEpAnalisi
  - studioEpidemiologico
  
Per ognuna di queste procedure nel file procedure.pks è disponibile una documentazione che spiega cosa viene svolto e i parametri necessari.

Nella cartella Script Python abbiamo:

- turni.py -> è lo script che ho utilizzato per generare l'elenco dei turni dei medici degli ambulatori
- generateMedico.py -> è lo script utilizzato per generare gli insert dei medici della clinica

Test degli script:
Nella cartella Test ci sono i due script, basta eseguire da terminale

```
python turni.py
```

Oppure 

```
python generateMedico.py
```

I file necessari all'esecuzione dei due script sono nella cartella Test.
