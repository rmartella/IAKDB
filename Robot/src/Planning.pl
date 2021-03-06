﻿/*************************************************************************
*
* UNIVERSIDAD NACIONAL AÚTONOMA DE MÉXICO
* IIMAS
* INTELIGENCIA ARTIFICIAL
* PROYECTO 2 Planeacion
* 
* MARTELL AVILA REYNALDO
* AUGUSTO JULIO CESAR VEGA GUTIÉRREZ
* PEDRO VEGA GALAVIZ
*
**************************************************************************
*/

:-op(15,xfx,=>).

elimina(_,[],[]):-!.
elimina(X,[X],[]):-!.
elimina(X,[X|B],S):-
	elimina(X,B,S),!.
elimina(X,[A|B],S):-
	elimina(X,B,W),addElement([A],W,S).

cuenta(_,[],0):-!.
cuenta(A,[A|T],X):-
	cuenta(A,T,X1),!,X is X1 + 1.
cuenta(A,[H|T],X):-
	A\=H,
	cuenta(A,T,X),!.

%brazosLibres(X,Y):-object(X,"Agente",Atrs,_),valor(brazosLibres,Atrs,Y).

%brazosLibres([[en,robot,inicio],[brazosLibres,2]],Y).
brazosLibres([],0):-!.
brazosLibres([H|T],Y):-
	[NombrePrecondicion|_] = H,
	(NombrePrecondicion = brazosLibres ->
		[brazosLibres,Y] = H;brazosLibres(T,Y)
	),!.

obtenTiempo([],0):-!.
obtenTiempo([H|T],Tiempo):-
	[NombrePrecondicion|_] = H,
	(NombrePrecondicion = tiempoRestate ->
		[tiempoRestate,Tiempo] = H;obtenTiempo(T,Tiempo)
	),!.

tiempoRestate(_,[],0):-!.
tiempoRestate(Tiempo,[H|T],NuevoTiempo):-
	[NombrePrecondicion|_] = H,
	(NombrePrecondicion = tiempoRestate ->
		[tiempoRestate,ViejoTiempo] = H, NuevoTiempo is ViejoTiempo - Tiempo;tiempoRestate(Tiempo,T,NuevoTiempo)
	),!.

/**
enTiempo([AccionH|AccionT],[H|T]):-
	(AccionH = mover ->
		[mover,_,Li,Lj] = [AccionH|AccionT], costoDeIr(Li,Lj,Costo);
		[NombreMetodo,Alimento,_,_] = [AccionH|AccionT],costoDe(NombreMetodo,Alimento,Costo)
	),
	tiempoRestate(Costo,[H|T],NuevoTiempo),
	(NuevoTiempo >= 0 -> true;false),!.
*/

enTiempo([AccionH|AccionT],[H|T]):-
	(AccionH = mover ->
		[mover,_,Li,Lj] = [AccionH|AccionT], costoDeIr(Li,Lj,Costo);
		(AccionH = buscar ->
			[_,Alimento,_,_] = [AccionH|AccionT],
			costoDe(buscar,Alimento,CostoBuscar),
			%costoDe(agarrar,Alimento,CostoAgarrar),
			%costoDe(entregar,Alimento,CostoEntregar),
			%Costo is CostoBuscar + CostoAgarrar + CostoEntregar
			Costo =  CostoBuscar
			;
			(AccionH = agarrar ->
				[_,Alimento,_,_] = [AccionH|AccionT],
				costoDe(agarrar,Alimento,CostoAgarrar),
				%costoDe(entregar,Alimento,CostoEntregar),
				%Costo is CostoAgarrar + CostoEntregar
				Costo =  CostoAgarrar
				;
				[_,Alimento,_,_] = [AccionH|AccionT],
				costoDe(entregar,Alimento,CostoEntregar),
				Costo is CostoEntregar
			)
		)
	),
	tiempoRestate(Costo,[H|T],NuevoTiempo),
	(NuevoTiempo >= 0 -> true;false),!.

%modificaBrazosLibres(1,[[agarrado,refresco,robot],[en,robot,mesa1],[en,agua,mesa1],[brazosLibres,0]],L).
modificaBrazosLibres(_,[],[]):-!.
modificaBrazosLibres(Valor,[H|T],L):-
	modificaBrazosLibres(Valor,T,Res),
	[NombrePrecondicion|_] = H,
	(NombrePrecondicion = brazosLibres ->
		[brazosLibres,Y] = H, NewY is Y + Valor, addElement([[brazosLibres,NewY]],Res,L);addElement([H],Res,L)
	),!.

%obtenEstadoAgente([en,robot,inicio],S).
obtenEstadoAgente([H|T],Lista):-
	[en,A,L] = [H|T],
	object(A,"Agente",_,_) -> (
		Lista = [en,A,L]; Lista = []
	),!.

%iteradorEstadoAgente([[en, robot, inicio], [brazoLibre], [en, agua, estante1]],L).
iteradorEstadoAgente([],[]):-!.
iteradorEstadoAgente([H|_],L):-
	obtenEstadoAgente(H,L),
	length(L,Size),
	Size > 0,!.
iteradorEstadoAgente([_|T],L):-
	iteradorEstadoAgente(T,L),!.

%TIENE EN DURO clase alimento
%obtenEstadoObjeto([en,agua,estante1],L).
obtenEstadoObjeto([H|T],Lista):-
	[en,_,_] \= [H|T],
	Lista = [],!.
obtenEstadoObjeto([H|T],Lista):-
	[en,O,L] = [H|T],
	object(O,"Alimento",_,_) -> (
		Lista = [en,O,L]; Lista = []
	),!.
obtenEstadoObjeto([H|T],Lista):-
	[en,_,_] = [H|T],
	Lista = [],!.

%iteradorEstadoObjetos([[en, robot, inicio], [brazoLibre], [en, agua, estante1]],L).
iteradorEstadoObjetos([],[]):-!.
iteradorEstadoObjetos([H|T],L):-
	iteradorEstadoObjetos(T,LR),
	obtenEstadoObjeto(H,R),
	length(R,Size),
	(Size > 0 ->addElement([R],LR,UL);addElement([],LR,UL)
	),L = UL,!.

estadoDumy(L):-
	%L = [[en,robot,inicio],[brazoLibre],[en,refresco,estante1],[en,agua,estante1]].
	%L = [[en,robot,estante1],[brazoLibre],[en,refresco,estante1],[en,agua,estante2]].
	%L = [[en,robot,estante1],[brazoLibre],[en,refresco,estante1],[en,agua,estante1],[buscado,refresco,robot]].
	%L = [[en,robot,estante1],[en,refresco,estante1],[en,agua,estante1],[buscado,agua,robot],[buscado,refresco,robot]].
	%L = [[en, robot, estante1], [brazoLibre], [en, agua, estante1], [agarrado, refresco, robot]].
	%L = [[en, robot, estante1], [brazoLibre], [agarrado, refresco, robot],[agarrado, agua, robot]].
	L = [[en, robot, mesa1], [en, refresco,mesa1],[en, agua,mesa2]].
efectosDumy(EP,EN):-
	%EP = [[en,robot,mesa1]],EN = [[en,robot,inicio]].
	EP = [[buscado,agua,robot]],EN = [[]].
