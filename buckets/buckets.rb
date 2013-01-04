class Buckets

	def initialize(filename)
		@filename = filename
		@id = 0
		@n = 0
		@capacity = Array.new
		@starting = Array.new
		@ending = Array.new
		readInput
	end

	def run
		runPriority
		# runBfs
		# runDfs
	end

	def runBfs
		@length = 0
		@startingSpace = Space.new(@starting.dup, 0)
		
		@queue = [@startingSpace]
		@visited = {@startingSpace.key => true}
		
		while !@queue.empty?
			@spaceI = @queue.shift()#pop()
			@length += 1
			
			if not @visited[@spaceI.key] then
				puts "#{@spaceI}"
				if @spaceI.space == @ending
					puts "end #{@spaceI} #{@length}"
					exit
				end
				@visited[@spaceI.key] = true
			end

			for i in 0..(@n - 1)
				@spaceNew1 = @spaceI.clone
				@spaceNew1.fillBucket(i, @capacity[i])
				if not @visited[@spaceNew1.key] and not @queue.include?(@spaceNew1) then
					@spaceNew1.incDepth
					@queue.push @spaceNew1
				end

				if @spaceI.space[i] != 0
					@spaceNew2 = @spaceI.clone
					@spaceNew2.emptyBucket(i)
					if not @visited[@spaceNew2.key] and not @queue.include?(@spaceNew2) then
						@spaceNew2.incDepth
						@queue.push @spaceNew2
					end
				end

				for j in 0..(@n - 1)
					if i != j and @spaceI.space[i] != @spaceI.space[j] then
						@spaceNew3 = @spaceI.clone
						@spaceNew3.refillBucket(i, j, @capacity[j])
						if not @visited[@spaceNew3.key] and not @queue.include?(@spaceNew3) then
							@spaceNew3.incDepth
							@queue.push @spaceNew3
						end
					end
				end
			end
		end
	end

	def runDfs
		@length = 0
		@startingSpace = Space.new(@starting.dup, 0)
		
		@queue = [@startingSpace]
		@visited = {@startingSpace.key => true}
		
		while !@queue.empty?
			@spaceI = @queue.pop()
			@length += 1
			if @length > 10000
				puts "nothing found"
				exit
			end
			
			if not @visited[@spaceI.key] then
				puts "#{@spaceI}"
				if @spaceI.space == @ending
					puts "end #{@spaceI} #{@length}"
					exit
				end
				@visited[@spaceI.key] = true
			end

			for i in 0..(@n - 1)
				@spaceNew1 = @spaceI.clone
				@spaceNew1.fillBucket(i, @capacity[i])
				if not @visited[@spaceNew1.key] and not @queue.include?(@spaceNew1) then
					@spaceNew1.incDepth
					@queue.push @spaceNew1
				end

				if @spaceI.space[i] != 0
					@spaceNew2 = @spaceI.clone
					@spaceNew2.emptyBucket(i)
					if not @visited[@spaceNew2.key] and not @queue.include?(@spaceNew2) then
						@spaceNew2.incDepth
						@queue.push @spaceNew2
					end
				end

				for j in 0..(@n - 1)
					if i != j and @spaceI.space[i] != @spaceI.space[j] then
						@spaceNew3 = @spaceI.clone
						@spaceNew3.refillBucket(i, j, @capacity[j])
						if not @visited[@spaceNew3.key] and not @queue.include?(@spaceNew3) then
							@spaceNew3.incDepth
							@queue.push @spaceNew3
						end
					end
				end
			end
		end
	end

	def readInput
		File.open(@filename, "r") do |f|
			lines = f.readlines
			lines.each do |line|
				input = line.strip.split

				@id = input[0]
				@n = input[1].to_i

				@capacity = Array.new
				for i in 2..(@n + 1)
					@capacity.push input[i].to_i
				end

				@starting = Array.new
				for i in (@n + 2)..(2 * @n + 1)
					@starting.push input[i].to_i
				end
				
				@ending = Array.new
				for i in (2 * @n + 2)..(3 * @n + 1)
					@ending.push input[i].to_i
				end

				run
			end
		end
	end

	def computePriority(space)
		priority = @n
		@ending.each_with_index do |x, i|
			if @ending[i] == space.space[i]
				priority -= 1
			end
		end
		priority
	end

	def runPriority
		@length = 0
		@startingSpace = Space.new(@starting.dup, 0)
		
		@queue = PriorityQueue.new()
		@queue.push(@startingSpace, computePriority(@startingSpace))

		@visited = {@startingSpace.key => true}

		while true #!@queue.empty?
			@spaceI = @queue.pop()
			@length += 1
			
			if not @visited[@spaceI.key] then
				# puts "#{@spaceI}"
				if @spaceI.space == @ending
					puts "end #{@spaceI} #{@length}"
					exit
				end
				@visited[@spaceI.key] = true
			end

			for i in 0..(@n - 1)
				@spaceNew1 = @spaceI.clone
				@spaceNew1.fillBucket(i, @capacity[i])
				if not @visited[@spaceNew1.key] then
					@spaceNew1.incDepth
					@queue.push @spaceNew1, computePriority(@spaceNew1)
				end

				@spaceNew2 = @spaceI.clone
				@spaceNew2.emptyBucket(i)
				if not @visited[@spaceNew2.key] then
					@spaceNew2.incDepth
					@queue.push @spaceNew2, computePriority(@spaceNew2)
				end

				for j in 0..(@n - 1)
					if i != j then
						@spaceNew3 = @spaceI.clone
						@spaceNew3.refillBucket(i, j, @capacity[j])
						if not @visited[@spaceNew3.key] then
							@spaceNew3.incDepth
							@queue.push @spaceNew3, computePriority(@spaceNew3)
						end
					end
				end
			end
		end
	end
end

class PriorityQueue
	def initialize
		@pq = []
		for i in 0..5
			@pq[i] = []
		end
	end

	def push(space, priority)
		if priority < 0 or priority > 5
			puts "Illegal priority " + priority
			exit
		end

		if @pq[priority].empty?
			@pq[priority].push space
			return
		end

		if not @pq[priority].include?(space)
			@pq[priority].push space
		end
	end

	def pop
		@pq.each_with_index do |x, i|
			if @pq[i] == nil or @pq[i].empty?
				next
			end
			return @pq[i].pop()
		end
	end
end

class Space
	include Comparable
	attr_reader :space, :depth

	def initialize(space, depth)
		@space = space
		@depth = depth
	end

	def incDepth
		@depth += 1
	end

	def fillBucket(i, capacity)
		@space[i] = capacity
	end

	def emptyBucket(i)
		@space[i] = 0
	end

	def refillBucket(i, j, capacity)
		# Px->y x > 0, y < 3, <x-d1,y+d1> d1 = min(x, 3-y)
		x = @space[i]
		y = @space[j]
		d = 0
		d = [x, (capacity - y)].min
		@space[i] = x - d
		@space[j] = y + d
	end

	def key
		"#{@space[0]}-#{@space[1]}-#{@space[2]}-#{@space[3]}-#{@space[4]}"
	end

	def to_s
		"#{@space} #{@depth}"
	end

	def <=>(other)
		@space <=> other.space
	end

	def ==(other)
  		@space == other.space
	end

	def clone
		Space.new(@space.clone, @depth)
	end
end

buckets = Buckets.new("bu.inst.dat")
buckets.run
