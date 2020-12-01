using DelimitedFiles #pacote necessário para passar os dados do txt p uma variável
using JuMP
using Cbc

#passando os dados da instancia.txt para uma variável
instancia = readdlm("instanciaPCP.txt", ' ',Float64)
print(size(instancia)) #checando se o tamnho passado para a array corresponde ao arquivo orginal

m = 100 #facilidades
n = 100 #clientes
p = 3 #3 ou #5 facilidades

matriz_dist = zeros(Float64,m,n) #é importante notar que essa matriz é espelhada
for i in 1:m
    for j in 1:n
        matriz_dist[i,j] =  sqrt((instancia[j,2]-instancia[i,2])^2 + (instancia[j,3]-instancia[i,3])^2)
    end
end

init_time = time_ns()

model = Model(Cbc.Optimizer)
set_optimizer_attribute(model, "seconds", 120)
#_________________________________________________________

#definindo as variáveis
@variable(model, x[i in 1:m, j in 1:n], Bin)
@variable(model, y[i in 1:m], Bin)
@variable(model, z)
#_________________________________________________________

#definindo as restrições
#p facilidades serão atendidas
@constraint(model, sum(y[i] for i in 1:m) == p)

#cada cliente é atendido por uma única facilidade
for j in 1:m
    @constraint(model, sum(x[i,j] for i in 1:n) == 1)
end

#cada cliente j só pode ser designado a uma facilidade
for i in 1:m
    for j in 1:n
        @constraint(model, x[i,j] <= y[i])
    end
end

#z
for j in 1:n
    @constraint(model, sum(matriz_dist[i,j]*x[i,j] for i in 1:m) <= z)
end
#_________________________________________________________

#definindo a função objetivo
@objective(model, Min, z)
#_________________________________________________________

optimize!(model)

elapsed_time = (time_ns() - init_time) * 1e-9

status = termination_status(model)
println("STATUS: ", status, " ---------------------------")

solvalue = objective_value(model)
p_centros = Int64[]
if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
	for i in 1:m
		if JuMP.value(y[i]) == 1
			push!(p_centros, i)
		end
	end
	sort!(p_centros)

else
	println("no solution has been found")
end

println("Problema de localização de facilidades, código 1")
println("Para p = $p, os p-centros são: $p_centros")
println("Suas localizações são:")
for i in 1:p
	t = p_centros[i]
	println(t, ": ", "x=", instancia[t,2], " y=", instancia[t,3])
end
println("O valor da solução ótima é $solvalue")
print("O tempo de execução foi $(round(elapsed_time; digits=4))")
