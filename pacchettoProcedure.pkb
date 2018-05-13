create or replace package body ProcedureLucaC as

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
    Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio
    e l'id sessione. Poi mostra l'elenco dei medici di un certo ambulatorio all'interno del popup.
    Cliccando sul nome di un medico potremo anche vedere i dettagli.
  */
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
PROCEDURE VisualizzaMediciAmbulatorio (
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

        rights number default 1;
        operativi number default 0;
        nonOp number default 0;
        licenziati number default 0;
BEGIN


DECLARE Cursor listaMedici is
    Select imp_medico.nome, imp_medico.cognome, imp_medico.id_medico, imp_medico.stato
    from imp_medico join centro_sanitario on imp_medico.centro_sanitario = centro_sanitario.id_centro join ambulatorio on ambulatorio.centro_sanitario = centro_sanitario.id_centro
    where ambulatorio.id_amb = select_ambulatorio and centro_sanitario.id_centro = select_centro;

BEGIN
/*
  L'elenco dei medici di un certo ambulatorio può essere visionato da :
   - Super user
   - DBA
   - Direttori del centro sanitario
   - Responsabili di un ambulatorio
*/
------------------------- DIRITTI --------------------------------------------
        SELECT BIN_TO_NUM(0,1,1,0,0,0,1,1) INTO rights FROM DUAL;
------------------------------------------------------------------------------

    if(loginlogout.checkRights(rights, id_sessione) > 0) then

        GUI.APRIDIV(attributi => 'id = ''visualMedici'' ');
        gui.aggiungiLineaVuota();


        for i in listaMedici
        loop
          if(i.stato = 0) THEN
            nonOp := nonOp + 1;
          elsif(i.stato = 1) THEN
            operativi := operativi + 1;
          elsif(i.stato = 2) THEN
            licenziati := licenziati + 1;
          end if;
        end loop;

        if(operativi > 0) then
          gui.apriTabella('Medici Operativi');
          for i in listaMedici
          loop
              if(i.stato = 1) then
              gui.apriRigaTabella();

              gui.creaCellaTabella('' || to_char(i.nome) || ' ' || to_char(i.cognome)  ||  '', eventJS => 'onclick', scriptJS => '
                  var url = '''|| GuiConst.root ||'getinfoMedico?'';
                  url = url + ''MED='' + ' || i.id_medico ||' + ''&'';
                  url = url + ''id_sessione='' + ' || id_sessione ||' ;
                  url = encodeURI(url);
                  console.log(url);
                  startRequest(url);
              ');
              gui.chiudiRigaTabella();
              end if;
          end loop;
        end if;

          gui.chiudiTabella();
        if (nonOp > 0) then
          gui.apriTabella('Medici Non operativi');

          for i in listaMedici
          loop
              if (i.stato = 0) then
              gui.apriRigaTabella();

              gui.creaCellaTabella('' || to_char(i.nome) || ' ' || to_char(i.cognome)  ||  '', eventJS => 'onclick', scriptJS => '
                  var url = '''|| GuiConst.root ||'getinfoMedico?'';
                  url = url + ''MED='' + ' || i.id_medico ||' + ''&'';
                  url = url + ''id_sessione='' + ' || id_sessione ||' ;
                  url = encodeURI(url);
                  console.log(url);
                  startRequest(url);
              ');
              gui.chiudiRigaTabella();
              end if;

          end loop;

          gui.chiudiTabella();
        end if;
        if(licenziati > 0) then
          gui.apriTabella('Medici Licenziati');

          for i in listaMedici
          loop
              if(i.stato = 2) then
              gui.apriRigaTabella();

              gui.creaCellaTabella('' || to_char(i.nome) || ' ' || to_char(i.cognome)  ||  '', eventJS => 'onclick', scriptJS => '
                  var url = '''|| GuiConst.root ||'getinfoMedico?'';
                  url = url + ''MED='' + ' || i.id_medico ||' + ''&'';
                  url = url + ''id_sessione='' + ' || id_sessione ||' ;
                  url = encodeURI(url);
                  console.log(url);
                  startRequest(url);
              ');
              gui.chiudiRigaTabella();
              end if;
          end loop;

          gui.chiudiTabella();
        end if;

        gui.aggiungiLineaVuota();
        gui.aggiungiLineaVuota();


        gui.chiudidiv();
    end if;

    exception
      when others then
        gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
        gui.aggiungiLineaVuota();
        gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');


end;
END VisualizzaMediciAmbulatorio;


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
  VISUALIZZAZIONE DETTAGLI AMBULATORIO
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio
  ,l'id sessione e lo stato dell'ambulatorio (attino / non attivo).
  Poi mostra all'interno del popup tutti i dettagli relativi a quello specifico ambulatorio.
*/
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
procedure viewDettagliAmbulatorio (
        idAmb    	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        idCentro    in Ambulatorio.centro_sanitario%TYPE DEFAULT NULL,
        statoAmbulatorio    in Ambulatorio.stato%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

    nomeAmb ambulatorio.nome%TYPE;
    indirizzoAmb ambulatorio.indirizzo%TYPE;
    maxStanzeAmb ambulatorio.maxstanze%TYPE;
    statoAmb ambulatorio.stato%TYPE;
    respAmb ambulatorio.responsabile%TYPE;
    nomeMed imp_medico.nome%TYPE;
    cognomeMedico imp_medico.cognome%TYPE;
    nomeCentro centro_sanitario.nome%TYPE;
    idMedico imp_medico.id_medico%TYPE;
    rights number default 1;

begin

    /*
      Distinguo due casi, il primo caso è quello in cui l'ambulatorio è attivo e funzionante, quindi ha anche un
      responsabile. Nel secondo caso invece l'ambulatorio è al momento chiuso e non ha un responsabile
    */
    if(statoAmbulatorio = 0) then
        select ambulatorio.nome, ambulatorio.indirizzo, ambulatorio.maxstanze, ambulatorio.stato, imp_medico.nome as nomeMedico, imp_medico.cognome as cognomeMedico, imp_medico.id_medico as idM, centro_sanitario.nome as nomeCentro, ambulatorio.responsabile
        into nomeAmb, indirizzoAmb, maxStanzeAmb, statoAmb, nomeMed, cognomeMedico, idMedico, nomeCentro, respAmb
        from ambulatorio join imp_medico on imp_medico.id_medico = ambulatorio.responsabile join centro_sanitario on centro_sanitario.id_centro = ambulatorio.centro_sanitario
        where ambulatorio.id_amb = idAmb;
    else
        select ambulatorio.nome, ambulatorio.indirizzo, ambulatorio.maxstanze, ambulatorio.stato, centro_sanitario.nome as nomeCentro
        into nomeAmb, indirizzoAmb, maxStanzeAmb, statoAmb, nomeCentro
        from ambulatorio join centro_sanitario on centro_sanitario.id_centro = ambulatorio.centro_sanitario
        where ambulatorio.id_amb = idAmb;
    end if;

    /*
      Popup che compare nel momento in cui clicco sul nome di un ambulatorio.
      All'interno del popup ci sono i dettagli degli ambulatori e poi ci sono due pulsanti, il pulsante OK e il
      pulsante modifica che serve per modificare i dettagli dell'ambulatorio.
      Se l'ambulatorio attualmente è aperto aggiungo anche un bottone che permette la chiusura dell'ambulatorio
    */
    gui.apriDiv('id = ''informazioni''');

    gui.aggiungiParagrafoPopup('<b>Nome Ambulatorio: </b> ' || nomeAmb ||' ');
    gui.aggiungiParagrafoPopup('<b>Indirizzo: </b> ' || indirizzoAmb ||' ');
    gui.aggiungiParagrafoPopup('<b>Numero di Stanze: </b> ' || maxStanzeAmb ||'  ');
    htp.print('<b>Centro Sanitario: </b>');

    htp.print('<a href=''#'' onclick= ''
            var v = "'|| GuiConst.root ||'"
            var url =  v + "'|| 'DETTAGLI_CENTRO_INS?' || '";
            url = url + "'|| 'id_sessione=' || '" + "'|| id_sessione || '" ;
            url = url + "'|| '&idcentro=' || '" + ' || idCentro ||' ;
            console.log(url);
            startRequest(url);
            ''
    > '|| nomeCentro ||' </a>');



    if(statoAmb = 0) then
    gui.aggiungiLineaVuota();
    gui.aggiungiLineaVuota();
        htp.print('<b>Responsabile: </b>');
        htp.print('<a href=''#'' onclick= ''
                var v = "'|| GuiConst.root ||'"
                var url =  v + "'|| 'getinfoMedico?' || '";
                url = url + "'|| 'MED=' || '" + "'|| idMedico || '" ;
                url = url + "'|| '&id_sessione=' || '" + ' || id_sessione ||' ;
                console.log(url);
                startRequest(url);
                ''
        > '|| nomeMed || ' ' ||cognomeMedico ||' </a>');

        gui.aggiungiParagrafoPopup('<b>Stato Ambulatorio:</b> ' || 'Aperto' || ' ');

        /*
          La parte sopra la possono vedere tutti quelli che hanno l'autorizzazione dalla pagina
          di visualizzazione della lista.
          Quindi poi il responsabile ad esempio che nella pagina principale si trova solamente il suo
          centro, qua trova visualizza medici e visualizza specializzazioni del suo centro
           - Il pulsante di modifica e di chiusura del centro lo vede solamente il DBA e il SU
        */

        gui.aggiungiBottone(mValue=>'Visualizza Medici',eventJS=>'onclick',scriptJS=>'{
                var url = '''|| GuiConst.root ||'ProcedureLucac.visualizzamediciambulatorio?'';
                url = url + ''select_centro='' + ' || idCentro ||' + ''&'';
                url = url + ''select_ambulatorio='' + ' || idAmb ||' + ''&'';
                url = url + ''id_sessione='' + ' || id_sessione ||';
                url = encodeURI(url);
                console.log(url);

                startRequest(url);

        }');
        gui.aggiungiBottone(mValue=>'Visualizza Specializzazioni',eventJS=>'onclick',scriptJS=>'{
                var url = '''|| GuiConst.root ||'aggiungispecamb?'';

                url = url + ''idAmb='' + ' || idAmb ||' + ''&'';
                url = url + ''id_sessione='' + ' || id_sessione ||';
                url = encodeURI(url);
                console.log(url);
                startRequest(url);

        }');

        gui.aggiungiLineaVuota();
        gui.aggiungiLineaVuota();
    else
        gui.aggiungiParagrafoPopup('<b>Stato:</b> ' || 'Chiuso' || ' ');
    end if;


    /* Questa parte la possono fare solamente
     il superuser e il DBA.
     Sono i pulsanti per la modifica e la chiusura dell'ambulatorio
    */
    SELECT BIN_TO_NUM(0,0,0,0,0,0,1,1) INTO rights FROM DUAL;

    if(loginlogout.checkRights(rights, id_sessione) > 0) then

      ---- Pulsante per la modifica dei dati dell'ambulatorio
      gui.aggiungiBottone(mValue=>'Modifica',eventJS=>'onclick',scriptJS=>'{

          md = 0;
          var url = '''|| GuiConst.root ||'ProcedureLucac.CONFERMAMODIFICAAMB?'';
          url = url + ''select_centro='' + ' || idCentro ||' + ''&'';
          url = url + ''select_ambulatorio='' + ' || idAmb ||' + ''&'';
          url = url + ''statoAmbulatorio='' + ' || statoAmb ||' + ''&'';
          url = url + ''id_sessione='' + ' || id_sessione ||';
          url = encodeURI(url);
          console.log(url)
          startRequest(url)

      }');

      if(statoAmb = 0) then

        --- Pulsante per chiudere un ambulatorio
        gui.aggiungiBottone(mValue=>'Chiudi Ambulatorio',eventJS=>'onclick',scriptJS=>'{

                  var url = '''|| GuiConst.root ||'ProcedureLucac.confermaeliminazione?'';
                  url = url + ''select_centro='' + ' || idCentro ||' + ''&'';
                  url = url + ''select_ambulatorio='' + ' || idAmb ||' + ''&'';
                  url = url + ''id_sessione='' + ' || id_sessione ||';
                  url = encodeURI(url);

                  var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');


                  xhttp=new XMLHttpRequest();
                  xhttp.onreadystatechange = function() {

                  if (xhttp.readyState == 4 || status == 200) {
                      a.innerHTML = '''';
                      a.innerHTML = this.responseText;

                  } }
                  xhttp.open(''GET'', url, true);
                  xhttp.send();
                  return false;

          }');

          end if;
    end if;


    gui.chiudiDiv;
    exception
      when others then
        gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
        gui.aggiungiLineaVuota();
        gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');


end viewDettagliAmbulatorio;



------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id dell'ambulatorio e l'id sessione.
  Mostra le specializzazioni di un ambulatorio all'interno del popup.
*/
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
procedure viewSpecializzazioniAmb(
        select_ambulatorio    	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

begin


    GUI.apriTabella('');

    gui.apriTestataTabella;
    for i in 1 .. 1
    loop
      gui.creaCampoTestataTabella('Nome');

    end loop;
    gui.chiudiTestataTabella;

    for i in (select specializzazione.nome, specializzazione.importobase
    from ambulatorio join copertura_amb on ambulatorio.id_amb = copertura_amb.id_amb join specializzazione on SPECIALIZZAZIONE.ID_SPEC = copertura_amb.id_spec
    where ambulatorio.id_amb = select_ambulatorio)
    loop
      gui.apriRigaTabella;

          gui.creaCellaTabella(to_char(i.nome));


      gui.chiudiRigaTabella;
    end loop;

    GUI.chiudiTabella;
    exception
      when others then
        gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
        gui.aggiungiLineaVuota();
        gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');


end viewSpecializzazioniAmb;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id sessione e si occupa di mostrare
  l'elenco di tutti gli ambulatori presenti all'interno dei vari centri sanitari.
  C'è anche la possibilità di filtrare l'elenco degli ambulatori in base al centro sanitario.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

procedure visualizzaListaAmbulatorio(
    id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL
)
is

rights number default 1;

begin

------------------------- FUNZIONI JAVASCRIPT --------------------------------------------
gui.AggiungiJavascript('

      var HTMLPagina = [];


      function startRequest(url){
          var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
          if(HTMLPagina[0] != a.innerHTML){
            HTMLPagina.push(a.innerHTML);
          }

          console.log(HTMLPagina.length);

          xhttp=new XMLHttpRequest();
          xhttp.onreadystatechange = function() {

          if (xhttp.readyState == 4 || status == 200) {
              a.innerHTML = '''';
              a.innerHTML = this.responseText;
              var b = document.createElement("button");
              b.className = ''bottone'';
              b.setAttribute(''onclick'',"a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body''); a.innerHTML = HTMLPagina.pop()");

              b.innerHTML = ''INDIETRO'';

              a.appendChild(b);
              dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
          } }
          xhttp.open(''GET'', url, true);
          xhttp.send();
          return false;
      }

      ');
------------------------------------------------------------------------------

------------------------- DIRITTI --------------------------------------------
      SELECT BIN_TO_NUM(0,1,1,0,0,0,1,1) INTO rights FROM DUAL;
------------------------------------------------------------------------------
GUI.APRIPAGINA('Elenco Ambulatori');

if(loginlogout.checkRights(rights, id_sessione) > 0) then



  GUI.APRIFINESTRAPOPUP('Informazioni', COSTANTIGRUPPO1.popup);
  gui.chiudifinestrapopup;


  PAGINEINCOMUNE.creaNavBar(id_sessione);

  GUI.AGGIUNGILINEAVUOTA;
  GUI.AGGIUNGILINEAVUOTA;
  GUI.AGGIUNGILINEAVUOTA;
  -- Controlliamo che la lista venga mostrata solamente a chi ha i diritti

      /*
        Se l'utente connesso è un DBA o un SP allora viene data la possibilità di filtrare
        gli ambulatori in base ai centri sanitari e poi viene mostrata tutta la lista degli
        ambulatori
      */
      if(loginlogout.getUserType(id_sessione) = 'SP' or loginlogout.getUserType(id_sessione) = 'DBA') then
            GUI.apriTabella('ELENCO AMBULATORI');
            gui.aggiungiJavascript('
            document.getElementsByTagName(''table'')[0].id = "myTab"
            ');

            gui.apriRigaTabella;

            gui.apriCellaTabella;
            gui.apriSelectForm('select_centro',false,'onChange',
              '

               cs = document.getElementsByName(''select_centro'')[0];
               a = cs.options[cs.selectedIndex].getAttribute(''value'');

               amb = document.getElementById(''myTab'').children[1];
               coun = document.getElementById(''myTab'').children[1].childElementCount

               if(cs.selectedIndex == 0){
                 for (i=3;i<coun;i++){
                        amb.children[i].style='''';
                        i+=1;
                        }
               }
               else{
                 for (i=3;i<coun;i++){
                     if(amb.children[i].getAttribute(''centro'') != a){

                         amb.children[i].style=''display:none'';
                         i+=1;
                    }
                    else{
                        amb.children[i].style=''display:block'';
                        i+=1;
                    }
               }

              };');

          gui.aggiungiOptionSelectForm(' ',selected=>TRUE);
          gui.AggiungiJavascript('ii = 1');

          for i in (select centro_sanitario.nome, centro_sanitario.id_centro from centro_sanitario)
          loop
              gui.aggiungiOptionSelectForm(i.id_centro, to_char(i.nome));

          end loop;
          gui.chiudiSelectForm;
          gui.chiudiCellaTabella;
          gui.chiudiRigaTabella;

          gui.apriTestataTabella;

          for i in 1 .. 1
          loop

            gui.creaCampoTestataTabella('Nome Ambulatorio');

          end loop;
          gui.chiudiTestataTabella;
          gui.AggiungiJavascript('
                index = 3;

                ');

          for i in (select ambulatorio.nome, ambulatorio.id_amb, ambulatorio.centro_sanitario, ambulatorio.stato, ambulatorio.maxstanze, centro_sanitario.nome as nomeCentro
          from ambulatorio join centro_sanitario on ambulatorio.centro_sanitario = centro_sanitario.id_centro )
          loop
            gui.apriRigaTabella;


                gui.creaCellaTabella('<br> Centro Sanitario ' || to_char(i.nomeCentro) || '<br> Ambulatorio ' || to_char(i.nome)  || '<br><br>' , eventJS => 'onClick', scriptJS  => '

                xhttp=new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
                if (xhttp.readyState == 4 || status == 200) {
                    a.innerHTML = '''';
                    a.innerHTML = this.responseText;
                    dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
                } }

                var url = '''|| GuiConst.root ||'ProcedureLucac.viewDettagliAmbulatorio?idAmb='';
                url = url + ''' || i.id_amb || '''
                url = url + ''&idCentro='' + ''' || i.centro_sanitario || ''';
                url = url + ''&statoAmbulatorio='' + ''' || i.stato || ''' + ''&'';
                url = url + ''id_sessione='' + '|| id_sessione ||';
                console.log(url);

                url = encodeURI(url);
                console.log(url);
                xhttp.open(''GET'', url, true);
                xhttp.send();
                return false;
                ');


            gui.chiudiRigaTabella;
            gui.aggiungiJavascript('
                document.getElementById(''myTab'').children[1].children[index].setAttribute(''centro'', ' || i.centro_sanitario || ');

                console.log(index);
                index = index+2;
                ');
          end loop;

          GUI.chiudiTabella;

          gui.aggiungiLineaVuota();
          gui.aggiungiLineaVuota();

          gui.aggiungiBottone('Aggiungi Nuovo Ambulatorio', 'Aggiungi Nuovo Ambulatorio', 'onclick', '
            md = 0;
            xhttp=new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
            var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
            if (xhttp.readyState == 4 || status == 200) {
                a.innerHTML = '''';
                a.innerHTML = this.responseText;
                dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
            } }


            var url = '''|| GuiConst.root ||'ProcedureLucac.insertAmbulatorio?'';
            url = url + ''id_sessione='' + ' || id_sessione ||';

            url = encodeURI(url);
            console.log(url)
            xhttp.open(''GET'', url, true);
            xhttp.send();
            return false;
            ');
      /*
        Se l'utente loggato è un dirigente di un centro sanitario, allora mostro
        nella lista degli ambulatori solamente gli ambulatori che sono nel suo centro sanitario
        gli fornisco anche la possibilità di vedere medici e specializzazioni di ogni ambulatorio.
      */
      else if (loginlogout.getUserType(id_sessione) = 'D') then
          GUI.apriTabella('ELENCO AMBULATORI');
          gui.aggiungiJavascript('
          document.getElementsByTagName(''table'')[0].id = "myTab"
          ');

          gui.apriRigaTabella;


          gui.apriCellaTabella;
          gui.apriTestataTabella;

          for i in 1 .. 1
          loop

            gui.creaCampoTestataTabella('Nome Ambulatorio');

          end loop;
          gui.chiudiTestataTabella;
          gui.AggiungiJavascript('
                index = 3;

                ');

          for i in (select ambulatorio.nome, ambulatorio.id_amb, ambulatorio.centro_sanitario, ambulatorio.stato, ambulatorio.maxstanze, centro_sanitario.nome as nomeCentro
          from ambulatorio join centro_sanitario on ambulatorio.centro_sanitario = centro_sanitario.id_centro
          where centro_sanitario.dirigente = loginlogout.getPersonFromSession(id_sessione))
          loop
            gui.apriRigaTabella;


                gui.creaCellaTabella('<br> Centro Sanitario ' || to_char(i.nomeCentro) || '<br> Ambulatorio ' || to_char(i.nome)  || '<br><br>' , eventJS => 'onClick', scriptJS  => '

                xhttp=new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
                if (xhttp.readyState == 4 || status == 200) {
                    a.innerHTML = '''';
                    a.innerHTML = this.responseText;
                    dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
                } }

                var url = '''|| GuiConst.root ||'ProcedureLucac.viewDettagliAmbulatorio?idAmb='';
                url = url + ''' || i.id_amb || '''
                url = url + ''&idCentro='' + ''' || i.centro_sanitario || ''';
                url = url + ''&statoAmbulatorio='' + ''' || i.stato || ''' + ''&'';
                url = url + ''id_sessione='' + '|| id_sessione ||';
                console.log(url);

                url = encodeURI(url);
                console.log(url);
                xhttp.open(''GET'', url, true);
                xhttp.send();
                return false;
                ');


            gui.chiudiRigaTabella;
            gui.aggiungiJavascript('
                document.getElementById(''myTab'').children[1].children[index].setAttribute(''centro'', ' || i.centro_sanitario || ');

                console.log(index);
                index = index+2;
                ');
          end loop;

          GUI.chiudiTabella;

        /*
          Se l'utente è un responsabile di un ambulatorio invece devo far vedere solamente
          il suo ambulatorio e il pulsante per vedere medici e specializzazioni di quello
          specifico ambulatorio.
        */
        else if(loginlogout.getUserType(id_sessione) = 'RA') then
              GUI.apriTabella('ELENCO AMBULATORI');
              gui.aggiungiJavascript('
              document.getElementsByTagName(''table'')[0].id = "myTab"
              ');

              gui.apriRigaTabella;


              gui.apriCellaTabella;
              gui.apriTestataTabella;

              for i in 1 .. 1
              loop

                gui.creaCampoTestataTabella('Nome Ambulatorio');

              end loop;
              gui.chiudiTestataTabella;
              gui.AggiungiJavascript('
                    index = 3;

                    ');

              for i in (select ambulatorio.nome, ambulatorio.id_amb, ambulatorio.centro_sanitario, ambulatorio.stato, ambulatorio.maxstanze, centro_sanitario.nome as nomeCentro
              from ambulatorio join centro_sanitario on ambulatorio.centro_sanitario = centro_sanitario.id_centro
              where ambulatorio.responsabile = loginlogout.getPersonFromSession(id_sessione))
              loop
                gui.apriRigaTabella;


                    gui.creaCellaTabella('<br> Centro Sanitario ' || to_char(i.nomeCentro) || '<br> Ambulatorio ' || to_char(i.nome)  || '<br><br>' , eventJS => 'onClick', scriptJS  => '

                    xhttp=new XMLHttpRequest();
                    xhttp.onreadystatechange = function() {
                    var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
                    if (xhttp.readyState == 4 || status == 200) {
                        a.innerHTML = '''';
                        a.innerHTML = this.responseText;
                        dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
                    } }

                    var url = '''|| GuiConst.root ||'ProcedureLucac.viewDettagliAmbulatorio?idAmb='';
                    url = url + ''' || i.id_amb || '''
                    url = url + ''&idCentro='' + ''' || i.centro_sanitario || ''';
                    url = url + ''&statoAmbulatorio='' + ''' || i.stato || ''' + ''&'';
                    url = url + ''id_sessione='' + '|| id_sessione ||';
                    console.log(url);

                    url = encodeURI(url);
                    console.log(url);
                    xhttp.open(''GET'', url, true);
                    xhttp.send();
                    return false;
                    ');


                gui.chiudiRigaTabella;
                gui.aggiungiJavascript('
                    document.getElementById(''myTab'').children[1].children[index].setAttribute(''centro'', ' || i.centro_sanitario || ');

                    console.log(index);
                    index = index+2;
                    ');
              end loop;

              GUI.chiudiTabella;
        /*
          SE NON è un utente di nessuno dei tipi precedenti non ha i diritti quindi non deve stare qua.
        */
        else
          gui.aggiungiTestoForm('<b>Non hai i diritti per visualizzare questa pagina</b>');
          gui.aggiungiLineaVuota();
          gui.aggiungiLineaVuota();
          gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/RddAJiGxTPQFa" width="480" height="394" frameBorder="0" class="giphy-embed" ></iframe><p></p>''');

      end if;
      end if;
      end if;
  /*
    Caso in cui check rights funziona e mi dice che è 0
  */
  ELSE
    gui.aggiungiTestoForm('<b>Non hai i diritti per visualizzare questa pagina</b>');
    gui.aggiungiLineaVuota();
    gui.aggiungiLineaVuota();
    gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/RddAJiGxTPQFa" width="480" height="394" frameBorder="0" class="giphy-embed" ></iframe><p></p>''');

  end if;

  exception
  when others then
    gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
    gui.aggiungiLineaVuota();
    gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');

