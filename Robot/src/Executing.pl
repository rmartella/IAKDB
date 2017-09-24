/*************************************************************************
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

% Predicado auxiliar que a partir de una lista atributo-valor, cuyo formato es 
%  [a1=>v1, a2=>v2, ..., aN=>vN ], obtenga el valor de un atributo 
%  que se le pida
valor(X,[X=>Y|_],Y):-!.
valor(X,[_=>_|T],Y):-valor(X,T,Y).

% Predicado auxiliar que a partir de una lista atributo-valor, cuyo formato es 
%  [a1=>v1, a2=>v2, ..., aN=>vN ], obtenga el nombre de un atributo 
%  que se le pida dado su valor
name(X,[Y=>X|_],Y).
name(X,[_=>_|T],Y):-valor(X,T,Y).


%% Ejecucion de acciones %%


%%%
%
% Accion de moverse de la posicion i a la posicion j
%
%%%
mover(Agente,LocationI,LocationJ):-
object(Agente,"Agente",Atrs,Rels),
valor(posicion,Atrs,Value),
LocationI=Value,
%(Value\=LocationJ->
display("Posicion del Agente:"),
posicionAgente(Agente,PA),
display(PA),nl,
display("Accion:mover("),
display(LocationI),display(","),
display(LocationJ),
display(")"),nl,
display("Brazos:"),display(Rels),nl,
costoDeIr(LocationI,LocationJ,Costo),
costoAgente(Agente,CA),
Res is CA + Costo,
display("Costo de la accion:"),display(Costo),nl,
display("Costo Acumulado:"),display(Res),nl,
modifyValueRelation(costo=>_,Res,robot,_),
tiempoRestante(Agente,TT),
write("Tiempo restante:"),write(TT),nl,
TT>=0,
(Value\=LocationJ->
probabilidadDeIr(LocationI,LocationJ,X),random(Y),
write("Probabilidad de Accion:"),tab(1),write(X),nl,
write("Probabilidad de Realizar"),tab(1),write(Y),nl,
recompensaAgente(Agente,RA),
display("Recompensa Acumulada:"),display(RA),nl,
(Y=<X->
modifyValueRelation(posicion=>LocationI,LocationJ,robot,_),
nl,nl ;

nl,writeln("*** Se ejecuta la replaneacion ***"),nl,nl,
metasAgente(Agente,Metas),
planning(Metas,Agente,TT,TP,Plan),
modifyValueRelation(tiempoTotal=>_,TP,robot,_),nl,
modifyValueRelation(acciones=>_,Plan,Agente,_),nl,
modifyValueRelation(costo=>_,0,Agente,_),
accionesAgente(Agente,Acciones),
write("Acciones:"),write(Acciones),nl,
nl,write("Tiempo restante:"),write(TP),nl,false
%,ejecutarPlan(Acciones)

);
writeln("Ya estas en la posicion objetivo"),nl
).


%%%
%
% Accion de buscar un objeto en la posicion actual
%
%%%
buscar(Object,_,Agente):-
object(Object,_,_,Relaciones),
valor(ubicacion,Relaciones,Value1),
object(Agente,"Agente",Atributos,Rels),
valor(brazosLibres,Atributos,BL),0<BL,
valor(posicion,Atributos,Value2),
Value1=Value2,
valor(encontrado,Atributos,E),
%(E=""->
display("Posicion del Agente:"),
posicionAgente(Agente,PA),
display(PA),nl,
display("Accion:buscar("),
display(Object),
display(")"),nl,
display("Brazos:"),display(Rels),nl,
costoDe(buscar,Object,Costo),
costoAgente(Agente,CA),
Res is CA + Costo,
modifyValueRelation(costo=>_,Res,robot,_),
display("Costo de la accion:"),display(Costo),nl,
display("Costo Acumulado:"),display(Res),nl,
tiempoRestante(Agente,TT),
write("Tiempo restante:"),write(TT),nl,
(E=""->
TT>=0,
probabilidadDe(buscar,Object,X),random(Y),
write("Probabilidad de Accion:"),tab(1),write(X),nl,
write("Probabilidad de Realizar"),tab(1),write(Y),nl,
(Y=<X->
recompensaDe(buscar,Object,R),
recompensaAgente(Agente,RA),
RC is R +RA,modifyValueRelation(recompensa=>_,RC,robot,_),
modifyValueRelation(encontrado=>_,Object,Agente,_),
display("Recompensa de la accion:"),display(R),nl,
display("Recompensa Acumulada:"),display(RC),nl,nl ;

nl,writeln("*** Se ejecuta la replaneacion ***"),nl,nl,
metasAgente(Agente,Metas),
planning(Metas,Agente,TT,TP,Plan),
modifyValueRelation(tiempoTotal=>_,TP,robot,_),nl,
modifyValueRelation(acciones=>_,Plan,Agente,_),nl,
modifyValueRelation(costo=>_,0,Agente,_),
accionesAgente(Agente,Acciones),
write("Acciones:"),write(Acciones),nl,
nl,write("Tiempo restante:"),write(TP),nl,false
%,ejecutarPlan(Acciones)

);
writeln("Ya se busco el objeto"),nl
).


%%%
%
% Accion de agarrar el objeto en la posicion actual, se debio
% haber encontrado el objeto antes 
%
%%%
agarrar(Object,_,Agente):- 
object(Agente,"Agente",Atrs,Rels),
valor(brazosLibres,Atrs,BL),BL>0,
valor(brazo1,Rels,W1), 
valor(brazo2,Rels,W2),
valor(encontrado,Atrs,E),
%(E=Object->
display("Posicion del Agente:"),
posicionAgente(Agente,PA),
ubicacion(Object,UB),
display(PA),nl,
display("Accion:agarrar("),
display(Object),
display(")"),nl,
display("Brazos:"),display(Rels),nl,
%valor(brazosLibres,Atrs,BL),BL>0,
costoDe(agarrar,Object,Costo),
costoAgente(Agente,CA),
Res is CA + Costo,
display("Costo de la accion:"),display(Costo),nl,
display("Costo Acumulado:"),display(Res),nl,
UB=PA,
modifyValueRelation(costo=>_,Res,robot,_),
tiempoRestante(Agente,TT),
write("Tiempo restante:"),write(TT),nl,
(E=Object->
TT>=0,
probabilidadDe(agarrar,Object,X),random(Y),
write("Probabilidad de Accion:"),tab(1),write(X),nl,
write("Probabilidad de Realizar"),tab(1),write(Y),nl,
( Y=<X->
( W1=""->modifyRelationWith(brazo1=>"",Object,robot,_) ; 
  ( W2=""->modifyRelationWith(brazo2=>"",Object,robot,_) ) ),
NBL is BL - 1,
modifyValueRelation(brazosLibres=>_,NBL,robot,_),
modifyValueRelation(encontrado=>Object,"",Agente,_),
recompensaDe(agarrar,Object,R),
recompensaAgente(Agente,RA),
RC is R +RA,modifyValueRelation(recompensa=>_,RC,robot,_),
display("Recompensa de la accion:"),display(R),nl,
display("Recompensa Acumulada:"),display(RC),nl,nl ;

nl,writeln("*** Se ejecuta la replaneacion ***"),nl,nl,
metasAgente(Agente,Metas),
planning(Metas,Agente,TT,TP,Plan),
modifyValueRelation(tiempoTotal=>_,TP,robot,_),nl,
modifyValueRelation(acciones=>_,Plan,Agente,_),nl,
modifyValueRelation(costo=>_,0,Agente,_),
accionesAgente(Agente,Acciones),nl,
write("Acciones:"),write(Acciones),
nl,write("Tiempo restante:"),write(TP),nl,false
%,ejecutarPlan(Acciones)

);
writeln("No se ha buscado el objeto"),nl
).


%%%
%
% Acción de entregar
%
%%%
entregar(Object,Location,Agente):-
object(Agente,"Agente",Atrs,Y),
valor(brazo1,Y,W1),valor(brazo2,Y,W2),
posicionAgente(Agente,Pos),
Location=Pos,
%(W1=Object ; W2=Object->
display("Posicion del Agente:"),
posicionAgente(Agente,PA),
display(PA),nl,
display("Accion:entregar("),
display(Object),
display(")"),nl,
display("Brazos:"),display(Y),nl,
costoDe(entregar,Object,Costo),
costoAgente(Agente,CA),
Res is CA + Costo,
display("Costo de la accion:"),display(Costo),nl,
display("Costo Acumulado:"),display(Res),nl,
modifyValueRelation(costo=>_,Res,robot,_),
tiempoRestante(Agente,TT),
write("Tiempo restante:"),write(TT),nl,
((W1=Object ; W2=Object)->
TT>=0,
probabilidadDe(entregar,Object,X),random(R),
write("Probabilidad de Accion:"),tab(1),write(X),nl,
write("Probabilidad de Realizar"),tab(1),write(R),nl,
( R=<X->
( W1=Object->modifyRelationWith(brazo1=>W1,"",robot,_);
 ( W2=Object->modifyRelationWith(brazo2=>W2,"",robot,_) ) ),
valor(brazosLibres,Atrs,BL), BL<2,
NBL is BL + 1,
modifyValueRelation(brazosLibres=>_,NBL,robot,_),
recompensaDe(entregar,Object,RO),
recompensaAgente(Agente,RA),
RC is RO +RA,modifyValueRelation(recompensa=>_,RC,robot,_),
metasAgente(Agente,Metas),
elimina(Object=>PA,Metas,New),
modifyValueRelation(metas=>_,New,Agente,_),
display("Recompensa de la accion:"),display(RO),nl,
display("Recompensa Acumulada:"),display(RC),nl,nl ;

nl,writeln("*** Se ejecuta la replaneacion ***"),nl,nl,
metasAgente(Agente,Metas),
planning(Metas,Agente,TT,TP,Plan),
modifyValueRelation(tiempoTotal=>_,TP,robot,_),nl,
modifyValueRelation(acciones=>_,Plan,Agente,_),nl,
modifyValueRelation(costo=>_,0,Agente,_),
accionesAgente(Agente,Acciones),
write("Acciones:"),write(Acciones),nl,
nl,write("Tiempo restante:"),write(TP),nl,false
%,ejecutarPlan(Acciones)

);
writeln("No se tiene el objeto"),nl
).


%%%
% 
% Predicado de ejecucion de acciones
%
%%%
ejecutar(T,X):-X=..T,X.


%%%
%
% Ejecucion del plan
%
%%%
ejecutarPlan(_,[]):-!.
ejecutarPlan(_,[T]):-ejecutar(T,_),!.
ejecutarPlan(Agente,[H|T]):-ejecutar(H,_),ejecutarPlan(Agente,T).
ejecutarPlan(Agente,[_|_]):-
       accionesAgente(Agente,Acciones),
       ejecutarPlan(Agente,Acciones),!.

%
% Reset del Agente 
%
%%%
resetAgente(Agente):-
modifyValueRelation(recompensa=>_,0,Agente,_),
modifyValueRelation(costo=>_,0,Agente,_),
modifyValueRelation(metas=>_,[],Agente,_),
modifyValueRelation(acciones=>_,[],Agente,_),
modifyValueRelation(brazosLibres=>_,2,Agente,_),
modifyValueRelation(tiempoTotal=>_,0,Agente,_),
modifyValueRelation(posicion=>_,inicio,Agente,_),
modifyValueRelation(encontrado=>_,"",Agente,_),
modifyRelationWith(brazo1=>_,"",Agente,_),
modifyRelationWith(brazo2=>_,"",Agente,_).


%% Fin ejecucion de acciones %% 


%% Metodos auxiliares %%


%% Predicados del estados de los objetos %%

%% Predicado que da la ubicacion de un alimento %%
ubicacion(Alimento,Ubicacion):-
object(Alimento,"Alimento",_,Y),
valor(ubicacion,Y,Ubicacion).

%% Predicado que da el costo de realizar una accion %% 
%% de un alimento %%
costoDe(Accion,Alimento,Costo):-
object(Accion,"Accion",X,_),
valor(Alimento,X,V1),
valor(costo,V1,Costo).

%% Predicado que da la probabilidad de realizar una accion %% 
%% de un alimento %%
probabilidadDe(Accion,Alimento,Probabilidad):-
object(Accion,"Accion",X,_),
valor(Alimento,X,V1),
valor(probabilidad,V1,Probabilidad).

%% Predicado que da la probabilidad de realizar una accion %% 
%% de un alimento %%
recompensaDe(Accion,Alimento,Recompensa):-
object(Accion,"Accion",X,_),
valor(Alimento,X,V1),
valor(recompensa,V1,Recompensa).

%% Predicado que da el costo de ir de una posicion a otra %% 
costoDeIr(Posicion1,Posicion2,Costo):-
object(Posicion1,"Localizacion",X,_),
valor(Posicion2,X,V1),
valor(costo,V1,Costo).

%% Predicado que da la probabilidad de ir de una posicion a otra %%
probabilidadDeIr(Posicion1,Posicion2,Probabilidad):-
object(Posicion1,"Localizacion",X,_),
valor(Posicion2,X,V1),
valor(probabilidad,V1,Probabilidad).


%% Predicados del estados de los objetos %% 


%% Predicados del estado del agente %%

%% Predicado que da la posicion del agente %%
posicionAgente(Agente,Posicion):-
object(Agente,"Agente",X,_),
valor(posicion,X,Posicion).

%% Predicado que me da el costo que lleva el robot %%
costoAgente(Agente,Y):-
object(Agente,"Agente",X,_),
valor(costo,X,Y).

%% Predicado que me da la recompensa que lleva el robot %%
recompensaAgente(Agente,Y):-
object(Agente,"Agente",X,_),
valor(recompensa,X,Y).

%% Predicado que da el tiempo total restante del agente %%
tiempoRestante(Agente,TT):-
object(Agente,"Agente",Atrs,_),
valor(tiempoTotal,Atrs,V1),
costoAgente(Agente,V2), TT is V1 -V2,!.

%% Predicado que da el tiempo total del agente %%
tiempoTotal(Agente,T):-
object(Agente,"Agente",Atrs,_),
valor(tiempoTotal,Atrs,T).

% Predicado que muestra el estado de los brazos %
estadoBrazo(X,Edo):-
object(X,"Agente",_,Rels),
valor(brazo1,Rels,V1),
valor(brazo2,Rels,V2),
( V1\="", V2\=""->
 concatenar([[agarrado,X,V1]],[[agarrado,X,V2]],Edo) ;
  ( V1="",V2=""-> Edo=[] ;
    ( V1=""->Edo=[agarrado,V2,X];
	     Edo=[agarrado,V1,X] ) ) ).

% Predicado que da el no. de brazos libres
noBrazosL(X,No):-
object(X,"Agente",Atrs,_),
valor(brazosLibres,Atrs,No).

%% Metas del agente %%
metasAgente(Agente,Metas):-
object(Agente,"Agente",Atrs,_),
valor(metas,Atrs,Metas).

%% Acciones del agente %%
accionesAgente(Agente,Acciones):-
object(Agente,"Agente",Atrs,_),
valor(acciones,Atrs,Acciones).


%% Objeto encontrado %%
obEncontrado(Agente,En):-
object(Agente,"Agente",Atrs,_),
valor(encontrado,Atrs,Encontrado),
(Encontrado\=""->
 En =[buscado,Encontrado,Agente];
 En =[] ).


%% Fin Predicados del estado del agente %% 

/*
%% Heuristicas %%

%% Predicado que da la recompensa total de un alimento %%
recompensaTotal(Alimento,Recompensa):-
recompensaDe(buscar,Alimento,R1),
recompensaDe(agarrar,Alimento,R2),
recompensaDe(entregar,Alimento,R3),
Recompensa is R1+R2+R3.

%% Probabilidad para heuristica %%
probabilidadTotal(Alimento,Probabilidad):-
probabilidadDe(buscar,Alimento,R1),
probabilidadDe(agarrar,Alimento,R2),
probabilidadDe(entregar,Alimento,R3),
Probabilidad is (1-R1)+(1-R2)+(1-R3).

%% suma de la probabilidadesde los objetos en la lista dada %%
sumaProbabilidades([],0).
sumaProbabilidades([X|T],Suma):-
probabilidadTotal(X,PT), 
sumaProbabilidades(T, Suma2), 
Suma is PT + Suma2. 

%% Promedio de las rpobabilidades %%
promedioProb([X|T],Prob):-sumaProbabilidades([X|T],R1),length([X|T],R2), Prob is R1/R2.


%% Fin Heuristicas %%
*/

