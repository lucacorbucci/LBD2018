'''
Generazione dei medici della clinica. Per ogni medico vanno generate le seguenti informazioni:
- ID del medico
- Nome del medico
- Cognome
- sesso
- codice fiscale
- stipendio
- telefono
- email
- flag direttore
- flag responsabile
- data di nascita
- monte ore annuale
- stato attuale tra OPERATIVO, NON OPERATIVO, LICENZIATO
- centro sanitario in cui lavora
'''

import json
from random import randint
import random
import cf

tmp_cognomi = []
cognomi = []
nomi = []
sesso = []
date = []
date_format = []
stipendio = []
email = []
codiceFiscale = []
telefono = []
monteore = []
mesi = ["JAN", "FEB","MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
specializzazioni = []
tempo = []
costo = []

month = {
"JAN": "1",
"FEB" : "2",
"MAR" : "3",
"APR" : "4",
"MAY" : "5",
"JUN" : "6",
"JUL" : "7",
"AUG" : "8",
"SEP" : "9",
"OCT" : "10",
"NOV" : "11",
"DEC" : "12"
}


def generateSurname():
    with open("cognomi.txt") as fc:
        line = fc.readline().splitlines()

        while(line):
            tmp_cognomi.append(line[0])
            line = fc.readline().splitlines()


    for i in range (0,60):
        index = randint(0,600)
        cognomi.append(tmp_cognomi[index].lower())

def generateName():
    data = json.load(open('nomi.json'))
    for i in range (0,60):
        index = randint(0,100)
        nomi.append(data["male"]["mostUsed"][index]["name"].lower())
        sesso.append("m")
        nomi.append(data["female"]["mostUsed"][index]["name"].lower())
        sesso.append("f")

def generateDate():
    for i in range(0,20):
        year = randint(1965,1975)

        day = randint(1,28)
        m = randint(0,11)
        date.append(str(day) + "-" + str(mesi[m]) + "-" + str(year))
        date_format.append(str(day) + "/" + str(month[mesi[m]]) + "/" + str(year))

        year = randint(1975,1985)

        day = randint(1,28)
        m = randint(0,11)
        date.append(str(day) + "-" + str(mesi[m]) + "-" + str(year))
        date_format.append(str(day) + "/" + str(month[mesi[m]]) + "/" + str(year))

        year = randint(1990,2000)

        m = randint(0,11)
        day = randint(1,28)
        date.append(str(day) + "-" + str(mesi[m]) + "-" + str(year))
        date_format.append(str(day) + "/" + str(month[mesi[m]]) + "/" + str(year))

        year = randint(1970,1980)

        day = randint(1,28)
        m = randint(0,11)
        date.append(str(day) + "-" + str(mesi[m]) + "-" + str(year))
        date_format.append(str(day) + "/" + str(month[mesi[m]]) + "/" + str(year))





def generateStipendio():
    ore = [80, 100, 125]
    for i in range (0,20):
        stip = round(random.uniform(1500,3000), 2)
        stipendio.append(stip)
        if(stip > 2500):
            index = 2
        elif (stip < 2000):
            index = 0
        else:
            index = 1
        monteore.append(ore[index]*12)


def generateTelefono():
    pre = [339, 346, 392,  380, 320]

    for y in range(0,60):
        num = ""
        for i in range(0,7):
            num += str(randint(0,9))
        index = randint(0,4)
        telefono.append(str(pre[index]) + num)



def generateCF():
    for i in range (0,60):

        codiceFiscale.append(cf.calcola_cf(cognomi[i], nomi[i],date_format[i],sesso[i],""))

def generateEmail():
    for i in range(0,60):
        mail = nomi[i] + "." + cognomi[i] + "@gmail.com"
        email.append(mail)

def generateSpecializzazione():
    with open("specializzazione.txt") as fb:
        line = fb.readline().split(" - ")


        while(len(line)>1):
            specializzazioni.append(line[0].lower())
            tempo.append(int(line[1]))
            costo.append(int(line[2]))
            line = fb.readline().split(" - ")



def print_specializzazione():
    for i in range (0,26):
        print "INSERT INTO specializzazione (ID_SPEC, NOME, DURATAVISITA, IMPORTOBASE)"
        print """VALUES (%s, '%s', %d, %d);\n""" % ("idSpecSeq.nextVal", specializzazioni[i], tempo[i], costo[i])



def print_imp_medico():
    for i in range (0,20):
        print "INSERT INTO IMP_MEDICO (ID_MEDICO, NOME, COGNOME, SESSO, CF, STIPENDIO, TELEFONO, EMAIL, DATANASC, MONTEORE,CENTRO_SANITARIO)"
        print """VALUES (%s, '%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', %d, %s);\n""" % ("idImpiegatiSeq.nextVal", nomi[i], cognomi[i], sesso[i], codiceFiscale[i], stipendio[i], telefono[i], email[i], date[i], monteore[i], str(1))


def print_listaSpecializzazioni():
    for i in range (1,31):
        print "INSERT INTO lista_specializzazioni (ID_SPEC, ID_MEDICO)"
        if(i < 21):
            print """VALUES ( , %d);\n""" % i
        else:
            print """VALUES ( , );\n"""



def print_paziente():
    re = ['A', 'B', 'C', 'D']
    for i in range (0,60):
        y = randint(0,3)
        reddito = re[y]
        print "INSERT INTO paziente (ID_PAZIENTE, NOME, COGNOME, SESSO, CF, TELEFONO, EMAIL, REDDITO, DATANASC)"
        print """VALUES (%s, '%s','%s', '%s', '%s', '%s', '%s', '%s', '%s');\n""" % ("idPazienteSeq.nextVal", nomi[i], cognomi[i], sesso[i] ,codiceFiscale[i], telefono[i], email[i], reddito, date[i])



tipo = ['M', 'T']
# medico - tecnico - medico e responsabile ambulatorio - responsabile laboratorio e tecnico
dirittoM = ['00010000', '00110000']
dirittoT = ['00000100', '00001100']
def print_temp_insert():
    for i in range(0,10):
        index = randint(0,1)
        cur = randint(0,1)
        if(cur == 0):
            print "INSERT INTO utente (id_utente, username, pwd, diritti, tipo)"
            print """VALUES (%s, '%s','%s', %d, '%s');\n""" % ("seq_utente.nextVal", "user" + str(i), '1234', int(dirittoM[index], 2),tipo[cur])
        else:
            print "INSERT INTO utente (id_utente, username, pwd, diritti, tipo)"
            print """VALUES (%s, '%s','%s', %d, '%s');\n""" % ("seq_utente.nextVal", "user" + str(i), '1234', int(dirittoT[index], 2),tipo[cur])


generateName()
generateSurname()
generateDate()
generateCF()
generateStipendio()
generateTelefono()
generateEmail()
print_imp_medico()
#generateSpecializzazione()
#print_specializzazione()
#print_listaSpecializzazioni()
#print_temp_insert()
