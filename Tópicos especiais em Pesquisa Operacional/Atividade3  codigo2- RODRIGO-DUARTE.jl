using DelimitedFiles #pacote necessário para passar os dados do txt p uma variável
using JuMP
using Cbc

#passando os dados da instancia.txt para uma variável
instancia = readdlm("instanciaPCP.txt", ' ',Float64)
print(size(instancia)) #checando se o tamnho passado para a array corresponde ao arquivo orginal

m = 100 #facilidades
n = 100 #clientes
p = 2 #3 ou #5 facilidades

matriz_dist = zeros(Float64,m,n) #é importante notar que essa matriz é espelhada
for i in 1:m
    for j in 1:n
        matriz_dist[i,j] =  sqrt((instancia[j,2]-instancia[i,2])^2 + (instancia[j,3]-instancia[i,3])^2)
    end
end

#definindo o vetor distancia
vetor_dist = Float64[]
for i in 1:m
    for j in 1:n
        if matriz_dist[i,j] != 0
            push!(vetor_dist, matriz_dist[i,j])
        end
    end
end
unique!(vetor_dist)
sort!(vetor_dist)
f = length(vetor_dist)
#_________________________________________________________

init_time = time_ns()
for z in 1:f
    r = vetor_dist[z]
    a = zeros(Int64,m,n)
    for i in 1:m
        for j in 1:n
            if matriz_dist[i,j] <= r
                a[i,j] = 1
            end
        end
    end
    #_________________________________________________________
    model = Model(Cbc.Optimizer)
    #_________________________________________________________

    #definindo as variáveis
    @variable(model, y[i in 1:m], Bin)
    #________________________________________________________

    #definindo as restrições
    #conjunto de clientes atendidos pela facilidade com r
    for j in 1:n
        @constraint(model, sum(a[i,j]*y[i] for i in 1:m)>= 1 )
    end
    #_________________________________________________________

    #definindo a função objetivo
    @objective(model, Min, sum(y[i] for i in 1:m))
    #_________________________________________________________
    optimize!(model)

    if objective_value(model) <= p
        elapsed_time = (time_ns() - init_time) * 1e-9
        p_centros = Int64[]
        for i in 1:m
        	if value.(y[i]) == 1
        		push!(p_centros, i)
        	end
        end
        sort!(p_centros)

        println("Problema de localização de facilidades, código 2")
        println("Para p = $p, os p-centros são: $p_centros")
        println("Suas localizações são:")
        for i in 1:p
        	t = p_centros[i]
        	println(t, ": ", "x=", instancia[t,2], " y=", instancia[t,3])
        end
        println("O valor da solução ótima é ", r)
        println("O número de iterações foi de $z")
        print("O tempo de execução foi $(round(elapsed_time; digits=4))")
        break
    end
end