accionDummy(L):-
	%L = [mover,_,_,_].
	%L = [buscar,_,_,_].
	L = [agarrar,_,_,_].
	%L = [colocar,_,_,_].

%efectosDumy(EP,EN),estadoDumy(L),eliminaEfectosNegativos(EN,L,R).
eliminaEfectosNegativos([],[R|S],L):-L = [R|S],!.
eliminaEfectosNegativos([H|T],[R|S],L):-
	eliminaEfectosNegativos(T,[R|S],RS),
	elimina(H,RS,L),!.

encuentraTiempoRestante([],[]):-!.
encuentraTiempoRestante([ESH|EST],L):-
	(ESH = [tiempoRestate,Valor] ->
		L = [tiempoRestate,Valor];encuentraTiempoRestante(EST,L)
	),!.

%efectosDumy(EP,EN),estadoDumy(L),calculaNuevoEstadoAccion(EP,EN,L,R).
%getEfecto([mover,inicio,mesa1],EP,EN),estadoDumy(L),calculaNuevoEstadoAccion(EP,EN,L,R).
%getEfecto([buscar,refresco,estante1,robot],EP,EN),estadoDumy(L),calculaNuevoEstadoAccion(EP,EN,L,R).
%getEfecto([agarrar,refresco,estante1,robot],EP,EN),estadoDumy(L),write(EP),nl,write(EN),nl,write(L),nl,calculaNuevoEstadoAccion(EP,EN,L,R).
%getEfecto([entregar,refresco,mesa1,robot],EP,EN),estadoDumy(L),write(EP),nl,write(EN),nl,write(L),nl,calculaNuevoEstadoAccion(EP,EN,L,R).
calculaNuevoEstadoAccion(Costo,[EPH|EPT],[ENH|ENT],[ESH|EST],L):-
	eliminaEfectosNegativos([ENH|ENT],[ESH|EST],RE),
	addElement(RE,[EPH|EPT],NuevoEstado),
	tiempoRestate(Costo,NuevoEstado,NuevoTiempo),
	encuentraTiempoRestante(NuevoEstado,TiempoRestante),
	eliminaEfectosNegativos([TiempoRestante],NuevoEstado,EstadoSinTiempoRestante),
	addElement([[tiempoRestate,NuevoTiempo]],EstadoSinTiempoRestante,L),!.

%accionDummy(L),L = [mover,robot,inicio,mesa1],getEfecto(L,EP,EN).
getEfecto([EstadoH|EstadoT],[H|T],EP,EN,L):-
	[mover,X,Y,Z] = [H|T],
	addElement([[en,X,Z]],[],EP),
	addElement([[en,X,Y]],[],EN),
	L = [EstadoH|EstadoT],!.
%accionDummy(L),L = [buscar,refresco,estante1,robot],getEfecto(L,EP,EN).
getEfecto([EstadoH|EstadoT],[H|T],EP,EN,L):-
	[buscar,O,_,X] = [H|T],
	addElement([[buscado,O,X]],[],EP),
	addElement([[]],[],EN),
	L = [EstadoH|EstadoT],!.
%accionDummy(L),L = [agarrar,refresco,estante1,robot],getEfecto(L,EP,EN).
%getEfecto([[brazosLibres,2],[en,agua,estante2],[en,refresco,estante2],[en,robot,estante2],[buscado,refresco,robot]],[agarrar,refresco,estante2,robot],EP,EN).
getEfecto([EstadoH|EstadoT],[H|T],EP,EN,NuevoEstado):-
	[agarrar,O,L,X] = [H|T],
	addElement([[agarrado,O,X]],[],EP),
	addElement([[en,O,L],[buscado,O,X]],[],EN),
	modificaBrazosLibres(-1,[EstadoH|EstadoT],NuevoEstado),!.
%accionDummy(L),L = [colocar,refresco,estante1,robot],getEfecto(L,EP,EN).
getEfecto([EstadoH|EstadoT],[H|T],EP,EN,NuevoEstado):-
	[entregar,O,L,X] = [H|T],
	addElement([[en,O,L]],[],EP),
	addElement([[agarrado,O,X]],[],EN),
	modificaBrazosLibres(1,[EstadoH|EstadoT],NuevoEstado),!.
%estadoDumy(L),iteradorEstadoObjetos(L,A),encuentraAccionBusqueda([en, refresco, estante1],L,E,R).
%estadoDumy(L),iteradorEstadoObjetos(L,A),encuentraAccionBusqueda([en, agua, estante1],L,E,R).
encuentraAccionBusqueda([H|T],[],E,[]):- E = [H|T],!.
encuentraAccionBusqueda([H|T],[R|S],E,A):-
	[Metodo|_] = R,
	(Metodo = buscado ->(
			([en,O,_] = [H|T],
			[buscado,O,X] = R)->(
				addElement([buscado,O,X],[],A),
				E = []
			);
			encuentraAccionBusqueda([H|T],S,E,A)
		);
		encuentraAccionBusqueda([H|T],S,E,A)
	),!.
%estadoDumy(L),iteradorEstadoObjetos(L,A),encuentraAccionesBusqueda(A,L,E,R).
encuentraAccionesBusqueda([],[_|_],[],[]):-!.
encuentraAccionesBusqueda([H|T],[R|S],E,L):-
	encuentraAccionesBusqueda(T,[R|S],RE1,RS),
	encuentraAccionBusqueda(H,[R|S],RE,RA),
	length(RE,SizeRE),
	(SizeRE > 0 -> addElement([RE],RE1,E); addElement([],RE1,E)
	),
	length(RA,SizeRA),
	(SizeRA > 0 -> addElement([RA],RS,L); addElement([],RS,L)
	),!.

%estadoDumy(L),iteradorEstadoAgente(L,EA),iteradorEstadoObjetos(L,EO),iteraAccionBuscarMover(EA,EO,R).
iteraAccionBuscarMover([_|_],[],[_|_],false,[]):-!.
iteraAccionBuscarMover([R|S],[Y|W],[EstadoH|EstadoT],FlagBuscar,L):-
	brazosLibres([EstadoH|EstadoT],Z),
	(Z > 0 ->
		iteraAccionBuscarMover([R|S],W,[EstadoH|EstadoT],ResFlagBuscar,RS),
		[en,A,La] = [R|S],
		[en,O,Lo] = Y,
		(La \= Lo  ->  	cuenta([mover,A,La,Lo],RS,Cuenta),
				FlagBuscar = ResFlagBuscar,
				(Cuenta = 0,enTiempo([mover,A,La,Lo],[EstadoH|EstadoT]) ->
					addElement([[mover,A,La,Lo]],RS,L);addElement([],RS,L))
				;
				(enTiempo([buscar,O,Lo,A],[EstadoH|EstadoT]) ->
					addElement([[buscar,O,Lo,A]],RS,L),FlagBuscar = true;addElement([],RS,L),FlagBuscar = false
				)
		);
		L = []
		%VALIDAR SI ES NECESARIO
		%[en,A,La] = [R|S],
		%[en,_,Lo] = Y,
		%cuenta([mover,A,La,Lo],RS,Cuenta),
		%(Cuenta = 0 -> addElement([[mover,A,La,Lo]],RS,L);addElement([],RS,L))
	),!.

