---- MODULE MC ----
EXTENDS OpCounter, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
r1, r2, r3
----

\* MV CONSTANT definitions Replica
const_1556525890848150000 == 
{r1, r2, r3}
----

\* SYMMETRY definition
symm_1556525890848151000 == 
Permutations(const_1556525890848150000)
----

\* CONSTANT definition @modelParameterDefinitions:0
CONSTANT def_ov_1556525890848152000
----
=============================================================================
\* Modification History
\* Created Mon Apr 29 16:18:10 CST 2019 by jywellin
