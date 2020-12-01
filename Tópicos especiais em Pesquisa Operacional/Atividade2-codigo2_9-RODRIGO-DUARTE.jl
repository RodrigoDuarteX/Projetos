using JuMP
using Cbc

#problema de corte 2.9

model = Model(Cbc.Optimizer)

L = 400
T = 1

#demanda
m = 4 #i
l = [40/400, 45/400, 55/400, 60/400] #larguras
b = [5, 3.5, 4, 5] #quantidades

#padrões de corte
a = [10 0 0 0; 1 8 0 0; 0 0 7 0; 1 0 0 6; 0 4 4 0; 0 0 4 3]
n = 6 #j

#definindo as variáveis
@variable(model, x[1, j in 1:n] >= 0, Int)

#restriçôes
for i in 1:m
    @constraint(model, sum((a[j, i]*l[i])*x[1, j] for j in 1:n) >= b[i])
end

#definindo a função objetivo
@objective(model, Min, sum( x[1, j] for j in 1:n))

print(model)
optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64, 1, n)
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for j in 1:n
		solvariables[j] = JuMP.value(x[1, j])
	end

else
	println("no solution has been found")
end

#Printing solution to the screen -------------------------------------------------------------------------------------
println("Solution Cost: ", solvalue)
print("Solução das variáveis: \n")
for j in 1:n
	println("x[$j]: ", solvariables[1, j])
end

#Printing solution to a file -----------------------------------------------------------------------------------------
io = open("output/problema_corte_2_9.txt", "a") #parametros: "w", "r", "a", "w+", "r+", "a+"; write = true; append=true; only read; etc.
write(io, "Problema de corte, exemplo 2.9\n")
write(io, "Custo da solução: $solvalue\n")
write(io, "Solucao variaveis: \n")
for j in 1:n
	write(io, "x[$j] = ", solvariables[1, j])
end

println(io, "---------------------------------------------------\n")
close(io)