iteraAccionAgarrar([_|_],[],[_|_],[]):-!.
iteraAccionAgarrar([A|B],[H|T],[EstadoH|EstadoT],L):-
	brazosLibres([EstadoH|EstadoT],Z),
	(Z > 0 ->
		iteraAccionAgarrar([A|B],T,[EstadoH|EstadoT],RS),
		[en,X,Lx] = [A|B],
		[buscado,O,X] = H,
		(enTiempo([agarrar,O,Lx,X],[EstadoH|EstadoT]) ->
			addElement([[agarrar,O,Lx,X]],RS,L);addElement([],RS,L)
		)
		;
		L = []
	),!.


%iteraObjetoAgarrado(agua,[en,robot,estante1],[[en,agua,mesa1],[en,refresco,mesa2]],L).
iteraObjetoAgarrado([_,_],_,[_|_],[],[]):-write("Entro"),!.
iteraObjetoAgarrado([EstadoH|EstadoT],Objeto,[C|D],[E|F],L):-
	[en,O,Lo] = E,
	(O = Objeto -> 	[en,A,La] = [C|D],
			(Lo = La ->
				(enTiempo([entregar,O,Lo,A],[EstadoH|EstadoT]) ->
					L = [entregar,O,Lo,A]; L = []
				);
				(enTiempo([mover,A,La,Lo],[EstadoH|EstadoT]) ->
					L = [mover,A,La,Lo]; L = []
				)
			);
			iteraObjetoAgarrado([EstadoH|EstadoT],Objeto,[C|D],F,L)
	),!.

%iteraObjetosAgarrados([agua,refresco],[en,robot,estante1],[[en,agua,mesa1],[en,refresco,mesa2]],L).
iteraObjetosAgarrados([_|_],[],[_|_],[_|_],[]):-!.
iteraObjetosAgarrados([EstadoH|EstadoT],[H|T],[C|D],[E|F],L):-
	iteraObjetosAgarrados([EstadoH|EstadoT],T,[C|D],[E|F],RS),
	iteraObjetoAgarrado([EstadoH|EstadoT],H,[C|D],[E|F],RA),
	length(RA,Size),
	(Size > 0 ->
		addElement([RA],RS,L);addElement([],RS,L)
	),!.

%agregaObjetosAgarrados([[agarrado,agua,robot],[agarrado,refresco,robot],[en,robot,inicio]],L).
agregaObjetosAgarrados([],[]):-!.
agregaObjetosAgarrados([H|T],L):-
	agregaObjetosAgarrados(T,RS),
	([agarrado,O,_] = H ->	addElement([O],RS,L);addElement([],RS,L)
	),!.

iteraDepuraAccionesAlcanzadas([_|_],[],[]):-!.
iteraDepuraAccionesAlcanzadas([],[EoH|EoT],L):-L = [EoH|EoT],!.
iteraDepuraAccionesAlcanzadas([ObH|ObT],[EoH|EoT],L):-
	iteraDepuraAccionesAlcanzadas(ObT,[EoH|EoT],RE),
	elimina(ObH,RE,L),!.

%depuraAccionesAlcanzadas([[en,agua,mesa1],[en,refresco,mesa2]],[[en,agua,estante1],[en,refresco,estante2]],L).
depuraAccionesAlcanzadas([_|_],[],[]):-!.
depuraAccionesAlcanzadas([A|B],[R|S],L):-
	iteraDepuraAccionesAlcanzadas([A|B],[R|S],L).

%estadoDumy(L),estadoObjetivo([agua=>mesa1,refresco=>mesa2],LO),encuentraAccionesAplicables(LO,L,S).
%encuentraAccionesAplicables([[en,agua,mesa1],[en,refresco,mesa2]],[[en,agua,estante2],[en,refresco,estante2],[en,robot,estante2],[buscado,agua,robot],[buscado,refresco,robot]],L).
encuentraAccionesAplicables([A|B],[R|S],L):-
	iteradorEstadoAgente([R|S],EA),iteradorEstadoObjetos([R|S],EO),
	depuraAccionesAlcanzadas([A|B],EO,EO1),
	encuentraAccionesBusqueda(EO1,[R|S],EO2,EB),
	length(EB,Size),
	(Size > 0 ->
		L1 = []; iteraAccionBuscarMover(EA,EO2,[R|S],FlagBuscar,LF),eliminaMovimientos(FlagBuscar,LF,L1)
	),
	iteraAccionAgarrar(EA,EB,[R|S],L2),
	addElement(L1,L2,L3),
	agregaObjetosAgarrados([R|S],OA),
	iteraObjetosAgarrados([R|S],OA,EA,[A|B],L4),
	addElement(L3,L4,L),!.
	
eliminaMovimientos(_,[],[]):-!.
eliminaMovimientos(FlagBuscar,[LBMH|LBMT],LF):-
	eliminaMovimientos(FlagBuscar,LBMT,Res),
	(FlagBuscar ->
		[AM|_] = LBMH,
		(AM = buscar->
			addElement([LBMH],Res,LF);addElement([],Res,LF)
		)
		;
		LF = [LBMH|LBMT]
	),!.

nodo([_|_]).

%estadoDumy(L),generaNodoPadreDummy(L,NodoPadreDummy).
generaNodoPadreDummy(L,NodoPadreDummy):-
	NodoPadreDummy = nodo([estado=>L,probabilidad=>96,recompenza=>300,costo=>15,heuristicaProbabilidad=>818,heuristicaRecompenza=>1310]).

