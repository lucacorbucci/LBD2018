#!/usr/bin/python
# -*- coding: utf-8 -*-

'''
    Esecuzione:

    python turni.py 
'''

import time
from random import randint
import time
import datetime
from datetime import timedelta



medici = []
ambulatori = []
specializzazioni = {}
durata_visita = {}
lista_spec = {}

class settimana:

    def __init__(self):
        self.mattina = {
                "lun": "",
                "mar": "",
                "mer": "",
                "gio": "",
                "ven": ""
            }
        self.pomeriggio = {
                "lun": "",
                "mar": "",
                "mer": "",
                "gio": "",
                "ven": ""
            }

'''
    La classe medico serve per rappresentare tutte le informazioni che riguardano il MEDICO
    come ad esempio nome, cognome, monte ore lavorative e centro sanitario in cui lavora
    In ambulatorio salviamo invece i nomi degli ambulatori dove il medico lavora
'''
class medico:

    def __init__(self, nome, cognome, id, monteOre, centroSanitario):
        self.nome = nome
        self.cognome = cognome
        self.id = id
        self.monteOre = monteOre
        self.centroSanitario = centroSanitario
        if(int(monteOre) == 1500):
            self.oreSettimanali = 30
            self.oreGiornaliere = 6
        elif(int(monteOre) == 1200):
            self.oreSettimanali = 25
            self.oreGiornaliere = 5
        else:
            self.oreSettimanali = 25
            self.oreGiornaliere = 5

        self.oreAssegnate = 0
        self.ambulatori_medico = []
        cal = settimana()
        self.orario = cal


    def appendAmbulatori(amb):
        self.ambulatori_medico.append(amb)


'''
    La classe ambulatorio serve per rappresentare tutte le informazioni che riguardano un Ambulatorio
    Per ogni ambulatorio ho una serie di stanze, il masssimo è maxstanze. Per ogni stanza viene creato
    un orario (classe settimana) in modo che poi
'''
class ambulatorio:

    def __init__(self, colore, maxStanze, centroSanitario,id):
        self.colore = colore
        self.maxStanze = maxStanze
        self.centroSanitario = centroSanitario
        self.turni = []
        self.id = id
        for i in range (0, int(maxStanze)):
            d = settimana()
            self.turni.append(d)


'''
    Funzione utilizzata per leggere i file con tutte le informazioni necessarie a generare l'orario
    Quindi viene letto il file dei medici, quello degli ambulatori, poi le specializzazioni e la durata_visita
'''
def extractData():
    with open("medici.sql") as fb:
        line = fb.readline()
        line = fb.readline().split(", ")
        i = 1

        while(line):
            m = medico(line[1].split("'")[1], line[2].split("'")[1], i, line[9], line[10].split(")")[0])
            medici.append(m)
            i+=1
            if(line):
                line = fb.readline()
            if(line):
                line = fb.readline().split(", ")

    with open("ambulatorio.sql") as fb:
        line = fb.readline()
        line = fb.readline().split(", ")
        i = 1

        while(len(line)>0):
            a = ambulatorio(line[0].split("'")[1],line[1], line[2], i)
            ambulatori.append(a)

            i+=1

            if(line):
                line = fb.readline()
            if(line):
                line = fb.readline().split(", ")


    with open("specializzazioni.sql") as fb:
          line = fb.readline()
          line = fb.readline().split(", ")


          while(len(line)>0):
              med = str(line[1].split(")")[0])
              spec = int(line[0].split("( ")[1])
              if med not in specializzazioni:
                   specializzazioni[med] = []
              specializzazioni[med].append(spec)

              # print line[0].split("( ")[1]
              # print line[1].split(")")[0]
              if(line):
                  line = fb.readline()
              if(line):
                  line = fb.readline().split(", ")


    with open("durata_visita.sql") as fb:
        line = fb.readline()
        line = fb.readline().split(", ")
        i = 1

        while(len(line)>0):
            d = line[2]

            durata_visita[i] = d

            i+=1

            if(line):
                line = fb.readline()
            if(line):
                line = fb.readline().split(", ")

