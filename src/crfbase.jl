type Variable

	name::ASCIIString
	values::Array{Int64,1}
	valuenum::Int64
	function Variable(name, values)
		new(name, values, length(values))
	end

end

type Factor

	name::ASCIIString
	vars::Array{Variable,1}
	stats::Array{Float64}
	varsnum::Int64
	function Factor(name, vars, stats)
		dims = size(stats)
		varsnum = length(vars)
		if varsnum != length(dims)
			println("invalid factor ", name, ": dimensions inconsistent")
			exit()
		end
		for (i, varlength) in enumerate(dims)
			if varlength != vars[i].valuenum
				println("invalid variable ", vars[i].name, " in factor ", name, ": dimensions inconsistent")
				exit()
			end
		end
		new(name, vars, stats, varsnum)
	end

end