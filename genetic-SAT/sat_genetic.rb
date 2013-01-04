require "benchmark"

class SATGenetic
	def initialize(input, output = nil)
		@input = input
		@output = output
	end

	def runGenetic
		readInput(@input)
		# puts @formula.inspect

		# config
		@populationSize = 500
		@recombinationProbability = 0.7
		@mutationProbability = 2 / @variables
		@maxGenerations = 100
		@maxGenerationsWithoutImprovement = 25
		@twoPointCrossover = true

		@population = Array.new(@populationSize) {|i| Sat.new(@formula, @weights)}
		# puts @population.inspect
		# puts puts

		time = Benchmark.realtime do
			@best = currentBest()
			@i = 0
			noChange = 0
			generationCount = 0
			while noChange < @maxGenerationsWithoutImprovement && @i <= @maxGenerations do
				# print "#{@i}	"
				# # print "#{@best.genome}	"
				# print "#{@best.fitness}	"
				# print "#{@population.inject(0) {|mem, obj| mem + obj.fitness} / @population.size}	"
				# # print "#{currentWorst.genome}	"
				# print "#{currentWorst.fitness}"
				# puts

				newBest = evolve()
				noChange += 1

				if newBest > @best
					@best = newBest
					noChange = 0
				end

				@i += 1
				generationCount += 1
			end
		end

		# output
		if @output != nil
			File.open(@output, "a") do |file|
				file.puts "#{weight}	#{@best.genome}	%0.10f" % time
			end
		end
		weight = 0
		0.upto @best.genome.length - 1 do |i|
			j = @best.genome[i].to_i
			if j == 1
				weight += @weights[i].to_i
			end
		end

		print "#{weight}	"
		print "#{@i}	"
		print "#{@best.genome}	"
		print "#{time}	"
		puts

	end

	def evolve()
		@population = nextGeneration()
		@population.each {|p| p.mutate(@mutationProbability)}
		currentBest()
	end

	def nextGeneration()
		@population = @population.sort_by{ |a| a.fitness }.reverse
		# puts @population
		@newPopulation = []
		while @newPopulation.size < @populationSize do
			@newPopulation.concat(getchild())
		end
		@newPopulation[0..(@populationSize - 1)]
	end

	def getchild()
		parent1 = selectParent()
		parent2 = selectParent()
		if rand < @recombinationProbability
			doCrossover(parent1, parent2)
		else
			parent1 = @population.shift
			parent2 = @population.shift
			# puts "#{parent1} #{parent2}"
			[parent1, parent2]
		end
	end

	def selectParent()
		opponent1 = @population[rand @population.size]
		opponent2 = @population[rand @population.size]
		if opponent1 >= opponent2
			opponent1
		else
			opponent2
		end
	end

	def doCrossover(parent1, parent2)
		randRange = parent1.genome.length - 1

		child1 = nil
		child2 = nil

		if (@twoPointCrossover)
			crossoverPoints = [rand(randRange), rand(randRange)].sort
			genome1 = parent1.genome
			genome2 = parent2.genome
			child1 = genome1[0..crossoverPoints[0]] + genome2[(crossoverPoints[0]+1)..crossoverPoints[1]] + genome1[(crossoverPoints[1]+1)..-1]
			child2 = genome2[0..crossoverPoints[0]] + genome1[(crossoverPoints[0]+1)..crossoverPoints[1]] + genome2[(crossoverPoints[1]+1)..-1]
		else
			crossoverPoint = rand(randRange)
			child1 = parent1.genome[0..crossoverPoint] + parent2.genome[(crossoverPoint + 1)..-1]
			child2 = parent2.genome[0..crossoverPoint] + parent1.genome[(crossoverPoint + 1)..-1]
		end

		[Sat.new(@formula, @weights, child1), Sat.new(@formula, @weights, child2)]
	end

	def currentBest()
		@population.sort.last
	end

	def currentWorst()
		@population.sort.first
	end

	def runBrute()
		readInput(@input)
		# puts @formula.inspect
		
		best_solution = nil
		best_weight = 0

		time = Benchmark.realtime do
			solution = Array.new(@variables, 0)
			first = true
			for i in 0..(2 ** @variables - 1)
				j = @variables - 1

				if !first
					while solution[j] != 0 and j > 0
						solution[j] = 0
						j -= 1
					end
					solution[j] = 1
				end
				first = false

				formula_not_true = false
				# puts solution.inspect
				for clause in 0..@formula.size - 1 # formula
					for literal in 0..@formula[clause].size - 1
						# puts "l #{literal}"
						i = @formula[clause][literal]
						s = solution[i.abs - 1]
						if (i > 0 and s == 1) or (i < 0 and s == 0) # true
							# puts "+ #{i} #{s}"
							formula_not_true = false

							break
						end
						# puts "- #{i} #{s}"
						formula_not_true = true
					end

					if formula_not_true
						break
					end
				end

				if formula_not_true
					next
				end

				weight = 0
				for sol in 0..solution.size - 1
					if solution[sol] == 1
						weight += @weights[sol].to_i
					end
				end
				# puts "#{weight} #{solution.inspect}"
				if weight > best_weight
					# puts "#{weight}" 
					best_weight = weight
					best_solution = solution.dup
				end
			end
		end


		puts "#{best_weight} #{best_solution.inspect} #{time}"
	end

	def readInput(filename)
		File.open(filename, "r") { |f|
			lines = f.readlines
			lines.each { |line|
				line = line.strip

				if line[0] == "c"
					input = line.split
					if input[1] != "weights"
						next
					end

					# remove first two elements
					input.shift
					input.shift
					# puts input.inspect
					@weights = input
					next
				end

				if line[0] == "p"
					input = line.split
					# puts input.inspect
					@variables = input[2].to_i
					@clauses = input[3].to_i
					@formula = []
					next
				end

				input = line.split
				input.pop
				input.map!{|v| v.to_i}
				# puts input.inspect
				@formula << input

				# puts @formula.inspect
				# runInstance
				# exit
			}
		}
	end
