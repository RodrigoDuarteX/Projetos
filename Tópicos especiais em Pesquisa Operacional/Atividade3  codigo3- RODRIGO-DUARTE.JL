using DelimitedFiles #pacote necessário para passar os dados do txt p uma variável
using JuMP
using Cbc

#passando os dados da instancia.txt para uma variável
instancia = readdlm("instanciaPCP.txt", ' ',Float64)
print(size(instancia)) #checando se o tamnho passado para a array corresponde ao arquivo orginal

m = 100 #facilidades
n = 100 #clientes
global p = 2 #3 ou #5 facilidades

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
global I = 1
global u = f
global iteracoes = 0
global p_centros = Int64[]
while I <= u
    global media = floor(Int64, (I + u)/2)
    r = vetor_dist[media]
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
        global u = m
    else
        global I = m + 1
    end
    global iteracoes += 1
    for i in 1:m
        if JuMP.value.(y[i]) == 1
            push!(p_centros, i)
        end
    end
end
elapsed_time = (time_ns() - init_time) * 1e-9
p_centros1 = Int64[]
global o = p
for i in 1:o
    push!(p_centros1, p_centros[length(p_centros) - o])
    global o -= i
end

println("Problema de localização de facilidades, código 2")
println("Para p = $p, os p-centros são: $p_centros1")
println("Suas localizações são:")
for i in 1:p
    t = p_centros1[i]
    println(t, ": ", "x=", instancia[t,2], " y=", instancia[t,3])
end
println("O valor da solução ótima é ", media)
println("O número de iterações foi de $iteracoes")
print("O tempo de execução foi $(round(elapsed_time; digits=4))")