%% Estados %%

% estadoInicial([refresco=>mesa1,agua=>mesa3,cafe=>mesa2,sandwich=>mesa2],L).
%% Estado Actual del robot %%
estadoInicial(Objects,Tiempo,EdoInicial):-
posicionAgente(robot,X),
ubicaciones(Objects,UB),
concatenar([[en,robot,X],[brazosLibres,2],[tiempoRestate,Tiempo]],UB,EdoInicial).

ubicaciones([],[]).
ubicaciones([A=>_|T],L):-
ubicacion(A,UB),
ubicaciones(T,L2),
concatenar([[en,A,UB]],L2,L).

%% Estado Objetivo %%
estadoObjetivo([],[]).
estadoObjetivo([X=>Y|T],EdoObjetivo):-
estadoObjetivo(T,L2),
concatenar([[en,X,Y]],L2,EdoObjetivo).


/*
eliminarObjetosAgarrados(Metas,Agarrados,R):-
[HM|TM]=Metas,[HA|_]=Agarrados,
intersection(HM,HA,HR),
( HR\=[]->elimina(HM,Metas,R) ;
eliminarObjetosAgarrados(TM,Agarrados,R1),
eliminarObjetosAgarrados(R1,Agarrados,R2)
R=[HM|R2]
).


eliminarObjetosAgarrados([H|T],[X|Y],R):-
eliminarObjetosAgarrados([H|T],Y,R1),
eliminarObjetosAgarrados(T,[X|Y],R2),
concatenar(R1,R2,R),!.


eliminarObjetosAgarrados([H|T],[X|_],R):-
intersection(H,X,HR),HR\=[],borrar(H,T,R).

borrar(_,[],[]).
borrar(X,[X|C],M):-!,borrar(X,C,M).
borrar(X,[Y|L1],[Y|L2]):- borrar(X,L1,L2).
*/

/*
%% Fin Estados %% 

sublista([X|T],Pos,R):-
(Pos=1->R = [X];
P1 is Pos-1,
sublista(T,P1,R1),
R = [X|R1]
),!.
*/	