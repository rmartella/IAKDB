/*************************************************************************
*
* UNIVERSIDAD NACIONAL A�TONOMA DE M�XICO
* IIMAS
* INTELIGENCIA ARTIFICIAL
* PROYECTO 1 (REPRESENTACI�N DE CONOCIMIENTO
* 
* MARTELL AVILA REYNALDO
* AUGUSTO JULIO CESAR VEGA GUTI�RREZ
* PEDRO VEGA GALAVIZ
*
**************************************************************************
*/


/****/

:-op(15,xfx,=>).

%Rutinas para abrir archivos
open_kb(Route,KB):-
	open(Route,read,Stream),
	readclauses(Stream,X),
	close(Stream),
	atom_to_term(X,KB).
readclauses(InStream,W) :-
        get0(InStream,Char),
        checkCharAndReadRest(Char,Chars,InStream),
	atom_chars(W,Chars).
save_kb(Route,KB):-
	open(Route,write,Stream),
	writeq(Stream,KB),
	close(Stream).
	
checkCharAndReadRest(-1,[],_) :- !.  % End of Stream	
checkCharAndReadRest(end_of_file,[],_) :- !.

checkCharAndReadRest(Char,[Char|Chars],InStream) :-
        get0(InStream,NextChar),
        checkCharAndReadRest(NextChar,Chars,InStream).

atom_to_term(ATOM, TERM) :-
	atom(ATOM),
	atom_to_chars(ATOM,STR),
	atom_to_chars('.',PTO),
	append(STR,PTO,STR_PTO),
	read_from_chars(STR_PTO,TERM).


loadFilePredicates(Lista):-
	%open_kb('/opt/codigo/prolog/Robot/src/kb.txt',KB),
	open_kb('kb.txt',KB),
	Lista = KB.
	%write(KB),nl,
	%save_kb('/opt/codigo/prolog/RepresentacionConocimiento/src/kbPredicates.txt',KB),
	%consult('/opt/codigo/prolog/RepresentacionConocimiento/src/kbPredicates.txt').

writeElements([]):-!.
writeElements([H|T]):-
	asserta(H),
	writeElements(T).
deleteElements([]):-!.
deleteElements([H|T]):-
	retract(H),
	deleteElements(T).
loadBD:-
	loadFilePredicates(Lista),
	searchValue('ClassList',Lista,ListaClases),
	searchValue('ObjectList',Lista,ListaObjecto),
	writeElements(ListaObjecto),
	writeElements(ListaClases).
addClass([],[]):-!.
addClass([H|T],L):-
	addClass(T,S), class(H,Parent,Attrs,Links),addElement([class(H,Parent,Attrs,Links)],S,L).
addObject([],[]):-!.
addObject([H|T],L):-
	addObject(T,S), object(H,Class,Attrs,Links),addElement([object(H,Class,Attrs,Links)],S,L).
findListTokens(ListaClases,ListaObjectos):-
	findall(X,class(X,_,_,_),ListC),addClass(ListC,ListaClases),
	findall(X,object(X,_,_,_),ListO),addObject(ListO,ListaObjectos),!.	

%Predicados para agregar elementos a una lista
addElement([],E,E):-!.
addElement([A|B],E,[A|D]):-
	addElement(B,E,D).

%searchValue(name,[name=>class1,parent=>object,attributes=>[attr1=>value1]], Value).
%Predicado que busca el valor de la propiedad
searchValue(Property,[H|T],Value):-
	=>(Property,Value) = H,!;searchValue(Property,T,Value).
%Predicado que encuentra el valor de la propiedad de una clase
%findNameClass(class("Class1","Class2",[attribute1=>value1]),Value).
findNameClass(Class,Value):-
	class(Value,_,_,_) = Class.
%findParentClass(class("Class1","Class2",[attribute1=>value1]),Value).
findParentClass(Class,Value):-
	class(_,Value,_,_) = Class.
%findAttributesClass(class("Class1","Class2",[attribute1=>value1]),Value).
findAttributesClass(Class,Value):-
	class(_,_,Value,_) = Class.
findLinksClass(Class,Value):-
	class(_,_,_,Value) = Class.
findNameObject(Object,Value):-
	object(Value,_,_,_) = Object.
findClassObject(Object,Value):-
	object(_,Value,_,_) = Object.
findAttributesObject(Object,Value):-
	object(_,_,Value,_) = Object.
findLinksObject(Object,Value):-
	object(_,_,_,Value) = Object.
	
%Predicado que busca una clase por el valor de la propiedad
%findClassByName("Class6",Class).
findClassByName(Name,Class):-
	class(Name,Parent,Attrs,Links), Class = class(Name,Parent,Attrs,Links),!.
%findObjectByName("Object1",Object).
findObjectByName(Name,Object):-
	object(Name,Class,Attrs,Links), Object = object(Name,Class,Attrs,Links),!.
	
%addIfExtendsObject(object("Object3","Class3",[attr1=>value5,attr3=>value4]),"Class3",class("Class3","Class2",[attr1=>value1,attr2=>value2]),[class("Object","Object",[]),class("Class1","Object",[attr1=>value1]),class("Class2","Object",[attr1=>value1,attr2=>value2]),class("Class3","Class2",[attr1=>value5,attr3=>value4])],L).
%addIfExtendsObject(object("Object3","Class3",[attr1=>value5,attr3=>value4]),"Class2",class("Class3","Class2",[attr1=>value1,attr2=>value2]),[class("Object","Object",[]),class("Class1","Object",[attr1=>value1]),class("Class2","Object",[attr1=>value1,attr2=>value2]),class("Class3","Class2",[attr1=>value5,attr3=>value4])],L).
%addIfExtendsObject(object("Object3","Class3",[attr1=>value5,attr3=>value4]),"Class1",class("Class3","Class2",[attr1=>value1,attr2=>value2]),[class("Object","Object",[]),class("Class1","Object",[attr1=>value1]),class("Class2","Object",[attr1=>value1,attr2=>value2]),class("Class3","Class2",[attr1=>value5,attr3=>value4])],L).
addIfExtendsObject(_,_,IndexClass,_):-
	findNameClass(IndexClass,IndexClassName),
	findParentClass(IndexClass,ParentName),
	ParentName = IndexClassName,
	%write("final root"),tab(2),nl,
	!.
addIfExtendsObject(Object,ClassName,IndexClass,L):-
	findNameClass(IndexClass,IndexClassName),
	IndexClassName= ClassName,
	findNameObject(Object,ObjectName),
	addElement([ObjectName],[],L),
	%write("Se agrega nodo:"),tab(2),write(Object),nl,
	!.
addIfExtendsObject(Object,ClassName,IndexClass,L):-
	findNameClass(IndexClass,IndexClassName),
	IndexClassName \= ClassName,
	findParentClass(IndexClass,ParentName),
	findClassByName(ParentName,ClassParent),
	%write(ParentName),tab(2),nl,
	addIfExtendsObject(Object,ClassName,ClassParent,L).
addExtendsObjects(ClassName,[H|T],L):-ClassName="",L = [H|T],!.
addExtendsObjects(_,[],[]):-!.
addExtendsObjects(ClassName,[H|T],L):-
	findClassObject(H,ClassObjectName),
	findClassByName(ClassObjectName,Class),
	addExtendsObjects(ClassName,T,R),
	addIfExtendsObject(H,ClassName,Class,S),
	addElement(S,R,L).
/*
*
*A.- La extensi�n de una clase (el conjunto de todos los objetos que pertenecen a la misma,
*ya sea porque se declaren directamente o porque est�n en la cerradura de la relaci�n de herencia).
*
**/
%getExtendsBD("Object",L).
%getExtendsBD("Class1",L).
%getExtendsBD("Class2",L).
%getExtendsBD("Class3",L).
%getExtendsBD("Class4",L).
%getExtendsBD("Class5",L).
%getExtendsBD("Class6",L).
getExtendsBD(ClassName,L):-
	findListTokens(_,ObjectList),
	addExtendsObjects(ClassName,ObjectList,L).

