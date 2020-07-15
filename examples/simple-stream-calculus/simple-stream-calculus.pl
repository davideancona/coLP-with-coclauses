:- use_module(folder(meta_interpreter)).

%%% concat(W1,W2,W): concatenation of possibly infinite words
%%%                  W is the concatenation of W1 and W2
concat([],W,W). 
concat([X|W1],W2,[X|W]) :- concat(W1,W2,W).
%%% eval(T,R,S): evaluation of expression T produces result R and stream S
%                R = end, div 
eval(skip,end,[]). 
eval(out(X),end,[X]). 
eval(seq(T1,T2),R,S) :- eval(T1,end,S1), eval(T2,R,S2), concat(S1,S2,S). 
eval(seq(T1,_T2),div,S) :- eval(T1,div,S). 

%co(concat(W,_,W)).       %% cofact 
co(eval(_T,div,[])). 
co(eval(seq(T1,_T2),div,S)) :- eval(T1,end,[X|S1]), concat([X|S1],_S2,S). 

%%% tests
%%% commented tests fail, because the interpreter is not complete
main :-
    test_true01,
    test_true02,
    test_true03, 
    test_true04, 
    test_false01, 
    test_false02, 
    test_false03, 
    !,
    write('All tests passed').

main :- write('Failed test').

%%% tests 

test_true01 :- solve(eval(seq(out(0),skip),end,[0])).

test_true02 :- T = seq(T,T), solve(eval(T,div,[])). 

test_true03 :- T = seq(out(1),T), S = [1|S], solve(eval(T,div,S)). 

test_true04 :- T = seq(T,out(1)), solve(eval(T,div,[])).

test_false01 :- T = seq(skip,T), S = [1|S], solve(eval(T,div,S)),!,fail. 
test_false01. 

test_false02 :- T = seq(T,T), S = [1|S], solve(eval(seq(print(1),T),div,S)),!,fail. 
test_false02. 

test_false03 :- T = seq(T,out(1)), solve(eval(T,_,[1])),!,fail. 
test_false03. 