end

class Sat
	include Comparable
	attr_reader :genome
	def initialize(formula, weights, bitString = nil)
		@formula = formula
		@weights = weights
		if bitString
			@genome = bitString
		else
			n = weights.length
			tmp = rand(2 ** n).to_s(2)
			@genome = "0" * (n - tmp.length) + tmp
		end

		updateFitness()
	end

	def fitness()
		@fitness ||= calcFitness()
	end

	def calcFitness()
		# puts "#{@genome} #{@weights}"
		for clause in 0..@formula.size - 1
			for literal in 0..@formula[clause].size - 1
				i = @formula[clause][literal]
				s = @genome[i.abs - 1].to_i
				if (i > 0 and s == 1) or (i < 0 and s == 0) # true
					formula_not_true = false
					break
				end
				formula_not_true = true
			end

			if formula_not_true
				break
			end
		end

		weight = 0
		if formula_not_true
			return weight
		end

		0.upto @genome.length - 1 do |j|
			k = @genome[j].to_i
			if k == 1
				weight += @weights[j].to_i
			end
		end

		# puts "#{weight}"
		weight
	end

	def updateFitness()
		@fitness = calcFitness()
	end

	def mutate(mutationProbability)
		# flip bits according to mutation probability
		0.upto @genome.length - 1 do |i|
			if rand() < mutationProbability
				@genome[i] = @genome[i] == '0' ? '1' : '0'
			end
		end
		updateFitness()
	end

	def <=>(other)
		fitness <=> other.fitness
	end

	def to_s
		"#{@genome} #{@fitness}"
	end
end


if ARGV.length < 1
	puts "Usage #{__FILE__} input_file [type=genetic] [output_file=stdout]"
	exit
end

d = SATGenetic.new(ARGV[0], ARGV[2])
if ARGV[1] == "brute"
	d.runBrute
else
	d.runGenetic
end
