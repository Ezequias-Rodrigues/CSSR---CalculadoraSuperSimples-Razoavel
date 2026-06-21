%Vo definir varios operadores para permitir qualquer formato
%Correção, eu IA definir varios, mas tem que repetir muito codigo, então vou dar uma resumida
%negacoes
:- op(1, fy, not). 
:- op(2, yfx, xor).
:- op(3, yfx, nand).
:- op(3, yfx, nor).
%Ands (4 é a precedencia, xfy é a ordem q ele atua, poderia ser xfx mas bugaria com A and B and C e coisas do estilo):
%Tive q mudar de xfy pra yfx pq o treco buga se tu por parenteses a direita com xfy... 0 sentido mas bele
:- op(4, yfx, and).
:- op(5, yfx, or).
:- op(6, xfy, implies).
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
    write('! A simplificação heuristica foca em deixar a expressão mais curta, então xor e xnor são a forma final.'), nl, 
    write('    E por esse mesmo motivo, a distributiva só faz fatoração.'),nl,
    write('! A simplificação tabular foca em pegar a menor expressão em que os termos não se repitam, usando somente negação, conjunção e disjunção, e por isso acredito que é mais completa.'),
    get_expr.
get_expr :-
    nl,
    write('---------------------------------------------------------------------------'), nl,
    write('Digite sua expressão(ou sair. para sair): '),
    read(Expr),!,nl,         
    find_vars(Expr, Vars),
    ( (Expr == sair ; Expr == end_of_file) ->
        write('<Som do windows xp encerrando>.'), nl
    ;
        write('Expressão foi entendida como: '), write_canonical( Expr),nl,
        write('Tabela verdade:'), nl,
        print_header(Vars),nl,
        generate_combinations(Vars, Combs),
        once(print_rows(Combs, Expr, Vars, NTrue, NFalse)), nl,
        (NFalse == 0 -> 
            write("Essa expressão é uma tautologia"), nl
        ;
            (NTrue == 0 -> 
                write("Essa expressão é uma contradição"), nl
            ;
                simplify_step(Expr, Simp),
                write('Essa expressão é uma contingência e foi simplificada para: '), write(Simp),nl,
            
                ( get_simplified_tabular(Expr, Vars, SimplifiedTabular) ->
                        write('Simplificação pelas linhas verdadeiras: '), write(SimplifiedTabular), nl
                    ;
                        write('Simplificação pelas linhas verdadeiras: [Erro na geração]'), nl
                    )
            )
        ),nl,
        get_expr
    ).
print_header([]) :- write('    Formula').
print_header([Var|Vars]) :-
    write(Var), write(' | '),
    print_header(Vars).
print_row([], [], E) :-
    format_E(E).
print_row([_=Value|Rest], [_|Vars], E) :-
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
collect_all_the_trues(_, [], _, []).
collect_all_the_trues(Expr, [Combo|Rest], Vars, Formulas) :-
    evaluate(Expr, Combo, Result),
    ( Result == true ->
        generate_row_formula(Combo, Formula),
        Formulas = [Formula|RestFormulas],
        collect_all_the_trues(Expr, Rest, Vars, RestFormulas)
    ;
        collect_all_the_trues(Expr, Rest, Vars, Formulas)
    ).
truthLine_to_expr([], true) :- !.
truthLine_to_expr([any|Rest], Expr) :- !, truthLine_to_expr(Rest, Expr).
truthLine_to_expr([X], X) :- !.
truthLine_to_expr([X|Rest], and(X, RestExpr)) :- 
    truthLine_to_expr(Rest, RestExpr).
clean_list([], []).
clean_list([any|Rest], Clean) :- !, clean_list(Rest, Clean).
clean_list([X|Rest], [X|Clean]) :- clean_list(Rest, Clean).
build_master_formula([], false).
build_master_formula([M], Formula) :- 
    truthLine_to_expr(M, Formula).
build_master_formula([M1,M2|Rest], Formula) :-
    truthLine_to_expr(M1, E1),
    truthLine_to_expr(M2, E2),
    build_master_or(E1, E2, Rest, Formula).
build_master_or(E1, E2, [], or(E1, E2)).
build_master_or(E1, E2, [M|Rest], Formula) :-
    truthLine_to_expr(M, E3),
    build_master_or(or(E1, E2), E3, Rest, Formula).
