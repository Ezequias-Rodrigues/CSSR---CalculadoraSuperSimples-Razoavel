%Vo definir varios operadores para permitir qualquer formato
%Correção, eu IA definir varios, mas tem que repetir muito codigo, então vou dar uma resumida
%negacoes
:- op(1, fy, not). 

%xor
:- op(2, yfx, xor).


%nand
:- op(3, yfx, nand).
%nor
:- op(3, yfx, nor).

%Ands (4 é a precedencia, xfy é a ordem q ele atua, poderia ser xfx mas bugaria com A and B and C e coisas do estilo):
%Tive q mudar de xfy pra yfx pq o treco buga se tu por parenteses a direita com xfy... 0 sentido mas bele
:- op(4, yfx, and).
%:- op(4, yfx, &).
%:- op(4, yfx, ∧). Prolog n aceita isso, infelizmente
%Ors 
:- op(5, yfx, or).
%:- op(5, yfx, +).

%implicacao
:- op(6, yfx, implies).
%:- op(6, yfx, ->).
%:- op(6, yfx, >).

%bicondicional
%:- op(7, yfx, <>).
:- op(7, yfx, xnor ). %tive q ir pesquisar pra achar esse nome

start :-
    write('------- Calculadora de Lógica --------'),nl,
    write('Instruções:'),nl,
    write('-> "and" para conectivo E, exemplo: p and q. Isso é o mesmo que p ∧ q.'), nl,
    write('-> "or" para conectivo OU, exemplo: p or q. Isso é o mesmo que p ∨ q.'), nl,
    write('-> "not" para negação, exemplo: not p or q. Isso é o mesmo que ¬p ∨ q.'), nl,
    write('-> "implies" para conectivo de implicação, exemplo: p implies q. Isso é o mesmo que p ⇒ q.'), nl,
    write('-> "xnor" para conectivo bicondicional, exemplo: p xnor q. Isso é o mesmo que p ↔ q.'), nl,
    write('-> "xor" para conectivo OU Exclusivo, exemplo: p xor q. Isso é o mesmo que p ⊕ q.'), nl,
    write('-> "nor" para conectivo OU Negado, exemplo: p nor q. Isso é o mesmo que p ↓ q.'), nl,
    write('-> "nand" para conectivo E Negado, exemplo: p nand q. Isso é o mesmo que p ↑ q.'), nl,nl,
    write('! xor tem precedência superior ao E.'),nl, write('! Parenteses são aceitos e bem vindos.'), nl,
    write('! A simplificação foca em deixar a expressão mais curta, então xor e xnor são a forma final. E por esse mesmo motivo, a distributiva só faz fatoração.'),nl,
    get_expr.
get_expr :-
    nl,
    write('---------------------------------------------------------------------------'), nl,
    write('Digite sua expressão(ou sair. para sair): '),
    read(Expr),nl,         
    find_vars(Expr, Vars),
    ( (Expr == sair ; Expr == end_of_file) ->
        write('<Som do windows xp encerrando>.'), nl
    ;
       
        write('Expressão foi entendida como: '), write_canonical( Expr),nl,
        write('Tabela verdade:'), nl,
        print_header(Vars),nl,
        generate_combinations(Vars, Combs),
        print_rows(Combs, Expr, Vars, NTrue, NFalse), nl,
        (NFalse == 0 -> 
            write("Essa expressão é uma tautologia"), nl
        ;
            (NTrue == 0 -> 
                write("Essa expressão é uma contradição"), nl
            ;
                simplify_step(Expr, Simp),
                write('Essa expressão é uma contingência e foi simplificada para: '), write(Simp),nl,
                get_simplified_tabular(Expr, Vars, SimplifiedTabular),
                write('Simplificação pelas linhas verdadeiras: '), write(SimplifiedTabular), nl, nl
            )
        ),
        
        
        nl,
        get_expr %o ponto... ele n era pra ser aqui? pq q é dps do parenteses?
    ).

print_header([]) :- write('    Formula').
print_header([Var|Vars]) :-
    write(Var), write(' | '),
    print_header(Vars).