%estadoDumy(L),generaNodoPadreDummy(L,NodoPadreDummy),comparaMejorNodo(NodoPadreDummy,[buscar,refresco,estante1,robot],nodo([estado=>[],probabilidad=>0,recompenza=>0,costo=>0]),NewNodo),write(NewNodo).
%estadoDumy(L),generaNodoPadreDummy(L,NodoPadreDummy),comparaMejorNodo(NodoPadreDummy,[buscar,refresco,estante1,robot],nodo([estado=>[[en,robot,estante1],[brazoLibre],[en,agua,estante1],[agarrado,refresco,robot],[buscado,refresco,robot],[buscado,refresco,robot]],probabilidad=>96.0,recompenza=>50,costo=>2,heuristicaProbabilidad=>818,heuristicaRecompenza=>1310,accion=>[mover,robot,inicio,estante1]]),NewNodo),write(NewNodo).
%comparaMejorNodo(nodo([estado=>[[brazosLibres,2],[en,agua,estante2],[en,refresco,estante2],[en,robot,estante2],[buscado,refresco,robot]],probabilidad=>96.0,recompenza=>50,costo=>2,heuristicaProbabilidad=>554.0,heuristicaRecompenza=>860,accion=>[buscar,refresco,estante2,robot]]),[agarrar,refresco,estante2,robot],nodo([estado=>[[brazosLibres,2]],probabilidad=>0,recompenza=>0,costo=>0,accion=>[]]),N).
comparaMejorNodo(NodoPadre,MinDecision,MinNodo,[AccionH|AccionT],[ObH|ObT],NewDecision,NewNodo):-
	%write("---- Se compara nodo ----"),nl,
	%write("NodoPadre:"),tab(2),write(NodoPadre),nl,
	%write("[AccionH|AccionT]:"),tab(2),write([AccionH|AccionT]),nl,
	%write("NodoHijoMin:"),tab(2),write(NodoHijoMin),nl,
	[NombreAccion|_] = [AccionH|AccionT],
	nodo([NPH|NPT]) = NodoPadre,
	%nodo([NHMH|NHMT]) = NodoHijoMin,
	searchValue(probabilidad,[NPH|NPT],ProbabilidadAcumulada),
	searchValue(recompenza,[NPH|NPT],RecompenzaAcumulada),
	searchValue(costo,[NPH|NPT],CostoAcumulado),
	searchValue(h1T,[NPH|NPT],H1T),
	searchValue(h2T,[NPH|NPT],H2T),
	%searchValue(probabilidadH,[NHMH|NHMT],ProbabilidadHMin),
	%searchValue(recompenzaH,[NHMH|NHMT],RecompenzaHMin),
	%searchValue(costo,[NHMH|NHMT],CostoHMin),
	searchValue(estado,[NPH|NPT],Estado),
	(NombreAccion = buscar ->
		[_,Objeto,_,_] = [AccionH|AccionT],
		probabilidadDe(NombreAccion,Objeto,ProbabilidadNodo),
		probabilidadDe(agarrar,Objeto,ProbabilidadAgarrar),
		probabilidadDe(entregar,Objeto,ProbabilidadEntregar),
		recompensaDe(NombreAccion,Objeto,RecompenzaNodo),
		recompensaDe(agarrar,Objeto,RecompenzaAgarrar),
		recompensaDe(entregar,Objeto,RecompenzaEntregar),
		costoDe(NombreAccion,Objeto,CostoNodo),
		costoDe(agarrar,Objeto,CostoAgarrar),
		costoDe(entregar,Objeto,CostoEntregar),
		Probabilidades is ProbabilidadNodo * ProbabilidadAgarrar * ProbabilidadEntregar,
		Recompenzas is RecompenzaNodo + RecompenzaAgarrar + RecompenzaEntregar,
		Costos is CostoNodo + CostoAgarrar + CostoEntregar,
		TiempoAccion = CostoNodo,
		Mover = false;
		(NombreAccion = agarrar ->
			[_,Objeto,_,_] = [AccionH|AccionT],
			probabilidadDe(NombreAccion,Objeto,ProbabilidadNodo),
			recompensaDe(NombreAccion,Objeto,RecompenzaNodo),
			costoDe(NombreAccion,Objeto,CostoNodo),
			Probabilidades is ProbabilidadNodo,
			Recompenzas is RecompenzaNodo,
			Costos = CostoNodo,
			TiempoAccion = CostoNodo,
			Mover = false;
			(NombreAccion = entregar ->
				[_,Objeto,_,_] = [AccionH|AccionT],
				probabilidadDe(NombreAccion,Objeto,ProbabilidadNodo),
				recompensaDe(NombreAccion,Objeto,RecompenzaNodo),
				costoDe(NombreAccion,Objeto,CostoNodo),
				Probabilidades is ProbabilidadNodo,
				Recompenzas is RecompenzaNodo,
				Costos = CostoNodo,
				TiempoAccion = CostoNodo,
				Mover = false;
				obtenTiempo(Estado,TiempoRestante),
				[_,_,Li,Lj] = [AccionH|AccionT],
				probabilidadDeIr(Li,Lj,ProbabilidadNodo),
				RecompenzaNodo = 0,
				Probabilidades is ProbabilidadNodo * ProbabilidadAcumulada,
				%obtenCostoAristaMovimiento(TiempoRestante,Probabilidades,H1T,RecompenzaAcumulada,H2T,
				%	[AccionH|AccionT],Estado,[ObH|ObT],Resultado),
				%Resultado = [h=>Heu,numero=>Per],
				%(Per > 1 -> HeuristicaMovimiento is Heu / 2;HeuristicaMovimiento = Heu
				%),
				HeuristicaMovimiento = 9999999999,
				Recompenzas = RecompenzaNodo,
				costoDeIr(Li,Lj,TiempoAccion),
				CostoNodo = TiempoAccion,
				Costos =  CostoNodo,
				Mover = true
			)
		)
	),
	ProbabilidadTotal is ProbabilidadAcumulada * ProbabilidadNodo,
	RecompenzaTotal is RecompenzaAcumulada + RecompenzaNodo,
	CostoTotal is CostoAcumulado + CostoNodo,
	AESTREALLAF is (Recompenzas + RecompenzaAcumulada) /  (Probabilidades * ProbabilidadAcumulada),
	NH1T is H1T - CostoNodo,
	H1 is Costos,
	H2 is (Recompenzas + RecompenzaAcumulada),
	(Mover = true -> Heuristica = HeuristicaMovimiento;calculaHeuristica(H1,H1T,H2,H2T,Heuristica)),
	%write("Calculo Heuristicas"),nl,
	write(Heuristica + CostoTotal),nl,
	write(MinDecision),nl,
	%write("Fin Calculo Heuristicas"),nl,
	((Heuristica + AESTREALLAF) < MinDecision ->
		getEfecto(Estado,[AccionH|AccionT],EP,EN,EstadoBrazos),
		calculaNuevoEstadoAccion(TiempoAccion,EP,EN,EstadoBrazos,NuevoEstado),
		NewNodo = nodo([estado=>NuevoEstado,probabilidad=>ProbabilidadTotal,recompenza=>RecompenzaTotal,costo=>CostoTotal,h1T=>NH1T,h2T=>H2T,accion=>[AccionH|AccionT]]),
		NewDecision is Heuristica + AESTREALLAF
		;
		NewNodo = MinNodo,
		NewDecision = MinDecision
	),
	%write("---- Termino compara nodo ----"),
	nl,!.


%calculaHeuristica(96,818,50,1310,H).
calculaHeuristica(H1,H1T,H2,H2T,Heuristica):-
	Heuristica is sqrt((H1T - H1)^2 + (H2T - H2)^2).

%buscaMejorExpancion(nodo([estado=>[],probabilidad=>0,recompenza=>0,costo=>0,heuristicaProbabilidad=>818,heuristicaRecompenza=>1310]),[[buscar,refresco,mesa1,x],[mover,robot,mesa1,mesa2]],N).
%estadoInicial([agua=>mesa1,refresco=>mesa2],EI),estadoObjetivo([agua=>mesa1,refresco=>mesa2],LO),Nodo = nodo([estado=>EI,probabilidad=>0,recompenza=>0,costo=>0,heuristicaRecompenza=>1310,heuristicaProbabilidad=>818]),encuentraAccionesAplicables(LO,EI,AccionesAplicable),buscaMejorExpancion(Nodo,AccionesAplicable,NodoExpancion).
%estadoInicial([hamburguesa=>mesa1,refresco=>mesa2],EI),estadoObjetivo([hamburguesa=>mesa1,refresco=>mesa2],LO),Nodo = nodo([estado=>EI,probabilidad=>0,recompenza=>0,costo=>0,heuristicaRecompenza=>1310,heuristicaProbabilidad=>818]),encuentraAccionesAplicables(LO,EI,AccionesAplicable),buscaMejorExpancion(Nodo,AccionesAplicable,NodoExpancion).
%estadoInicial([agua=>mesa3,sandwich=>mesa1,hamburguesa=>mesa1,refresco=>mesa2],EI),estadoObjetivo([agua=>mesa3,sandwich=>mesa1,hamburguesa=>mesa1,refresco=>mesa2],LO),Nodo = nodo([estado=>EI,probabilidad=>0,recompenza=>0,costo=>0,heuristicaRecompenza=>1310,heuristicaProbabilidad=>818]),encuentraAccionesAplicables(LO,EI,AccionesAplicable),buscaMejorExpancion(Nodo,AccionesAplicable,NodoExpancion),write(NodoExpancion).
%estadoInicial([agua=>mesa3,sandwich=>mesa1,refresco=>mesa2],EI),estadoObjetivo([agua=>mesa3,sandwich=>mesa1,refresco=>mesa2],LO),Nodo = nodo([estado=>EI,probabilidad=>0,recompenza=>0,costo=>0,heuristicaRecompenza=>1310,heuristicaProbabilidad=>818]),encuentraAccionesAplicables(LO,EI,AccionesAplicable),buscaMejorExpancion(Nodo,AccionesAplicable,NodoExpancion),write(NodoExpancion).
%buscaMejorExpancion(nodo([estado=>[[brazosLibres,2],[en,agua,estante2],[en,refresco,estante2],[en,robot,estante2],[buscado,refresco,robot]],probabilidad=>96.0,recompenza=>50,costo=>2,heuristicaProbabilidad=>554.0,heuristicaRecompenza=>860,accion=>[buscar,refresco,estante2,robot]]),[[buscar,agua,estante2,robot],[agarrar,refresco,estante2,robot]],L).
buscaMejorExpancion(_,[],[_|_],NewDecision,NodoExpancion):-
	NewDecision = 99999999999999999999999999,
	NodoExpancion = nodo([]),!.
