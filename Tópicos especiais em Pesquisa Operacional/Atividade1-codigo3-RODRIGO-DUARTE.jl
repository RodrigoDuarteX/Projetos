using JuMP
using Cbc

# problema de transbordo

n = 10 #número de variáveis, m * n


model = Model(Cbc.Optimizer)

oferta = [800, 1000]
demanda = [500, 400, 900]
custo = [1 3 0; 1 2 0; 1 3 3; 3 4 1]

#definindo as variáveis
@variable(model, x[i in 1:4, j in 1:7] >= 0, Int)

#restrição de oferta
for i in 1:2
	@constraint(model, sum(x[i, j] for  j in 3:4) <= oferta[i])
end

#definindo as restrições de demanda
for j in 1:3
	k = 5 + j -1
	@constraint(model, sum(x[i, k] for i in 3:4) == demanda[j])
end

#definindo as restrições de transbordo
@constraint(model, x[1,3] + x[2,3] == x[3,5] + x[3,6] + x[3,7])
@constraint(model, x[1,4] + x[2,4] == x[4,5] + x[4,6] + x[4,7])

#definindo a função objetivo
@objective(model, Min, x[1,3] + x[1,4]*3 + x[2,3] + x[2,4]*2 + x[3,5] + x[3,6]*3 + x[3,7]*3 + x[4,5]*3 + x[4,6]*4 + x[4,7])
print(model) #ver se o modelo está corretamente formulado
optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64,4,7) #criando uma array ?
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for i in 1:2
		for j in 3:4
			solvariables[i, j] = JuMP.value(x[i,j])
		end
	end
	for i in 3:4
		for j in 5:7
			solvariables[i, j] = JuMP.value(x[i,j])
		end
	end

else
	println("no solution has been found")
end

#Printing solution to the screen -------------------------------------------------------------------------------------
println("Solution Cost: ", solvalue)
print("Solução das variáveis: \n")
println("Solução Ótima da orgiem -> depósito:")
for i in 1:2
	for j in 3:4
		println("x[$i,$j]: ", solvariables[i, j])
	end
end

println("Solução Ótima do depósito -> destino:")
for k in index_k
	for j in 5:7
		println("x[$k,$j] = ", solvariables[i, j])
	end
end


#Printing solution to a file -----------------------------------------------------------------------------------------
io = open("output/problema_transporte_2.5.txt", "a") #parametros: "w", "r", "a", "w+", "r+", "a+"; write = true; append=true; only read; etc.
write(io, "Problema de transporte, exemplo 2.5\n")
write(io, "Solution Cost: $solvalue\n")
write(io, "Solução variáveis: \n")
write(io, "Solução Ótima da origem -> depósito: \n")
for i in 1:2
	for j in 3:4
		write(io, "x[$i,$j]: \n", solvariables[i, j])
	end
end

write(io, "Solução Ótima do depósito -> destino: \n")
for k in index_k
	for j in 5:7
		write(io, "x[$k,$j] = \n", solvariables[i, j])
	end
end

write(io, "---------------------------------------------------\n")
close(io)