print_row([], [], E) :-
    format_E(E).
print_row([Var=Value|Rest], [_|Vars], E) :-
    format_value(Value),
    write(' | '),
    print_row(Rest, Vars, E).

print_rows(Combs, Expr, Vars, NTrue, NFalse) :-
    print_rows(Combs, Expr, Vars, 0, 0, NTrue, NFalse).

print_rows([], _, _, AccT, AccF, AccT, AccF).
print_rows([Combo|Rest], Expr, Vars, AccT, AccF, NTrue, NFalse) :-
    once(evaluate(Expr, Combo, E)),
    print_row(Combo, Vars, E),
    ( E == true ->
        generate_row_formula(Combo, Formula),
        format_formula(Formula, FormulaStr),
        write('  ( '), write(FormulaStr), write(' )')
    ;
        write('  ( false )')
    ),
    nl,
    ( E == true
    -> AccT1 is AccT + 1, AccF1 = AccF
    ;  AccT1 = AccT, AccF1 is AccF + 1
    ),
    print_rows(Rest, Expr, Vars, AccT1, AccF1, NTrue, NFalse).
    


collect_true_minterms(_, [], _, []).
collect_true_minterms(Expr, [Combo|Rest], Vars, [Formula|Formulas]) :-
    once(evaluate(Expr, Combo, true)),
    generate_row_formula(Combo, Formula),
    collect_true_minterms(Expr, Rest, Vars, Formulas).

collect_true_minterms(Expr, [Combo|Rest], Vars, Formulas) :-
    once(evaluate(Expr, Combo, false)),
    collect_true_minterms(Expr, Rest, Vars, Formulas).

minterm_to_expr([X], X). 
minterm_to_expr([X,Y|Rest], and(X, RestExpr)) :-
    minterm_to_expr([Y|Rest], RestExpr).


build_master_formula([], false).
build_master_formula([M], Formula) :- 
    minterm_to_expr(M, Formula).
build_master_formula([M1,M2|Rest], Formula) :-
    minterm_to_expr(M1, E1),
    minterm_to_expr(M2, E2),
    build_master_or(E1, E2, Rest, Formula).

build_master_or(E1, E2, [], or(E1, E2)).
build_master_or(E1, E2, [M|Rest], Formula) :-
    minterm_to_expr(M, E3),
    build_master_or(or(E1, E2), E3, Rest, Formula).


minterm_to_expr([Var], Var) :- atom(Var). %Aparentemente minha ideia de juntar as linhas que formam uma tabela de tauntologia se chama soma dos produtos... 
minterm_to_expr([not(Var)], not(Var)).
minterm_to_expr([Var|Rest], and(Var, RestExpr)) :-
    Rest \= [],
    minterm_to_expr(Rest, RestExpr).
minterm_to_expr([not(Var)|Rest], and(not(Var), RestExpr)) :-
    Rest \= [],
    minterm_to_expr(Rest, RestExpr).


get_tabular_expression(Expr, Vars, TabularExpr) :-
    generate_combinations(Vars, Combs),
    collect_true_minterms(Expr, Combs, Vars, Minterms),
    build_master_formula(Minterms, TabularExpr).

get_simplified_tabular(Expr, Vars, SimplifiedTabular) :-
    get_tabular_expression(Expr, Vars, TabularExpr),
    simplify_step(TabularExpr, SimplifiedTabular).

format_value(true) :- write('T').
format_value(false) :- write('F').
format_E(true) :- write(' T ').
format_E(false) :- write(' F ').


% Generate formula for a specific combination (minterm)
generate_row_formula([], []).
generate_row_formula([Var=true|Rest], [Var|RestFormula]) :-
    generate_row_formula(Rest, RestFormula).
generate_row_formula([Var=false|Rest], [not(Var)|RestFormula]) :-
    generate_row_formula(Rest, RestFormula).

% Convert formula list to readable string
format_formula([], '').
format_formula([X], Result) :-
    format_term(X, Result).
format_formula([X|Rest], Result) :-
    format_term(X, TermX),
    format_formula(Rest, RestStr),
    atomic_list_concat([TermX, ' and ', RestStr], Result).