buscaMejorExpancion(Nodo,[AccionesH|AccionesT],[ObH|ObT],NewDecision,NodoExpancion):-
	buscaMejorExpancion(Nodo,AccionesT,[ObH|ObT],MinDecision,MinNodo),
	comparaMejorNodo(Nodo,MinDecision,MinNodo,AccionesH,[ObH|ObT],NewDecision,NodoExpancion),!.

iteraEstadoObjetivos([_|_],[],CuentaTotal):-CuentaTotal = 0,!.
iteraEstadoObjetivos([H|T],[EoH|EoT],CuentaTotal):-
	cuenta([H|T],[EoH|EoT],Cuenta),
	(Cuenta>0 ->
		CuentaTotal is Cuenta;
		iteraEstadoObjetivos([H|T],EoT,CuentaParcial),
		CuentaTotal = CuentaParcial
	),!.

%iteraEstadosObjetivos([[en,agua,mesa1],[en,refresco,mesa2]],[],Cuenta).
iteraEstadosObjetivos([_|_],[],CuentaTotal):-CuentaTotal = 0,!.
iteraEstadosObjetivos([],[_|_],CuentaTotal):-CuentaTotal = 0,!.
iteraEstadosObjetivos([ObH|ObT],[EoH|EoT],CuentaTotal):-
	iteraEstadosObjetivos(ObT,[EoH|EoT],CuentaParcial),
	iteraEstadoObjetivos(ObH,[EoH|EoT],CuentaObjetivo),
	CuentaTotal is CuentaParcial + CuentaObjetivo,!.
%estadoObjetivo([agua=>mesa2,refresco=>mesa1],LO),estadoDumy(L),validaSatisfacibilidad(LO,L).
validaSatisfacibilidad([ObH|ObT],[EsH|EsT]):-
	iteradorEstadoObjetos([EsH|EsT],EO),
	iteraEstadosObjetivos([ObH|ObT],EO,Cuenta),
	length([ObH|ObT],Size),
	(Cuenta =  Size ->
		write("No satisface"),nl,
		false;
		write("Satisface"),nl,
		true
	),!.

%obtenRecompenzaObjetivo([agua=>mesa1,refresco=>mesa2], R).
obtenRecompenzaObjetivo([],0):-!.
obtenRecompenzaObjetivo([H|T],RecompenzaObjetivo):-
	obtenRecompenzaObjetivo(T,RecompenzaRes),
	=>(Objeto,_) = H,
	recompensaDe(buscar,Objeto,RecompenzaBuscar),
	recompensaDe(agarrar,Objeto,RecompenzaAgarrar),
	recompensaDe(entregar,Objeto,RecompenzaEntregar),
	RecompenzaObjetivo is RecompenzaRes + RecompenzaBuscar + RecompenzaAgarrar + RecompenzaEntregar,!.

%obtenProbabilidadObjetivo([agua=>mesa1,refresco=>mesa2], R).
obtenProbabilidadObjetivo([],1):-!.
obtenProbabilidadObjetivo([H|T],ProbabilidadObjetivo):-
	obtenProbabilidadObjetivo(T,ProbabilidadRes),
	=>(Objeto,_) = H,
	probabilidadDe(buscar,Objeto,ProbabilidadBuscar),
	probabilidadDe(agarrar,Objeto,ProbabilidadAgarrar),
	probabilidadDe(entregar,Objeto,ProbabilidadEntregar),
	%write("("),write(ProbabilidadBuscar),write(")*"),write("("),write(ProbabilidadAgarrar),write(")*"),write("("),write(ProbabilidadEntregar),write(")"),nl,
	ProbabilidadObjetivo is ProbabilidadRes + ProbabilidadBuscar + ProbabilidadAgarrar + ProbabilidadEntregar,!.

%planning([agua=>mesa1,refresco=>mesa2],Plan).
planeador(Nodo,[ObH|ObT],Plan):-
	%estadoInicial([H|T],E0),
	%nodo([estado=>E0,probabilidad=>0,recompenza=>0,costo=>0,heuristicaRecompenza=>1310,heuristicaProbabilidad=>818]),
	write("Nueva Iteracion"),nl,
	nodo([NodoH|NodoT]) = Nodo,
	searchValue(estado,[NodoH|NodoT],Estado),
	validaSatisfacibilidad([ObH|ObT],Estado),
	write("Nodo"),nl,
	write(Nodo),nl,
	encuentraAccionesAplicables([ObH|ObT],Estado,AccionesAplicable),
	write("Acciones"),nl,
	write(AccionesAplicable),nl,
	%write("Acciones"),nl,
	%write(AccionesAplicable),nl,nl,
	buscaMejorExpancion(Nodo,AccionesAplicable,[ObH|ObT],_,NodoExpancion),
	nodo([NodoEH|NodoET]) = NodoExpancion,
	searchValue(accion,[NodoEH|NodoET],Accion),
	length(AccionesAplicable,Size),
	(Size > 0 ->
		planeador(NodoExpancion,[ObH|ObT],PlanInicial),
		addElement([Accion],PlanInicial,Plan);
		Plan = []
	),!.
planeador(Nodo,[_|_],[]):-
	nodo([NodoH|NodoT]) = Nodo,
	searchValue(recompenza,[NodoH|NodoT],Recompenza),
	searchValue(probabilidad,[NodoH|NodoT],Probabilidad),
	searchValue(costo,[NodoH|NodoT],Costo),
	write(Recompenza),nl,write(Probabilidad),nl,write(Costo),nl,
	write("Fin de la planeacion"),nl,!.

obtenMovimientoCostoEntrega([],[]):-!.
obtenMovimientoCostoEntrega([EstadoH|EstadoT],ObjetosAgarrados):-
	obtenObjetoAgarrados(EstadoT,Res),
	[Metodo|_] = EstadoH,
	(Metodo = agarrado ->
		[Metodo,Objeto,_] = EstadoH,
		addElement(Objeto,Res,ObjetosAgarrados)
		;
		addElement([],Res,ObjetosAgarrados)
	),!.


