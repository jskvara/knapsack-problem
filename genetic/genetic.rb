class Genetic
	def initialize(input, output)
		@input = input
		@output = output
	end

	def run
		readInput @input
	end

	def runInstance
		require "benchmark"

		# config
		@populationSize = 500
		@recombinationProbability = 0.7
		@mutationProbability = 2 / @n
		@maxGenerations = 100
		@maxGenerationsWithoutImprovement = 25
		@twoPointCrossover = false

		# puts "#{@n}, #{@M}, #{@cena}, #{@vaha}"

		@population = Array.new(@populationSize) {|i| Knapsack.new(@n, @cena, @vaha, @M)}
		# puts @population.inspect
		# puts puts

		time = Benchmark.realtime do
			@best = currentBest
			i = 0
			noChange = 0
			generationCount = 0
			while noChange < @maxGenerationsWithoutImprovement && i <= @maxGenerations do
				# puts "Starting Generation #{i}"
				# puts "Current best: #{@best.genome} with fitness: #{@best.fitness}"
				# puts "Average: #{@population.inject(0) {|mem, obj| mem + obj.fitness} / @population.size}"
				# puts "Worst: #{currentWorst}"
				# puts

				# print "#{i}	"
				# print "#{@best.fitness}	"
				# print "#{@population.inject(0) {|mem, obj| mem + obj.fitness} / @population.size}	"
				# print "#{currentWorst.fitness}"
				# puts

				newBest = evolve()
				noChange += 1

				if newBest > @best
					@best = newBest
					noChange = 0
				end

				i += 1
				generationCount += 1
			end

		end

		# output
		# File.open(@output, "a") do |file|
		# 	file.puts "#{@id},#{@n},%0.10f,	#{@maxPrice}" % time
		# end
		maxPrice = 0
		0.upto @best.genome.length - 1 do |i|
			j = @best.genome[i].to_i
			maxPrice += j * @cena[i]
		end

		print "#{maxPrice} "
		print "#{time} "
		puts
	end

	def evolve()
		@population = nextGeneration()
		@population.each {|p| p.mutate @mutationProbability}
		currentBest
	end

	def nextGeneration()
		@newPopulation = []
		while @newPopulation.size < @populationSize do
			@newPopulation.concat getchild()
		end
		@newPopulation[0..(@populationSize - 1)]
	end

	def getchild()
		parent1 = selectParent()
		parent2 = selectParent()

		if rand < @recombinationProbability
			doCrossover(parent1, parent2)
		else
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

		[Knapsack.new(@n, @cena, @vaha, @M, child1), Knapsack.new(@n, @cena, @vaha, @M, child2)]
	end

	def currentBest
		@population.sort.last
	end

	def currentWorst
		@population.sort.first
	end

	def readInput(filename)
		File.open(filename, "r") do |f|
			lines = f.readlines
			lines.each do |line|
				# puts line
				input = line.strip.split

				@id = input[0]
				@n = input[1].to_i
				@M = input[2].to_i

				@vaha = []
				@cena = []
				(3..(2 * @n + 2)).step(2) do |i|
					@vaha << input[i].to_i
					@cena << input[i+1].to_i
				end
				# puts @vaha.inspect
				# puts @cena.inspect
				runInstance
				# exit
			end
		end
	end
end

class Knapsack
	include Comparable
	attr_reader :genome
	def initialize(n, cena, vaha, m, bitString=nil)
		@n = n
		@cena = cena
		@vaha = vaha
		@M = m
		if bitString
			@genome = bitString
		else
			tmp = rand(2**@n).to_s(2)
			@genome = "0" * (@n - tmp.length) + tmp
		end

		updateFitness()
	end

	def fitness()
		@fitness ||= calcFitness
	end

	def calcFitness
		mem = Hash.new
		mem[:cena] = 0
		mem[:vaha] = 0
		0.upto @genome.length - 1 do |i|
			j = @genome[i].to_i
			# # puts "#{j} #{@cena[i]}"
			# mem["cena"] += j * @cena[i]

			# if mem["vaha"] <= @M
			# 	# puts "#{j} #{@vaha[i]}"
			# 	mem["vaha"] += j * @vaha[i]
			# end
			mem[:cena] += j * @cena[i]
			mem[:vaha] += j * @vaha[i]
		end

		# penalty for invalid solutions
		if (mem[:vaha] > @M) then
			mem[:cena] -= 7 * (mem[:vaha] - @M)
		end

		# puts "#{mem[:cena]}, #{mem[:vaha]}"
		mem[:cena]
	end

	def updateFitness
		@fitness = calcFitness()
	end

	def mutate(mutationProbability)
		# flip bits according to mutation probability
		0.upto @genome.length - 1 do |i|
			if rand < mutationProbability
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
	puts "Usage #{__FILE__} input_file [output_file]"
	exit
end

d = Genetic.new(ARGV[0], ARGV[1])
d.run

