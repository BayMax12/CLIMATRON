/* Program authored by : Sachin (IIT2014501), Rajeshwar(IIT2014055) , Saurabh(IIT2014140)*/
/* DATE : 11 NOV 2016 */
/* Dynamic variables */

:- dynamic temp_median/1.
:- dynamic temp_mean/1.
:- dynamic humid_median/1.
:- dynamic humid_mean/1.
:- dynamic current_temp/1.
:- dynamic outdoor_temp/1.
:- dynamic current_humid/1.




/* Mergesort to sort the input values */
/* source : http://stackoverflow.com/questions/13839979/prolog-merge-sort-a-list-that-is-inside-a-list */

mergesort([],[]).		    % An output of sorting an empty list is another empty list
mergesort([A],[A]).			% List with only one element is the same list when sorted
mergesort([A,B|R],S) :-		% recursively call mergesort
   split([A,B|R],L1,L2),	% split the list into two halves
   mergesort(L1,S1),		% recursive calls to mergesort
   mergesort(L2,S2),
   merge(S1,S2,S).

/* To split the passed list into two halves*/
split([],[],[]).
split([A],[A],[]).
split([A,B|R],[A|Ra],[B|Rb]) :-  split(R,Ra,Rb).

/* To merge the two passed lists while sorting the values before merging */
merge(A,[],A).
merge([],B,B).
merge([A|Ra],[B|Rb],[A|M]) :-  A =< B, merge(Ra,[B|Rb],M).
merge([A|Ra],[B|Rb],[B|M]) :-  A > B,  merge([A|Ra],Rb,M).








/* TO convert list of atoms to list of numbers */
change([],[]).
change([H|T],[He|At]):-
	atom_number(H,He), change(T,At).






/* Various predicates to be called to inform the user of the decision the climatron has made */