%obtenMovimientoCostoEntrega(20,56,40,200,600,0,[mover,robot,estante1,mesa1],[[agarrado,agua],[agarrado,cafe,robot]],[en,cafe,mesa1],NR,NC).
%obtenMovimientoCostoEntrega(16,56,40,200,600,0,[mover,robot,estante1,mesa2],[[agarrado,agua],[agarrado,cafe,robot]],[en,cafe,mesa1],NR,NC).
obtenMovimientoCostoEntrega(_,_,_,_,_,
	MinimaHeuristica,[_|_],[],[_|_],NuevaMinimaHeuristica,_):- NuevaMinimaHeuristica = MinimaHeuristica,!.
obtenMovimientoCostoEntrega(CostoLimite,ProbabilidadH,H1T,RecompenzaH,H2T,
	MinimaHeuristica,[AccionH|AccionT],[EstadoH|EstadoT],[MetaH|MetaT],NuevaMinimaHeuristica,H):-
	[Metodo|_] = EstadoH,
	(Metodo = agarrado ->
		([mover,_,Li,Lj] = [AccionH|AccionT],
		[en,ObjetoMeta,Lj] = [MetaH|MetaT],
		[agarrado,ObjetoMeta,_] = EstadoH ->
			costoDeIr(Li,Lj,CostoIr),
			(CostoLimite - CostoIr >= 0 ->
				probabilidadDe(NombreAccion,Objeto,ProbabilidadBuscar),
				probabilidadDe(agarrar,Objeto,ProbabilidadAgarrar),
				probabilidadDe(entregar,Objeto,ProbabilidadEntregar),
				recompensaDe(NombreAccion,Objeto,RecompenzaBuscar),
				recompensaDe(agarrar,Objeto,RecompenzaAgarrar),
				recompensaDe(entregar,Objeto,RecompenzaEntregar),
				Probabilidades is ProbabilidadBuscar * ProbabilidadAgarrar * ProbabilidadEntregar * ProbabilidadH,
				Recompenzas is RecompenzaBuscar + RecompenzaAgarrar + RecompenzaEntregar + RecompenzaH,
				AESTREALLAF is Recompenzas / Probabilidades,
				H1 is CostoIr,
				H2 is Recompenzas,
				calculaHeuristica(H1,H1T,H2,H2T,Heuristica),
				(Heuristica + AESTREALLAF < MinimaHeuristica ->
					H is Heuristica + AESTREALLAF,NuevaMinimaHeuristica is  Heuristica + AESTREALLAF
					;H = MinimaHeuristica, NuevaMinimaHeuristica =  MinimaHeuristica
				);
				H = MinimaHeuristica,NuevaMinimaHeuristica =  MinimaHeuristica
			)
			;
			obtenMovimientoCostoEntrega(CostoLimite,ProbabilidadH,H1T,RecompenzaH,H2T,
				MinimaHeuristica,[AccionH|AccionT],EstadoT,[MetaH|MetaT],NuevaMinimaHeuristica,H)
		)
		;
		obtenMovimientoCostoEntrega(CostoLimite,ProbabilidadH,H1T,RecompenzaH,H2T,
			MinimaHeuristica,[AccionH|AccionT],EstadoT,[MetaH|MetaT],NuevaMinimaHeuristica,H)
	),!.

%obtenMovimientoCostoEntregas(16,56,40,200,600,[mover,robot,estante1,mesa2],[[agarrado,agua],[agarrado,cafe,robot]],[[en,cafe,mesa1],[en,cafe,mesa2]],0,Costo).
obtenMovimientoCostoEntregas(CostoLimite,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,
	[AccionH|AccionT],[EstadoH|EstadoT],[ObjetivoH|ObjetivoT],MinimaHeuristica,Costo):-
	obtenMovimientoCostoEntrega(CostoLimite,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,
		MinimaHeuristica,[AccionH|AccionT],[EstadoH|EstadoT],ObjetivoH,ResMinimaHeuristica,Costo),
	obtenMovimientoCostoEntregas(CostoLimite,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,
		[AccionH|AccionT],[EstadoH|EstadoT],ObjetivoT,ResMinimaHeuristica,Costo),!.
obtenMovimientoCostoEntregas(_,_,_,_,_,
	[_|_],[_|_],[],0,Costo):- Costo = 0,!.
obtenMovimientoCostoEntregas(_,_,_,_,_,
	[_|_],[_|_],[],_,_):-!.

%obtenCostoAristaMovimiento(14,56,40,200,600,[mover,robot,estante1,mesa2],[[agarrado,agua],[agarrado,cafe,robot]],[[en,cafe,mesa1],[en,cafe,mesa2]],Costo).
obtenCostoAristaMovimiento(CostoLimite,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,
	[AccionH|AccionT],[EstadoH|EstadoT],[ObjetivoH|ObjetivoT],Permutacion):-
	calculaHeuristica(0,HeuristicaProbabilidad,0,HeuristicaRecompenza,MH),
	MinimaHeuristicaInicial is MH + HeuristicaRecompenza / 0.1,
	obtenMovimientoCostoEntregas(CostoLimite,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,
		[AccionH|AccionT],[EstadoH|EstadoT],[ObjetivoH|ObjetivoT],MinimaHeuristicaInicial,CostoMovimientoEntrega),
	(CostoMovimientoEntrega = 0 ->
		brazosLibres([EstadoH|EstadoT],BrazosLibres),
		(BrazosLibres = 2 ->
			depuraAccionesAlcanzadas([ObjetivoH|ObjetivoT],[EstadoH|EstadoT],Res),
			obtenHeuristicasPorTiempo(CostoLimite,_,HeuristicaProbabilidad,_,HeuristicaRecompenza,
				[AccionH|AccionT],[ObjetivoH|ObjetivoT],Res,_,L),
				write(L),nl,
			obtenMejorPermutacion(CostoLimite,L,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,[ObjetivoH|ObjetivoT],L,NuevoMinimo),
			searchValue(heuristica,NuevoMinimo,Heu),
			searchValue(permutaciones,NuevoMinimo,Per),
			Permutacion = [h=>Heu,numero=>Per]
			;
			Permutacion = [h=>999999999999999999999,numero=>1]
		)
		;
		Permutacion = [h=>CostoMovimientoEntrega,numero=>1]
	),!.

%obtenHeuristicasPorTiempo(20,70,60,300,1000,[mover,robot,mesa1,mesa2],[[en,agua,estante1],[en,refresco,mesa2],[en,cafe,mesa2]],M,C).
obtenHeuristicasPorTiempo(_,_,HeuristicaProbabilidad,_,HeuristicaRecompenza,
	[_|_],[_|_],[],MinimaHeuristicaInicial,[]):-
	calculaHeuristica(0,HeuristicaProbabilidad,0,HeuristicaRecompenza,MH),
	MinimaHeuristicaInicial is MH + HeuristicaRecompenza / 0.1,!.
