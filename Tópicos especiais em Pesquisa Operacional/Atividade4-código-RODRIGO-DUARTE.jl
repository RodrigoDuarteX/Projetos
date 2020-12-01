using JuMP
using Cbc

matriz_dist = [0 88 97 110 127 136 114 95 82 76;
               88 0 25 51 77 58 31 8 26 52;
               97 25 0 26 51 39 20 27 51 77;
               110 51 26 0 26 33 34 52 76 102;
               127 77 51 26 0 44 57 78 102 127;
               136 58 39 33 44 0 27 55 82 109;
               114 31 20 34 57 27 0 27 55 82;
               95 8 27 52 78 55 27 0 27 55;
               82 26 51 76 102 82 55 27 0 27;
               76 52 77 102 127 109 82 55 27 0]

n = 10 #cidades

model = Model(Cbc.Optimizer)

#definando as variáveis de decisão
@variable(model, x[i in 1:n, j in 1:n] >= 0, Bin)
#váriavel que representa a ordem de visia, começa no 2
@variable(model, u[i = 2:n] >= 0, Int)

#definindo as restrições
for i in 1:n
	@constraint(model, sum(x[i,j] for j in 1:n) == 1)
end

for j in 1:n
    @constraint(model, sum(x[i,j] for i in 1:n) == 1)
end

#necessário, pois as restrições acima necesitam que i seja diferente de j
for i in 1:n
	for j in 1:n
		if i == j
			@constraint(model, x[i,j] == 0)
		end
	end
end

#eliminação de sub=rotas,
for i in 2:n
        for j in 2:n
                if i != j
                    @constraint(model, u[i] - u[j] + n*x[i,j] <= n - 1)
                end
        end
end
for i in 2:n #eliminação de sub=rotas,
    @constraint(model, u[i] >= 1)
end

for i in 2:n
    @constraint(model, u[i] <= n)
end
#_________________________________________________________

#definindo a função objetivo
@objective(model, Min, sum(sum(matriz_dist[i,j]*x[i,j] for j=1:n) for i=1:n))

optimize!(model)

valor_da_solucao = objective_value(model)

variaveis = zeros(Bool, n, n)

for i in 1:n
	for j in 1:n
		variaveis[i,j] = value.(x[i,j])
	end
end

println("Problema de caixeiro viajante")
println("Custo mínimo: ", valor_da_solucao)
print("Variáveis de decisão (Rota): \n")
for i in 1:n
	for j in 1:n
		if variaveis[i,j] == 1
			println("x[", i, ",", j, "]: ", variaveis[i,j])
		end
	end
end
