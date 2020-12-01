using JuMP
using Cbc

# designação generaliza

m = 3 #agentes
n = 8 #tarefas
#i -> 3 e j ->8

model = Model(Cbc.Optimizer)

c = [16 62 3 92 88 65 67 47; 21 29 77 51 52 80 34 76; 20 23 42 41 25 5 88 43]
a = [30 66 16 84 52 61 31 52; 22 21 73 84 92 54 31 73; 22 53 38 62 85 65 33 30]
b = [200 210 190]

#definindo as variáveis
@variable(model, x[i in 1:3, j in 1:8] >= 0, Bin)

#restrição de tarega realizada por um único agente
for j in 1:n
    @constraint(model, sum(x[i, j] for  i in 1:m) == 1)
end

#restrição de tarega realizada por um único agente
for i in 1:m
    @constraint(model, sum(x[i, j]*a[i, j] for  j in 1:n) <= b[i])
end

#definindo a função objetivo
@objective(model, Min, sum( sum(c[i, j]*x[i, j] for j in 1:n) for i in 1:m))
print(model)
optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64,3,8)
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for i in 1:3
		for j in 1:8
			solvariables[i, j] = JuMP.value(x[i,j])
		end
	end

else
	println("no solution has been found")
end

#Printing solution to the screen -------------------------------------------------------------------------------------
println("Solution Cost: ", solvalue)
print("Solução das variáveis: \n")
for i in 1:3
	for j in 1:8
		println("x[$i,$j]: ", solvariables[i, j])
	end
end

#Printing solution to a file -----------------------------------------------------------------------------------------
io = open("output/problema_transporte_3.8.txt", "a") #parametros: "w", "r", "a", "w+", "r+", "a+"; write = true; append=true; only read; etc.
write(io, "Problema de transporte, exemplo 3.8\n")
write(io, "Solution Cost: $solvalue\n")
write(io, "Solucao variaveis: \n")
for i in 1:3
	for j in 1:8
		write(io, "x[$i,$j] =", solvariables[i, j])
	end
end

write(io, "---------------------------------------------------\n")
close(io)