obtenHeuristicasPorTiempo(CostoLimite,_,H1T,_,H2T,
	[AccionH|AccionT],[ObjetivoH|ObjetivoT],[EstadoH|EstadoT],NuevaMinimaHeuristica,L):-
	obtenHeuristicasPorTiempo(CostoLimite,_,H1T,_,H2T,
		[AccionH|AccionT],[ObjetivoH|ObjetivoT],EstadoT,MinimaHeuristica,Res),
	([en,Entidad,Lj] = EstadoH,object(Entidad,"Alimento",_,_),[mover,A,Li,Lj] = [AccionH|AccionT] ->
		costoDe(buscar,Entidad,CostoBuscar),
		costoDe(agarrar,Entidad,CostoAgarrar),
		costoDe(entregar,Entidad,CostoEntregar),
		recompensaDe(buscar,Entidad,RecompenzaBuscar),
		recompensaDe(agarrar,Entidad,RecompenzaAgarrar),
		recompensaDe(entregar,Entidad,RecompenzaEntregar),
		probabilidadDe(buscar,Entidad,ProbabilidadBuscar),
		probabilidadDe(agarrar,Entidad,ProbabilidadAgarrar),
		probabilidadDe(entregar,Entidad,ProbabilidadEntregar),
		CostoParcial is CostoBuscar + CostoAgarrar + CostoEntregar,
		(CostoLimite - CostoParcial >= 0 ->
			Probabilidades is ProbabilidadBuscar * ProbabilidadAgarrar * ProbabilidadEntregar,
			Recompenzas is RecompenzaBuscar + RecompenzaAgarrar + RecompenzaEntregar,
			Costo is CostoParcial,
			addElement([[buscar,Entidad,Lj,A]],[],L1),
			addElement([[agarrar,Entidad,Lj,A]],L1,L2),
			movimientoEntrega(Entidad,[ObjetivoH|ObjetivoT],LugarF),
			addElement([[entregar,Entidad,LugarF,A]],L2,Acciones)
			;
			CostoParcialBusquedaAgarrar is CostoBuscar + CostoAgarrar,
			(CostoLimite - CostoParcialBusquedaAgarrar >= 0 ->
				Probabilidades is ProbabilidadBuscar * ProbabilidadAgarrar,
				Recompenzas is RecompenzaBuscar + RecompenzaAgarrar,
				Costo is CostoParcialBusquedaAgarrar,
				addElement([[buscar,Entidad,Lj,A]],[],L1),
				addElement([[agarrar,Entidad,Lj,A]],L1,Acciones)
				;
				CostoParcialBusqueda is CostoBuscar,
				(CostoLimite - CostoParcialBusqueda >= 0 ->
					Recompenzas is RecompenzaBuscar,
					Probabilidades is ProbabilidadBuscar,
					Costo is CostoParcialBusqueda,
					addElement([[buscar,Entidad,Lj,A]],[],Acciones)
					;
					Costo = 0
				)
			)
		),
		(Costo > 0 ->
			AESTREALLAF is Recompenzas / Probabilidades,
			H1 is Costo,
			H2 is Recompenzas,
			calculaHeuristica(H1,H1T,H2,H2T,Heuristica),
			(Heuristica + AESTREALLAF < MinimaHeuristica ->
				NuevaMinimaHeuristica is  Heuristica + AESTREALLAF, 
				addElement([[acciones=>Acciones,objeto=>Entidad,origen=>Li,origenBusqueda=>Lj,probabilidad=>Probabilidades,recompenza=>Recompenzas,costo=>Costo,heuristica=>NuevaMinimaHeuristica]],Res,L)
				;NuevaMinimaHeuristica =  MinimaHeuristica,
				addElement(Res,[[acciones=>Acciones,objeto=>Entidad,origen=>Li,origenBusqueda=>Lj,probabilidad=>Probabilidades,recompenza=>Recompenzas,costo=>Costo,heuristica=>NuevaMinimaHeuristica]],L)
			)
			;
			NuevaMinimaHeuristica =  MinimaHeuristica,
			addElement([],Res,L)
		)
		;
		NuevaMinimaHeuristica =  MinimaHeuristica,
		addElement([],Res,L)
	),!.

%permutaHeuristica(20,[condicion=>[en, refresco, mesa2], probabilidad=>0.9119999999999999, recompenza=>130, costo=>4],70,60,300,1000,[[condicion=>[en, cafe, mesa2], probabilidad=>0.85, recompenza=>50, costo=>10]],N).
permutaHeuristica(_,H,_,_,_,_,[_|_],[],NuevoMinimo):-
	searchValue(acciones,H,A1),
	searchValue(heuristica,H,Heuristica),
	NuevoMinimo = [acciones=>A1,heuristica=>Heuristica,permutaciones=>1],!.
permutaHeuristica(Costo,H,_,_,_,_,[ObjetivoH|ObjetivoT],[H1|T],NuevoMinimo):-
	permutaHeuristica(Costo,H,_,_,_,_,[ObjetivoH|ObjetivoT],T,Minimo),
	searchValue(costo,H1,Costo2),
	searchValue(costo,H,Costo1),
	searchValue(acciones,H,A1),
	searchValue(acciones,H1,A2),
	addElement(A1,A2,Acciones),
	NuevoCosto is Costo2 + Costo1,
	(Costo - NuevoCosto > 0 ->
		searchValue(heuristica,H,Heuristica),
		searchValue(heuristica,Minimo,HeuristicaM),
		(Heuristica < HeuristicaM ->
			NuevoMinimo = [acciones=>Acciones,heuristica=>Heuristica,permutaciones=>2]
			;
			NuevoMinimo = Minimo
		)
		;
		MinCosto is Costo1,
		(Costo - MinCosto > 0 ->
			searchValue(heuristica,H,Heuristica),
			NuevoMinimo = [acciones=>A1,heuristica=>Heuristica,permutaciones=>1]
			;
			NuevoMinimo = Minimo
		)
	),!.
	
	
/*	searchValue(costo,H,Costo1),
	searchValue(probabilidad,H,P1),
	searchValue(recompenza,H,R1),
	searchValue(costo,H1,Costo2),
	searchValue(probabilidad,H1,P2),
	searchValue(recompenza,H1,R2),
	searchValue(objeto,H,Objeto1),
	searchValue(objeto,H1,Objeto2),
	searchValue(origen,H,Origen),
	searchValue(origenBusqueda,H,OrigenBusqueda),
	costoDeIr(Origen,OrigenBusqueda,CostoInicial),
	cuentaObjetosPorMovimientoYLugarEsperadoEntrega([ObjetivoH|ObjetivoT],Objeto1,Objeto2,OrigenBusqueda,CostoMovimiento),
	NuevoCosto is Costo2 + Costo1 + CostoMovimiento + CostoInicial,
	searchValue(acciones,H,A1),
	searchValue(acciones,H1,A2),
	addElement(A1,A2,Acciones),
	(Costo - NuevoCosto > 0 ->
		ProbabilidadTotalH is P1 + P2 + ProbabilidadH,
		RecompenzaTotalH is R1 + R2 + RecompenzaH,
		calculaHeuristica(ProbabilidadTotalH,HeuristicaProbabilidad,RecompenzaTotalH,HeuristicaRecompenza,Heuristica),
		searchValue(heuristica,Minimo,HeuristicaM),
		(Heuristica < HeuristicaM ->
			NuevoMinimo = [acciones=>Acciones,probabilidad=>ProbabilidadTotalH,recompenza=>RecompenzaTotalH,costo=>NuevoCosto,heuristica=>Heuristica]
			;
			NuevoMinimo = Minimo
		)
		;
		movimientoEntrega(Objeto1,[ObjetivoH|ObjetivoT],LugarMin),
		costoDeIr(OrigenBusqueda,LugarMin,CostoMin),
		MinCosto is Costo1 + CostoMin + CostoInicial,
		(Costo - MinCosto > 0 ->
			searchValue(heuristica,H,Heuristica),
			NuevoMinimo = [acciones=>A1,probabilidad=>P1,recompenza=>R1,costo=>MinCosto,heuristica=>Heuristica]
			;
			NuevoMinimo = Minimo
		)
	),!.
*/