'''
    Funzione che utilizziamo per assegnare ad un certo medico uno o più ambulatori in cui
    lavora
'''
def assignAmbulatori():

    for m in medici:
        if(int(m.monteOre) == 1500):
            if(int(m.centroSanitario) == 1):
                i1 = randint(0,1)
                m.ambulatori_medico.append(ambulatori[i1])

                i2 = randint(2,3)

                m.ambulatori_medico.append(ambulatori[i2])

                i3 = randint(4,5)

                m.ambulatori_medico.append(ambulatori[i3])

            elif(int(m.centroSanitario) == 2):
                m.ambulatori_medico.append(ambulatori[6])
                m.ambulatori_medico.append(ambulatori[7])
                m.ambulatori_medico.append(ambulatori[8])

            elif(int(m.centroSanitario) == 3):
                m.ambulatori_medico.append(ambulatori[9])

            elif(int(m.centroSanitario) == 4):
                m.ambulatori_medico.append(ambulatori[10])
                m.ambulatori_medico.append(ambulatori[11])

        elif(int(m.monteOre) == 1200):
            if(int(m.centroSanitario) == 1):
                i1 = randint(0,3)
                m.ambulatori_medico.append(ambulatori[i1])

                i2 = randint(4,5)
                m.ambulatori_medico.append(ambulatori[i2])

            elif(int(m.centroSanitario) == 2):
                i1 = randint(6,8)
                m.ambulatori_medico.append(ambulatori[i1])

                i2 = randint(6,8)
                while(i2 != i1):
                    i2 = randint(6,8)

                m.ambulatori_medico.append(ambulatori[i2])


            elif(int(m.centroSanitario) == 3):
                m.ambulatori_medico.append(ambulatori[9])

            elif(int(m.centroSanitario) == 4):
                m.ambulatori_medico.append(ambulatori[10])
                m.ambulatori_medico.append(ambulatori[11])

        else:
            if(int(m.centroSanitario) == 1):
                i1 = randint(0,3)
                m.ambulatori_medico.append(ambulatori[i1])

                i2 = randint(4,5)

                m.ambulatori_medico.append(ambulatori[i2])

            elif(int(m.centroSanitario) == 2):
                i1 = randint(6,8)
                m.ambulatori_medico.append(ambulatori[i1])

                i2 = randint(6,8)
                while(i2 != i1):
                    i2 = randint(6,8)

                m.ambulatori_medico.append(ambulatori[i2])

            elif(int(m.centroSanitario) == 3):
                m.ambulatori_medico.append(ambulatori[9])

            elif(int(m.centroSanitario) == 4):
                i1 = randint(10,11)
                m.ambulatori_medico.append(ambulatori[i1])



lista = []

