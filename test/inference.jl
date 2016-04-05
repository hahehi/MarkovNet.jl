using MarkovNet
#=
v1 = Variable("a", [1,2,3])
v2 = Variable("b", [2,3,4,5])
variables = [v1,v2]
f1 = Factor("fa", [v1], [1.0,1.0,1.0]) #[0.35,0.3,0.35]
f2 = Factor("fb", [v2], [1.0,1.0,1.0,1.0]) #[0.25,0.4,0.15,0.2]
f3 = Factor("fab", [v1,v2], [0.05 0.15 0.05 0.1; 0.05 0.1 0.1 0.05; 0.15 0.15 0 0.05])
factors = [f1,f2,f3]
thetas = [1.0,1.0,1.0]
=#
v1 = Variable("a", [1,2,3])
v2 = Variable("b", [2,3,4,5])
v3 = Variable("c", [3,4,5,6])
variables = [v1,v2,v3]
f1 = Factor("fa", [v1], [1.0,1.0,1.0]) #[0.35,0.3,0.35]
f2 = Factor("fb", [v2], [1.0,1.0,1.0,1.0]) #[0.25,0.4,0.15,0.2]
f3 = Factor("fab", [v1,v2], [0.05 0.15 0.05 0.1; 0.05 0.1 0.1 0.05; 0.15 0.15 0 0.05])
f4 = Factor("fac", [v1,v3], [0.1 0.0 0.1 0.15; 0.0 0.1 0.15 0.05; 0.2 0.1 0 0.05])
factors = [f3,f4]
thetas = [1.0,1.0]
#=
v1 = Variable("a", [1,2,3])
v2 = Variable("b", [2,3])
v3 = Variable("c", [3,4])
variables = [v1,v2,v3]
f1 = Factor("fabc", [v1,v2,v3], reshape([0.05,0.15,0.05,0.1,0.05,0.1,0.1,0.05,0.15,0.15,0,0.05],3,2,2))
factors = [f1]
thetas = [1.0]
=#

inference.init(variables, factors, thetas)

#println(BPInference.variables)
#println(BPInference.factors)
#println(BPInference.thetas)
#println(BPInference.varsnum)
#println(BPInference.facsnum)
#println(BPInference.edgesnum)
println(BPInference.msgedgearray)
println(BPInference.factorneighborsarray)
println(BPInference.variableneighborsarray)

println("----------BPInference initialized----------")

inference.run()

println(BPInference.msgedgearray)

println("----------BPInference message calculated----------")

inference.inference()

println("----------BPInference propability calculated----------")