end visualizzaListaAmbulatorio;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio
  e l'id sessione.
  Mi permette di rendere inattivo un certo ambulatorio selezionato.
  Il messaggio di conferma viene mostrato in un popup.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE CONFERMAELIMINAZIONE (
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

    idMedico NUMBER := 0;

BEGIN

        select ambulatorio.responsabile into idMedico
        from ambulatorio
        where ambulatorio.id_amb = select_ambulatorio and ambulatorio.id_amb = select_ambulatorio;


        UPDATE ambulatorio
        SET stato = 1, responsabile = NULL
        WHERE stato = 0 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;

        gui.aggiungiParagrafoPopup('Ambulatorio correttamente eliminato');
        gui.aggiungiBottone(mValue=>'OK',eventJS=>'onclick',scriptJS=>'{
            location.reload();
        }');


    exception

        when others then
            gui.aggiungiParagrafoPopup('Impossibile completare l''operazione');


END CONFERMAELIMINAZIONE;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio e il numero di stanze
  e l'id sessione.
  Mi permette di aumentare il numero di stanze di un ambulatorio.
  Il messaggio di conferma viene mostrato in un popup.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE CONFERMAAMPLIAAMBULATORIO (
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        newmaxStanze in ambulatorio.maxstanze%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

    numStanzeAtt NUMBER := 0;

BEGIN

        Select ambulatorio.maxstanze into numStanzeAtt
        from ambulatorio
        where ambulatorio.id_amb = select_ambulatorio;

        if(newmaxStanze <= 0) then
            gui.aggiungiParagrafoPopup('Impossibile completare l''operazione, il numero delle stanze deve essere maggiore di 0');
        end if;

        if(newmaxStanze > 0 and newmaxStanze < numStanzeAtt) then
            gui.aggiungiParagrafoPopup('Impossibile completare l''operazione, il numero delle stanze deve essere maggiore del numero attuale');


        else
            UPDATE ambulatorio
            SET ambulatorio.maxstanze = newmaxStanze
            WHERE stato = 0 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;
            gui.aggiungiParagrafoPopup('Ambulatorio correttamente ampliato');
        end if;

    exception
        when others then
            gui.aggiungiParagrafoPopup('Impossibile ampliare l''ambulatorio');

END CONFERMAAMPLIAAMBULATORIO;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio,
  l'id di un medico, e l'id sessione. Permette id modificare il responsabile di un
  certo ambulatorio.
  La conferma viene mostrata in un popup.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE CONFERMAMODIFICARESPONSABILE(
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is


    idMedico NUMBER := 0;

BEGIN

        UPDATE ambulatorio
        SET responsabile = select_Responsabile
        WHERE stato = 0 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;

        UPDATE imp_medico
        SET flag_R = 1
        WHERE imp_medico.id_medico = select_Responsabile;

        gui.aggiungiParagrafoPopup('Modifica responsabile effettuata correttamente');

    exception

        when others then
            gui.aggiungiParagrafoPopup('Impossibile modificare il responsabile');

END CONFERMAMODIFICARESPONSABILE;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro, l'id dell'ambulatorio
  , l'id sessione e l'id del medico responsabile.
  Mi permette di rendere attivo un certo ambulatorio selezionato.
  Il messaggio di conferma viene mostrato in un popup.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE CONFERMARIAPERTURA (
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

    idMedico NUMBER := 0;

BEGIN


        UPDATE ambulatorio
        SET stato = 0, responsabile = select_Responsabile
        WHERE stato = 1 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;

        gui.aggiungiParagrafoPopup('Ambulatorio correttamente rimesso in funzione');
        gui.aggiungiBottone(mValue=>'OK',eventJS=>'onclick',scriptJS=>'{

            location.reload();

        }');

    exception

        when others then
            gui.aggiungiParagrafoPopup('Impossibile completare l''operazione');

END CONFERMARIAPERTURA;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id sessione.
  Permette di aggiungere un nuovo ambulatorio in un centro sanitario.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

procedure insertAmbulatorio(
  id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
  is

y integer(1);
IDCENTRO integer(1);
rights number default 1;

begin
  SELECT BIN_TO_NUM(0,0,0,0,0,0,1,1) INTO rights FROM DUAL;


  GUI.APRIFINESTRAPOPUP('Inserimento di un ambulatorio', COSTANTIGRUPPO1.popup);
  GUI.CHIUDIFINESTRAPOPUP;

  GUI.AGGIUNGIERROREFORM('Ricontrolla i campi in rosso','errorInsert');

  --if(loginlogout.getUserType(id_sessione) = 'SP' or loginlogout.getUserType(id_sessione) = 'DBA') then
  if(loginlogout.checkRights(rights, id_sessione) > 0) then

      gui.apriForm('GET','#',errorBoxId=>'errorInsert',eventJS=>'onsubmit',scriptJS=>'

        if(md==0){
          errorBoxerrorInsert = new Error(''errorInsert'');
          md = 1;
        }
        if (checkForm(this,errorBoxerrorInsert)) {

        xhttp=new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
        var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');
        if (xhttp.readyState == 4 || status == 200) {
            a.innerHTML = '''';
            a.innerHTML = this.responseText;
            dialog_'|| COSTANTIGRUPPO1.popup ||'.openDialog();
        } }

        var x = document.getElementsByName(''nome'')[0];
        var y = document.getElementsByName(''Indirizzo'')[0];
        var z = document.getElementsByName(''maxstanze'')[0];
        var a = document.getElementsByName(''select_centro'')[0];
        var b = document.getElementsByName(''select_responsabile'')[0];
        var url = '''|| GuiConst.root ||'ProcedureLucac.addInAmbulatorio?'';
        url = url + ''nome='' + x.value + ''&'';
        url = url + ''indirizzo='' + y.value + ''&'';
        url = url + ''maxstanze='' + z.value + ''&'';
        url = url + ''select_centro='' + a.value + ''&'';
        url = url + ''select_responsabile='' + b.value + ''&'';
        url = url + ''id_sessione='' + ' || id_sessione ||';

        url = encodeURI(url);
        console.log(url)
        xhttp.open(''GET'', url, true);
        xhttp.send();
        return false;

        }

            return false;
        ');

      gui.apriTabellaForm('Inserisci un nuovo ambulatorio');

      gui.apriRigaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTestoForm('Nome dell''ambulatorio');
      gui.chiudiCellaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTextInputForm('nome', '','[a-zA-Z ]{4,10}', eventJS=>'onfocusout',scriptJS=>'{
        if(md==0){
          errorBoxerrorInsert = new Error(''errorInsert'');
          md = 1;
        }
        errorBoxerrorInsert.removeError(''name_format'');
        removeError(this);
        if(!this.checkValidity()) {
            errorBoxerrorInsert.addError(''name_format'',''Il nome deve contenere tra 4 e 20 caratteri e non deve contenere numeri'');
            setError(this);
        }
        if(this.value.length > 0) {
            errorBoxerrorInsert.removeError(''nome'');
        }

      }');

      gui.chiudiCellaTabella;
      gui.chiudiRigaTabella;
      gui.apriRigaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTestoForm('Indirizzo');
      gui.chiudiCellaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTextInputForm('Indirizzo', '', '\D{1,10}(?:\D{1,10}){3}\d{1,10}?([\D]{1})?$', eventJS=>'onfocusout',scriptJS=>'{
        if(md==0){
          errorBoxerrorInsert = new Error(''errorInsert'');
          md = 1;
        }
        errorBoxerrorInsert.removeError(''indirizzo_format'');
        removeError(this);
        if(!this.checkValidity()) {
            errorBoxerrorInsert.addError(''indirizzo_format'',''Il campo indirizzo deve essere nel formato via nome numero'');
            setError(this);
        }
        if(this.value.length > 0) {
            errorBoxerrorInsert.removeError(''Indirizzo'');
        }

      }');
      gui.chiudiCellaTabella;
      gui.chiudiRigaTabella;
      gui.apriRigaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTestoForm('Numero di stanze');
      gui.chiudiCellaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTextInputForm('maxstanze','', '^[1-9][0-9]*', eventJS=>'onfocusout',scriptJS=>'{
        if(md==0){
          errorBoxerrorInsert = new Error(''errorInsert'');
          md = 1;
        }
        errorBoxerrorInsert.removeError(''maxstanze_format'');
        removeError(this);
        if(!this.checkValidity()) {
            errorBoxerrorInsert.addError(''maxstanze_format'',''Il numero delle stanze deve essere maggiore di 0, non sono ammessi spazi'');
            setError(this);
        }
        if(this.value.length > 0) {
            errorBoxerrorInsert.removeError(''maxstanze'');
        }

      }');
      gui.chiudiCellaTabella;
      gui.chiudiRigaTabella;
      gui.apriCellaTabella;
      gui.aggiungiTestoForm('Centro Sanitario');
      gui.chiudiCellaTabella;
      gui.apriCellaTabella;
      gui.apriSelectForm('select_centro',false,'onChange','
         sel_centro = document.getElementsByName(''select_centro'')[0];


         if(md==0){
           errorBoxerrorInsert = new Error(''errorInsert'');
           md = 1;
         }

         if(sel_centro.selectedIndex != 0) {
             removeError(this);
             checkForm(document.getElementsByTagName(''form'')[0],errorBoxerrorInsert)

             idCentro = sel_centro.value;

             sel_responsabile = document.getElementsByName(''select_responsabile'')[0];
             var url = '''|| GuiConst.root ||'ProcedureLucac.searchAmbulatorio?'';
             url = url + ''idCentro='' +  idCentro;
             console.log(url);
             xhttp=new XMLHttpRequest();
             xhttp.onreadystatechange = function() {

             if (xhttp.readyState == 4 || status == 200) {
                 sel_responsabile.innerHTML = '''';
                 sel_responsabile.innerHTML = this.responseText;

             } }
             xhttp.open(''GET'', url, true);
             xhttp.send();
             return false;
         }



        ');


      gui.aggiungiOptionSelectForm(to_char(''));
      for i in (select centro_sanitario.nome, centro_sanitario.id_centro from centro_sanitario)
      loop
          gui.aggiungiOptionSelectForm(i.id_centro, to_char(i.nome));

      end loop;
      gui.chiudiSelectForm;
      gui.chiudiCellaTabella;
      gui.chiudiRigaTabella;


      gui.apriCellaTabella;
      gui.aggiungiTestoForm('Responsabile ambulatorio');
      gui.chiudiCellaTabella;
      gui.apriCellaTabella;
      gui.apriSelectForm('select_responsabile',false,'onChange','
         sel_responsabile = document.getElementsByName(''select_responsabile'')[0];


         if(md==0){
           errorBoxerrorInsert = new Error(''errorInsert'');
           md = 1;
         }


         if(sel_responsabile.selectedIndex != 0) {
             removeError(this);
             checkForm(document.getElementsByTagName(''form'')[0],errorBoxerrorInsert)

         }


        ');

      gui.chiudiSelectForm;
      gui.chiudiCellaTabella;
      gui.chiudiRigaTabella;

      gui.chiudiTabella;
      gui.aggiungiLineaVuota;
      gui.aggiungiLineaVuota;

      gui.aggiungiBottoneForm(mValue=>'conferma');
      gui.aggiungiBottoneResetForm(mValue=>'reset', eventJS => 'onclick', scriptJS => '
            sel_resp = document.getElementsByName(''select_responsabile'')[0];

            x = sel_resp.options.length;

            for (i=0;i<x;i++){
       	      sel_resp.options[i].text = '' '';
              sel_resp.options[i].style= ''display:none'';
            }
            sel_resp.selectedIndex = 0;
            ');
      gui.chiudiForm;

      GUI.AGGIUNGILINEAVUOTA;
      GUI.AGGIUNGILINEAVUOTA;
      GUI.AGGIUNGILINEAVUOTA;
      GUI.AGGIUNGILINEAVUOTA;


      GUI.CHIUDIBODY;
      GUI.CHIUDIPAGINA;
    else
      gui.aggiungiTestoForm('<b>Non hai i diritti per visualizzare questa pagina</b>');
      gui.aggiungiLineaVuota();
      gui.aggiungiLineaVuota();
      gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/RddAJiGxTPQFa" width="480" height="394" frameBorder="0" class="giphy-embed" ></iframe><p></p>''');

  end if;
  exception
    when others then
      gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
      gui.aggiungiLineaVuota();
      gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');

end insertAmbulatorio;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro, nome, indirizzo, numero di stanze, id del centro
  id del medico responsabile e id sessione.
  Si occupa dell'aggiornamento del database aggiungendo il nuovo ambulatorio che è stato
  inserito.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure addInAmbulatorio(
        nome    	in Ambulatorio.NOME%TYPE DEFAULT NULL,
        indirizzo 	in Ambulatorio.Indirizzo%TYPE DEFAULT NULL,
        maxstanze	in Ambulatorio.MaxStanze%TYPE DEFAULT NULL,
        select_centro     in Ambulatorio.Centro_sanitario%TYPE,
        select_responsabile in Ambulatorio.Responsabile%TYPE,
        id_sessione in sessioni.id_sessione%TYPE DEFAULT NULL)
        is

begin

    if maxstanze <= 0 then
        gui.apriDiv;
        gui.aggiungiParagrafoPopup('Si è verificato un errore, il numero delle stanze non può essere negativo');
        gui.aggiungiLineaVuota;
        gui.aggiungiBottone(mValue=>'ok',eventJS=>'onclick',scriptJS=>'
        {
        dialog_'|| COSTANTIGRUPPO1.popup ||'.closeDialog();
        }');
    else
        insert into ambulatorio(ID_AMB, NOME, INDIRIZZO, MAXSTANZE, CENTRO_SANITARIO, RESPONSABILE)
        values (IDAMBSEQ.nextVal, nome, indirizzo, maxstanze, select_centro, select_responsabile);
        gui.apriDiv;
        gui.aggiungiParagrafoPopup('Operazione effettuata con successo');
        gui.aggiungiLineaVuota;
        gui.aggiungiBottone(mValue=>'ok',eventJS=>'onclick',scriptJS=>'
        {
        location.reload();
        dialog_'|| COSTANTIGRUPPO1.popup ||'.closeDialog();
        }');
    end if;

exception

    when others then
        gui.apriDiv;
        gui.aggiungiParagrafoPopup('Si è verificato un errore');
        gui.aggiungiLineaVuota;
        gui.aggiungiBottone(mValue=>'ok',eventJS=>'onclick',scriptJS=>'
        {
        dialog_'|| COSTANTIGRUPPO1.popup ||'.closeDialog();
        }');

end addInAmbulatorio;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro sanitario e
  l'id sessione.
  Permette di eseguire una query basandoci sull'elemento selezionato
  all'interno della select form del centro sanitario.
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

PROCEDURE searchAmbulatorio(
  idCentro IN CENTRO_SANITARIO.ID_CENTRO%TYPE DEFAULT NULL,
  id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL) IS
BEGIN

    GUI.AGGIUNGIOPTIONSELECTFORM('','',true);


    FOR RESP IN (select imp_medico.nome, imp_medico.cognome, imp_medico.id_medico, centro_sanitario.id_centro
              from imp_medico join centro_sanitario on centro_sanitario.id_centro = imp_medico.centro_sanitario
              where imp_medico.flag_r = 1 and centro_sanitario.id_centro = idCentro and imp_medico.id_medico not in (
                  select imp_medico.id_medico
                  from ambulatorio join imp_medico on ambulatorio.responsabile = imp_medico.id_medico))
    LOOP
        GUI.AGGIUNGIOPTIONSELECTFORM(resp.id_medico , resp.nome || ' ' || resp.cognome);
    END LOOP;

    exception
      when others then
        gui.aggiungiTestoForm('<b>Si è verificato un errore</b>');
        gui.aggiungiLineaVuota();
        gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/mq5y2jHRCAqMo" width="480" height="480" frameBorder="0" class="giphy-embed" ></iframe>''');


END searchAmbulatorio;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio,
  lo stato dell'ambulatorio e l'id sessione. Possiamo anche avere:
  - Nuovo numero di Stanze
  - Nuovo responsabile
  - nuovo responsabile e nuovo numero di stanze insieme
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE CONFERMAMODIFICAAMB (
        select_centro   	in centro_sanitario.id_centro%TYPE DEFAULT NULL,
        select_ambulatorio 	in Ambulatorio.id_amb%TYPE DEFAULT NULL,
        newmaxStanze in ambulatorio.maxstanze%TYPE DEFAULT NULL,
        select_Responsabile in ambulatorio.responsabile%TYPE DEFAULT NULL,
        statoAmbulatorio in ambulatorio.stato%TYPE DEFAULT NULL,
        id_sessione IN sessioni.id_sessione%TYPE DEFAULT NULL)
        is

    numStanzeAtt NUMBER := 0;
    idMedico NUMBER := 0;

BEGIN

        if(statoAmbulatorio is not NULL) then
        /*
          Div che contiene i dettagli modificabili di un certo ambulatorio che ho selezionato.
          Se il centro è aperto posso modificare il responsabile e il numero delle stanze, se il centro è
          chiuso invece posso modificare il responsabile e posso riaprire il centro.
        */

        GUI.AGGIUNGIERROREFORM('Ricontrolla i campi in rosso','errorInsert');


        gui.apriTabellaForm();

        if(statoAmbulatorio = 0) then
          gui.apriRigaTabella;
          gui.apriCellaTabella;
          gui.aggiungiTestoForm('Numero di stanze');
          gui.chiudiCellaTabella;
          gui.apriCellaTabella;


          gui.aggiungiTextInputForm('maxstanze','', '^[1-9][0-9]*', eventJS=>'onfocusout',scriptJS=>'{

            if(md==0){
              formErrore = new Error(''errorInsert'');
              md = 1;
            }

            formErrore.removeError(''maxstanze_format'');
            removeError(this);
            if(!this.checkValidity()) {
                formErrore.addError(''maxstanze_format'',''Il numero delle stanze deve essere maggiore di 0, non sono ammessi spazi'');
                setError(this);
            }
            if(this.value.length > 0) {
                formErrore.removeError(''maxstanze'');
                formErrore.removeError(''vuoto'');
            }

          }');
          gui.chiudiCellaTabella;
          gui.chiudiRigaTabella;
        end if;

        gui.apriRigaTabella();
        gui.apriCellaTabella;
        gui.aggiungiTestoForm('Responsabile');
        gui.chiudiCellaTabella;
        gui.apriCellaTabella;
        gui.apriSelectForm('select_Responsabile', eventJS=>'onchange',scriptJS=>'{

          if( document.getElementsByName(''select_Responsabile'')[0].selectedIndex != 0){
            if(md==0){
              formErrore = new Error(''errorInsert'');
              md = 1;
            }
            formErrore.removeError(''maxstanze_format'');
            formErrore.removeError(''vuoto'');
          }

        }');
        gui.aggiungiOptionSelectForm(' ',selected=>TRUE);



        -- Il responsabile deve essere un medico che lavora in quel centro sanitario e deve avere il flag_r a 1
        -- inoltre non può essere un medico che è già responsabile di un altro ambulatorio.
        for i in (select imp_medico.nome, imp_medico.cognome, imp_medico.id_medico
                    from imp_medico join centro_sanitario on centro_sanitario.id_centro = imp_medico.centro_sanitario
                    where imp_medico.flag_r = 1 and centro_sanitario.id_centro = select_centro
                    and imp_medico.id_medico not in (
                    select imp_medico.id_medico
                    from ambulatorio join imp_medico on ambulatorio.responsabile = imp_medico.id_medico))
          loop
            gui.aggiungiOptionSelectForm(i.id_medico, to_char(i.nome) || ' '  || i.cognome );

          end loop;

        gui.chiudiSelectForm;
        gui.chiudiCellaTabella;
        gui.chiudiRigaTabella();
        gui.chiudiTabella;
        gui.aggiungiLineaVuota();
        gui.aggiungiLineaVuota();

        /*
          Nel popup di modifica se l'ambulatorio non è aperto allora devo andare a mettere un pulsante per
          aprire di nuovo quell'ambulatorio.
          Se invece è aperto gestisco sia il caso in cui voglio cambiare responsabile, sia quello in cui
          voglio modificare il numero delle stanze, queste modifiche posso anche farle contemporaneamente.
        */

        if(statoAmbulatorio = 1) then
            gui.aggiungiBottone(mValue=>'Apri Ambulatorio',eventJS=>'onclick',scriptJS=>'
                f = document.getElementsByName(''select_Responsabile'')[0];

                if(f.selectedIndex == 0){
                  if(md==0){
                    formErrore = new Error(''errorInsert'');
                    md = 1;
                  }
                  formErrore.removeError(''vuoto'');
                  formErrore.addError(''vuoto'',''Selezionare un responsabile'');
                }
                else{
                  var url = '''|| GuiConst.root ||'ProcedureLucac.confermariapertura?'';
                  url = url + ''select_centro='' + ' || select_centro ||' + ''&'';
                  url = url + ''select_ambulatorio='' + ' || select_ambulatorio ||' + ''&'';
                  url = url + ''select_Responsabile='' + f.value + ''&'';
                  url = url + ''id_sessione='' + ' || id_sessione ||';
                  url = encodeURI(url);
                  console.log(url)

                  var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');


                  xhttp=new XMLHttpRequest();
                  xhttp.onreadystatechange = function() {

                  if (xhttp.readyState == 4 || status == 200) {
                      a.innerHTML = '''';
                      a.innerHTML = this.responseText;

                  } }
                  xhttp.open(''GET'', url, true);
                  xhttp.send();
                  return false;
                }


            ');
        else

        gui.aggiungiBottone(mValue=>'Ok',eventJS=>'onclick',scriptJS=>'
            {

            f = document.getElementsByName(''select_Responsabile'')[0];
            stanze = document.getElementsByName(''maxstanze'')[0];

            // Caso errore con stanze minori di 0
            if(stanze.value < 0){

                if(md==0){
                  formErrore = new Error(''errorInsert'');
                  md = 1;
                }

                formErrore.removeError(''maxstanze_format'');
                formErrore.removeError(''vuoto'');

                removeError(this);
                formErrore.addError(''maxstanze_format'',''Il numero delle stanze deve essere maggiore di 0, non sono ammessi spazi'');

            }
            // Caso in cui ho i campi vuoti
            else if(f.selectedIndex == 0 && stanze.value==''''){
                if(md==0){
                  formErrore = new Error(''errorInsert'');
                  md = 1;
                }

                formErrore.removeError(''vuoto'');

                formErrore.addError(''vuoto'',''Compilare almeno uno dei due campi'');

            }
            // Caso in cui va tutto bene e ho compilato o tutti e due i campi o almeno uno.
            else{
                var url = '''|| GuiConst.root ||'ProcedureLucac.CONFERMAMODIFICAAMB?'';
                url = url + ''select_centro='' + ' || select_centro ||' + ''&'';
                url = url + ''select_ambulatorio='' + ' || select_ambulatorio ||' + ''&'';
                if(stanze.value!=''''){
                  url = url + ''newmaxStanze='' + stanze.value + ''&'';
                }
                if(f.selectedIndex != 0){
                  url = url + ''select_responsabile='' + f.value + ''&'';
                }
                url = url + ''id_sessione='' + ' || id_sessione ||';
                url = encodeURI(url);
                console.log(url)

                var a = document.getElementById(''dialog_'|| COSTANTIGRUPPO1.popup ||'_body'');

                xhttp=new XMLHttpRequest();
                xhttp.onreadystatechange = function() {

                if (xhttp.readyState == 4 || status == 200) {
                    temp = a.innerHTML;
                    a.innerHTML = '''';
                    a.innerHTML = ''<b>'' + this.responseText + ''</b>'';
                    a.innerHTML += temp;

                } }
                xhttp.open(''GET'', url, true);
                xhttp.send();
                return false;

            }

        }');
        end if;

        else


        if(select_Responsabile is not NULL) then


                UPDATE ambulatorio
                SET responsabile = select_Responsabile
                WHERE stato = 0 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;

                UPDATE imp_medico
                SET flag_R = 1
                WHERE imp_medico.id_medico = select_Responsabile;

                gui.aggiungiParagrafoPopup('Modifica responsabile effettuata correttamente');

        end if;

        -- Controllo se voglio modificare il numero delle stanze
        if(newmaxStanze is not NULL) then

          Select ambulatorio.maxstanze into numStanzeAtt
          from ambulatorio
          where ambulatorio.id_amb = select_ambulatorio;

          if(newmaxStanze <= 0) then
              gui.aggiungiParagrafoPopup('Impossibile completare l''operazione, il numero delle stanze deve essere maggiore di 0');
          end if;

          if(newmaxStanze > 0 and newmaxStanze < numStanzeAtt) then
              gui.aggiungiParagrafoPopup('Impossibile completare l''operazione, il numero delle stanze deve essere maggiore del numero attuale');
          else
              UPDATE ambulatorio
              SET ambulatorio.maxstanze = newmaxStanze
              WHERE stato = 0 and AMBULATORIO.ID_AMB = select_ambulatorio and ambulatorio.centro_sanitario = select_centro;
              gui.aggiungiParagrafoPopup('Ambulatorio correttamente ampliato');
          end if;
        end if;
        end if;

    exception
        when others then
            gui.aggiungiParagrafoPopup('Impossibile ampliare l''ambulatorio');
            gui.aggiungiParagrafoPopup('Impossibile modificare il responsabile');
END CONFERMAMODIFICAAMB;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
  Procedura che prende come parametro l'id del centro sanitario, l'id dell'ambulatorio,
  lo stato dell'ambulatorio e l'id sessione. Possiamo anche avere:
  - Nuovo numero di Stanze
  - Nuovo responsabile
  - nuovo responsabile e nuovo numero di stanze insieme
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE studioEpidemiologico(
        id_sessione  IN NUMBER DEFAULT NULL
    )AS
      rights number default 1;
    BEGIN


        SELECT BIN_TO_NUM(0,1,0,0,0,0,1,1) INTO rights FROM DUAL;


        GUI.APRIPAGINA('Studio epidemiologico');
        htp.print('<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.bundle.js"></script>');
        if(loginlogout.checkRights(rights, id_sessione) > 0) then
            PAGINEINCOMUNE.CREANAVBAR(id_sessione);
            GUI.AGGIUNGIERROREFORM('Errori ricerca','errorRic');
            GUI.APRIFORM('GET','#',errorBoxId=>'errorRic');
            GUI.APRITABELLA('Report Patologie più comuni');
            GUI.APRIRIGATABELLA();
            GUI.CREACELLATABELLA('Centro Sanitario: ');
            GUI.APRICELLATABELLA();
            GUI.APRISELECTFORM(mName=>'idCentro', eventJS=>'onchange', scriptJS=>'document.getElementById(''idCerca'').disabled = false;');
            FOR centro IN (SELECT * FROM CENTRO_SANITARIO)
            LOOP
                GUI.aggiungiOptionSelectForm(mValue=>centro.ID_CENTRO,mLabel=>centro.NOME);
            END LOOP;
            GUI.CHIUDISELECTFORM();
            GUI.CHIUDICELLATABELLA();
            GUI.CHIUDIRIGATABELLA();
            GUI.APRIRIGATABELLA();
            GUI.CREACELLATABELLA('Settimana del: ');
            GUI.APRICELLATABELLA();
            htp.print('<input type="date" id="inizioSett" name="inizioSett" class="textInput datePicker" min="2015-01-12" step="7">');
            GUI.CHIUDICELLATABELLA();
            GUI.CHIUDIRIGATABELLA();
            GUI.APRIRIGATABELLA();
            htp.print('<td colspan=2>');
            GUI.AGGIUNGIBOTTONE(mValue=>'Cerca',eventJS=>'onclick',scriptJS=>'{
                    xhttp=new XMLHttpRequest();
                    xhttp.onreadystatechange = function() {
                        var a = document.getElementById(''divReport'');
                        if (xhttp.readyState == 4 || status == 200) {
                            a.innerHTML = '''';
                            //a.innerHTML = this.responseText;
                            if(this.responseText != ''<h1>Report Patologie</h1><table>''){
                                var nomi = []
                                var valori = []

                                var htmlObject = $(this.responseText);
                                var nodeL = htmlObject[1].children[0].childNodes;
                                for (i=0;i<nodeL.length;i++){
                                    nomi.push(nodeL[i].children[0].textContent)
                                    valori.push(nodeL[i].children[1].textContent)
                                    i++;
                                }

                                father = document.getElementById(''divReport'');
                                father.innerHTML = ''''

                                var cnv = document.createElement(''canvas'');
                                cnv.id = ''doughnut-chart_Patologie''
                                cnv.width = ''800'';
                                cnv.height = ''450''
                                father.appendChild(cnv);



                                new Chart(document.getElementById(''doughnut-chart_Patologie''), {
                                      type: ''doughnut'',
                                      data: {
                                      labels: nomi,
                                      datasets: [
                                        {
                                          label: ''Population (millions)'',
                                          backgroundColor: [''#3e95cd'', ''#8e5ea2'',''#3cba9f'',''#e8c3b9'',''#c45850''],
                                          data: valori
                                        }
                                      ]
                                      },
                                      options: {
                                      title: {
                                        display: true,
                                        text: ''Tipi di analisi''
                                      }
                                      }
                                 });
                              }
                              else{
                                  a.innerHTML = ''<br><br><b>Non ci sono report per questo periodo<b>'';
                              }
                        }
                    }
                    var centro = document.getElementsByName(''idCentro'')[0].value;
                    var selectVal = document.getElementById(''inizioSett'').value;
                    var url = '''||GUICONST.root||'ProcedureLucaC.reportStudiEpPatologie?idCentro='' + centro + ''&inizioSett='' + selectVal + ''&idSessione='||id_sessione||''';
                    xhttp.open(''GET'', url, true);
                    xhttp.send();
                    return false;
                    }', idValue=>'idCerca', attributi=>'disabled=true');
            htp.print('</td>');
            GUI.CHIUDIRIGATABELLA();
            GUI.CHIUDITABELLA();
            GUI.CHIUDIFORM();
            GUI.APRIDIV('id=divReport');

            GUI.CHIUDIDIV();

            gui.aggiungiLineaVuota();

            GUI.APRIFORM('GET','#',errorBoxId=>'errorRic');
            GUI.APRITABELLA('Ricerca analisi più comuni');
            GUI.APRIRIGATABELLA();
            GUI.CREACELLATABELLA('Centro Sanitario: ');
            GUI.APRICELLATABELLA();
            GUI.APRISELECTFORM(mName=>'idCentroAnalisi', eventJS=>'onchange', scriptJS=>'document.getElementById(''idCercaAnalisi'').disabled = false;');
            FOR centro IN (SELECT * FROM CENTRO_SANITARIO)
            LOOP
                GUI.aggiungiOptionSelectForm(mValue=>centro.ID_CENTRO,mLabel=>centro.NOME);
            END LOOP;
            GUI.CHIUDISELECTFORM();
            GUI.CHIUDICELLATABELLA();
            GUI.CHIUDIRIGATABELLA();
            GUI.APRIRIGATABELLA();
            GUI.CREACELLATABELLA('Settimana del: ');
            GUI.APRICELLATABELLA();
            htp.print('<input type="date" id="inizioSettAnalisi" name="inizioSett" class="textInput datePicker" min="2015-01-12" step="7">');
            GUI.CHIUDICELLATABELLA();
            GUI.CHIUDIRIGATABELLA();
            GUI.APRIRIGATABELLA();
            htp.print('<td colspan=2>');
            GUI.AGGIUNGIBOTTONE(mValue=>'Cerca',eventJS=>'onclick',scriptJS=>'{


                    xxhttp=new XMLHttpRequest();
                    xxhttp.onreadystatechange = function() {
                        var a = document.getElementById(''divReportAnalisi'');
                        if (xxhttp.readyState == 4 || status == 200) {
                            a.innerHTML = '''';
                            var nomi = []
                            var valori = []
                            if(this.responseText != ''<h1>Tipi Analisi</h1><table>''){

                                var htmlObject = $(this.responseText);
                                var nodeL = htmlObject[1].children[0].childNodes;
                                for (i=0;i<nodeL.length;i++){
                                    nomi.push(nodeL[i].children[0].textContent)
                                    valori.push(nodeL[i].children[1].textContent)
                                    i++;
                                }


                                father = document.getElementById(''divReportAnalisi'');
                                father.innerHTML = ''''

                                var cnv = document.createElement(''canvas'');
                                cnv.id = ''doughnut-chart''
                                cnv.width = ''800'';
                                cnv.height = ''450''
                                father.appendChild(cnv);




                                new Chart(document.getElementById(''doughnut-chart''), {
                                      type: ''doughnut'',
                                      data: {
                                      labels: nomi,
                                      datasets: [
                                        {
                                          label: ''Population (millions)'',
                                          backgroundColor: [''#3e95cd'', ''#8e5ea2'',''#3cba9f'',''#e8c3b9'',''#c45850''],
                                          data: valori
                                        }
                                      ]
                                      },
                                      options: {
                                      title: {
                                        display: true,
                                        text: ''Tipi di analisi''
                                      }
                                      }
                                 });


                              }
                            else{

                              a.innerHTML = ''<br><br><b>Non ci sono analisi in questo periodo<b>'';
                            }




                        }
                    }
                    var centro = document.getElementsByName(''idCentroAnalisi'')[0].value;
                    var selectVal = document.getElementById(''inizioSettAnalisi'').value;
                    var url = '''||GUICONST.root||'ProcedureLucaC.reportStudiEpAnalisi?idCentro='' + centro + ''&inizioSett='' + selectVal + ''&idSessione='||id_sessione||''';
                    xxhttp.open(''GET'', url, true);
                    xxhttp.send();
                    return false;
                    }', idValue=>'idCercaAnalisi', attributi=>'disabled=true');
            htp.print('</td>');
            GUI.CHIUDIRIGATABELLA();
            GUI.CHIUDITABELLA();
            GUI.CHIUDIFORM();
            GUI.APRIDIV('id=divReportAnalisi');

            GUI.CHIUDIDIV();





            GUI.CHIUDIBODY();
        ELSE
            gui.aggiungiTestoForm('<b>Non hai i diritti per visualizzare questa pagina</b>');
            gui.aggiungiLineaVuota();
            gui.aggiungiLineaVuota();
            gui.aggiungiTestoForm('''<iframe src="https://giphy.com/embed/RddAJiGxTPQFa" width="480" height="394" frameBorder="0" class="giphy-embed" ></iframe><p></p>''');

        end if;
        GUI.CHIUDIPAGINA();
END studioEpidemiologico;



PROCEDURE reportStudiEpPatologie(
        idCentro    IN CENTRO_SANITARIO.ID_CENTRO%TYPE,
        inizioSett  IN VARCHAR2,
        idSessione  IN NUMBER DEFAULT NULL
    )AS
    curCentro CENTRO_SANITARIO%ROWTYPE;
    visiteTotali    NUMBER;
    visiteMedie     NUMBER;
    analisiTotali   NUMBER;
    analisiMedie    NUMBER;


    BEGIN


            DECLARE Cursor pato is
              SELECT diagnosi.id_pato, ambulatorio.centro_sanitario
              FROM VISITA,TURNO_MEDICO,AMBULATORIO, DIAGNOSI
              WHERE VISITA.TURNO=TURNO_MEDICO.ID_TURNO AND TURNO_MEDICO.AMB=AMBULATORIO.ID_AMB
                AND TURNO_MEDICO.INIZIO >= TO_DATE(inizioSett,'YYYY-MM-DD')
                AND TURNO_MEDICO.INIZIO <= (TO_DATE(inizioSett,'YYYY-MM-DD')+6)
                AND DIAGNOSI.ID_VISITA = VISITA.ID_VISITA;

            patCount NUMBER := 0;
            var pato%rowtype;
    BEGIN

      open pato;
          loop
            fetch pato into var;
            exit when pato%NOTFOUND;

          end loop;



        gui.apriTabella('Report Patologie');

        if(pato%ROWCOUNT != 0) then
            for i in (

            select distinct patologia.nome, (select count(pato.id_pato) from pato where pato.id_pato = patologia.id_pato and pato.centro_sanitario = idCentro group by pato.id_pato) as conteggio
            from patologia, pato
            where pato.centro_sanitario = idCentro and pato.id_pato = patologia.id_pato

            )
            LOOP

              gui.apriRigaTabella;
              gui.apriCellaTabella;
              gui.aggiungiTestoForm(i.nome);
              gui.chiudiCellaTabella;
              gui.apriCellaTabella;
              gui.aggiungiTestoForm(i.conteggio);
              gui.chiudiCellaTabella;
              gui.chiudiRigaTabella();
            end loop;
        end if;

END;
END reportStudiEpPatologie;

PROCEDURE reportStudiEpAnalisi(
        idCentro    IN CENTRO_SANITARIO.ID_CENTRO%TYPE,
        inizioSett  IN VARCHAR2,
        idSessione  IN NUMBER DEFAULT NULL
    )AS


    BEGIN

        gui.apriTabella('Tipi Analisi');
        for i in (

          select tipo_analisi.nome as nome, count(tipo_analisi.id_tipoanalisi) as conteggio
          from accertabili, analisi , tipo_analisi  , turno_tecnico, laboratorio
          where analisi.id_analisi = accertabili.id_analisi and
          tipo_analisi.id_tipoanalisi = analisi.tipoanalisi and
          turno_tecnico.id_turno = analisi.turno
          AND TURNO_tecnico.DATA_T >= TO_DATE(inizioSett,'YYYY-MM-DD')
          AND turno_tecnico.DATA_T <= (TO_DATE(inizioSett,'YYYY-MM-DD')+6) and
          laboratorio.id_lab = turno_tecnico.lab
          and laboratorio.centro_sanitario = idCentro
          group by tipo_analisi.nome, tipo_analisi.id_tipoanalisi


        )
        LOOP

          gui.apriRigaTabella;
          gui.apriCellaTabella;
          gui.aggiungiTestoForm(i.nome);
          gui.chiudiCellaTabella;
          gui.apriCellaTabella;
          gui.aggiungiTestoForm(i.conteggio);
          gui.chiudiCellaTabella;
          gui.chiudiRigaTabella();
        end loop;



END reportStudiEpAnalisi;

end ProcedureLucaC;