find_prime_implicants(TruthLines, PrimeImplicants) :-
    findall(M-N-Combined,
        ( member(M, TruthLines), member(N, TruthLines), M \= N,
          differ_by_one(M, N, Combined),
          \+ (Combined = [any, any, any])
        ), Merges),
    ( Merges == [] ->
        PrimeImplicants = TruthLines
    ;
        findall(Mu, member(Mu-_-_, Merges), UsedM),
        findall(Nu, member(_-Nu-_, Merges), UsedN),
        append(UsedM, UsedN, UsedAll), sort(UsedAll, UsedSet),
        subtract(TruthLines, UsedSet, Unmerged),
        findall(C, member(_-_-C, Merges), Combined0),
        sort(Combined0, SortedCombined),
        find_prime_implicants(SortedCombined, NextPIs),
        append(Unmerged, NextPIs, PrimeImplicants0),
        sort(PrimeImplicants0, PrimeImplicants)
    ).
differ_by_one([], [], _) :- fail.
differ_by_one([Var|Rest], [not(Var)|Rest], [any|Rest]) :- !.
differ_by_one([not(Var)|Rest], [Var|Rest], [any|Rest]) :- !.
differ_by_one([X|Rest1], [X|Rest2], [X|Rest]) :-
    differ_by_one(Rest1, Rest2, Rest).
literal_member(Lit, [Lit|_]).
literal_member(Lit, [_|Rest]) :- literal_member(Lit, Rest).
covers([], _).
covers([any|Rest], TruthLine) :- 
    !, 
    covers(Rest, TruthLine).
covers([Lit|Rest], TruthLine) :-
    literal_member(Lit, TruthLine),
    covers(Rest, TruthLine).
build_coverage_table([], _, []).
build_coverage_table([PI|Rest], TruthLines, [PI-Covered|Table]) :-
    findall(M, (member(M, TruthLines), covers(PI, M)), Covered),
    build_coverage_table(Rest, TruthLines, Table).
select_essential(Table, TruthLines, Essential) :-
    select_essential_helper(Table, TruthLines, [], Essential).
select_essential_helper(_, [], Essential, Essential).
select_essential_helper(Table, RemainingTruthLines, Acc, Essential) :-
    ( find_essential_pi(Table, RemainingTruthLines, PI, NewRemaining, NewTable) ->
        select_essential_helper(NewTable, NewRemaining, [PI|Acc], Essential)
    ;
        find_best_pi(Table, RemainingTruthLines, PI, NewRemaining, NewTable),
        select_essential_helper(NewTable, NewRemaining, [PI|Acc], Essential)
    ).
find_essential_pi(Table, TruthLines, PI, NewTruthLines, NewTable) :-
    member(M, TruthLines),
    findall(PI, (member(PI-Covered, Table), member(M, Covered)), [PI]),
    select(PI-Covered, Table, NewTable),
    subtract(TruthLines, Covered, NewTruthLines).
find_best_pi(Table, TruthLines, PI, NewTruthLines, NewTable) :-
    findall(Count-PI-Covered, 
        ( member(PI-Covered, Table),
          intersection(Covered, TruthLines, CoveredNow),
          length(CoveredNow, Count),
          Count > 0
        ),
        Candidates),
    keysort(Candidates, Sorted),
    reverse(Sorted, [_-BestPI-BestCovered|_]),
    select(BestPI-BestCovered, Table, NewTable),
    intersection(BestCovered, TruthLines, CoveredNow),
    subtract(TruthLines, CoveredNow, NewTruthLines),
    PI = BestPI.
get_simplified_tabular(Expr, Vars, SimplifiedTabular) :-
    generate_combinations(Vars, Combs),
    collect_all_the_trues(Expr, Combs, Vars, TruthLines),
    ( TruthLines = [] -> SimplifiedTabular = false
    ; find_prime_implicants(TruthLines, PIs),
      build_coverage_table(PIs, TruthLines, CoverageTable),
      select_essential(CoverageTable, TruthLines, EssentialPIs),
      build_expression_from_pis(EssentialPIs, SimplifiedTabular)
    ).
build_expression_from_pis([], false).
build_expression_from_pis([PI|Rest], Result) :-
    delete(PI, any, Clean),
    list_to_and(Clean, ExprPart),
    (Rest == [] -> 
        Result = ExprPart
    ;   Result = or(ExprPart, RestExpr),
        build_expression_from_pis(Rest, RestExpr)
    ).
