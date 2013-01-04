class Dyn
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
			table = Array.new(@cena.length)

			for i in 0..@cena.length-1
				table[i] = Array.new(@cena.sum)

				if i == 0 #first column
					table[i][@cena[i]] = @vaha[i]
					next
				end

				for j in 1..@cena.sum
					if j == @cena[i]
						if table[i][j] != nil and table[i][j] > @vaha[i]
							next
						else
							table[i][j] = @vaha[i]
						end
					elsif table[i-1][j] != nil
						table[i][j] = table[i-1][j]
						table[i][@cena[i] + j] = table[i-1][j] + @vaha[i]
					end
				end
			end

			findSolution table
		end

		# output
		# printTable table
		# print "#{time} "
		# puts
		File.open(@output, "a") do |file|
			file.puts "#{@id},#{@n},#{time},	#{@maxPrice}"
		end
	end

	def findSolution table
		solution = []
		sol = 0
		l = table.length-1
		(table[l].length-1).downto(0) {|i|
			if table[l][i] != nil and table[l][i] <= @M
				sol = i
				break
			end
		}
		
		# puts "#{sol} #{table[l][sol]}"
		# print "#{sol} "

		j = sol
		(table.length-1).downto(0) {|i|
			if table[i][j] == @vaha[i]
				solution[i] = 1
				break
			elsif table[i][j] != table[i-1][j]
				solution[i] = 1
				j -= @cena[i]
			end
		}

		# puts solution.inspect
	end

	def printTable(table)
		for	j in 0..table[0].length-1
			print "#{j}: "
			for i in 0..table.length-1
				if table[i][j] == nil
					print "    "
				else
					print "%03d " % table[i][j]
				end
			end
			puts
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

# Monkey patch
class Array
	def sum
		self.inject{|sum, x| sum + x }
	end
end

if ARGV.length != 2
	puts "Usage #{__FILE__} input_file output_file"
	exit
end

d = Dyn.new(ARGV[0], ARGV[1])
d.run
