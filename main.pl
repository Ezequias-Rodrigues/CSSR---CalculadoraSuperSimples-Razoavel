%Vo definir varios operadores para permitir qualquer formato
%negacoes
:- op(1, fx, not). 
:- op(1, fx, !).
%xor
:- op(2, yfx, xor).
:- op(2, yfx, ^).

%nand
:- op(3, yfx, nand).
%nor
:- op(3, yfx, nor).

%Ands (4 é a precedencia, xfy é a ordem q ele atua, poderia ser xfx mas bugaria com A and B and C e coisas do estilo):
%Tive q mudar de xfy pra yfx pq o treco buga se tu por parenteses a direita com xfy... 0 sentido mas bele
:- op(4, yfx, and).
:- op(4, yfx, &).
%:- op(4, yfx, ∧). Prolog n aceita isso, infelizmente
%Ors 
:- op(5, yfx, or).
:- op(5, yfx, +).

%implicacao
:- op(6, yfx, implies).
:- op(6, yfx, ->).
:- op(6, yfx, >).

%bicondicional
:- op(7, yfx, <>).
:- op(7, yfx, == ).
 
start :-
    write('Digite sua expressao: '),
    read(Expr),nl,         
    find_vars(Expr, Vars),
    write("Variaveis encontradas:"), write(Vars),nl,
    write('Expressao foi entendida como: '), write_canonical( Expr),nl,
    write('Tabela verdade:'), nl,
    print_header(Vars),nl,
    generate_combinations(Vars, Combs),
    print_rows(Combs, Expr, Vars),
    nl.


print_header([]).
print_header([Var|Vars]) :-
    write(Var), write(' | '),
    print_header(Vars).

print_rows([], _, _).
print_rows([Combo|Rest], Expr, Vars) :-
    evaluate(Expr, Combo, Result),
    print_row(Combo, Vars, Result),
    print_rows(Rest, Expr, Vars).

print_row([], [], Result) :-
    format_result(Result), nl.
print_row([Var=Value|Rest], [_|Vars], Result) :-
    format_value(Value),
    write(' | '),
    print_row(Rest, Vars, Result).
format_value(true) :- write('T').
format_value(false) :- write('F').
format_result(true) :- write(' T ').
format_result(false) :- write(' F ').

%AND/E
evaluate(and(Left, Right), Assign, true) :- %o vs code n tem um intelisense pra isso...
    evaluate(Left, Assign, true), %socorro...
    evaluate(Right, Assign, true).
    
evaluate(and(Left, Right), Assign, false) :-
    ( evaluate(Left, Assign, false) ; evaluate(Right, Assign, false) ).

evaluate(&(Left, Right), Assign, true) :-
    evaluate(Left, Assign, true),
    evaluate(Right, Assign, true).
    
evaluate(&(Left, Right), Assign, false) :-
    ( evaluate(Left, Assign, false) ; evaluate(Right, Assign, false) ). %Ok o troféu de convensão mais esquisita é de prolog... QUEM USA ";" COMO OR

%OR/OU
evaluate(or(Left, Right), Assign, true) :-
    ( evaluate(Left, Assign, true) ; evaluate(Right, Assign, true) ).

evaluate(or(Left, Right), Assign, false) :-
    evaluate(Left, Assign, false),
    evaluate(Right, Assign, false).

%Implicacao
evaluate(implies(Left, Right), Assign, true) :-
    ( not(evaluate(Left, Assign, true)) ; evaluate(Right, Assign, true) ).

evaluate(implies(Left, Right), Assign, false) :-
    evaluate(Left, Assign, true),
    evaluate(Right, Assign, false).

evaluate(>(Left, Right), Assign, true) :-
    ( not(evaluate(Left, Assign, true)) ; evaluate(Right, Assign, true) ).

evaluate(>(Left, Right), Assign, false) :-
    evaluate(Left, Assign, true),
    evaluate(Right, Assign, false).

evaluate(->(Left, Right), Assign, true) :-
    ( not(evaluate(Left, Assign, true)) ; evaluate(Right, Assign, true) ).

evaluate(->(Left, Right), Assign, false) :-
    evaluate(Left, Assign, true),
    evaluate(Right, Assign, false).

%BICONDICIONAL:
evaluate(==(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, true), evaluate(Right, Assign, true)).

evaluate(==(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false), evaluate(Right, Assign, false)).

evaluate(==(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(==(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).

%xor
evaluate(^(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true), evaluate(Right, Assign, true)).

evaluate(^(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, false), evaluate(Right, Assign, false)).

evaluate(^(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(^(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).

evaluate(xor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true), evaluate(Right, Assign, true)).

evaluate(xor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, false), evaluate(Right, Assign, false)).

evaluate(xor(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(xor(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).

%nand 
evaluate(nand(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, false)).

evaluate(nand(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).

    evaluate(nand(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(nand(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, true)).

%nor

evaluate(nor(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, false)).

evaluate(nor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).

evaluate(nor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(nor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, true)).

%NOT/NEGACAO
evaluate(not(Expr), Assign, true) :-
    evaluate(Expr, Assign, false).

evaluate(not(Expr), Assign, false) :-
    evaluate(Expr, Assign, true).    

evaluate(!(Expr), Assign, true) :-
    evaluate(Expr, Assign, false).

evaluate(!(Expr), Assign, false) :-
    evaluate(Expr, Assign, true).

%Variavel sozinha, basicamente a? então a = a. Papo de doido, tlg
evaluate(Var, Assign, Value) :-
    member(Var=Value, Assign).

%Fim da logica dos operadores

generate_combinations([], [[]]).

generate_combinations([Var|Vars], Result) :-
    generate_combinations(Vars, Rest),
    add_values(Var, Rest, Result).

add_values(_, [], []).
add_values(Var, [Combo|Rest], [[Var=true|Combo], [Var=false|Combo]|More]) :-
    add_values(Var, Rest, More).

%Daq pra baixo é só pra fazer o codigo "ler", isso é tipo o tokenizador, so q feito por alienigenas


find_vars(and(Left, Right), Vars) :-  %RECURSIVIDADE <3
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).
    
find_vars(&(Left, Right), Vars) :-  %Vo ter q definir uma dessa pra cada operador... regex era mais simples slc
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars). %Basicamente aquela bizarrisse do python de list(Dict.fromlist()) ou algo assim. A unica coisa normal nessa linguagem, aparentemente.

find_vars(xor(Left, Right), Vars) :- 
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(^(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(nor(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(nand(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(or(Left, Right), Vars) :-
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(+(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(>(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(->(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(implies(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(==(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(<>(Left, Right), Vars) :-  
    find_vars(Left, Vars1),
    find_vars(Right, Vars2),
    append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(not(Sentence), Vars) :-
    find_vars(Sentence, Vars2),
    sort(Vars2, Vars).

find_vars(!(Sentence), Vars) :-
    find_vars(Sentence, Vars2),
    sort(Vars2, Vars).

find_vars(Var, [Var]):- %mANO prolog é mto estranho
    atom(Var). %Hmmm sim, essa variavel é uma variavel
