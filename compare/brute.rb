class BF
	def initialize(input, output)
		@input = input
		@output = output
	end

	def run
		readInput @input
	end

	def runInstance
		require "benchmark"
		time = Benchmark.realtime do
			# start = Process.times.utime
			# start = Time.now

			@maxPrice = 0
			@bestSolution = nil
			@added = Array.new(@cena.length)
			price = 0
			weight = 0

			knap(price, weight, @added)
		end

		# output
		# print "#{@maxPrice} "
		# print "#{@bestSolution.inspect} "
		# print Process.times.utime - start
		# print Time.now - start
		File.open(@output, "a") do |file|
			file.puts "#{@id},#{@n},%0.10f,	#{@maxPrice}" % time
		end
		# print "#{time} "
		# puts
	end

	def knap(price, weight, added)
		if weight <= @M and price > @maxPrice
			@maxPrice = price
			@bestSolution = added
		end

		for i in 0..added.length-1
			if added[i] == nil and weight < @M
				added2 = added.dup
				added2[i] = 0
				knap(price, weight, added2)

				added[i] = 1
				knap(price + @cena[i], weight + @vaha[i], added)
			end
		end
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

if ARGV.length != 2
	puts "Usage #{__FILE__} input_file output_file"
	exit
end

d = BF.new(ARGV[0], ARGV[1])
d.run

