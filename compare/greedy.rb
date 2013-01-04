class Greedy
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

			cv = {}
			for i in 0..@cena.length-1
				cenaVaha = @cena[i]/@vaha[i].to_f
				# puts "#{i} #{cenaVaha}"
				cv[i] = cenaVaha
			end
			cv = cv.sort_by{|a,b| b}.reverse

			@maxPrice = 0
			@maxWeight = 0
			@bestSolution = []
			cv.each { |key, value| 
				v = @vaha[key]
				if @maxWeight + v >= @M
					next
				end

				@maxWeight += v
				@maxPrice += @cena[key]
				@bestSolution[key] = 1
			}
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

d = Greedy.new(ARGV[0], ARGV[1])
d.run

