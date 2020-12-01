#problema de partição - exemplo 3.9

using JuMP
using Cbc

model = Model(Cbc.Optimizer)

c = [20 76 16 23 23 18]
n = 6
sj=[1 1 0 0 0 0;
    1 0 1 0 1 0;
    0 1 0 1 1 0;
    0 0 1 0 0 0;
    1 0 0 0 0 0;
    0 0 0 1 1 0]] #subconjunto a ordem é de subcojunto -> instância do conjunto


#definindo as variáveis
@variable(model, x[j in 1:n], Bin)

#restriçôes
for i in 1:m
    @constraint(model, sum(sj[i, j]*x[j] for j in 1:n) >= 1)
end

#definindo a função objetivo
@objective(model, Min, sum(x[j]*c[j] for j in 1:n))

print(model)
optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64, 6)
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for j in 1:n
		solvariables[j] = JuMP.value(x[j])
	end

else
	println("no solution has been found")
end

println("Problema de partição, exemplo 3.9")
println("Custo da solução: ", solvalue)
print("Solução das variáveis: \n")
for j in 1:n
	println("x[$j]: ", solvariables[j])
end