%addIteratorAttributesObject(attr1,object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3]),[attr1=>valueO5,attr3=>valueO3],L).
%addIteratorAttributesObject(attr4,object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3]),[attr1=>valueO5,attr3=>valueO3],L).
%addIteratorAttributesObject(attr4,object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3]),[],L).
%addIteratorAttributesObject(attr4,object("Object1","Class1",[]),[],L).
addIteratorAttributesObject(_,_,[],[]):-!.
addIteratorAttributesObject(AttributeName,Object,[H|_],L):-
	=>(AttributeName,_) = H,
	findNameObject(Object,ObjectName),
	findClassObject(Object,ObjectClassName),
	addElement([object(ObjectName,ObjectClassName,[H])],[],L),!.
	%addElement([object(ObjectName,[H])],[],L),!.
	%addElement([[ObjectName,H]],[],L),!.
addIteratorAttributesObject(AttributeName,Object,[H|T],L):-
	=>(AttributeName,_) \= H,
	addIteratorAttributesObject(AttributeName,Object,T,L).

addIfExtendsAttributesObjects(_,[],[]):-!.
addIfExtendsAttributesObjects(AttributeName,[H|T],L):-
	findClassObject(H,ClassName),
	getAttributesOfClass(ClassName,S),
	findAttributesObject(H,Attributes),
	principioExpecificidad(Attributes,S,R),
	addIteratorAttributesObject(AttributeName,H,R,W),
	addIfExtendsAttributesObjects(AttributeName,T,P),
	addElement(W,P,L).

/*
*
*B.-La extensi�n de una propiedad (mostrar todos los objetos que tienen una propiedad
*espec�fica ya sea por declaraci�n directa o por herencia, incluyendo su respectivo valor)
*
**/	
%getExtendsAttributesBD(attr1,L).
%getExtendsAttributesBD(attr2,L).
%getExtendsAttributesBD(attr3,L).
%getExtendsAttributesBD(attr4,L).
%getExtendsAttributesBD(attr8,L).
getExtendsAttributesBD(AttributeName,L):-
	findListTokens(_,ObjectList),
	addIfExtendsAttributesObjects(AttributeName,ObjectList,L).
	
%addIteratorLink(hate,[hate=>mouse,hate=>monstro,inside=>monstro],L).
addIteratorLink(_,[],[]):-!.
addIteratorLink(LinkName,[H|T],L):-
	H \= =>(LinkName,_),
	addIteratorLink(LinkName,T,S),
	addElement([H],S,L),!.
addIteratorLink(LinkName,[H|T],L):-
	H = =>(LinkName,_),
	addIteratorLink(LinkName,T,L).
%addIteratorLinks([hate=>mouse,hate=>monstro,inside=>monstro],[hate=>mouse,hate=>monstro,inside=>monstro],L).
%addIteratorLinks([hate=>monstro],[hate=>toy, inside=>toy],L).
%addIteratorLinks([hate=>mouse,hate=>monstro,inside=>monstro],[],L).
addIteratorLinks([],[],[]):-!.
addIteratorLinks([],[Z|W],L):-L = [Z|W],!.
addIteratorLinks([_|_],[],[]):-!.
addIteratorLinks([H|T],[Z|W],L):-
	addIteratorLinks(T,[Z|W],R),
	H = =>(LinkName,_),
	addIteratorLink(LinkName,R,L).
%addIteratorLinksClass(class(elephant, mammal, [], [hate=>mouse]),[hate=>mouse],L).
%addIteratorLinksClass(class("", "", [], [hate=>mouse]),[hate=>mouse],L).
addIteratorLinksClass(Class,LI,L):-
	findParentClass(Class,ParentName),
	findNameClass(Class,ClassName),
	ParentName \= ClassName,
	findClassByName(ParentName,ParentClass),
	findLinksClass(ParentClass,ParentLinks),
	addIteratorLinks(LI,ParentLinks,S),
	addElement(LI,S,R),
	addIteratorLinksClass(ParentClass,R,L),!.
addIteratorLinksClass(Class,[H|T],L):-
	findParentClass(Class,ParentName),
	findNameClass(Class,ClassName),
	ParentName \= ClassName,
	L = [H|T],!.
addIteratorLinksClass(Class,[],[]):-
	findParentClass(Class,ParentName),
	findNameClass(Class,ClassName),
	ParentName \= ClassName.

%evalLinkClassToLinksObjects(hate,[hate=>human],L).
evalLinkClassToLinksObjects(_,[],[]):-!.
evalLinkClassToLinksObjects(LinkName,[H|T],L):-
	evalLinkClassToLinksObjects(LinkName,T,R),
	=>(LinkName,H) = LinkObject,
	addElement([LinkObject],R,L).
%evalLinkClassToLinks(hate,human,L).
evalLinkClassToLinks(LinkName,LinkValue,L):-
	findClassByName(LinkValue,_),
	getExtendsBD(LinkValue,R),
	evalLinkClassToLinksObjects(LinkName,R,L),!.
evalLinkClassToLinks(LinkName,LinkValue,L):-
	findObjectByName(LinkValue,_),
	addElement([],[LinkName=>LinkValue],L),!.
evalLinkClassToLinks(_,_,[]):-!.
	
%addIfLinksName(hate,[hate=>mouse],L).
%addIfLinksName(hate,[hate=>mouse,hate=>human,inside=>human],L).
addIfLinksName(_,[],[]):-!.
addIfLinksName(LinkName,[H|T],L):-
	H \= =>(LinkName,_),
	addIfLinksName(LinkName,T,L),!.
addIfLinksName(LinkName,[H|T],L):-
	H = =>(LinkName,LinkValue),
	addIfLinksName(LinkName,T,R),
	evalLinkClassToLinks(LinkName,LinkValue,S),
	%addElement([H],R,L),!.
	addElement(S,R,L),!.

%addIfExtendsLinksObject(hate,object(geppeto, human, [], [inside=>monstro]),[inside=>monstro],L).
addIfExtendsLinksObject(_,_,[],[]):-!.
addIfExtendsLinksObject(LinkName,Object,[H|T],L):-
	addIfLinksName(LinkName,[H|T],Links),
	length(Links,Size),
	Size =\= 0,
	findNameObject(Object,ObjectName),
	findClassObject(Object,ObjectClassName),
	addElement([object(ObjectName,ObjectClassName,Links)],[],L),!.
addIfExtendsLinksObject(LinkName,Object,[_|T],L):-
	addIfExtendsLinksObject(LinkName,Object,T,L).
addIfExtendsLinksObjects(_,[],[]):-!.
addIfExtendsLinksObjects(LinkName,[H|T],L):-
	addIfExtendsLinksObjects(LinkName,T,Y),
	findClassObject(H,ClassName),
	findClassByName(ClassName,Class),
	findLinksObject(H,LinksObject),
	findLinksClass(Class,LinksClass),
	addIteratorLinksClass(Class,LinksClass,AllLinksClass),
	addIteratorLinks(LinksObject,AllLinksClass,S),
	addElement(LinksObject,S,R),
	addIfExtendsLinksObject(LinkName,H,R,O),
	addElement(O,Y,L).

/*
*
*
*C.-La extensi�n de una relaci�n (mostrar todos los objetos que tienen una relaci�n espec�fica
*ya sea por declaraci�n directa o por herencia, incluyendo con qui�n est�n relacionados).
*
**/	
%getExtendsLinksBD(relacion1,L).
%getExtendsLinksBD(relacion2,L).
%getExtendsLinksBD(relacion3,L).
%getExtendsLinksBD(relacion5,L).
getExtendsLinksBD(LinkName,L):-
	findListTokens(_,ObjectList),
	addIfExtendsLinksObjects(LinkName,ObjectList,L).

%Predicado que obtiene una lista de nombres de clases de los cuales hereda una clase
%getExtends("Class1",L).
getExtends(ClassName,L):-
	findClassByName(ClassName,Class),
	findParentClass(Class,ParentName),
	ParentName \= ClassName,!,
	getExtends(ParentName,S),
	addElement([ParentName],S,L).
getExtends(ClassName,L):-
	findClassByName(ClassName,_),addElement([],[],L).