'''
    Funzione con cui ad ogni medico assegnamo i turni di lavoro che deve svolgere.
'''
def assignTurni():
    for m in medici:
        for i in range(0,len(m.ambulatori_medico)):
            for stanza in range(0, (int(m.ambulatori_medico[i].maxStanze))):

                if(int(m.oreAssegnate) < int(m.oreSettimanali)):
                    specia = randint(0,len(specializzazioni[str(m.id)])-1)
                    if(m.ambulatori_medico[i].turni[stanza].mattina["lun"]=="" and m.orario.mattina["lun"]=="" and m.orario.pomeriggio["lun"]==""):
                        m.ambulatori_medico[i].turni[stanza].mattina["lun"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["lun"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 16, 9, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))

                    elif(m.ambulatori_medico[i].turni[stanza].mattina["mar"]=="" and m.orario.mattina["mar"]=="" and m.orario.pomeriggio["mar"]==""):
                        m.ambulatori_medico[i].turni[stanza].mattina["mar"]=str(m.id) + " " + str(stanza)
                        m.orario.mattina["mar"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 17, 9, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))



                    elif(m.ambulatori_medico[i].turni[stanza].mattina["mer"]=="" and m.orario.mattina["mer"]=="" and m.orario.pomeriggio["mer"]==""):
                        m.ambulatori_medico[i].turni[stanza].mattina["mer"]=str(m.id) + " " + str(stanza)
                        m.orario.mattina["mer"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 18, 9, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].mattina["gio"]=="" and m.orario.mattina["gio"]=="" and m.orario.pomeriggio["gio"]==""):
                        m.ambulatori_medico[i].turni[stanza].mattina["gio"]=str(m.id) + " " + str(stanza)
                        m.orario.mattina["gio"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 19, 9, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].mattina["ven"]=="" and m.orario.mattina["ven"]=="" and m.orario.pomeriggio["ven"]==""):
                        m.ambulatori_medico[i].turni[stanza].mattina["ven"]=str(m.id) + " " + str(stanza)
                        m.orario.mattina["ven"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 20, 9, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].pomeriggio["lun"]=="" and m.orario.pomeriggio["lun"]=="" and m.orario.mattina["lun"]==""):
                        m.ambulatori_medico[i].turni[stanza].pomeriggio["lun"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["lun"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 16, 15, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].pomeriggio["mar"]=="" and m.orario.pomeriggio["mar"]=="" and m.orario.mattina["mar"]==""):
                        m.ambulatori_medico[i].turni[stanza].pomeriggio["mar"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["mar"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 17, 15, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].pomeriggio["mer"]=="" and m.orario.pomeriggio["mer"]=="" and m.orario.mattina["mer"]==""):
                        m.ambulatori_medico[i].turni[stanza].pomeriggio["mer"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["mer"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 18, 15, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].pomeriggio["gio"]=="" and m.orario.pomeriggio["gio"]=="" and m.orario.mattina["gio"]):
                        m.ambulatori_medico[i].turni[stanza].pomeriggio["gio"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["gio"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 19, 15, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))


                    elif(m.ambulatori_medico[i].turni[stanza].pomeriggio["ven"]=="" and m.orario.pomeriggio["ven"]=="" and m.orario.mattina["ven"]==""):
                        m.ambulatori_medico[i].turni[stanza].pomeriggio["ven"]=str(m.id) + " " + str(stanza)
                        m.orario.pomeriggio["ven"]= str(m.id) + " " + str(stanza)
                        m.oreAssegnate += m.oreGiornaliere
                        if m.cognome not in lista:
                            lista.append(m.cognome)
                        data = datetime.datetime(2018, 4, 20, 15, 00, 00)
                        tmp_data = data
                        while(data < tmp_data + timedelta(hours=m.oreGiornaliere)):

                            print "INSERT INTO turno_medico (ID_TURNO, INIZIO, STANZA, MEDICO, AMB, SPECIALIZZ)"
                            print """VALUES (%s, %s, %d, %d, %d, %d);\n""" % ("idTurnoMedico.nextVal", "TO_TIMESTAMP('" + str(data) + "', 'YYYY-MM-DD HH24:MI:SS')", int(stanza), int(m.id), m.ambulatori_medico[i].id, specializzazioni[str(m.id)][specia])
                            data = data + timedelta(minutes=int(durata_visita[specializzazioni[str(m.id)][specia]]))





def printDebug():
    for m in medici:
        print m.nome, m.cognome, m.monteOre, m.centroSanitario, len(m.ambulatori_medico), m.oreAssegnate, m.id
        print "MATTINA ", m.orario.mattina
        print "POMERIGGIO ", m.orario.pomeriggio

    print len(ambulatori)
    for a in ambulatori:
        print a.centroSanitario, a.colore, a.maxStanze
        for x in a.turni:
            print "MATTINA: ", x.mattina
            print "POMERIGGIO: ", x.pomeriggio

    print specializzazioni
    print len(specializzazioni)

    print len(lista)



extractData()
assignAmbulatori()
assignTurni()
#printDebug()
