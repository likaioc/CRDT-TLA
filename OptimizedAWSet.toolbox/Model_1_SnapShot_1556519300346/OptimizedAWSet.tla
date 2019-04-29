--------------------------- MODULE OptimizedAWSet ---------------------------
EXTENDS Naturals, Sequences
-----------------------------------------------------------------------------
CONSTANTS
    Data,
    Replica
    
VARIABLES
    aSet,
    seq,
    vc,
    incoming,  \* network variable
    msg,       \* network variable
    updateset  \* network variable

vars == <<aSet, seq, vc, incoming, msg, updateset>>
----------------------------------------------------------------------------- 
Vector == [Replica -> Nat]
Initvector == [r \in Replica |-> 0]
Instance == [d: Data, r: Replica, k: Nat]
Msg == [r : Replica, seq : Nat, vc: Vector, A: SUBSET Instance]
----------------------------------------------------------------------------- 
Network == INSTANCE Network
-----------------------------------------------------------------------------    
TypeOK == 
    /\ Network!NInit
    /\ aSet \in [Replica -> SUBSET Instance]
    /\ seq \in [Replica -> Nat]
    /\ vc \in [Replica -> Vector]
    
-----------------------------------------------------------------------------
Init == 
    /\ aSet = [r \in Replica |-> {}]
    /\ seq = [r \in Replica |-> 0]
    /\ vc = [r \in Replica |-> Initvector]          
-----------------------------------------------------------------------------
Add(d, r) == 
    /\ seq' = [seq EXCEPT ![r] = @ + 1]
    /\ LET D == {ins \in aSet[r] : ins.d = d}
       IN aSet'= [aSet EXCEPT ![r] = (@ \cup {[d |-> d, r |-> r, k |-> vc[r][r]+1]}) \D]
    /\ vc' = [vc EXCEPT ![r][r] = @ + 1]
    /\ UNCHANGED <<incoming, msg, updateset>>

Remove(d, r) ==
    /\ seq' = [seq EXCEPT ![r] = @ + 1]
    /\ LET D == {ins \in aSet[r] : ins.d = d}
       IN   aSet' = [aSet EXCEPT ![r] = @ \ D]
    /\ UNCHANGED <<vc, incoming, msg, updateset>>
-----------------------------------------------------------------------------
Send(r) == 
    /\ Network!NBroadcast(r, [r |-> r, seq |-> seq[r], vc|-> vc[r], A|-> aSet[r] ])  
    /\ UNCHANGED <<aSet, seq>>
    
SetMax(r, s) == IF r > s THEN r ELSE s      
    
Deliver(r) == 
    /\ Network!NDeliver(r)
    /\ LET D1 == {ins \in aSet - msg[r]'.A : ins.k <= msg[r]'.vc[r]}
           D2 == {ins \in msg[r]'.A - aSet : ins.k <= vc[r][r]}
           A1 == aSet \ D1
           A2 == msg[r]'.A \ D2
       IN  aSet' = [aSet EXCEPT ![r] = A1 \cup A2]    
    /\ \A s \in Replica : vc' = [vc EXCEPT ![r][s] = SetMax(@, msg'[r].vc[s])]         
    /\ UNCHANGED <<seq>>                    
-----------------------------------------------------------------------------
Next ==
    \/ \E r \in Replica: \E a \in Data: 
        Add(a, r) \/ Remove(a, r)
    \/ \E r \in Replica: 
        Send(r) \/ Deliver(r)

Spec == Init /\ [][Next]_vars \* /\ WF_vars(Next)
-----------------------------------------------------------------------------
Read(r) == {ins.d: ins \in aSet[r]}

(* QC: Quiescent Consistency *)
Quiescence == 
    \A r \in Replica: incoming[r] = <<>>
    
Convergence == 
    \A r, s \in Replica: Read(r) = Read(s)

QC == Quiescence => Convergence

=============================================================================
\* Modification History
\* Last modified Mon Apr 29 14:25:02 CST 2019 by jywellin
\* Created Sun Apr 28 13:52:27 CST 2019 by jywellin
