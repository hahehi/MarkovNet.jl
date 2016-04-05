module inference

	using crfbase

	type Msgedge
		edgetype::Int64		#0: factor to variable; 1: variable to factor
		edgefrom::Int64		#factor or variable id
		edgeto::Int64		#factor or variable id
		edgemsg::Array{Float64,1}
		edgeflag::Int64		#0: an edge to count; 1: an edge counted
	end
	type Factorneighbors
		neighborsnum::Int64
		variablesid::Array{Int64,1}
		msgedgeid::Array{Int64,1}
	end
	type Variableneighbors
		neighborsnum::Int64
		factorsid::Array{Int64,1}
		msgedgeid::Array{Int64,1}
	end

	variables = Array{Variable}(0)
	factors = Array{Factor}(0)
	thetas = Array{Float64}(0)
	varsnum = 0
	facsnum = 0
	edgesnum = 0
	msgedgearray = Array{Msgedge}(0)
	factorneighborsarray = Array{Factorneighbors}(0)
	variableneighborsarray = Array{Variableneighbors}(0)

	function init(vs::Array{Variable,1}, fs::Array{Factor,1}, ts::Array{Float64,1})
		_variables = vs
		_factors = fs
		_thetas = ts
		_varsnum = length(_variables)
		_facsnum = length(_factors)
		if _facsnum != length(_thetas)
			println("inference: dimensions inconsistent of factors and thetas")
			exit()
		end
		_edgesnum = 0
		for f in _factors
			for v in f.vars
				if findfirst(_variables, v) == 0
					println("inference: variable ", v, " in factor ", f, " not found")
					exit()
				end
			end
			_edgesnum += length(f.vars) * 2
		end

		# edges, neighbors set up
		_msgedgearray = Array{Msgedge}(0)
		_factorneighborsarray = Array{Factorneighbors}(0)
		_variableneighborsarray = Array{Variableneighbors}(0)
		for f in _factors
			_factorneighborsarray=[_factorneighborsarray;Factorneighbors(0,[],[])]
		end
		for v in _variables
			_variableneighborsarray=[_variableneighborsarray;Variableneighbors(0,[],[])]
		end
		_curedgeid = 1
		for (fi,f) in enumerate(_factors)
			for v in f.vars
				vi = findfirst(_variables, v)
				_msgedgearray = [_msgedgearray; Msgedge(0,fi,vi,Array{Float64}(v.valuenum),0)]
				_factorneighborsarray[fi].neighborsnum += 1
				_factorneighborsarray[fi].variablesid = [_factorneighborsarray[fi].variablesid; vi]
				_factorneighborsarray[fi].msgedgeid = [_factorneighborsarray[fi].msgedgeid; _curedgeid]
				_curedgeid += 1
				_msgedgearray = [_msgedgearray; Msgedge(1,vi,fi,Array{Float64}(v.valuenum),0)]
				_variableneighborsarray[vi].neighborsnum += 1
				_variableneighborsarray[vi].factorsid = [_variableneighborsarray[vi].factorsid; fi]
				_variableneighborsarray[vi].msgedgeid = [_variableneighborsarray[vi].msgedgeid; _curedgeid]
				_curedgeid += 1
			end
		end

		global variables = _variables
		global factors = _factors
		global thetas = _thetas
		global varsnum = _varsnum
		global facsnum = _facsnum
		global edgesnum = _edgesnum
		global msgedgearray = _msgedgearray
		global factorneighborsarray = _factorneighborsarray
		global variableneighborsarray = _variableneighborsarray
	end

	function isempty(array::Array{Int64})
		if length(array) == 0
			return true
		end
		return false
	end

	function gettop(array::Array{Int64})
		return array[length(array)]
	end

	function getedgetocalcu(msgedgeid, gettingtype)
		_msgedgearray = BPInference.msgedgearray
		_factorneighborsarray = BPInference.factorneighborsarray
		_variableneighborsarray = BPInference.variableneighborsarray
		m = _msgedgearray[msgedgeid]
		et = m.edgetype
		earray = Array{Int64}(0)
		if et == 0
			fi = m.edgefrom
			f = _factorneighborsarray[fi]
			for vi in f.variablesid
				if vi != m.edgeto
					v = _variableneighborsarray[vi]
					idi = findfirst(v.factorsid, fi)
					mi = v.msgedgeid[idi]
					if gettingtype == 1
						push!(earray, mi)
					elseif _msgedgearray[mi].edgeflag == 0
						push!(earray, mi)
					end
				end
			end
		else
			vi = m.edgefrom
			v = _variableneighborsarray[vi]
			for fi in v.factorsid
				if fi != m.edgeto
					f = _factorneighborsarray[fi]
					idi = findfirst(f.variablesid, vi)
					mi = f.msgedgeid[idi]
					if gettingtype == 1
						push!(earray, mi)
					elseif _msgedgearray[mi].edgeflag == 0
						push!(earray, mi)
					end
				end
			end
		end
		return earray
	end

	phi(x) = exp(x)

	function calcumsg(msgedgeid)
		_variables = BPInference.variables
		_factors = BPInference.factors
		_thetas = BPInference.thetas
		_msgedgearray = BPInference.msgedgearray
		_factorneighborsarray = BPInference.factorneighborsarray
		_variableneighborsarray = BPInference.variableneighborsarray
		m = _msgedgearray[msgedgeid]
		et = m.edgetype
		earray = getedgetocalcu(msgedgeid, 1)
		m.edgeflag = 1
		if et == 0
			fi = m.edgefrom
			vi = m.edgeto
			if length(earray) == 0
				m.edgemsg = phi(_thetas[fi] * _factors[fi].stats)
				return
			end
			v = _variables[vi]
			vars = _factors[fi].vars
			stats = _factors[fi].stats
			theta = _thetas[fi]
			sliceindex = findfirst(vars, v)
			msgarray = [1]
			vars = flipdim(vars, 1)
			for var in vars
				if var != v
					varid = findfirst(_variables, var)
					for edgeid in earray
						if _msgedgearray[edgeid].edgefrom == varid
							curmsg = _msgedgearray[edgeid].edgemsg
							newlength = length(msgarray) * length(curmsg)
							newmsgarray = Array{Float64}(newlength)
							i = 1
							for old in msgarray
								for cur in curmsg
									newmsgarray[i] = old * cur
									i += 1
								end
							end
							msgarray = newmsgarray
							break
						end
					end
				end
			end
			for (msgi, msg) in enumerate(m.edgemsg)
				statssliced = slicedim(stats, sliceindex, msgi)
				m.edgemsg[msgi] = 0
				for (stsi, sts) in enumerate(statssliced)
					m.edgemsg[msgi] += phi(theta * sts) * msgarray[stsi]
				end
			end
		else
			m.edgemsg = ones(length(m.edgemsg))
			for e in earray
				m.edgemsg .*= _msgedgearray[e].edgemsg
			end
		end
	end

	function run()
		#_variables = BPInference.variables
		#_factors = BPInference.factors
		#_thetas = BPInference.thetas
		#_varsnum = BPInference.varsnum
		#_facsnum = BPInference.facsnum
		#_edgesnum = BPInference.edgesnum
		_msgedgearray = BPInference.msgedgearray
		_factorneighborsarray = BPInference.factorneighborsarray
		_variableneighborsarray = BPInference.variableneighborsarray

		for (mi,m) in enumerate(_msgedgearray)
			et = m.edgetype
			if et == 0
				f = _factorneighborsarray[m.edgefrom]
				if f.neighborsnum == 1
					calcumsg(mi)
				end
			else
				v = _variableneighborsarray[m.edgefrom]
				if v.neighborsnum == 1
					calcumsg(mi)
				end
			end
		end
		todolist = Array{Int64}(0)
		for (mi,m) in enumerate(_msgedgearray)
			if m.edgeflag == 1
				continue
			end
			push!(todolist, mi)
			while !isempty(todolist)
				curedge = gettop(todolist)
				earray = getedgetocalcu(curedge, 0)
				if isempty(earray)
					calcumsg(curedge)
					pop!(todolist)
					continue
				else
					for e in earray
						push!(todolist, e)
					end
				end
			end
		end
	end

	function inferencev(varindex::Int64, var::Variable)
		_msgedgearray = BPInference.msgedgearray
		_variableneighborsarray = BPInference.variableneighborsarray
		msgsofvar = _variableneighborsarray[varindex].msgedgeid - 1
		p = ones(var.valuenum)
		for m in msgsofvar
			p .*= _msgedgearray[m].edgemsg
		end
		p /= sum(p)
		println(var.name, " distribution: ", p)
	end

	function inferencef(facindex::Int64, fac::Factor)
		_variables = BPInference.variables
		_factors = BPInference.factors
		_thetas = BPInference.thetas
		_msgedgearray = BPInference.msgedgearray
		_factorneighborsarray = BPInference.factorneighborsarray
		msgsoffac = _factorneighborsarray[facindex].msgedgeid + 1
		vars = _factors[facindex].vars
		stats = _factors[facindex].stats
		theta = _thetas[facindex]
		msgarray = [1]
		vars = flipdim(vars, 1)
		for var in vars
			varid = findfirst(_variables, var)
			for edgeid in msgsoffac
				if _msgedgearray[edgeid].edgefrom == varid
					curmsg = _msgedgearray[edgeid].edgemsg
					newlength = length(msgarray) * length(curmsg)
					newmsgarray = Array{Float64}(newlength)
					i = 1
					for old in msgarray
						for cur in curmsg
							newmsgarray[i] = old * cur
							i += 1
						end
					end
					msgarray = newmsgarray
					break
				end
			end
		end
		p = ones(size(stats))
		for (si,s) in enumerate(stats)
			p[si] = phi(theta * s) * msgarray[si]
		end
		p /= sum(p)
		println(fac.name, " distribution: ", p)
	end

	function inference()
		_variables = BPInference.variables
		_factors = BPInference.factors
		_thetas = BPInference.thetas
		_msgedgearray = BPInference.msgedgearray
		_factorneighborsarray = BPInference.factorneighborsarray
		_variableneighborsarray = BPInference.variableneighborsarray
		for (vi,v) in enumerate(_variables)
			inferencev(vi,v)
		end
		for (fi,f) in enumerate(_factors)
			inferencef(fi,f)
		end
	end

	export init, run, inference

end