msg1:- interface('AC is turning Off, till temperature reaches required one.',' ','
				Heater may be turned to acheive the desired temperature').

msg2:- interface('AC will be turned on again when the temperature changes by 3 degree,
				in order to maintain the required temperature','F','.').

msg3:- interface('Turning off AC  till indoor temperature equalizes with outside temperature','. ','
				 Heater will be turned on once the temperatures equalize.').

msg4:- interface('Turning on AC till desired temperature is reached','.','
				 AC will be turned off when desired temperature is reached.').

msg5:- interface('Turning on heater till desired temperature is reached','.','
				Heater will be turned off once the desired temperature is reached.
				It will be turned on when the temperature drops by 3F.').



/* Predicates for Comparison in temperatures */

inTempLessThanOutdoor(T):-
	outdoor_temp(X),
	(T < X) -> true; false.

desTempGreatThanCurrent(T):-
	current_temp(X),
	(T > X) -> true; false.

desTempLessThanCurrent(T):-
	current_temp(X),
	(T < X) -> true; false.

desTempLessOrEqualThanOutdoor(T):-
	outdoor_temp(X),
	(T =< X) -> true; false.

desTempGreaterThanOutdoor(T):-
	outdoor_temp(X),
	(T > X) -> true; false.

mean_G_median(Mean,Median):-
	(Mean > Median) -> true; false.

mean_LE_median(Mean,Median):-
	(Mean =< Median) -> true; false.

mean_GE_median(Mean,Median):-
	(Mean >= Median) -> true; false.

indoorTemp_GE_outdoorTemp(T):-
	outdoor_temp(X),
	(T >= X) -> true; false.

mean_L_median(Mean,Median):-
	(Mean < Median) -> true; false.

newTemp_LE_outdoorTemp(T):-
	outdoor_temp(X),
	(T =< X) -> true; false.

newTemp_G_outdoorTemp(T):-
	outdoor_temp(X),
	(T > X) -> true; false.


/* End of temperature predicates*/






/* Basic facts required by expert system shell as mentioned in documentation*/

faranheit_2_celcius(F,C):-
	C is ((F - 32) * (5/9)).

celcius_2_faranheit(C,F):-
	F is ((C * (9/5)) + 32).

default_values(Td,H):-
	Td is 40,
	H is 40.

/* End of facts*/






/* Setter and getter functions for dynamic variables*/

set_outdoor_temp(Outdoor_temp):-
	outdoor_temp(X), Y is X, retract(outdoor_temp(X)),
	asserta(outdoor_temp(Outdoor_temp)).

get_outdoor_temp(Out_temp):-
	outdoor_temp(X),
	Out_temp is X.

set_indoor_temp(T):-
	nl,
	current_temp(X),
	retract(current_temp(X)),
	asserta(current_temp(T)),
	interface('Setting temperature to ',T,' F').






/* Various Rules to be evaluated mentioned in documentation. Rules will be evaluated until one of them succeed. */

rule_no_1(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_LE_median(Mean,Median),

	desTempGreatThanCurrent(Mean),
	desTempLessOrEqualThanOutdoor(Mean),
	set_indoor_temp(Mean),
	msg1, msg2,
	begin.

rule_no_2(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_G_median(Mean,Median),

	desTempGreatThanCurrent(Median),
	desTempLessOrEqualThanOutdoor(Median),
	set_indoor_temp(Median),
	msg1, msg2,
	begin.

rule_no_3(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_LE_median(Mean,Median),

	desTempGreatThanCurrent(Mean),
	desTempGreaterThanOutdoor(Mean),
	set_indoor_temp(Mean),
	msg3, msg2,

	begin.

rule_no_4(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_G_median(Mean,Median),

	desTempGreatThanCurrent(Median),
	desTempGreaterThanOutdoor(Median),
	set_indoor_temp(Median),
	msg3, msg2,

	begin.

rule_no_5(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_G_median(Mean,Median),

	desTempLessThanCurrent(Mean),
	set_indoor_temp(Mean),
	msg4,msg2,

	begin.

rule_no_6(T):-
	inTempLessThanOutdoor(T),
	temp_mean(Mean), temp_median(Median),
	mean_LE_median(Mean,Median),

	desTempLessThanCurrent(Median),
	set_indoor_temp(Median),
	msg4,msg2,

	begin.

rule_no_7(T):-
	indoorTemp_GE_outdoorTemp(T),
	temp_mean(Mean), temp_median(Median),
	mean_GE_median(Mean,Median),

	desTempGreatThanCurrent(Median),
	set_indoor_temp(Median),
	msg5,

	begin.

rule_no_8(T):-
	indoorTemp_GE_outdoorTemp(T),
	temp_mean(Mean), temp_median(Median),
	mean_L_median(Mean,Median),

	desTempGreatThanCurrent(Mean),
	set_indoor_temp(Mean),
	msg5,

	begin.

rule_no_9(T):-
	indoorTemp_GE_outdoorTemp(T),
	temp_mean(Mean), temp_median(Median),
	mean_GE_median(Mean,Median),
	desTempLessThanCurrent(Median),
	newTemp_LE_outdoorTemp(Median),
	set_indoor_temp(Median),
	msg4, msg2,

	begin.

rule_no_10(T):-
	indoorTemp_GE_outdoorTemp(T),
	temp_mean(Mean), temp_median(Median),
	mean_L_median(Mean,Median),

	desTempLessThanCurrent(Mean),
	newTemp_G_outdoorTemp(Mean),
	set_indoor_temp(Mean),
	msg5,

	begin.


/* End of Rules */







/* Mean and Median related calculations */

/* Predicate to calculate the mean */

calculate_mean(List,Mean):-
	length(List, Len),
	sum(List, Sum),
	Mean is Sum / Len.

sum([], 0).
sum([H|T], Sum) :-
	sum(T, Temp),
	Sum is Temp + H.


/* Predicate to calculate the Median */

calculate_median(Xs, Median) :-
        median0(Xs, Total, 0, Median).

median0([], N, N, Median) :-
        N > 0.
median0([X|Xs], Total, N, Median) :-
        N1 is N + 1,
        median0(Xs, Total, N1, Med1),
        N2 is Total - N,
        median1(X, N1, N2, Med1, Median).

median1(X, N, N, M, X).
median1(X, N1, N2, X, X) :-
        N1 is N2 + 1.
median1(X, N1, N2, M, Median) :-
        N2 is N1 + 1,
        Median is (X + M) / 2.
median1(X, N1, N2, Med, Med) :-
        abs(N1 - N2, AbsN),
        AbsN > 1.








/* Calculate the new indoor temperature */

/* Predicates to calulate the mean and median of the temperature values */
calculate_temp([],Mean,Median):-
	Mean is 0,
	Median is 0.

/* Predicate to  calculate the mean and median and then evaluate the different rule_no_s */
/* Require mergesort(any sorting algo) to complement this part*/
calculate_temp(List,Mean,Median):-
	mergesort(List,Sorted),
	calculate_mean(Sorted,Mean),

	calculate_median(Sorted,Median),

	remove_if_exists(1,Prev_mean),
	asserta(temp_mean(Mean)),

	remove_if_exists(2,Prev_median),
	asserta(temp_median(Median)),

	current_temp(X),

	not(rule_no_1(X)),
	not(rule_no_2(X)),
	not(rule_no_3(X)),
	not(rule_no_4(X)),
	not(rule_no_5(X)),
	not(rule_no_6(X)),
	not(rule_no_7(X)),
	not(rule_no_8(X)),
	not(rule_no_9(X)),
	rule_no_10(X).





/* To remove a dynamic predicate if it exists */
remove_if_exists(V,Y):-
	(V == 1) -> ((temp_mean(X)) -> Y is X, retract(temp_mean(X)); Y is -999);
	(V == 2) -> ((temp_median(X)) -> Y is X, retract(temp_median(X)); Y is -999);
	(V == 3) -> ((humid_mean(X)) -> Y is X, retract(humid_mean(X)); Y is -999);
	(V == 4) -> ((humid_median(X)) -> Y is X, retract(humid_median(X)); Y is -999).






/* Calculate the new indoor humidity */



/* Predicates to calulate the mean and median of the humidity values*/
/* BASE CASE*/
calculate_humid([],Mean,Median):-
	Mean is 0,
	Median is 0.
/* calculation part done here */

calculate_humid(List,Mean,Median):-
	mergesort(List,Sorted),

	calculate_mean(Sorted,Mean),
	calculate_median(Sorted,Median),

	remove_if_exists(3,Prev_mean),
	asserta(humid_mean(Mean)),

	remove_if_exists(4,Prev_median),
	asserta(humid_median(Median)),

	(Mean =< Median) -> (Humid is Mean; Humid is Median),

	current_humid(X),
	retract(current_humid(X)),
	asserta(current_humid(Humid)),
	interface('Humidity is now set to ',
	Humid,
	' %'),

	( X < Humid-> interface('Humidifier is now turned on ',' ',' ');(X > Humid -> interface('Dehumidifier is now turned on ',' ',' ');interface('Humidifier unchanged ',' ',' '))),begin.





/* CONVERSION FROM Temp to humidity and vice versa */

/* Compute the relative humidity value from given temperature value */
verify_humidity(T,Humid) :-
	default_values(Td,H),
	Humid is 100*(((112 - (0.1 * T) + Td) / (112 + (0.9*T))) ^ 8).

/* Compute the temperature value from given relative humidity value */
verify_temp(Humid,Temp) :-
	default_values(Td,H),
	Temp is (Td - (112 * (Humid/100) ^ (1/8)) + 112) / ((0.9 * (Humid/100) ^ (1/8)) + 0.1).










/* Take as input list from the user(s) for the desired temperature value(s) */

reset_Temp:-
	current_temp(X),
	interface('Current temperature is ',X,'F'),
	interface3('Enter desired temperature separated by spaces example : 72.3 73.0 74.5 ',Te),
	atomic_list_concat(Response, ' ', Te),
	change(Response,Res1),
	calculate_temp(Res1,Mean,Median).

/* Take as input list from the user(s) for the desired humidity value(s) */
reset_Humid:-
	interface3('Enter desired humidities separated by spaces example : 30 40 50 ',Te),
	atomic_list_concat(Response, ' ', Te),
	change(Response,Res1),
	calculate_humid(Res1,Mean,Median).

/* To reset the outdoor temperature */
reset_outdoor_temp:-
	interface3('How much is outdoor temperature? ',Te),
	atom_number(Te,Temp),
	set_outdoor_temp(Temp),
	interface('Outdoor temperature set to ',Temp,' F'),
	begin.







/* GUI Functions */


interface(P,A,N) :-
	atom_concat(P,A, W),
	atom_concat(W,N,W4),
	/*atom_concat(B,W2,W3),*/
	jpl_new('javax.swing.JFrame', ['Room Climate Control Expert System'], F),
	jpl_new('javax.swing.JLabel',['--- CLIMATRON (EXPERT SYSTEM) ---'],LBL),
	jpl_new('javax.swing.JPanel',[],Pan),
	jpl_call(Pan,add,[LBL],_),
	jpl_call(F,add,[Pan],_),
	jpl_call(F, setLocation, [400,300], _),
	jpl_call(F, setSize, [400,300], _),
	jpl_call(F, setVisible, [@(true)], _),
	jpl_call(F, toFront, [], _),
	jpl_call('javax.swing.JOptionPane', showMessageDialog, [F,W4], S),
	jpl_call(F, dispose, [], _),
	(	S == @(void)
		->	write('')
		;	write("")
	).

interface3(P,N) :-
	/*atom_concat(P,W1, A),
	atom_concat(A,D,B),
	atom_concat(B,W2,W3),*/
	jpl_new('javax.swing.JFrame', ['Room Climate Control Expert System'], F),
	jpl_new('javax.swing.JLabel',['--- CLIMATRON (EXPERT SYSTEM) ---'],LBL),
	jpl_new('javax.swing.JPanel',[],Pan),
	jpl_call(Pan,add,[LBL],_),
	jpl_call(F,add,[Pan],_),
	jpl_call(F, setLocation, [400,300], _),
	jpl_call(F, setSize, [400,300], _),
	jpl_call(F, setVisible, [@(true)], _),
	jpl_call(F, toFront, [], _),
	jpl_call('javax.swing.JOptionPane', showInputDialog, [F,P], N),
	jpl_call(F, dispose, [], _),
	(	N == @(void)
		->	write('')
		;	write("")
	).



/* END OF GUI PART*/






/* Function which asks the user to enter relevant number, else type anything else */
begin:-
	nl, nl,
	interface3('
	     1. Reset Temperature
	     2. Reset Humidity
	     3. Update outdoor temperature
		     4. Exit
		 Enter 1, 2 ,3 or 4 as Response ',Res),
	nl,atom_number(Res,Response),

	/* Call respective predicate to perform action chosen by the user */
	not((Response == 1) -> reset_Temp; false),
	not((Response == 2) -> reset_Humid; false),
	not((Response == 3) -> reset_outdoor_temp; false),
	not((Response >= 4) -> abort; true).

/* The point of execution of CLIMATRON */
go:-
	interface('Welcome to CLIMATRON, ','Select OK to proceed','.'),
	interface3('How much is outdoor temperature? ', Ou),
	atom_number(Ou,Out_temp),
	asserta(outdoor_temp(Out_temp)),
	interface3('What is the current indoor temperature? ',In),
	atom_number(In,In_temp),
	asserta(current_temp(In_temp)),
	verify_humidity(In_temp,Humid),
	interface('Current indoor humidity is ',Humid,'%'),
	asserta(current_humid(Humid)),
	begin.

/* End of CLIMATRON*/
