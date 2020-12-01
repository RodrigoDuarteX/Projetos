using Cbc #solucionaddor
using JuMP #modelagem

function problema_transporte_23()

    n = 6 	# m*n

    init_time = time_ns() #grava o tempo que começou

    model = Model(Cbc.Optimizer)
	# são 2 origem m = 2
	# São 3 mercados consumidores n = 3
	# oferta = [800, 1000]
	# demanda = [500, 400, 900]
	# custo = [4, 2, 5; 11, 7, 4]

    #definindo as variáveis (m * n)
    @variable(model, x11 >= 0, Int)
	@variable(model, x12 >= 0, Int)
	@variable(model, x13 >= 0, Int)
	@variable(model, x21 >= 0, Int)
	@variable(model, x22 >= 0, Int)
	@variable(model, x23 >= 0, Int)

	#definindo as restriçôes (3)
	@constraint(model, x11 + x12 + x13 <= 800) #restricao de demanda 1
	@constraint(model, x21 + x22 + x23 <= 1000) #restricao de demanda 2
	@constraint(model, x11 + x21 == 500) #restricao de oferta 1
	@constraint(model, x12 + x22 == 400) #restricao de oferta 2
	@constraint(model, x13 + x23 == 900) #restricao de oferta 3

	#definindo a função objetivo
	@objective(model, Min, x11*4 + x12*2 + x13*5 + x21*11 + x22*7 + x23*4)

	optimize!(model)

	status = termination_status(model)
	println("STATUS: ", status, " ---------------------------")

	solvalue = objective_value(model)
	solvariables = zeros(Int64,6) #criando uma array ?
	if (status != MOI.INFEASIBLE && status != MOI.OBJECTIVE_LIMIT)
		# Modo 1 ************************************
		solvariables[1] = value.(x11)
		solvariables[2] = value.(x12)
		solvariables[3] = value.(x13)
		solvariables[4] = value.(x21)
		solvariables[5] = value.(x22)
		solvariables[6] = value.(x23)


		# *******************************************
#		# Modo 2 e 3 ********************************
#		for i = 1 : n
#			solvariables[i] = value.(x[i])
#		end
#		# *******************************************
	else
		println("no solution has been found")
	end

	elapsed_time = (time_ns() - init_time) * 1e-9
	####################################################################

	#Printing solution to the screen -------------------------------------------------------------------------------------
	println("Solution Cost: ", solvalue)
	print("Solution Variables: \n")
	for i in 1:n
		println("x", i ,": ", solvariables[i])
	end

	# --------------------------------------------------------------------------------------------------------------------
	println("Elapsed time in seconds = $(round(elapsed_time; digits=4))")

	#Printing solution to a file -----------------------------------------------------------------------------------------
	io = open("output/problema_transporte_2.3.txt", "a") #parametros: "w", "r", "a", "w+", "r+", "a+"; write = true; append=true; only read; etc.
	write(io, "Problema de transporte, exemplo 2.3\n")
	write(io, "Solution Cost: $solvalue\n")
	write(io, "Solution Variables: \n")
	for i in 1:n
		write(io, "x$i: $(solvariables[i]) \n")
	end
	write(io, "Elapsed time in seconds = $(round(elapsed_time; digits=4))\n")
	write(io, "---------------------------------------------------\n")
	close(io)

end