%obtenHeuristicasPorTiempo(20,70,60,300,1000,[mover,robot,mesa1,mesa2],[[en,agua,estante1],[en,refresco,mesa2],[en,cafe,mesa2]],M,C),obtenMejorPermutacion(20,C,70,60,300,1000,C,N).
obtenMejorPermutacion(_,[],_,_,_,_,[_|_],[_|_],[]):-!.
obtenMejorPermutacion(Costo,[H1|T1],ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,[ObjetivoH|ObjetivoT],[H2|T2],NuevoMinimo):-
	obtenMejorPermutacion(Costo,T1,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,[ObjetivoH|ObjetivoT],[H2|T2],Res),
	elimina(H1,[H2|T2],Permutar),
	permutaHeuristica(Costo,H1,ProbabilidadH,HeuristicaProbabilidad,RecompenzaH,HeuristicaRecompenza,[ObjetivoH|ObjetivoT],Permutar,Minimo),
	length(Res,Size),
	(Size > 0 ->
		searchValue(heuristica,Minimo,Heuristica),
		searchValue(heuristica,Res,MinHeuristica),
		(Heuristica < MinHeuristica ->
			NuevoMinimo = Minimo;NuevoMinimo = Res
		);
		NuevoMinimo = Minimo
	),!.

movimientoEntrega(Objeto,[ObjetivoH|ObjetivoT],Lugar):-
	([en,Objeto,LFinal] =  ObjetivoH->
		Lugar = LFinal; movimientoEntrega(Objeto,ObjetivoT,Lugar)
	),!.
	

cuentaObjetosPorMovimientoYLugarEsperadoEntrega([ObjetivoH|ObjetivoT],Objeto1,Objeto2,LugarOrigen,Costo):-
	movimientoEntrega(Objeto1,[ObjetivoH|ObjetivoT],Lugar1),
	movimientoEntrega(Objeto2,[ObjetivoH|ObjetivoT],Lugar2),
	(Lugar1 = Lugar2 ->
		costoDeIr(LugarOrigen,Lugar1,Costo1),Costo =  Costo1
		;
		costoDeIr(LugarOrigen,Lugar1,Costo1),costoDeIr(LugarOrigen,Lugar2,Costo2),Costo is  Costo1 + Costo2
	),!.

/*eliminaEstadoCuandoEsAgarrado([_|_],[]):-!.	
eliminaEstadoCuandoEsAgarrado([AgarradoH|AgarradoT],L):-
	eliminaEstadoCuandoEsAgarrado(AgarradoT,Res),
	(AgarradoH = []
	)
	addElement([],Res,L),*/

%eliminarObjetoAgarrado([agarrado,agua,mesa1],[en,agua,estante1],L).
eliminarObjetoAgarrado([AgarradoH|AgarradoT],[Metodo|Parametros],L):-
	[AgarradoH|AgarradoT] = [agarrado,Objeto,_],
	(Metodo = en ->
		[en,ObjetoAgarrado,Lugar] = [Metodo|Parametros],
		(Objeto = ObjetoAgarrado ->
			L = [en,ObjetoAgarrado,Lugar];L = []
		)
		;
		L = [Metodo|Parametros]
	),!.

%iteraEliminarObjetoAgarrado([agarrado,agua,robot],[[en,refresco,mesa2],[en,agua,mesa1]],L).
iteraEliminarObjetoAgarrado([_|_],[],[]):-!.
iteraEliminarObjetoAgarrado([AgarradoH|AgarradoT],[EstadosH|EstadosT],L):-
	eliminarObjetoAgarrado([AgarradoH|AgarradoT],EstadosH,ResEliminar),
	length(ResEliminar,Size),
	(Size > 0 ->
		addElement(ResEliminar,[],L);iteraEliminarObjetoAgarrado([AgarradoH|AgarradoT],EstadosT,L)
	),!.

%iteraEliminarObjetosAgarrados([[agarrado,agua,mesa1],[agarrado,refresco,mesa1]],[[en,refresco,mesa2],[en,agua,mesa1],[en,cafe,mesa1]],L).
iteraEliminarObjetosAgarrados([],[_|_],[]):-!.	
iteraEliminarObjetosAgarrados([AgarradosH|AgarradosT],[EstadosH|EstadosT],L):-
	iteraEliminarObjetosAgarrados(AgarradosT,[EstadosH|EstadosT],Res),
	iteraEliminarObjetoAgarrado(AgarradosH,[EstadosH|EstadosT],ResEliminar),
	addElement([ResEliminar],Res,L),!.

%Estado = [[en,refresco,mesa2],[en,agua,mesa1],[en,cafe,mesa1]],iteraEliminarObjetosAgarrados([[agarrado,agua,mesa1],[agarrado,refresco,mesa1]],Estado,L),eliminaObjetoAgarrados(L,Estado,A).
eliminaObjetoAgarrados([],[H|T],L):- L = [H|T],!.
eliminaObjetoAgarrados([],[H|T],L):- L = [H|T],!.	
eliminaObjetoAgarrados([AgarradosH|AgarradosT],[EstadosH|EstadosT],L):-
	elimina(AgarradosH,[EstadosH|EstadosT],ResEliminar),
	eliminaObjetoAgarrados(AgarradosT,ResEliminar,L),!.

%estadoActual(robot,[agua=>mesa1,refresco=>mesa2],30,L).
estadoActual(X,Objects,Tiempo,EdoActual):-
	posicionAgente(X,Pos),
	ubicaciones(Objects,UbicacionesObjetos),
	estadoObjetivo(Objects,UbicacionesMeta),
	%depuraAccionesAlcanzadas(UbicacionesMeta,UbicacionesObjetos,DepuracionMetas),
	estadoBrazo(X,EstadoBrazos),
	obEncontrado(X,En),
	noBrazosL(X,BL),
	(En = []->
		concatenar([[en,X,Pos],[brazosLibres,BL],[tiempoRestate,Tiempo]],[],R1);
		concatenar([[en,X,Pos],[brazosLibres,BL],[tiempoRestate,Tiempo]],[En],R1)
	),
	(EstadoBrazos = []->
		eliminaObjetoAgarrados(UbicacionesMeta,UbicacionesObjetos,NuevasCondiciones),
		concatenar(R1,NuevasCondiciones,EdoActual);
		eliminaObjetoAgarrados(UbicacionesMeta,UbicacionesObjetos,Condiciones),
		iteraEliminarObjetosAgarrados([EstadoBrazos],Condiciones,Res),
		eliminaObjetoAgarrados(Res,Condiciones,NuevasCondiciones),
		concatenar(R1,[EstadoBrazos],R2),
		concatenar(R2,NuevasCondiciones,EdoActual)
	),!.
	
	