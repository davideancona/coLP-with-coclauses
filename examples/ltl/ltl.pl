:- use_module(folder(meta_interpreter)).

%%% sat_exists(N,W,Ph): suffix at N of omega-word W satisfies Ph
sat_exists(0,W,Ph) :- sat(W,Ph).
sat_exists(s(N),[_B|W],Ph) :- sat_exists(N,W,Ph).
%%% sat_all(N,W,Ph): all suffixes of word W at index < N satisfy Ph
sat_all(0,_W,_Ph).
sat_all(s(N),[B|W],Ph) :- sat([B|W],Ph), sat_all(N,W,Ph).
%%% sat(W,Ph): omega-word W satisfies Ph
sat([0|_W],zero).
sat([1|_W],one).
sat([B|W],always(Ph)) :- sat([B|W],Ph), sat(W,always(Ph)).
sat([B|W],until(Ph1,Ph2)) :- sat_exists(N,[B|W],Ph2), sat_all(N,[B|W],Ph1).

co(sat(_W,always(_Ph))). %% cofact

%%% tests
main :-
    test_true01,
    test_true02,
    test_true03,
    test_true04,
    test_true05,
    test_false01,
    test_false02,
    test_false03,
    test_false04,
    test_false05,
    test_false06,
    test_false07,
    !,
    write('All tests passed').

main :- write('Failed test').

%%% tests in the paper

test_true01 :- W0=[0|W0], solve(sat(W0,always(zero))).

test_true02 :- W1=[1|W1], solve(sat([1,1,0|W1],until(one,zero))).

test_true03 :- W0=[0|W0], solve(sat([1,1|W0],until(one,always(zero)))).

test_false01 :- W1=[1|W1], solve(sat(W1,always(zero))), !, fail.
test_false01.

test_false02 :- W1=[1|W1], solve(sat(W1,until(one,zero))), !, fail.
test_false02.

test_false03 :- W1=[1|W1], solve(sat(W1,until(always(one),zero))), !, fail.
test_false03.

test_false04 :- W1=[1|W1], solve(sat(W1,until(always(one),always(zero)))), !, fail.
test_false04.

%%% additional tests

test_true04 :- W01=[0,1|W01], solve(sat(W01,always(until(zero,one)))).

test_true05 :- W0=[0|W0], solve(sat(W0,until(always(until(zero,one)),always(zero)))). 

test_false05 :- W0=[0|W0], solve(sat([1,1,0,1|W0],until(one,always(zero)))).
test_false05.

test_false06 :- W01=[0,1|W01], solve(sat(W01,until(always(until(zero,one),always(zero))))). %% counter-example for initially incorrect version
test_false06.

test_false07 :- W0=[0|W0], solve(sat(W0,always(until(zero,one)))).
test_false07.




