----------------------------- MODULE OpCounter -----------------------------
EXTENDS 
    Naturals, Sequences, SEC

-----------------------------------------------------------------------------
VARIABLE 
    counter,
    buffer,
    seq,
    incoming,     \* network variable
    msg,          \* network variable
    messageset    \* network variable
    
vars == <<counter, buffer, seq, incoming, msg, messageset, SECvars>>

Msg == [r : Replica, update : SUBSET Update, seq : Nat, buf : Nat]
-----------------------------------------------------------------------------
(**********************************************************************)
(* Reliable Network                                                   *)
(**********************************************************************)
Network == INSTANCE ReliableNetwork
-----------------------------------------------------------------------------
TypeOK == 
    /\ counter \in [Replica -> Nat]
    /\ buffer \in [Replica -> Nat]
 
-----------------------------------------------------------------------------       
Init == 
    /\ Network!RInit
    /\ SECInit
    /\ seq = [r \in Replica |-> 0]
    /\ counter = [r \in Replica |-> 0]
    /\ buffer = [r \in Replica |-> 0]
     
Read(r) == counter[r]

Inc(r) == 
    /\ counter' = [counter EXCEPT ![r] = @ + 1]
    /\ buffer' = [buffer EXCEPT ![r] = @ + 1]
    /\ seq' = [seq EXCEPT ![r] = @ + 1]
    /\ SECUpdate(r, seq[r])
    /\ UNCHANGED <<incoming, msg, messageset>>

Send(r) ==  
    /\ buffer[r] # 0
    /\ buffer' = [buffer EXCEPT ![r] = 0]
    /\ Network!RBroadcast(r, [r |-> r, seq |-> seq[r], update|-> OpUpdate(r), buf |-> buffer[r]])
    /\ SECSend(r)
    /\ UNCHANGED <<counter, seq>>

Receive(r) == 
    /\ Network!RDeliver(r)
    /\ SECDeliver(r, msg'[r])
    /\ counter' = [counter EXCEPT ![r] = @ + msg'[r].buf]
    /\ UNCHANGED <<buffer, seq>>
-----------------------------------------------------------------------------                
Next == 
   \E r \in Replica: Inc(r) \/ Send(r)\/ Receive(r)
-----------------------------------------------------------------------------                   
Spec == Init /\ [][Next]_vars   
-----------------------------------------------------------------------------
EmptyBuffer == buffer = [r \in Replica |-> 0 ]
EC == Network!EmptyChannel /\ EmptyBuffer
            => \A r1, r2 \in Replica : counter[r1] = counter[r2]
            
SEC == \A r1, r2 \in Replica : Sameupdate(r1, r2)
            => counter[r1] = counter[r2]
=============================================================================
\* Modification History
\* Last modified Tue May 07 00:57:30 CST 2019 by xhdn
\* Last modified Mon May 06 15:51:30 CST 2019 by jywellin
\* Created Fri Mar 22 20:43:27 CST 2019 by jywellin
