:- use_module(folder(meta_interpreter)).

%%% concat(W1,W2,W): concatenation of possibly infinite words
%%%                  W is the concatenation of W1 and W2
concat([],W,W). 
concat([X|W1],W2,[X|W]) :- concat(W1,W2,W).
%%% match(W,R): possibly infinite word W matches expression R
match([],eps).
match([0],0).
match([1],1).
match(W,plus(R1,_))   :- match(W,R1).
match(W,plus(_,R2))   :- match(W,R2).
match(W,cat(R1,R2))   :- match(W1,R1), concat(W1,W2,W), match(W2,R2). 
match(W,star(R))      :- match_star(N,W,R). 
match([],omega(R))    :- match([],R). 
match([B|W],omega(R)) :- match([B|W1],R), concat(W1,W2,W), match(W2,omega(R)). 
%%% match_star(N,W,R) : W can be decomposed in N parts all matching R
match_star(0,[],_). 
match_star(s(N),W,R)  :- match(W1,R), concat(W1,W2,W), match_star(N,W2,R). 

co(concat(W,_,W)).       %% cofact 
%co(match([],omega(R))).  %% cofact
%co(match(W,omega(R))) :- match([B|W1],R), concat([B|W1],W2,W). 
co(match(W,omega(R))). 

%%% tests
%%% commented tests fail, because the interpreter is not complete
main :-
    test_true01,
%    test_true02,
    test_true03,
    test_true04,
%    test_true05,
    test_true06,
    test_false01,
    test_false02,
    test_false03,
    test_false04,
    test_false05,
    test_false06,
    test_false07,
    test_false08, 
    !,
    write('All tests passed').

main :- write('Failed test').

%%% tests in the paper

test_true01 :- W0=[0|W0], solve(match(W0,omega(0))).

test_true02 :- W1=[1|W1], solve(match([1,1,0|W1],cat(cat(star(1),0),omega(1)))).

test_true03 :- solve(match([1,1],omega(plus(eps,1)))).

test_true04 :- W1=[1|W1], solve(match(W1,omega(plus(eps,1)))).

test_false01 :- W1=[1|W1], solve(match(W1,star(1))), !, fail.
test_false01.

test_false02 :- W1=[1|W1], solve(match(W1,omega(0))), !, fail.
test_false02.

test_false03 :- W1=[1|W1], solve(match(W1,cat(cat(star(1),0),omega(1)))), !, fail.
test_false03.

test_false04 :- W1=[1|W1], solve(match(W1,omega(eps))), !, fail.
test_false04.

%%% additional tests

test_true05 :- W01=[0,1|W01], solve(match(W01,omega(cat(star(0),1)))).

test_true06 :- W0=[0|W0], solve(match(W0,cat(star(omega(cat(star(0),1) ) ) ,omega(0)))). 

test_false05 :- W0=[0|W0], solve(match([1,1,0,1|W0],cat(star(1),omega(0)))),!,fail. 
test_false05.

test_false06 :- W01=[0,1|W01], solve(match(W01,star(cat(omega(plus(eps,0)),1)))),!,fail.  %% counter-example for initially incorrect version
test_false06.

test_false07 :- W0=[0|W0], solve(match(W0,omega(cat(star(0),1)))),!,fail. 
test_false07.

test_false08 :- W0=[0|W0], solve(match([1|W0],omega(star(1)))),!,fail.
test_false08.