list_to_and([], true).
list_to_and([X], X) :- !.
list_to_and([X|Rest], and(X, Expr)) :- 
    list_to_and(Rest, Expr).
build_or_chain([], true).
build_or_chain([PI], Expr) :- 
    (PI == [] -> Expr = true ; truthLine_to_expr(PI, Expr)).
build_or_chain([PI|Rest], or(ExprPart, RestExpr)) :-
    (PI == [] -> ExprPart = true ; truthLine_to_expr(PI, ExprPart)),
    build_or_chain(Rest, RestExpr).
get_tabular_expression(Expr, Vars, TabularExpr) :-
    generate_combinations(Vars, Combs),
    collect_all_the_trues(Expr, Combs, Vars, TruthLines),
    build_master_formula(TruthLines, TabularExpr).
format_value(true) :- write('T').
format_value(false) :- write('F').
format_E(true) :- write(' T ').
format_E(false) :- write(' F ').
generate_row_formula([], []).
generate_row_formula([Var=true|Rest], [Var|RestFormula]) :-
    generate_row_formula(Rest, RestFormula).
generate_row_formula([Var=false|Rest], [not(Var)|RestFormula]) :-
    generate_row_formula(Rest, RestFormula).
format_formula([], '').
format_formula([X], Result):- format_term(X, Result).
format_formula([X|Rest], Result):- format_term(X, TermX), format_formula(Rest, RestStr),atomic_list_concat([TermX, ' and ', RestStr], Result).
format_term(Var, Var) :- atom(Var).
format_term(not(Var), Result):-atomic_list_concat(['not ', Var], Result).
%AND/E
evaluate(and(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( (ValA == true, ValB == true) -> Val = true ; Val = false ).
%OR/OU
evaluate(or(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( (ValA == true ; ValB == true) -> Val = true ; Val = false ).
%Implicacao%
evaluate(implies(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( (ValA == true, ValB == false) -> Val = false ; Val = true ).
%BICONDICIONAL:
evaluate(xnor(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( ValA == ValB -> Val = true ; Val = false ).
%xor
evaluate(xor(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( ValA \== ValB -> Val = true ; Val = false ).
%nand 
evaluate(nand(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( (ValA == true, ValB == true) -> Val = false ; Val = true ).
%nor
evaluate(nor(A, B), E, Val) :-
    evaluate(A, E, ValA), evaluate(B, E, ValB),
    ( (ValA == false, ValB == false) -> Val = true ; Val = false ).
%NOT
evaluate(not(Expr), E, Val) :-
    evaluate(Expr, E, ValExpr),
    ( ValExpr == true -> Val = false ; Val = true ).
evaluate(true, _, true).
evaluate(false, _, false).
%Variavel sozinha, basicamente a? então a = a. Papo de doido, tlg
evaluate(Var, E, Value) :-
    member(Var=Value, E).
%Fim da logica dos operadores
generate_combinations([], [[]]).
generate_combinations([Var|Vars], E) :-
    generate_combinations(Vars, Rest),
    add_values(Var, Rest, E).
add_values(_, [], []).
add_values(Var, [Combo|Rest], [[Var=true|Combo], [Var=false|Combo]|More]) :-
    add_values(Var, Rest, More).
%Daq pra baixo é só pra fazer o codigo "ler", isso é tipo o tokenizador, so q feito por alienigenas
find_vars(Term, Vars) :- %Essas 6 linhas substituiram + de 40... bizarro
    compound(Term),
    Term =.. [_|Args],
    maplist(find_vars, Args, VarsList),
    append(VarsList, VarsFlat),
    sort(VarsFlat, Vars).
find_vars(not(X), Vars) :- find_vars(X, Vars).
find_vars(X, [X]) :- atom(X), X \= true, X \= false.
find_vars(_, []).
find_vars(true, []).
find_vars(false, []).
find_vars(Var, [Var]):- %mANO prolog é mto estranho
    atom(Var), %Hmmm sim, essa variavel é uma variavel
    Var \= true,
    Var \= false.
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
%(Calculadora do Ezequias):- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
size(xnor(X, Y), Size) :- size(X, S1), size(Y, S2), Size is S1 + S2 + 1.
%-------------Regras de simplificação
%---- identidades
simplify(true, true).
simplify(not(false), true).
simplify(false, false).
simplify(not(true), false).
simplify(A or false, E) :-    simplify(A, E).
simplify(false or A, E) :-    simplify(A, E).
simplify(_ or true, true).
simplify(true or _, true).
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
simplify((A or (A and _)), E):- simplify(A, E). 
simplify((A or (_ and A)), E):- simplify(A, E). 
simplify(((A and _) or A), E):- simplify(A, E). 
simplify(((_ and A) or A), E):- simplify(A, E). 
simplify((A and (A or _)), E):- simplify(A, E). 
simplify((A and (_ or A)), E):- simplify(A, E). 
simplify(((A or _) and A), E):- simplify(A, E). 
simplify(((_ or A) and A), E):- simplify(A, E). 
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
simplify((A and (A or _)), E) :- simplify(A, E).
simplify(((A or _) and A), E) :- simplify(A, E).
simplify((A and (_ or A)), E) :- simplify(A, E).
simplify(((_ or A) and A), E) :- simplify(A, E).

simplify((A or (A and _)), E) :- simplify(A, E).
simplify(((A and _) or A), E) :- simplify(A, E).
simplify((A or (_ and A)), E) :- simplify(A, E).
simplify(((_ and A) or A), E) :- simplify(A, E).
simplify(A and true, E) :-       simplify(A, E).
simplify(true and A, E) :-       simplify(A, E).
simplify(false or A, E) :-       simplify(A, E).
simplify(A or false, E) :-       simplify(A, E).
simplify(_ and false, false).
simplify(false and _, false).
simplify(true or _, true).
simplify(_ or true, true).
%------- Equivalencias
simplify((implies(A, B) and implies(B, A)), xnor(SA, SB)):- simplify(A, SA), simplify(B, SB).
simplify(((not(A) or B) and (not(B) or A)), xnor(SA, SB)):- simplify(A, SA), simplify(B, SB).
%Implicação
simplify((not(A) or B), implies(SA, SB)):- simplify(A, SA), simplify(B, SB).
simplify((A or not(B)), implies(SB, SA)):- simplify(B, SB), simplify(A, SA).
%xor
simplify((or(A, B) and not(and(A, B))), xor(SA, SB)):- simplify(A, SA), simplify(B, SB).
simplify((not(and(A, B)) and or(A, B)), xor(SA, SB)):- simplify(A, SA), simplify(B, SB).
%nand
simplify((not(A) or not(B)), nand(SA,SB)) :- simplify(A, SA), simplify(B, SB).
%nor
simplify((not(A) and not(B)), nor(SA,SB)) :- simplify(A, SA), simplify(B, SB).
simplify(not(not(A)), E) :- simplify(A, E).
simplify(not((A)), not(E)) :- simplify(A, E).

%----- Seção esquisita
simplify(xnor(A,B), xnor(SA,SB)) :- simplify(A, SA), simplify(B, SB) .% 3º hora mexendo nesse código... nada mais me impressiona
simplify(xor(A,B), xor(SA,SB)) :- simplify(A, SA), simplify(B, SB).
simplify(nand(A,B), nand(SA,SB)) :- simplify(A, SA), simplify(B, SB).
simplify(nor(A,B), nor(SA,SB)) :- simplify(A, SA), simplify(B, SB).
simplify(A and B, SA and SB) :- simplify(A, SA), simplify(B, SB).
simplify(A or B, SA or SB) :- simplify(A, SA), simplify(B, SB).
simplify(implies(A, B), implies(SA, SB)) :- simplify(A, SA), simplify(B, SB).
simplify(A, A) :- atom(A).

simplify_step(A, E) :-
    simplify_step_iterative(A, E, 10). %roda mais 10x só pra garantir
simplify_step_iterative(A, E, 0) :-
    simplify(A, E).  
simplify_step_iterative(A, E, N) :-
    N > 0,
    simplify(A, T),
    (A == T -> 
        E = T
    ; size(A, SA), size(T, ST),  (ST =< SA -> N1 is N - 1; N1 is N), %Roda  N vezes a mais depois de ter ficado do menor tamanho possivel
       
        simplify_step_iterative(T, E, N1)
    ).
