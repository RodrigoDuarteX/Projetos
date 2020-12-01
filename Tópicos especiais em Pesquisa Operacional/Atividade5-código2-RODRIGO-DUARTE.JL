using JuMP, Cbc, DataFrames, Gadfly, Cairo, Fontconfig

m = 3 #número de máquinas
n = 21 #número de tarefas
p = [2 1 9 7 5 7 3 4 5 8 6 4 3 2 2 1 4 3 5 5 3] #tempo de processamento das tarefas

#criando o intervalo
lb = sum(p[j] for j in 1:n)/m
lb = floor(Int64, lb)
ub = sum(p[j] for j in 1:n)
ub = floor(Int64, ub)

seq = zeros(Int64, ub - lb) #vetor começando do index 1 - 29 com valores 0
for k in lb:ub
    if k != ub
        seq[k+1-lb] = k
    else
        seq[k-lb] = k
    end
end

k = length(seq)

for t in 1:k
	cap = seq[t]
	model = Model(Cbc.Optimizer)

	#definando as variáveis de decisão
	@variable(model, x[i in 1:n, j in 1:m] >= 0, Bin)
	@variable(model, y[i in 1:n] >=0, Bin)
	#_________________________________________________________

	#definindo as restrições
	for i in 1:n
		@constraint(model, sum(x[i,j] for j in 1:m) == 1)
	end

	#restrição do makespan
	for i in 1:n
		@constraint(model, cap*y[i] - sum(p[i]*x[i,j] for j in 1:m) >= 0)
	end

	#_________________________________________________________

	#definindo a função objetivo
	@objective(model, Min, sum(y[i] for i in 1:n))
	#_________________________________________________________

	optimize!(model)

	valor_da_solucao = objective_value(model) #Cmax, valor ótimo da solução
	global variaveis = zeros(Bool, n, m)
	if valor_da_solucao <= t
		for i in 1:n
			for j in 1:m
				variaveis[i,j] = value.(x[i,j])
			end
		end
		println("Problema de sequenciamento, busca linear")
		println("Valor Ótimo: ", seq[t]) #valor do Cmax
		print("Variáveis de decisão: \n")
		for j in 1:m
			for i in 1:n
				if variaveis[i,j] == 1
					println("máquina ", j, " tarefa ", i)
				end
			end
		end
		break
	end
end
#_________________________________________________________

								#Gráfico
#realizar código para calcular o inicio e o fim do tempo de cada tarefa
auxiliar = sum(x->x>0, variaveis, dims=1) #realiza a contagem de quantas tarefas tem para cada máquina
tempos_máquina_inicial = Vector{Int64}()
tempos_máquina_final = Vector{Int64}()
#variaveis é a array contendo os valores do modelo, roda o código do modelo e ela vai ficar salva na memória do programa, ai roda esse programa
for j in 1:3 #existe um tempo de termino e inicio para cada máquina
    for i in 1:21
        if length(tempos_máquina_inicial) == 0
            if variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999
                append!(tempos_máquina_inicial, 0)
                append!(tempos_máquina_final, p[i])
            end
        elseif j == 2 && auxiliar[1] == length(tempos_máquina_final)
            if variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999
                append!(tempos_máquina_inicial, 0) #apaga o último termo
                append!(tempos_máquina_final, p[i])
            end
        elseif j == 3 && auxiliar[2] + auxiliar[1] == length(tempos_máquina_final)
            if variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999
                append!(tempos_máquina_inicial, 0)
                append!(tempos_máquina_final, p[i])
            end
        elseif variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999 #i determina qual tarefa
            append!(tempos_máquina_inicial, last(tempos_máquina_final))
            append!(tempos_máquina_final, p[i] + last(tempos_máquina_final)) #adicionando no segundo index
        end
    end
end

ylabdict = Dict(i=>"Máquina $i"  for i in 1:3)

y = Vector{Int64}()
ylab = Vector{String}()
for j in 1:3
    for i in 1:21
        if variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999
            append!(y, j)
            push!(ylab, ylabdict[j])
        end
    end
end

id_aux = ["j1","j2","j3","j4","j5","j6",
"j7","j8","j9","10","j11","j12","j13",
"j14","j15","j16","j17","j18","j19","j20","j21"]
id = Vector{String}()
for j in 1:3
    for i in 1:21
        if variaveis[i,j] == 1 || variaveis[i,j] == 0.9999999999999999
            push!(id, id_aux[i])
        end
    end
end

D1 = DataFrame(y = y, #3 máquinas
    ylab=ylab,
    x = tempos_máquina_inicial, #tempo de inicio, os tempos são ordenados de cada tarefa à máquina
    #ex: máquina 1 tem as tarefas seguints, logo se coloca os tempos da tarefas 1 logo
    xend = tempos_máquina_final, #tempo fim, segue a mesma lógica acima
    id = id) #tarefas work


coord = Coord.cartesian(ymin=0.4, ymax=4.6)

p = Gadfly.plot(D1, coord,
    layer(label=:id, x=:x, xend=:xend, y=:y, yend=:y, color=:id, Geom.segment, Geom.label(position=:above, hide_overlaps=true), Theme(line_width=2.7mm)),
    Scale.y_continuous(labels=i->get(ylabdict,i,"")),
    Guide.xlabel("Time"), Guide.ylabel(""),
    Theme(key_position=:none)
)

draw(PNG("Gant2.png", 6inch, 4inch), p)