/*
*D.- Todas las clases a las que pertenece un objeto
*
*/
%getExtendsOfObject("Object",L).
%getExtendsOfObject("Object1",L).
%getExtendsOfObject("Object2",L).
%getExtendsOfObject("Object3",L).
%getExtendsOfObject("Object4",L).
%getExtendsOfObject("Object5",L).
%getExtendsOfObject("Object7",L).
%Predicado que obtiene una lista de clases a las que pertenece el objeto
getExtendsOfObject(ObjectName,L):-
	findObjectByName(ObjectName,Object),
	findClassObject(Object,ClassName),
	getExtends(ClassName,S),
	addElement([ClassName],S,L),!.
%principioExpecificidad(attr3=>value0,[attr1=>value5,attr3=>value4,attr2=>value3],[attr1=>value5,attr3=>value4,attr2=>value3],L).
%principioExpecificidad(attr1=>value0,[attr1=>value5,attr3=>value4,attr2=>value3],[attr1=>value5,attr3=>value4,attr2=>value3],L).
%principioExpecificidad(attr2=>value0,[attr1=>value5,attr3=>value4,attr2=>value3],[attr1=>value5,attr3=>value4,attr2=>value3],L).
%principioExpecificidad(attr4=>value0,[attr1=>value5,attr3=>value4,attr2=>value3],[attr1=>value5,attr3=>value4,attr2=>value3],L).
%principioExpecificidad(attr4=>value0,[],[],L).
principioExpecificidad(AttributeIn,[],[_|_],L):- addElement([AttributeIn],[],L), !.
principioExpecificidad(AttributeIn,[],[],L):- addElement([AttributeIn],[],L), !.
principioExpecificidad(AttributeIn,[H|T],[_|_],L):-
	=>(AtributeInName,_)= AttributeIn,
	=>(AtributeInName,_)=H,
	%write("Elemento Actualizado"),tab(2),write(AttributeIn),nl,
	%write("Elemento Actualizado"),tab(2),write(T),nl,
	%write("Elemento Actualizado"),tab(2),write(L),nl,
	addElement([AttributeIn],T,L),
	%write("Elemento Actualizado"),tab(2),write(AttributeIn),nl,
	!.
principioExpecificidad(AttributeIn,[H|T],[Y|Z],L):-
	=>(AtributeInName,_)= AttributeIn,
	=>(AtributeInName,_)\=H,
	%write("Siguiente elemento"),tab(2),write(T),nl,
	principioExpecificidad(AttributeIn,T,[Y|Z],S),
	%write("Agregando elemento"),tab(2),write(H),nl,
	addElement([H],S,L).
	
%principioExpecificidad([attr1=>value5,attr3=>value4],[attr1=>value1,attr3=>value4,attr2=>value2],L).
%principioExpecificidad([attr1=>value5,attr3=>value4,attr2=>value2],[attr1=>value1,attr3=>value4,attr2=>value2],L).
%principioExpecificidad([attr4=>value5],[attr1=>value5,attr3=>value4,attr2=>value2],L).
principioExpecificidad([],[Y|Z],L):-addElement([Y|Z],[],L),
	%write("LLego al final"),nl,
	!.
principioExpecificidad([],[],L):-addElement([],[],L),
	%write("LLego al final"),nl,
	!.
principioExpecificidad([H|T],[],L):-addElement([H|T],[],L),!.
principioExpecificidad([H|T],[Y|Z],L):-
	principioExpecificidad(H,[Y|Z],[Y|Z],S),
	principioExpecificidad(T,S,L).

getAttributesOfClass(ClassName,L):-
	findClassByName(ClassName,Class),
	findParentClass(Class,ParentName),
	findAttributesClass(Class,Attributes),
	ParentName \= ClassName,!,
	getAttributesOfClass(ParentName,S),
	principioExpecificidad(Attributes,S,L).
getAttributesOfClass(_,L):-addElement([],[],L).
getAttributesOfObject(ObjectName,L):-
	findObjectByName(ObjectName,Object),
	findClassObject(Object,ClassName),
	getAttributesOfClass(ClassName,S),
	findAttributesObject(Object,Attributes),
	principioExpecificidad(Attributes,S,L).

getLinksOfClass(ClassName,L):-
	findClassByName(ClassName,Class),
	findLinksClass(Class,Links),
	addIteratorLinksClass(Class,Links,L).
	
getLinksOfObject(ObjectName,L):-
	findObjectByName(ObjectName,Object),
	findClassObject(Object,ClassName),
	getLinksOfClass(ClassName,LinksClass),
	findLinksObject(Object,LinksObject),
	addIteratorLinks(LinksObject,LinksClass,R),
	addElement(LinksObject,R,L).

/*
*
*
*E.- Todas las propiedades de un objeto o clase
*
*/
%getAttributesBD("Object1",object,L).
%getAttributesBD("Object2",object,L).
%getAttributesBD("Object3",object,L).
%getAttributesBD("Object4",object,L).
%getAttributesBD("Object5",object,L).
%getAttributesBD("Object6",object,L).
%getAttributesBD("Object7",object,L).
getAttributesBD(ObjectName,object,L):-
	getAttributesOfObject(ObjectName,L).
%getAttributesBD("Object",class,L).
%getAttributesBD("Class1",class,L).
%getAttributesBD("Class2",class,L).
%getAttributesBD("Class3",class,L).
%getAttributesBD("Class4",class,L).
%getAttributesBD("Class5",class,L).
%getAttributesBD("Class6",class,L).
%getAttributesBD("Class7",class,L).
getAttributesBD(ClassName,class,L):-
	getAttributesOfClass(ClassName,L).
	
/*
*F.- Todas las relaciones de un objeto o clase
*
*/
%getLinksBD("Object1",object,L).
%getLinksBD("Object2",object,L).
%getLinksBD("Object3",object,L).
%getLinksBD("Object4",object,L).
%getLinksBD("Object5",object,L).
%getLinksBD("Object6",object,L).
%getLinksBD("Object7",object,L).
getLinksBD(ObjectName,object,L):-
	getLinksOfObject(ObjectName,L),!.
%getLinksBD("Object",class,L).
%getLinksBD("Class1",class,L).
%getLinksBD("Class2",class,L).
%getLinksBD("Class3",class,L).
%getLinksBD("Class4",class,L).
%getLinksBD("Class5",class,L).
%getLinksBD("Class6",class,L).
%getLinksBD("Class7",class,L).
getLinksBD(ClassName,class,L):-
	getLinksOfClass(ClassName,L),!.
/*
*
*****************************************************************************************
* 2.- Crear predicados para a�adir
*****************************************************************************************
*
**/
/*
* Falta validacion de atributos repetidos y links repetidos cuando se agregan objetos y clases
*/
%validateExistsLinks([link1=>"Class1",link1=>"Class2"]).
%validateExistsLinks([link1=>"Class2",link1=>"Class4"]).
validateExistsLinks([]):-!.
validateExistsLinks([H|T]):-
	validateExistsLinks(T), =>(_,Link) = H, (findClassByName(Link,_),!;findObjectByName(Link,_),!).
%validateDuplicateAdd(attr1,[attr2=>value]).
%validateDuplicateAdd(attr2,[attr2=>value]).
validateDuplicateAdd(_,[]):-!.
validateDuplicateAdd(AttributeName,[H|T]):-
	validateDuplicateAdd(AttributeName,T),not(=>(AttributeName,_) = H).
validateDuplicateAddLink(_,[]):-!.
validateDuplicateAddLink(Link,[H|T]):-
	validateDuplicateAddLink(Link,T),not(Link = H).
/*
*
* A) Clases u objetos
*
*/
%addElementToTree(class("Class1","Object",[],[]),class).
%addElementToTree(class("Class2","Class1",[attr2=>val5],[link1=>"class3"]),class).
%addElementToTree(class("Class3","Class2",[attr2=>val5],[link1=>"class3"]),class).
%addElementToTree(class("Class4","Object",[attr2=>val5],[link1=>"class5"]),class).
addElementToTree(Class,class):-
	findNameClass(Class,ClassNameInsert),
	findParentClass(Class,ClassParentName),
	\+ findClassByName(ClassNameInsert,_),
	findClassByName(ClassParentName,_),
	findLinksClass(Class,Links),
	validateExistsLinks(Links),
	asserta(Class),!.
