class Generate
	def initialize(variables, clauses, min_weight, max_weight)
		if variables == nil
			@variables = 4
		else
			@variables = variables.to_i
		end

		if @clauses == nil
			@clauses = 6
		else
			@clauses = clauses.to_i
		end

		if @min_weight == nil
			@min_weight = 1
		else
			@min_weight = min_weight.to_i
		end

		if @max_weight == nil
			@max_weight = 10
		else
			@max_weight = max_weight.to_i
		end
	end

	def generate
		puts "c #{@variables} promenne #{@clauses} klauzuli"
		puts "c weights #{generateWeights}"
		puts "p cnf #{@variables} #{@clauses}"
		puts "#{generateClauses}"
	end

	protected
	def generateWeights
		weights = ""
		for i in 0..@variables - 1
			weights += Random.rand(@min_weight...@max_weight).to_s
			weights += " " if i != @variables - 1
		end
		weights
	end

	def generateClauses
		clauses = ""
		for i in 0..@clauses - 1
			for j in 0..@variables - 1
				state = Random.rand(3)
				if state == 0 #skip
					next
				elsif state == 1 # negative
					k = (j + 1) * -1
				else
					k = (j + 1)
				end
				# puts state
				clauses += "#{k} "
			end
			clauses += "0\n"
		end
		clauses
	end
end

# puts "Usage: #{__FILE__} [variables=4] [clauses=6] [min_weight=0] [max_weight=10]"
g = Generate.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3])
g.generate