format_term(Var, Var) :- atom(Var).
format_term(not(Var), Result) :-
    atomic_list_concat(['not ', Var], Result).

%AND/E
evaluate(and(Left, Right), Assign, true) :- %o vs code n tem um intelisense pra isso...
    evaluate(Left, Assign, true), evaluate(Right, Assign, true). %socorro...
   
evaluate(and(Left, Right), Assign, false) :-
    ( evaluate(Left, Assign, false) ; evaluate(Right, Assign, false) ).%Ok o troféu de convensão mais esquisita é de prolog... QUEM USA ";" COMO OR

%OR/OU
evaluate(or(Left, Right), Assign, true) :-
    ( evaluate(Left, Assign, true) ; evaluate(Right, Assign, true) ).

evaluate(or(Left, Right), Assign, false) :-
    evaluate(Left, Assign, false), evaluate(Right, Assign, false).

%Implicacao
evaluate(implies(Left, Right), Assign, true) :-
    ( not(evaluate(Left, Assign, true)) ; evaluate(Right, Assign, true) ).

evaluate(implies(Left, Right), Assign, false) :-
    evaluate(Left, Assign, true), evaluate(Right, Assign, false).


%BICONDICIONAL:
evaluate(xnor(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, true), evaluate(Right, Assign, true)).

evaluate(xnor(Left, Right), Assign, true) :-
    (evaluate(Left, Assign, false), evaluate(Right, Assign, false)).

evaluate(xnor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, true) , evaluate(Right, Assign, false)).

evaluate(xnor(Left, Right), Assign, false) :-
    (evaluate(Left, Assign, false) , evaluate(Right, Assign, true)).


%xor

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

evaluate(true, _, true).
evaluate(false, _, false).
%Variavel sozinha, basicamente a? então a = a. Papo de doido, tlg
evaluate(Var, Assign, Value) :-
    member(Var=Value, Assign).

%Fim da logica dos operadores

generate_combinations([], [[]]).

generate_combinations([Var|Vars], E) :-
    generate_combinations(Vars, Rest),
    add_values(Var, Rest, E).

add_values(_, [], []).
add_values(Var, [Combo|Rest], [[Var=true|Combo], [Var=false|Combo]|More]) :-
    add_values(Var, Rest, More).

%Daq pra baixo é só pra fazer o codigo "ler", isso é tipo o tokenizador, so q feito por alienigenas


find_vars(and(Left, Right), Vars) :-  %RECURSIVIDADE <3
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars). %Basicamente aquela bizarrisse do python de list(Dict.fromlist()) ou algo assim. A unica coisa normal nessa linguagem, aparentemente.

    
find_vars(xor(Left, Right), Vars) :- 
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(nor(Left, Right), Vars) :-  
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(nand(Left, Right), Vars) :-  
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(or(Left, Right), Vars) :-
    find_vars(Left, Vars1),find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(implies(Left, Right), Vars) :-  
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(xnor(Left, Right), Vars) :-  
    find_vars(Left, Vars1), find_vars(Right, Vars2), append(Vars1, Vars2, Vars3),
    sort(Vars3, Vars).

find_vars(not(Sentence), Vars) :-
    find_vars(Sentence, Vars2),
    sort(Vars2, Vars).


find_vars(true, []).
find_vars(false, []).
find_vars(Var, [Var]):- %mANO prolog é mto estranho
    atom(Var), %Hmmm sim, essa variavel é uma variavel
    Var \= true,
    Var \= false.