%addElementToTree(object("Object9","Class9",[],[]),object).
%addElementToTree(object("Object3","Class1",[],[link4=>class6]),object).
addElementToTree(Object,object):-
	findClassObject(Object,ObjectClassName),
	findClassByName(ObjectClassName,_),
	findNameObject(Object,ObjectName),
	\+ findObjectByName(ObjectName,_),
	findLinksObject(Object,Links),
	validateExistsLinks(Links),
	asserta(Object),!.

%updateClassByAttributes(class("Class3","Class2",[],[]),[attr9=>5],ClassNew).
%updateClassByAttributes(class("Class3","Class2",[attr3=>5],[relacion2=>"Class2"]),[attr9=>5],ClassNew).
updateClassByAttributes(Class,Attributes,ClassNew):-
	findNameClass(Class,ClassName),
	findParentClass(Class,ParentClass),
	findLinksClass(Class,LinksClass),
	ClassNew = class(ClassName,ParentClass,Attributes,LinksClass).
%updateObjectByAttributes(object("Object12","Class2",[],[]),[attr9=>5],ClassNew).
%updateObjectByAttributes(object("Object13","Class4",[attr3=>5],[relacion2=>"Class2"]),[attr9=>5],ClassNew).
updateObjectByAttributes(Object,Attributes,ObjectNew):-
	findNameObject(Object,ObjectName),
	findClassObject(Object,ObjectClassName),
	findLinksObject(Object,LinksObject),
	ObjectNew = object(ObjectName,ObjectClassName,Attributes,LinksObject).
%updateClassByLinks(class("Class3","Class2",[],[]),[relacion3=>Class1,relacion4=>Class2],ClassNew).
%updateClassByLinks(class("Class3","Class2",[attr3=>5],[relacion2=>"Class2"]),[relacion3=>Class1],ClassNew).
updateClassByLinks(Class,Links,ClassNew):-
	findNameClass(Class,ClassName),
	findParentClass(Class,ParentClass),
	findAttributesClass(Class,AttributesClass),
	ClassNew = class(ClassName,ParentClass,AttributesClass,Links).
%updateObjectByLinks(object("Object12","Class2",[],[]),[rel3=>5],ClassNew).
%updateObjectByLinks(object("Object13","Class4",[attr3=>5],[relacion2=>"Class2"]),[rel8=>5,rel9=>4],ClassNew).
updateObjectByLinks(Object,Links,ObjectNew):-
	findNameObject(Object,ObjectName),
	findClassObject(Object,ObjectClassName),
	findAttributesObject(Object,AttributesClass),
	ObjectNew = object(ObjectName,ObjectClassName,AttributesClass,Links).
/*
*
*B)  Propiedades nuevas a clases u objetos
*
*/
%addAttributeToClass(attr8=>5,"Class1",class).
%addAttributeToClass(attr9=>5,"Class7",class).
addAttributeToClass(Attribute,ClassName,class):-
	findClassByName(ClassName,Class),
	findAttributesClass(Class,Attributes),
	=>(AttributeName,_) = Attribute,
	validateDuplicateAdd(AttributeName,Attributes),
	addElement([Attribute],Attributes,NewAttributes),
	retract(Class),
	updateClassByAttributes(Class,NewAttributes,ClassNew),
	asserta(ClassNew),!.
%addAttributeToObject(attr8=>5,"Object7",object).
%addAttributeToObject(attr9=>5,"Object6",object).
addAttributeToObject(Attribute,ObjectName,object):-
	findObjectByName(ObjectName,Object),
	findAttributesObject(Object,Attributes),
	=>(AttributeName,_) = Attribute,
	validateDuplicateAdd(AttributeName,Attributes),
	addElement([Attribute],Attributes,NewAttributes),
	retract(Object),
	updateObjectByAttributes(Object,NewAttributes,ObjectNew),
	asserta(ObjectNew),!.
/*
*
* C) Relaciones nuevas a clases u objetos
*
*/
%addLinkToClass(rel4=>"Class1","Class2",class).
%addLinkToClass(rel7=>"Class6","Class1",class).
addLinkToClass(Link,ClassName,class):-
	findClassByName(ClassName,Class),
	findLinksClass(Class,Links),
	validateExistsLinks([Link]),
	validateDuplicateAddLink(Link,Links),
	write("Entro"),
	addElement([Link],Links,NewLinks),
	retract(Class),
	updateClassByLinks(Class,NewLinks,ClassNew),
	asserta(ClassNew),!.
%addLinkToObject(rel4=>"Class1","Object3",object).
%addLinkToObject(rel4=>"Class1","Object2",object).
addLinkToObject(Link,ObjectName,object):-
	findObjectByName(ObjectName,Object),
	findLinksObject(Object,Links),
	validateExistsLinks([Link]),
	validateDuplicateAddLink(Link,Links),
	addElement([Link],Links,NewLinks),
	retract(Object),
	updateObjectByLinks(Object,NewLinks,ObjectNew),
	asserta(ObjectNew),!.

/*
*
*****************************************************************************************
* 3.- Crear predicados para eliminar
*****************************************************************************************
*
**/
%searchChild("Class1",[class("Object","Object",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[relacion1=>"Class2",relacion2=>"Class3"]),class("Class2","Object",[attr1=>value1,attr2=>value2],[relacion1=>"Class1",relacion3=>"Class4"]),class("Class3","Class2",[attr1=>value5,attr3=>value3],[]),class("Class4","Object",[attr3=>value43],[]),class("Class5","Class4",[attr1=>value5,attr3=>value53],[]),class("Class6","Class5",[attr1=>value55,attr3=>value35],[relacion1=>"Class4",relacion5=>"Class5"]),class("Class7","Class6",[],[])],L).
%searchChild("Class6",[class("Object","Object",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[relacion1=>"Class2",relacion2=>"Class3"]),class("Class2","Object",[attr1=>value1,attr2=>value2],[relacion1=>"Class1",relacion3=>"Class4"]),class("Class3","Class2",[attr1=>value5,attr3=>value3],[]),class("Class4","Object",[attr3=>value43],[]),class("Class5","Class4",[attr1=>value5,attr3=>value53],[]),class("Class6","Class5",[attr1=>value55,attr3=>value35],[relacion1=>"Class4",relacion5=>"Class5"]),class("Class7","Class6",[],[])],L).
searchChild(_,[],[]):-!.
searchChild(ClassName,[H|T],L):-
	class(_,ClassName,_,_) \= H,
	searchChild(ClassName,T,L),!.
searchChild(ClassName,[H|T],L):-
	class(_,ClassName,_,_) = H,
	searchChild(ClassName,T,S),
	addElement([H],S,L),!.
%searchInstanceClass("Class1",[object("","",[],[]),object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],L).
searchInstanceClass(_,[],[]):-!.
searchInstanceClass(ClassName,[H|T],L):-
	object(_,ClassName,_,_) \= H,
	searchInstanceClass(ClassName,T,L),!.
searchInstanceClass(ClassName,[H|T],L):-
	object(_,ClassName,_,_) = H,
	searchInstanceClass(ClassName,T,S),
	addElement([H],S,L),!.
	
%updateChildClassByClass(class("Class3","Class2",[],[]),"Class4",ClassNew).
%updateChildClassByClass(class("Class3","Class2",[attr3=>5],[relacion2=>"Class2"]),"Class5",ClassNew).
updateChildClassByClass(Class,ParentClass,ClassNew):-
	findNameClass(Class,ClassName),
	findAttributesClass(Class,AttributesClass),
	findLinksClass(Class,LinksClass),
	ClassNew = class(ClassName,ParentClass,AttributesClass,LinksClass),!.
%updateObjectByLinks(object("Object12","Class2",[],[]),[rel3=>5],ClassNew).
%updateObjectByLinks(object("Object13","Class4",[attr3=>5],[relacion2=>"Class2"]),[rel8=>5,rel9=>4],ClassNew).
updateInstanceObjectByClass(Object,ParentClass,ObjectNew):-
	findNameObject(Object,ObjectName),
	findAttributesObject(Object,AttributesClass),
	findLinksObject(Object,LinksClass),
	ObjectNew = object(ObjectName,ParentClass,AttributesClass,LinksClass),!.

