---- MODULE MC ----
EXTENDS OpCounter, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
r1, r2, r3
----

\* MV CONSTANT definitions Replica
const_1556525939064156000 == 
{r1, r2, r3}
----

\* SYMMETRY definition
symm_1556525939064157000 == 
Permutations(const_1556525939064156000)
----

\* CONSTANT definition @modelParameterDefinitions:0
CONSTANT def_ov_1556525939064158000
----
=============================================================================
\* Modification History
\* Created Mon Apr 29 16:18:59 CST 2019 by jywellin
