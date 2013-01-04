class Fptas
	FPTAS = 50
	def run
		filename = "inst/knap_4.inst.dat"
		# filename = "inst/knap_10.inst.dat"
		# filename = "inst/knap_15.inst.dat"
		# filename = "inst/knap_20.inst.dat"
		readInput filename
	end

	def runInstance
		require "benchmark"
		time = Benchmark.realtime do
			table = Array.new(@cena.length)

			for i in 0..@cena.length-1
				table[i] = Array.new(fptas(@cena.sum))

				if i == 0 #first column
					table[i][fptas(@cena[i])] = @vaha[i]
					next
				end

				for j in 1..@cena.sum
					if j == fptas(@cena[i])
						if table[i][j] != nil and table[i][j] > @vaha[i]
							next
						else
							table[i][j] = @vaha[i]
						end
					elsif table[i-1][j] != nil
						table[i][j] = table[i-1][j]
						table[i][fptas(@cena[i]) + j] = table[i-1][j] + @vaha[i]
					end
				end
			end

			findSolution table
			# printTable table
		end

		# print "#{time} "
		puts
	end

	def fptas(num)
		num / FPTAS
	end

	def defptas(num)
		num * FPTAS
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
		
		print "#{defptas(sol)} "
		# print "#{table[l][sol]} "

		j = sol
		(table.length-1).downto(0) {|i|
			if table[i][j] == @vaha[i]
				solution[i] = 1
				break
			elsif table[i][j] != table[i-1][j]
				solution[i] = 1
				j -= fptas(@cena[i])
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

d = Fptas.new
d.run