%------ Truque sujo para evitar loop quando chegar naquele inferno que é a distributiva KKKKK
size(true, 1).
size(false, 1).
size(Var, 1) :- atom(Var).
size(not(X), Size) :- size(X, S), Size is S + 1.
size(and(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(or(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(xor(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(nand(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(nor(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(implies(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(xnor(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.

%-------------Regras de simplificação
%---- identidades
simplify(true, true).
simplify(not(false), true).
simplify(false, false).
simplify(not(true), false).
simplify(A or false, E) :-    simplify(A, E).
simplify(false or A, E) :-    simplify(A, E).
simplify(A or true, true).
simplify(true or A, true).
%---- idempotencias
simplify(A and A, E) :- simplify(A, E).
simplify(not(A) and not(A), not(E)):- simplify(A, E).
simplify(A or A, E) :- simplify(A, E).
simplify(not(A) or not(A), not(E)):- simplify(A, E).
%---- tautologia e contradição
simplify(A or not(A), true).
simplify(not(A) or A, true).
simplify(A and not(A), false).
simplify(not(A) and A, false).
%--------- De morgans
simplify((not(or(A, B))), (not(SA) and not(SB))) :- simplify(A, SA), simplify(B, SB).
simplify((not(and(A, B))), (not(SA) or not(SB))) :- simplify(A, SA), simplify(B, SB).
%------ absorção
simplify((A or (A and B)), E):- simplify(A, E). 
simplify((A or (B and A)), E):- simplify(A, E). 
simplify(((A and B) or A), E):- simplify(A, E). 
simplify(((B and A) or A), E):- simplify(A, E). 

simplify((A and (A or B)), E):- simplify(A, E). 
simplify((A and (B or A)), E):- simplify(A, E). 
simplify(((A or B) and A), E):- simplify(A, E). 
simplify(((B or A) and A), E):- simplify(A, E). 

simplify((A or (not(A) and B)), or(SA, SB)) :-  %REGRA DESTRUTIVA, JÁ PATENTEEI
    simplify(A, SA), simplify(B, SB).
simplify(((not(A) and B) or A), or(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).
simplify((A or (B and not(A))), or(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).
simplify(((B and not(A)) or A), or(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).

simplify((A and (not(A) or B)), and(SA, SB)) :-  
    simplify(A, SA), simplify(B, SB).
simplify(((not(A) or B) and A), and(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).
simplify((A and (B or not(A))), and(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).
simplify(((B or not(A)) and A), and(SA, SB)) :- 
    simplify(A, SA), simplify(B, SB).
%---- distributiva (A x B) y (A x C) = A x (B y C)
%Esse código foi feito por Ezequias.
%Só to pondo aqui caso alguem copie do repo público KKKK
% -- A seção a seguir é... peculiar
simplify(((A and B) or (A and C)), (SA and (SB or SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((A and B) or (A and C)), S1),
    size((SA and (SB or SC)), S2),
    S2 < S1.

simplify(((B and A) or (A and C)), (SA and (SB or SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((B and A) or (A and C)), S1),
    size((SA and (SB or SC)), S2),
    S2 < S1.

simplify(((A and B) or (C and A)), (SA and (SB or SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((A and B) or (C and A)), S1),
    size((SA and (SB or SC)), S2),
    S2 < S1.

simplify(((B and A) or (C and A)), (SA and (SB or SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((B and A) or (C and A)), S1),
    size((SA and (SB or SC)), S2),
    S2 < S1.

simplify(((A or B) and (A or C)), (SA or (SB and SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((A or B) and (A or C)), S1),
    size((SA or (SB and SC)), S2),
    S2 < S1.

simplify(((B or A) and (A or C)), (SA or (SB and SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((B or A) and (A or C)), S1),
    size((SA or (SB and SC)), S2),
    S2 < S1.

simplify(((A or B) and (C or A)), (SA or (SB and SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((A or B) and (C or A)), S1),
    size((SA or (SB and SC)), S2),
    S2 < S1.

simplify(((B or A) and (C or A)), (SA or (SB and SC))) :- 
    simplify(A, SA), 
    simplify(B, SB), 
    simplify(C, SC),
    size(((B or A) and (C or A)), S1),
    size((SA or (SB and SC)), S2),
    S2 < S1.

%Removi a expansão da distributiva pq não acho que faz mto sentido aumentar o tamanho pra simplificar
%simplify((A and (B or C)), E) :- 
 %   simplify(A, SA), 
  %  simplify(B, SB), 
   % simplify(C, SC),
   % Exp = ((SA and SB) or (SA and SC)),
   % simplify_step(Exp, Simp), 
   % size((A and (B or C)), S1),
   % size(Simp, S2),
   % S2 < S1,
   % E = Simp.

%simplify(((B or C) and A), E) :- 
    %simplify(A, SA), 
    %simplify(B, SB), 
    %simplify(C, SC),
    %Exp = ((SB and SA) or (SC and SA)),
   %simplify_step(Exp, Simp),
   % size(((B or C) and A), S1),
   %% size(Simp, S2),
  %%  S2 < S1,
 %   E = Simp.

%simplify((A or (B and C)), E) :- 
    %simplify(A, SA), 
    %simplify(B, SB), 
    %simplify(C, SC),
    %Exp = ((SA or SB) and (SA or SC)),
    %simplify_step(Exp, Simp),
    %size((A or (B and C)), S1),
   % size(Simp, S2),
  %  S2 < S1,
 %   E = Simp.

%simplify(((B and C) or A), E) :- 
   % simplify(A, SA), 
   % simplify(B, SB), 
   % simplify(C, SC),
   % Exp = ((SB or SA) and (SC or SA)),
   % simplify_step(Exp, Simp),
   % size(((B and C) or A), S1),
   % size(Simp, S2),
   % S2 < S1,
   % E = Simp.


simplify((A and (A or B)), E) :- simplify(A, E).
simplify(((A or B) and A), E) :- simplify(A, E).
simplify((A and (B or A)), E) :- simplify(A, E).
simplify(((B or A) and A), E) :- simplify(A, E).

simplify((A or (A and B)), E) :- simplify(A, E).
simplify(((A and B) or A), E) :- simplify(A, E).
simplify((A or (B and A)), E) :- simplify(A, E).
simplify(((B and A) or A), E) :- simplify(A, E).


simplify(A and true, E) :-    simplify(A, E).
simplify(true and A, E) :-    simplify(A, E).

simplify(false or A, E) :-    simplify(A, E).
simplify(A or false, E) :-    simplify(A, E).

simplify(A and false, false).
simplify(false and B, false).

simplify(true or B, true).
simplify(A or true, true).
%------- Equivalencias
simplify((implies(A, B) and implies(B, A)), xnor(SA, SB)):- 
    simplify(A, SA), 
    simplify(B, SB).
simplify(((not(A) or B) and (not(B) or A)), xnor(SA, SB)):- 
    simplify(A, SA), 
    simplify(B, SB).

%Implicação
simplify(implies(A, B), E) :- simplify(A, SA), simplify(B, SB), simplify_step(not(SA) or SB, E). % 3º hora mexendo nesse código... nada mais me impressiona

%xor
simplify((or(A, B) and not(and(A, B))), xor(SA, SB)):- simplify(A, SA), simplify(B, SB).
simplify((not(and(A, B)) and or(A, B)), xor(SA, SB)):- simplify(A, SA), simplify(B, SB).

%nand
simplify((not(A) or not(B)), nand(SA,SB)) :- simplify(A, SA), simplify(B, SB).
%nor
simplify((not(A) and not(B)), nor(SA,SB)) :- simplify(A, SA), simplify(B, SB).
simplify(not(not(A)), E) :- simplify(A, E).
simplify(not((A)), not(E)) :- simplify(A, E).


simplify(xnor(A,B), xnor(SA,SB)) :- simplify(A, SA), simplify(B, SB).

simplify(xor(A,B), xor(SA,SB)) :- simplify(A, SA), simplify(B, SB).

simplify(nand(A,B), nand(SA,SB)) :- simplify(A, SA), simplify(B, SB).

simplify(nor(A,B), nor(SA,SB)) :- simplify(A, SA), simplify(B, SB).
    
simplify(A and B, SA and SB) :- simplify(A, SA), simplify(B, SB).

simplify(A or B, SA or SB) :- simplify(A, SA), simplify(B, SB).


simplify(A, A) :- atom(A).

simplify_step(A, E):-
    simplify(A, T),
    (A == T -> E = T ; size(A, SA), size(T, ST),
     (ST =< SA -> simplify_step(T, E) ; E = T)). %OK, a sintaxe de If em prolog é bonitinha, mas só isso e o sort
