#problema de partição - exemplo 3.10

using JuMP
using Cbc

model = Model(Cbc.Optimizer)

n = 6 #número de voos
m = 24

sj=[1 0 1 0 1 0; # a ordem importa?
    1 0 1 0 0 1;
    1 0 0 1 1 0;
    1 0 0 1 0 1;
    0 1 1 0 1 0;
    0 1 1 0 0 1;
    0 1 0 1 1 0;
    0 1 0 1 0 1;
    1 0 1 0 1 0;
    0 1 1 0 1 0;
    1 0 1 0 0 1;
    0 1 1 0 0 1;
    1 0 0 1 1 0;
    0 1 0 1 1 0;
    1 0 0 1 0 1;
    0 1 0 1 0 1;
    1 0 1 0 1 0;
    1 0 0 1 1 0;
    0 1 1 0 1 0;
    0 1 0 1 1 0;
    1 0 1 0 0 1;
	1 0 0 1 0 1;
    0 1 1 0 0 1;
    0 1 0 1 0 1]

c = [20 , 16, 17, 18, 20, 13, 14, 15, 20, 21, 31, 15, 11, 43, 54, 45, 34, 23, 34, 12, 34, 11, 43, 12]

#definindo as variáveis
@variable(model, x[j in 1:m], Bin)

#restriçôes
#utilizando matriz transposta
transposta = transpose(sj)
for i in 1:n
    @constraint(model, sum(transposta[i, j]*x[j] for j in 1:m) == 1)
end

#utilizando uma transformação manual
#voo = zeros(Int64,6,24)
#for j in 1:6
    #for i in 1:24
        #if sj[i,j] == 1
            #voo[j, i] = sj[i,j]
        #else
            #voo[j, i] = sj[i,j]
        #end
    #end
#end


#definindo a função objetivo
@objective(model, Min, sum(x[j]*c[j] for j in 1:m))

print(model)
optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64, m)
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for j in 1:m
		solvariables[j] = JuMP.value(x[j])
	end

else
	println("no solution has been found")
end

println("Problema de partição, exemplo 3.10")
println("Custo da solução: ", solvalue)
print("Solução das variáveis: \n")
for j in 1:m
	println("x[$j]: ", solvariables[j])
end