%addToLink("Like",class,[class("Pera","Fruta",[],[])],L).
%addToLink("Like",class,[class("Manzana","Fruta",[],[]),L).
%addToLink("Like",class,[class("Pi�a","Fruta",[],[]),class("Manzana","Fruta",[],[]),class("Pera","Fruta",[],[])],L).
addToLink(_,_,[],[]):-!.
addToLink(LinkName,class,[Y|W],L):-
	addToLink(LinkName,class,W,S),
	findNameClass(Y,NameClass),
	=>(LinkName,NameClass) = Link,
	addElement([Link],S,L),!.
%addToLink("Like",object,[object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"])],L).
addToLink(LinkName,object,[Y|W],L):-
	addToLink(LinkName,object,W,S),
	findNameObject(Y,ObjectName),
	=>(LinkName,ObjectName) = Link,
	addElement([Link],S,L),!.

%checkIteratorLink("Fruta",[like=>"Fruta"],[class("Pera","Fruta",[],[])],[object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"])],L).
%checkIteratorLink("Fruta",[like=>"Fruta"],[class("Pera","Fruta",[],[])],[],L).
%checkIteratorLink("Fruta",[like=>"Fruta"],[],[object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"])],L).
%checkIteratorLink("Fruta",[like=>"Fruta"],[],[],L).
checkIteratorLink(_,[_|_],[],[],[]):-!.
checkIteratorLink(_,[],[_|_],[_|_],[]):-!.
checkIteratorLink(_,[],[_|_],[],[]):-!.
checkIteratorLink(_,[],[],[_|_],[]):-!.
checkIteratorLink(LinkClass,[H|T],[Y|W],[],L):-
	=>(LinkName,LinkClass) = H,
	checkIteratorLink(LinkClass,T,[Y|W],[],S),
	addToLink(LinkName,class,[Y|W],R),
	addElement(R,S,L),!.
checkIteratorLink(LinkClass,[H|T],[Y|W],[],L):-
	=>(_,LinkClass) \= H,
	checkIteratorLink(LinkClass,T,[Y|W],[],S),
	addElement([H],S,L).
checkIteratorLink(LinkClass,[H|T],[],[X|Z],L):-
	=>(LinkName,LinkClass) = H,
	checkIteratorLink(LinkClass,T,[],[X|Z],S),
	addToLink(LinkName,object,[X|Z],P),
	addElement(P,S,L),!.
checkIteratorLink(LinkClass,[H|T],[],[X|Z],L):-
	=>(_,LinkClass) \= H,
	checkIteratorLink(LinkClass,T,[],[X|Z],S),
	addElement([H],S,L).
checkIteratorLink(LinkClass,[H|T],[Y|W],[X|Z],L):-
	=>(LinkName,LinkClass) = H,
	checkIteratorLink(LinkClass,T,[Y|W],[X|Z],S),
	addToLink(LinkName,class,[Y|W],R),
	addElement(R,S,V),
	addToLink(LinkName,object,[X|Z],P),
	addElement(V,P,L),!.
checkIteratorLink(LinkClass,[H|T],[Y|W],[X|Z],L):-
	=>(_,LinkClass) \= H,
	checkIteratorLink(LinkClass,T,[Y|W],[X|Z],S),
	addElement([H],S,L).
%checkIteratorLinkClass("Class1",[class("","",[],[]),class("Object","",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[]),class("Class2","Object",[attr1=>value1,attr2=>value2],[]),class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[]),class("Class5","Class2",[attr1=>value5,attr3=>value53],[relacion1=>"Class1",relacion2=>"Class2"]),class("Class6","Class2",[attr1=>value55,attr3=>value35],[]),class("Class7","Class6",[],[])],[class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[])],[object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"])]).
%checkIteratorLinkClass("Class1",[class("","",[],[]),class("Object","",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[]),class("Class2","Object",[attr1=>value1,attr2=>value2],[]),class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[]),class("Class5","Class2",[attr1=>value5,attr3=>value53],[relacion1=>"Class1",relacion2=>"Class2"]),class("Class6","Class2",[attr1=>value55,attr3=>value35],[]),class("Class7","Class6",[],[])],[class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[])],[]).
%checkIteratorLinkClass("Class1",[class("","",[],[]),class("Object","",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[]),class("Class2","Object",[attr1=>value1,attr2=>value2],[]),class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[]),class("Class5","Class2",[attr1=>value5,attr3=>value53],[relacion1=>"Class1",relacion2=>"Class2"]),class("Class6","Class2",[attr1=>value55,attr3=>value35],[]),class("Class7","Class6",[],[])],[],[object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"])]).
%checkIteratorLinkClass("Class1",[class("","",[],[]),class("Object","",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[]),class("Class2","Object",[attr1=>value1,attr2=>value2],[]),class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[]),class("Class5","Class2",[attr1=>value5,attr3=>value53],[relacion1=>"Class1",relacion2=>"Class2"]),class("Class6","Class2",[attr1=>value55,attr3=>value35],[]),class("Class7","Class6",[],[])],[],[]).
%checkIteratorLinkClass("Class2",[class("","",[],[]),class("Object","",[],[]),class("Class1","Object",[attr1=>value1,attr4=>value11],[]),class("Class2","Object",[attr1=>value1,attr2=>value2],[]),class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[]),class("Class5","Class2",[attr1=>value5,attr3=>value53],[relacion1=>"Class1",relacion2=>"Class2"]),class("Class6","Class2",[attr1=>value55,attr3=>value35],[]),class("Class7","Class6",[],[])],[class(Class5,Class2,[attr1=>value5,attr3=>value53],[relacion1=>Class4,relacion1=>Class3,relacion2=>Class2,relacion1=>Object1]),class(Class6,Class2,[attr1=>value55,attr3=>value35],[])],[object(Object2,Class2,[attr1=>valueO5,attr3=>valueO3],[])]).
% [H|T] Lista de classes
% [Y|Z] Lista de classes hijos que se quieren agregar
% [W|X] Lista de objetos relacionados con la clase
checkIteratorLinkClass(_,[_|_],[],[]):-!.
checkIteratorLinkClass(_,[],[_|_],[_|_]):-!.
checkIteratorLinkClass(_,[],[_|_],[]):-!.
checkIteratorLinkClass(_,[],[],[_|_]):-!.
checkIteratorLinkClass(Link,[H|T],[Y|Z],[W|X]):-
	checkIteratorLinkClass(Link,T,[Y|Z],[W|X]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[W|X],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkClass(Link,[H|T],[],[W|X]):-
	checkIteratorLinkClass(Link,T,[],[W|X]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[],[W|X],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkClass(Link,[H|T],[Y|Z],[]):-
	checkIteratorLinkClass(Link,T,[Y|Z],[]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkClass(Link,[H|T],[Y|Z],[W|X]):-
	checkIteratorLinkClass(Link,T,[Y|Z],[W|X]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[W|X],LinksNew),
	Links \= LinksNew,
	findNameClass(H,NameClass),
	findClassByName(NameClass,ClassConcurrenty),
	updateClassByLinks(ClassConcurrenty,LinksNew,NewClass),
	retract(ClassConcurrenty),asserta(NewClass),!.
checkIteratorLinkClass(Link,[H|T],[],[W|X]):-
	checkIteratorLinkClass(Link,T,[],[W|X]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[],[W|X],LinksNew),
	Links \= LinksNew,
	findNameClass(H,NameClass),
	findClassByName(NameClass,ClassConcurrenty),
	updateClassByLinks(ClassConcurrenty,LinksNew,NewClass),
	retract(ClassConcurrenty),asserta(NewClass),!.
checkIteratorLinkClass(Link,[H|T],[Y|Z],[]):-
	checkIteratorLinkClass(Link,T,[Y|Z],[]),
	findLinksClass(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[],LinksNew),
	Links \= LinksNew,
	findNameClass(H,NameClass),
	findClassByName(NameClass,ClassConcurrenty),
	updateClassByLinks(ClassConcurrenty,LinksNew,NewClass),
	retract(ClassConcurrenty),asserta(NewClass),!.
%checkIteratorLinkObject("Class1",[object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],[class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[])],[object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"])]).
%checkIteratorLinkObject("Class1",[object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],[class("Class3","Class1",[attr1=>value5,attr3=>value3],[]),class("Class4","Class1",[attr3=>value43],[])],[]).
%checkIteratorLinkObject("Class1",[object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],[],[object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"])]).
%checkIteratorLinkObject("Class1",[object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[relacion20=>"Class1"]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],[],[]).
checkIteratorLinkObject(_,[_|_],[],[]):-!.
checkIteratorLinkObject(_,[],[_|_],[_|_]):-!.
checkIteratorLinkObject(_,[],[_|_],[]):-!.
checkIteratorLinkObject(_,[],[],[_|_]):-!.
checkIteratorLinkObject(Link,[H|T],[Y|Z],[W|X]):-
	checkIteratorLinkObject(Link,T,[Y|Z],[W|X]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[W|X],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkObject(Link,[H|T],[],[W|X]):-
	checkIteratorLinkObject(Link,T,[],[W|X]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[],[W|X],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkObject(Link,[H|T],[Y|Z],[]):-
	checkIteratorLinkObject(Link,T,[Y|Z],[]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[],LinksNew),
	Links = LinksNew,!.
checkIteratorLinkObject(Link,[H|T],[Y|Z],[W|X]):-
	checkIteratorLinkObject(Link,T,[Y|Z],[W|X]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[W|X],LinksNew),
	Links \= LinksNew,
	findNameObject(H,NameObject),
	findObjectByName(NameObject,ObjectConcurrency),
	updateObjectByLinks(ObjectConcurrency,LinksNew,NewObject),
	retract(ObjectConcurrency),asserta(NewObject),!.
checkIteratorLinkObject(Link,[H|T],[],[W|X]):-
	checkIteratorLinkObject(Link,T,[],[W|X]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[],[W|X],LinksNew),
	Links \= LinksNew,
	findNameObject(H,NameObject),
	findObjectByName(NameObject,ObjectConcurrency),
	updateObjectByLinks(ObjectConcurrency,LinksNew,NewObject),
	retract(ObjectConcurrency),asserta(NewObject),!.
checkIteratorLinkObject(Link,[H|T],[Y|Z],[]):-
	checkIteratorLinkObject(Link,T,[Y|Z],[]),
	findLinksObject(H,Links),
	checkIteratorLink(Link,Links,[Y|Z],[],LinksNew),
	Links \= LinksNew,
	findNameObject(H,NameObject),
	findObjectByName(NameObject,ObjectConcurrency),
	updateObjectByLinks(ObjectConcurrency,LinksNew,NewObject),
	retract(ObjectConcurrency),asserta(NewObject),!.
%updateChildsClass("Class4",[class("Class1","Object",[attr1=>value1,attr4=>value11],[relacion1=>"Class2",relacion2=>"Class3"]),class("Class2","Object",[attr1=>value1,attr2=>value2],[relacion1=>"Class1",relacion3=>"Class4"]),class("Class3","Class2",[attr1=>value5,attr3=>value3],[]),class("Class4","Object",[attr3=>value43],[]),class("Class5","Class4",[attr1=>value5,attr3=>value53],[]),class("Class6","Class5",[attr1=>value55,attr3=>value35],[relacion1=>"Class4",relacion5=>"Class5"]),class("Class7","Class6",[],[])],L).
%updateChildsClass("Class4",[],L).
updateChildsClass(_,[],[]):-!.	
updateChildsClass(ParentClass,[H|T],L):-
	updateChildsClass(ParentClass,T,R),
	updateChildClassByClass(H,ParentClass,S),
	addElement([S],R,L).
%updateInstanceClass("Class4",[object("Object1","Class1",[attr1=>valueO5,attr3=>valueO3],[]),object("Object2","Class2",[attr1=>valueO5,attr3=>valueO3],[]),object("Object3","Class3",[attr1=>valueO5,attr4=>valueO4],[]),object("Object4","Class4",[attr1=>valueO5,attr4=>valueO4],[]),object("Object5","Class5",[attr1=>valueO5,attr5=>valueO5],[]),object("Object6","Class6",[attr1=>valueO6,attr6=>valueO6],[relacion1=>"Class7",relacion3=>"Class2"]),object("Object7","Class7",[attr1=>valueO7,attr7=>valueO7],[])],L).
%updateInstanceClass("Class4",[],L).
updateInstanceClass(_,[],[]):-!.	
updateInstanceClass(ParentClass,[H|T],L):-
	updateInstanceClass(ParentClass,T,R),
	updateInstanceObjectByClass(H,ParentClass,S),
	addElement([S],R,L),!.

%checkLink("Objeto1",[relacion0=>"Objeto2",relacion1=>"Objeto1",relacion2=>"Objeto2",relacion5=>"Objeto1"],L).
%checkLink("Objeto1",[relacion9=>"Objeto1",relacion0=>"Objeto2",relacion1=>"Objeto1",relacion2=>"Objeto2",relacion5=>"Objeto1"],L).
checkLink(_,[],[]):-!.
checkLink(LinkObject,[H|T],L):-
	checkLink(LinkObject,T,L),
	=>(_,LinkObject) = H,!.
checkLink(LinkObject,[H|T],L):-
	checkLink(LinkObject,T,S),
	=>(_,LinkObject) \= H,
	addElement([H],S,L),!.
deleteLinkOfClass(_,[]):-!.
deleteLinkOfClass(LinkObject,[H|T]):-
	deleteLinkOfClass(LinkObject,T),
	findLinksClass(H,Links),
	checkLink(LinkObject,Links,LinksNew),
	Links = LinksNew,!.
deleteLinkOfClass(LinkObject,[H|T]):-
	deleteLinkOfClass(LinkObject,T),
	findLinksClass(H,Links),
	checkLink(LinkObject,Links,LinksNew),
	Links \= LinksNew,
	findNameClass(H,NameClass),
	findClassByName(NameClass,ClassConcurrenty),
	updateClassByLinks(ClassConcurrenty,LinksNew,NewClass),
	retract(ClassConcurrenty),asserta(NewClass),!.
deleteLinkOfObject(_,[]):-!.
deleteLinkOfObject(LinkObject,[H|T]):-
	deleteLinkOfObject(LinkObject,T),
	findLinksObject(H,Links),
	checkLink(LinkObject,Links,LinksNew),
	Links = LinksNew,!.
deleteLinkOfObject(LinkObject,[H|T]):-
	deleteLinkOfObject(LinkObject,T),
	findLinksObject(H,Links),
	checkLink(LinkObject,Links,LinksNew),
	Links \= LinksNew,
	findNameObject(H,NameObject),
	findObjectByName(NameObject,ObjectConcurrency),
	updateObjectByLinks(ObjectConcurrency,LinksNew,ObjectNew),
	write(ObjectNew),
	retract(ObjectConcurrency),asserta(ObjectNew),!.
	
/*
*
* A) Clases u objetos
*
*
*/
%deleteElementToTree("Class1",class).
%deleteElementToTree("Class2",class).
deleteElementToTree(ClassName,class):-
	findClassByName(ClassName,Class),
	findParentClass(Class,ParentClass),
	findListTokens(ClassList,ObjectList),
	searchChild(ClassName,ClassList,Childs),
	updateChildsClass(ParentClass,Childs,NewClass),
	searchInstanceClass(ClassName,ObjectList,Objects),
	updateInstanceClass(ParentClass,Objects,NewObjects),
	deleteElements(Childs),
	writeElements(NewClass),
	deleteElements(Objects),
	writeElements(NewObjects),
	checkIteratorLinkClass(ClassName,ClassList,Childs,Objects),
	checkIteratorLinkObject(ClassName,ObjectList,Childs,Objects),
	findNameClass(Class,RebindingClassName),
	findClassByName(RebindingClassName,RebindingClass),
	retract(RebindingClass),!.
%deleteElementToTree("Object6",object).
deleteElementToTree(ObjectName,object):-
	findListTokens(ClassList,ObjectList),
	deleteLinkOfClass(ObjectName,ClassList),
	deleteLinkOfObject(ObjectName,ObjectList),
	findObjectByName(ObjectName,ObjectBindingName),
	retract(ObjectBindingName),!.
 
% 
%Borra el valor de la lista L 
deleteValue(_,[],[]). 
deleteValue(Atr=>Val,[Atr=>Val|T],T):-!. 
deleteValue(Atr=>Val,[H|T],[H|R]):-deleteValue(Atr=>Val,T,R). 
 
/*
*
* B) Propiedades espec�ficas de clases u objetos
*
*
**/
% 
% Ej 3B 
% Eliminar prop especificas 
% Object no tiene propiedades 
deleteProperty(_,"",[]). 
 
%si nos pasan una clase 
deleteProperty(Atr=>Val,C,L):-class(C,Parent,Prop,Rel),  
    existValue(Atr=>Val,Prop,B), 
        (B-> 
            (deleteValue(Atr=>Val,Prop,L), retract(class(C,Parent,Prop,Rel)),assert(class(C,Parent,L,Rel)) 
            ) 
        ). 
%si nos pasan una objeto 
deleteProperty(Atr=>Val,Name,L):-object(Name,Class,Prop,Rel), 
    existValue(Atr=>Val,Prop,B), 
        (B-> 
            (deleteValue(Atr=>Val,Prop,L), retract(object(Name,Class,Prop,Rel)),assert(object(Name,Class,L,Rel)) 
            ) 
        ).
       
% 
% Ej 3C 
% Eliminar relaciones especificas 
%Predicado que cambia por el nuevo valor 
changeAtrValue(_,_,[],[]). 
changeAtrValue(Atr=>OldValue,NewValue,[Atr=>OldValue|T],[Atr=>NewValue|T]):-!. 
changeAtrValue(Atr=>OldValue,NewValue,[H|T],[H|T1]):- changeAtrValue(Atr=>OldValue,NewValue,T,T1). 
 
%%%verifica si alguna la clase o algun padre tiene la propiedad 
existProp("",_,false):-!.     
existProp(Name,Attr,B):-findClassByName(Name,H), 
       H=class(_,X,Lr,_),  
       existAtr(Attr,Lr,A), 
       ( A -> (A=B); existProp(X,Attr,B) ),!. 
existProp(Name,Attr,B):-findObjectByName(Name,H), 
       H=object(_,X,Lr,_),  
       existAtr(Attr,Lr,A), 
       ( A -> (A=B); existProp(X,Attr,B)),!.  
       
/*
*
* C) Relaciones espec�ficas de clases u objetos
*
*
*/
  
% Object no tiene relaciones 
deleteRelation(_,"",[]).
%si nos pasan una clase 
deleteRelation(Atr=>Val,C,L):-class(C,Parent,Prop,Rel),  
    existValue(Atr=>Val,Rel,B), 
        (B-> 
            (deleteValue(Atr=>Val,Rel,L), retract(class(C,Parent,Prop,Rel)), assert(class(C,Parent,Prop,L)) 
            ) 
        ). 
%si nos pasan una objeto 
deleteRelation(Atr=>Val,Name,L):-object(Name,Class,Prop,Rel), 
            existValue(Atr=>Val,Rel,B), 
        (B-> 
            (deleteValue(Atr=>Val,Rel,L), retract(object(Name,Class,Prop,Rel)), assert(object(Name,Class,Prop,L)) 
            ) 
        ).


		
/*
*
*****************************************************************************************
* 4.- Crear predicados para modificar
*****************************************************************************************
*/
concatenar([],L,L).
concatenar([X|T1],L,[X|T2]):-concatenar(T1,L,T2).

%Predicado que modifica el nombre de una clase u objetos en una lista
changeName(_,_,[],[]):-!.
changeName(Name,New,[H|T],[S|R]):-( (H=class(Name,_,_,_)->changeNameC(H,New,S));
                                    (H=object(Name,_,_,_)->changeNameO(H,New,S)) ), 
				  retract(H),assert(S),
				  changeName(Name,New,T,R),!.
changeName(Name,New,[H|T],[S|R]):-( (H=class(_,Name,_,_)->changeFatherC(H,New,S));
				    (H=object(_,Name,_,_)->changeFatherO(H,New,S)) ),	
				  retract(H),assert(S),
				  changeName(Name,New,T,R),!.
changeName(Name,New,[H|T],[H|R]):-changeName(Name,New,T,R).

%Predicado que modifica el nombre de una clase u objeto en las relaciones
changeNameR(_,_,[],[]).
changeNameR(Name,New,[H|T],[S|R]):-
				   H=class(_,_,_,Lr),changeValueR(Name,New,Lr,L),
				   changeLRC(H,L,S),
				   retract(H),assert(S),
				   changeNameR(Name,New,T,R),!.
changeNameR(Name,New,[H|T],[S|R]):-
				   H=object(_,_,_,Lr)->changeValueR(Name,New,Lr,L),
				   changeLRO(H,L,S),
				   retract(H),assert(S),
				   changeNameR(Name,New,T,R),!.

% Predicados que cambian el nombre de un objeto o el padre de un objeto 
% especificado.
changeNameO(object(_,X,Y,Z),New,R):-R=object(New,X,Y,Z).
changeFatherO(object(X,_,Y,Z),New,R):-R=object(X,New,Y,Z).

% Predicados que cambian el nombre de una clase o el padre de un clase 
% especificado.
changeNameC(class(_,X,Y,Z),New,R):-R=class(New,X,Y,Z).
changeFatherC(class(X,_,Y,Z),New,R):-R=class(X,New,Y,Z).

%Predicado que modifica el valor de un atributo de una lista atributo valor.
changeValue(_,_,[],[]):-!.
changeValue(Name,New,[Name=>_|T],[Name=>New|T]):-!.
changeValue(Name,New,[H=>V|T],[H=>V|R]):-changeValue(Name,New,T,R).

%Predicado que cambia el valor de una relacion 
changeValueR(_,_,[],[]):-!.
changeValueR(Old,New,[H=>Old|T],[H=>New|R]):-changeValueR(Old,New,T,R),!.
changeValueR(Old,New,[H=>V|T],[H=>V|R]):-changeValueR(Old,New,T,R).

%Predicado que cambia la lista de relaciones de una clase
changeLRC(class(X,Y,Z,_),New,R):-R=class(X,Y,Z,New).

%Predicado que cambia la lista de relaciones de una clase
changeLRO(object(X,Y,Z,_),New,R):-R=object(X,Y,Z,New).

/*
*
* A) El nombre de una clase u objeto
*
*/
%Predicado que cambia el nombre de una clase u objeto.
changeName(Name,New,R):- 
			 New\="Object",Name\="Object",%No permite modificar la clase padre
			 findListTokens(L1,L2),concatenar(L1,L2,L3),
			 changeName(Name,New,L3,S),
			 changeNameR(Name,New,S,R),commit.

%Ej 4B 
%Modificar el valor de una propiedad espec�fica 
%"" no tiene propiedades  
 
%Predicado que busca si existe un atributo en la lista 
existValue(_,[],false):-!. 
existValue(Atr=>Val,[Atr=>Val|_],true):-!. 
existValue(Atr=>Val,[_|T],Bool):-existValue(Atr=>Val,T,Bool). 
 
%Predicado que busca si existe un atributo en la lista 
existAtr(_,[],false):-!. 
existAtr(Atr,[Atr=>_|_],true):-!. 
existAtr(Atr,[_|T],Bool):-existAtr(Atr,T,Bool). 
 
%%%verifica si alguna la clase o algun padre tiene la propiedad 
existRel("",_,false):-!.     
existRel(Name,Attr,B):-findClassByName(Name,H), 
       H=class(_,X,_,Lr),  
       existAtr(Attr,Lr,A), 
       ( A -> (A=B); existRel(X,Attr,B) ),!. 
existRel(Name,Attr,B):-findObjectByName(Name,H), 
       H=object(_,X,_,Lr),  
       existAtr(Attr,Lr,A), 
       ( A -> (A=B); existRel(X,Attr,B)),!.  

/*
*
* B) El valor de una propiedad espec�fica de una clase u objeto
*
*/
modifyValueRelation(_=>_,_,"",[]). 

%si nos pasan una clase 
modifyValueRelation(R=>V,NewV,Name,L):- 
    class(Name,Parent,Prop,Rel),  
    existValue(R=>V,Prop,B), 
    ( B-> 
         (changeAtrValue(R=>V,NewV,Prop,L) 
          ); 
         ( existProp(Name,R,C),C=true, 
           concatenar([R=>NewV],Prop,L)) 
         ), retract(class(Name,Parent,Prop,Rel)), 
      assert(class(Name,Parent,L,Rel)). 
%si nos pasan una objeto 
modifyValueRelation(R=>V,NewV,Name,L):- 
    object(Name,Class,Prop,Rel), 
    existValue(R=>V,Prop,B),  
    ( B-> 
     (changeAtrValue(R=>V,NewV,Prop,L)  
      ); 
     ( existProp(Name,R,C),C=true, 
           concatenar([R=>NewV],Prop,L)) 
     ), 
     retract(object(Name,Class,Prop,Rel)), 
     assert(object(Name,Class,L,Rel)) . 

/*
*
* C) Con qui�n mantiene una relaci�n espec�fica una clase u objeto
*
*/
%Modificar el valor de una relacion 
%"" no tiene propiedades  
modifyRelationWith(_=>_,_,"",[]). 
 
%si nos pasan una clase 
modifyRelationWith(R=>V,NewV,Name,L):- 
    class(Name,Parent,Prop,Rel),  
    existValue(R=>V,Rel,B), 
    ( B-> 
         (changeAtrValue(R=>V,NewV,Rel,L) 
          ); 
         ( existRel(Name,R,C),C=true, 
           concatenar([R=>NewV],Rel,L)) 
         ), retract(class(Name,Parent,Prop,Rel)), 
      assert(class(Name,Parent,Prop,L)). 
 
%si nos pasan una objeto 
modifyRelationWith(R=>V,NewV,Name,L):- 
    object(Name,Class,Prop,Rel), 
    existValue(R=>V,Rel,B),  
    ( B-> 
     (changeAtrValue(R=>V,NewV,Rel,L)  
      ); 
     ( existRel(Name,R,C),C=true, 
           concatenar([R=>NewV],Rel,L)) 
     ), 
     retract(object(Name,Class,Prop,Rel)), 
     assert(object(Name,Class,Prop,L)) .

%Sirve para guardar las modificaciones a la BD
commit:-
	findListTokens(ClassList,ObjectList),
	addElement(['ClassList' => ClassList],['ObjectList' => ObjectList],R),
	save_kb('kb.txt',R).

/**
*
* Proyecto 2
*
*/

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

%% Accion de moverse de la posicion i a la posicion j%%
mover(LocationI,LocationJ):-object(robot,_,Atrs,_),valor(posicion,Atrs,Value),LocationI=Value,Value\=LocationJ,!,costoDeIr(LocationI,LocationJ,Costo),costoAgente(CA),Res is CA + Costo,modifyValueRelation(costo=>_,Res,robot,_),probabilidadDeIr(LocationI,LocationJ,X),random(Y),Y=<X,modifyValueRelation(posicion=>LocationI,LocationJ,robot,_),!.

%% Accion de buscar un objeto en la posicion actual %%
buscar(Object):-object(Object,_,_,Relaciones),valor(ubicacion,Relaciones,Value1),object(robot,_,Atributos,_),valor(posicion,Atributos,Value2),Value1=Value2,costoDe(buscar,Object,Costo),costoAgente(CA),Res is CA + Costo,modifyValueRelation(costo=>_,Res,robot,_),
probabilidadDe(buscar,Object,Prob),random(Rand),Prob=<Rand,!.

%% Accion de agarrar el objeto en la posicion actual, se debio%%
%% haber encontrado el objeto antes %%
agarrar(Object):- 
object(robot,"Agente",_,Rels),
valor(brazo1,Rels,W1), valor(brazo2,Rels,W2),
probabilidadDe(agarrar,Object,X),random(Y),Y=<X,
( W1=""->modifyRelationWith(brazo1=>"",Object,robot,_) ; 
  ( W2=""->modifyRelationWith(brazo2=>"",Object,robot,_) ) ).

%% Metodos auxiliares %%
valor(Object1,Object2,Value,V2):-object(Object1,_,X,_),valor(Object2,X,V1),valor(Value,V1,V2).

%% Predicado que da la ubicacion de un alimento %%
ubicacion(Alimento, Ubicacion):-object(Alimento,"Alimento",_,Y),valor(ubicacion,Y,Ubicacion).

%% Predicado que da la posicion del agente %%
posicionAgente(Posicion):-object(robot,"Agente",X,_),valor(posicion,X,Posicion).

%% Predicado que da el costo de realizar una accion %% 
%% de un alimento %%
costoDe(Accion,Alimento,Costo):-object(Accion,"Accion",X,_),valor(Alimento,X,V1),valor(costo,V1,Costo).

%% Predicado que da la probabilidad de realizar una accion %% 
%% de un alimento %%
probabilidadDe(Accion,Alimento,Probabilidad):-object(Accion,"Accion",X,_),valor(Alimento,X,V1),valor(probabilidad,V1,Probabilidad).

%% Predicado que da la probabilidad de realizar una accion %% 
%% de un alimento %%
recompensaDe(Accion,Alimento,Recompensa):-object(Accion,"Accion",X,_),valor(Alimento,X,V1),valor(recompensa,V1,Recompensa).

%% Predicado que da el costo de ir de una posicion a otra %% 
costoDeIr(Posicion1,Posicion2,Costo):-object(Posicion1,"Localizacion",X,_),valor(Posicion2,X,V1),valor(costo,V1,Costo).

%% Predicado que da la probabilidad de ir de una posicion a otra %%
probabilidadDeIr(Posicion1,Posicion2,Probabilidad):-object(Posicion1,"Localizacion",X,_),valor(Posicion2,X,V1),valor(probabilidad,V1,Probabilidad).

%% Predicado que me da el costo que lleva el robot %%
costoAgente(Y):-object(robot,"Agente",X,_),valor(costo,X,Y).

%% Predicado que da la recompensa total de un alimento %%
recompensaTotal(Alimento,Recompensa):-recompensaDe(buscar,Alimento,V1),recompensaDe(agarrar,Alimento,V2),recompensaDe(entregar,Alimento,V3), Recompensa is V1+V2+V3.

%% Predicado que da la recompensa total de un alimento %%
probabilidadTotal(Alimento,Probabilidad):-probabilidadDe(buscar,Alimento,V1),probabilidadDe(agarrar,Alimento,V2),probabilidadDe(entregar,Alimento,V3), Probabilidad is V1*V2*V3.

%%
probabilidadTotal(Alimento,Ubicacion,Recompensa):-recompensaTotal(Alimento,Rec),probabilidadTotal(Alimento,Prob),ubicacion(Alimento,Pos),probabilidadDeIr(inicio,Pos,P1),probabilidadDeIr(Pos,Ubicacion,P2),Recompensa is Rec / 1-(Prob*P1*P2).

%% Media ponderada
probabilidadTotalPonderada(Alimento,Probabilidad):-probabilidadDe(buscar,Alimento,V1),probabilidadDe(agarrar,Alimento,V2),probabilidadDe(entregar,Alimento,V3), Probabilidad is V1+V2+V3.

%% Media ponderada
probabilidadTotalPonderada(Alimento,Ubicacion,Recompensa):-recompensaTotal(Alimento,Rec),probabilidadTotalPonderada(Alimento,Prob),ubicacion(Alimento,Pos),probabilidadDeIr(inicio,Pos,P1),probabilidadDeIr(Pos,Ubicacion,P2),Recompensa is Rec / (Prob+P1+P2).

%%Predicado de ejecucion de acciones
ejecutar(T,X):-X=..T,X.

ejecutarPlan([T],X):-ejecutar(T,X).
ejecutarPlan([H|T],[X,Y]):-ejecutar(H,X),ejecutarPlan(T,Y),!.

%% Accion de ordenar 
ordenar(Y,_):-plan(Y).

plan(_).