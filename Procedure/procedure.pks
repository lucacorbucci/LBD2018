create or replace package ProcedureLucaC as

/*
  Procedura che prende come parametro l'id sessione e si occupa di mostrare
  l'elenco di tutti gli ambulatori presenti all'interno dei vari centri sanitari.
  C'è anche la possibilità di filtrare l'elenco degli ambulatori in base al centro sanitario.
*/
procedure visualizzaListaAmbulatorio(
          id_sessione              in sessioni.id_sessione%TYPE DEFAULT NULL
  );

/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio
  e l'id sessione. Poi mostra l'elenco dei medici di un certo ambulatorio all'interno del popup.
  Cliccando sul nome di un medico potremo anche vedere i dettagli.
*/
procedure VisualizzaMediciAmbulatorio(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);
/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio
  ,l'id sessione e lo stato dell'ambulatorio (attino / non attivo).
  Poi mostra all'interno del popup tutti i dettagli relativi a quello specifico ambulatorio.
*/
procedure viewDettagliAmbulatorio(
        idAmb    	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        idCentro    in Ambulatorio.centro_sanitario%TYPE DEFAULT NULL,
        statoAmbulatorio    in Ambulatorio.stato%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id dell'ambulatorio e l'id sessione.
  Mostra le specializzazioni di un ambulatorio all'interno del popup.
*/
procedure viewSpecializzazioniAmb(
        select_ambulatorio    	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio
  e l'id sessione.
  Mi permette di rendere inattivo un certo ambulatorio selezionato.
  Il messaggio di conferma viene mostrato in un popup.
*/
procedure CONFERMAELIMINAZIONE(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio e il numero di stanze
  e l'id sessione.
  Mi permette di aumentare il numero di stanze di un ambulatorio.
  Il messaggio di conferma viene mostrato in un popup.
*/
procedure CONFERMAAMPLIAAMBULATORIO(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        newmaxStanze in ambulatorio.maxstanze%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio,
  l'id di un medico, e l'id sessione. Permette id modificare il responsabile di un
  certo ambulatorio.
  La conferma viene mostrata in un popup.
*/
procedure CONFERMAMODIFICARESPONSABILE(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);


/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio
  , l'id sessione e l'id del medico responsabile.
  Mi permette di rendere attivo un certo ambulatorio selezionato.
  Il messaggio di conferma viene mostrato in un popup.
*/
procedure CONFERMARIAPERTURA(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro, nome, indirizzo, numero di stanze, id del centro
  id del medico responsabile e id sessione.
  Si occupa dell'aggiornamento del database aggiungendo il nuovo ambulatorio che è stato
  inserito.
*/
procedure addInAmbulatorio(
        nome    	in Ambulatorio.NOME%TYPE DEFAULT NULL,
        indirizzo 	in Ambulatorio.Indirizzo%TYPE DEFAULT NULL,
        maxstanze	in Ambulatorio.MaxStanze%TYPE DEFAULT NULL,
        select_centro     in Ambulatorio.Centro_sanitario%TYPE,
        select_responsabile in Ambulatorio.Responsabile%TYPE,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id sessione.
  Permette di aggiungere un nuovo ambulatorio in un centro sanitario.
*/
procedure insertAmbulatorio(
  id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

/*
  Procedura che prende come parametro l'id del centro sanitario e
  l'id sessione.
  Permette di eseguire una query basandoci sull'elemento selezionato
  all'interno della select form del centro sanitario.
*/
PROCEDURE searchAmbulatorio(
  idCentro IN CENTRO_SANITARIO.ID_CENTRO%TYPE DEFAULT NULL,
  id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

PROCEDURE CONFERMAMODIFICAAMB (
          select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
          select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
          newmaxStanze in ambulatorio.maxstanze%TYPE DEFAULT NULL,
          select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
          statoAmbulatorio in ambulatorio.stato%TYPE DEFAULT NULL,
          id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL);

PROCEDURE reportStudiEpPatologie(
          idCentro    IN CENTRO_SANITARIO.ID_CENTRO%TYPE,
          inizioSett  IN VARCHAR2,
          idSessione  IN NUMBER DEFAULT NULL);

PROCEDURE reportStudiEpAnalisi(
          idCentro    IN CENTRO_SANITARIO.ID_CENTRO%TYPE,
          inizioSett  IN VARCHAR2,
          idSessione  IN NUMBER DEFAULT NULL);


PROCEDURE studioEpidemiologico(
        id_sessione  IN NUMBER DEFAULT NULL);

end procedureLucaC;
