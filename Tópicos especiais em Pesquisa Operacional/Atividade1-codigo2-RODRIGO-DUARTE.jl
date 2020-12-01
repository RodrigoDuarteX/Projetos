using JuMP
using Cbc

n = 12 #número de variáveis, m * n
#número de origens = 4
#número de destinos = 3
model = Model(Cbc.Optimizer)

oferta = [433, 215, 782, 300]
demanda = [697, 421, 612]
custo = [30 13 21; 12 40 26; 27 15 35; 37 25 19]

#definindo as variáveis
@variable(model, x[i in 1:4, j in 1:3] >= 0, Int)

#restrição de oferta
for i in 1:4
	@constraint(model, sum(x[i, j] for  j in 1:3) <= oferta[i])
end

#definindo as restrições de demanda
for j in 1:3
	@constraint(model, sum(x[i, j] for i in 1:4) == demanda[j])
end

#definindo a função objetivo
@objective(model, Min, sum(custo[i,1]*x[i,1] for i in 1:4) + sum(custo[i,2]*x[i,2] for i in 1:4) + sum(custo[i,3]*x[i,3] for i in 1:4))

optimize!(model)

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
solvariables = zeros(Int64,4,3) #criando uma array ?
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for i in 1:4
		for j in 1:3
			solvariables[i, j] = value.(x[i,j])
		end
	end

else
	println("no solution has been found")
end

#Printing solution to the screen -------------------------------------------------------------------------------------
println("Solution Cost: ", solvalue)
print("Solution Variables: \n")
for i in 1:4
	for j in 1:3
		println("x[$i,$j]: ", JuMP.value(x[i,j]))
	end
end

#Printing solution to a file -----------------------------------------------------------------------------------------
io = open("output/problema_transporte_2.4.txt", "a") #parametros: "w", "r", "a", "w+", "r+", "a+"; write = true; append=true; only read; etc.
write(io, "Problema de transporte, exemplo 2.4\n")
write(io, "Solution Cost: $solvalue\n")
write(io, "Solution Variables: \n")
for i in 1:4
	for j in 1:3
		write(io, "x[$i,$j]: \n", solvariables[i, j])
	end
end
write(io, "---------------------------------------------------\n")
close(io)
