include("../src/MarkovNet.jl")
using MarkovNet

## test1:
#=
v1 = MarkovNet.Variable("a", [1,2,3])
v2 = MarkovNet.Variable("b", [2,3,4,5])
variables = [v1,v2]
f1 = MarkovNet.Factor("fa", [v1], [1.0,1.0,1.0]) #[0.35,0.3,0.35]
f2 = MarkovNet.Factor("fb", [v2], [1.0,1.0,1.0,1.0]) #[0.25,0.4,0.15,0.2]
f3 = MarkovNet.Factor("fab", [v1,v2], [0.05 0.15 0.05 0.1; 0.05 0.1 0.1 0.05; 0.15 0.15 0 0.05])
factors = [f1,f2,f3]
thetas = [1.0,1.0,1.0]
=#

## test2:
v1 = MarkovNet.Variable("a", [1,2,3])
v2 = MarkovNet.Variable("b", [2,3,4,5])
v3 = MarkovNet.Variable("c", [3,4,5,6])
variables = [v1,v2,v3]
f1 = MarkovNet.Factor("fa", [v1], [1.0,1.0,1.0]) #[0.35,0.3,0.35]
f2 = MarkovNet.Factor("fb", [v2], [1.0,1.0,1.0,1.0]) #[0.25,0.4,0.15,0.2]
f3 = MarkovNet.Factor("fab", [v1,v2], [0.05 0.15 0.05 0.1; 0.05 0.1 0.1 0.05; 0.15 0.15 0 0.05])
f4 = MarkovNet.Factor("fac", [v1,v3], [0.1 0.0 0.1 0.15; 0.0 0.1 0.15 0.05; 0.2 0.1 0 0.05])
factors = [f3,f4]
thetas = [1.0,1.0]

## test3:
#=
v1 = MarkovNet.Variable("a", [1,2,3])
v2 = MarkovNet.Variable("b", [2,3])
v3 = MarkovNet.Variable("c", [3,4])
variables = [v1,v2,v3]
f1 = MarkovNet.Factor("fabc", [v1,v2,v3], reshape([0.05,0.15,0.05,0.1,0.05,0.1,0.1,0.05,0.15,0.15,0,0.05],3,2,2))
factors = [f1]
thetas = [1.0]
=#

MarkovNet.bpinference(variables, factors, thetas)