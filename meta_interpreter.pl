%%%% meta-interpreter for generalized inference systems with corules
%%%% February 2017, DIBRIS, University of Genoa
%%%% Updated by Pietro Barbieri and Francesco Dagnino, June 2019

:- module(meta_interpreter,[solve/1]).

:- use_module(library(assoc)). %%% needed to keep track of atom occurrences for finite failure 

solve(Goal) :- solve_gfp([],Goal). %%% (main)

%%% solver for the inductive system with corules

solve_lfp(AtomAssoc, (Goal1,Goal2)) :- !,solve_lfp(AtomAssoc, Goal1), solve_lfp(AtomAssoc,Goal2). %%% seq
solve_lfp(_,Atom) :- predefined(Atom),!,Atom. %%% predef
solve_lfp(AtomAssoc,Atom):- find(Atom,AtomAssoc,Count), (Count<2 -> clause(co(Atom),Body),solve_lfp(AtomAssoc,Body);!,fail).  %%% cut
solve_lfp(AtomAssoc,Atom):- clause(Atom,Body),insert(Atom,AtomAssoc,NewAtomAssoc),solve_lfp(NewAtomAssoc,Body). %%% step
%%% solver for the coinductive system with no corules

solve_gfp(AtomList, (Goal1,Goal2)) :- !,solve_gfp(AtomList, Goal1), solve_gfp(AtomList,Goal2). %%% co-seq
solve_gfp(_,Atom) :- predefined(Atom),!,Atom. %%% co-predef
solve_gfp(AtomList,Atom):- co_find(Atom, AtomList),!,empty_assoc(EmptyAssoc),solve_lfp(EmptyAssoc,Atom). %%% co-hyp
solve_gfp(AtomList,Atom):- clause(Atom,Body),co_insert(Atom,AtomList,NewAtomList),solve_gfp(NewAtomList,Body). %%% co-step

%%% predefined predicates are interpreted in the standard way

predefined(Atom) :- predicate_property(Atom,built_in),!.
predefined(Atom) :- predicate_property(Atom,file(AbsPath)),file_name_on_path(AbsPath,library(_)),!.

%%% auxiliary predicates for the coinductive solver

co_find(Atom,AtomList) :- member(Atom,AtomList).

co_insert(Atom,AtomList,[Atom|AtomList]).  

%%% auxiliary predicates for the inductive solver

%%% finds if AtomAssoc contains an AtomKey unifiable with Atom, but does not perform unification; if so, returns its corresponding hit count
%%% used by the inductive solver

find(Atom,AtomAssoc,Count) :- retrieve(Atom,AtomAssoc,AtomKey), get_assoc(AtomKey,AtomAssoc,Count).

%%% retrieve the AtomKey in AtomAssoc which is unifiable with Atom; no unification is performed
%%% used by found

retrieve(Atom,AtomAssoc,AtomKey) :- assoc_to_keys(AtomAssoc,AtomKeyList),get(Atom,AtomKeyList,AtomKey).

%%% checks if Atom is unifiable with an atom in AtomList; if so, returns such an atom. No unification is performed
%%% used by retrieve

get(Atom,[UnifiableAtom|_],UnifiableAtom) :- unifiable(Atom,UnifiableAtom,_),!. 
get(Atom,[_|AtomList],UnifiableAtom) :- get(Atom,AtomList,UnifiableAtom). 

%%% insertion in the list of visited atoms when implementing the inductive solver
%%% keeps track of how many times an atom has been hit

insert(Atom,AtomAssoc,NewAtomAssoc) :- 
    retrieve(Atom,AtomAssoc,AtomKey) -> 
	get_assoc(AtomKey,AtomAssoc,Counter), IncCounter is Counter+1,put_assoc(AtomKey,AtomAssoc,IncCounter,NewAtomAssoc); 
        copy_term(Atom,CopiedAtom),put_assoc(CopiedAtom,AtomAssoc,1,NewAtomAssoc).
