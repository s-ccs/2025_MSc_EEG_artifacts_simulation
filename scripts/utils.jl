# For helper function to read in the large model
# using HDF5
# using DataFrames

# for angle conversion - need to check if we still need this or if the simple angle conversion util code will suffice
# using CartesianFromSpherical

function read_new_hartmut(;p = "HArtMuT_NYhead_large_fibers.mat")
    file = matopen(p);
    hartmut = read(file, "HArtMuT");
    close(file)
    
    fname = tempname(); # temporary file
    
    fid = h5open(fname, "w") 
    
    
    label = string.(hartmut["electrodes"]["label"][:, 1])
    chanpos = Float64.(hartmut["electrodes"]["chanpos"])
    
    cort_label = string.(hartmut["cortexmodel"]["labels"][:, 1])
    cort_orient = hartmut["cortexmodel"]["orientation"]
    cort_leadfield = hartmut["cortexmodel"]["leadfield"]
    cort_pos = hartmut["cortexmodel"]["pos"]
    
    
    art_label = string.(hartmut["artefactmodel"]["labels"][:, 1])
    art_orient = hartmut["artefactmodel"]["orientation"]
    art_leadfield = hartmut["artefactmodel"]["leadfield"]
    art_pos = hartmut["artefactmodel"]["pos"]
    
    e = create_group(fid, "electrodes")
    e["label"] = label
    e["pos"] = chanpos
    c = create_group(fid, "cortical")
    c["label"] = cort_label
    c["orientation"] = cort_orient
    c["leadfield"] = cort_leadfield
    c["pos"] = cort_pos
    a = create_group(fid, "artefacts")
    a["label"] = art_label
    a["orientation"] = art_orient
    a["leadfield"] = art_leadfield
    a["pos"] = art_pos
        a["fiber"] = Int.(hartmut["artefactmodel"]["fiber"][1,:])
    a["dist_from_muscle_center"] = hartmut["artefactmodel"]["dist_from_muscle_center"][1,:]
    close(fid)
    
    #-- read it back in (illogical, I know ;)
    h = h5open(fname)


    weirdchan = ["Nk1", "Nk2", "Nk3", "Nk4"]
    ## getting index of these channels from imported hartmut model data, exclude them in the topoplot
    remove_indices =
        findall(l -> l ∈ weirdchan, h["electrodes"] |> read |> x -> x["label"])
    print(remove_indices)

    function sel_chan(x)

        if "leadfield" ∈ keys(x)
            x["leadfield"] = x["leadfield"][Not(remove_indices), :, :] .* 10e3 # this scaling factor seems to generate potentials with +-1 as max
        else
            x["label"] = x["label"][Not(remove_indices)]
            pos3d = x["pos"][Not(remove_indices), :]
            pos3d = pos3d ./ (4 * maximum(pos3d, dims = 1))
            x["pos"] = pos3d
        end
        return x
    end
    headmodel = Hartmut(
        h["artefacts"] |> read |> sel_chan,
        h["cortical"] |> read |> sel_chan,
        h["electrodes"] |> read |> sel_chan,
    )
    return headmodel
end

function read_eyemodel(;p = "HArtMuT_NYhead_extra_eyemodel.mat")
    # read the intermediate eye model (only eye-points)
    file = matopen(p);
    hartmut = read(file,"eyemodel")
    close(file)
    hartmut["label"] = hartmut["labels"]
    delete!(hartmut,"labels")
    hartmut
end

function hart_indices_from_labels(headmodel,labels=["dummy"]; plot=false)
    # given a headmodel and a list of labels, return a Dict with the keys being the label and the values being the indices of sources with that label in the given model. plot=true additionally plots the points into an existing Makie figure. 
    labelsourceindices = Dict()
    for l in labels
        labelsourceindices[l] = findall(k->occursin(l,k),headmodel["label"][:])
        if plot
            WGLMakie.scatter!(model["pos"][labelsourceindices[l],:]) #optional: plot these points into the existing figure
        end
        println(l, ": ", length(labelsourceindices[l])," points")
    end
    return labelsourceindices
end

"""
Project electrode positions from 3-D to 2-D positions usable in TopoPlots.jl.
"""
function pos2dfrom3d(pos3d)
    #ref: UnfoldSim docs multichannel example
	pos2d = UnfoldMakie.to_positions(pos3d')
	pos2d = [Point2f(p[1] + 0.5, p[2] + 0.5) for p in pos2d]; 
    return pos2d
end

"""
Given two leadfields and a set of 2D electrode positions, plot them both and their difference (lf2-lf1)
"""
function topoplot_leadfields_difference(lf1,lf2,pos2d; labels=["","","",""], commoncolorrange=true)
    # from UnfoldSim docs - multichannel example
	f = Figure(size=(750, 700))
    max, min = maximum([lf1 lf2]), minimum([lf1 lf2])
    Label(f[1,1][1, 1:2, Top()], labels[1], valign = :bottom, font = :bold, padding = (0, 0, 5, 30))
	Label(f[1,2][1, 1:2, Top()], labels[2], valign = :bottom, font = :bold, padding = (0, 0, 5, 30))
	Label(f[2,1][1, 1:2, Top()], labels[3], valign = :bottom, font = :bold, padding = (0, 0, 5, 30))
	Label(f[2,2][1, 1:2, Top()], labels[4], valign = :bottom, font = :bold, padding = (0, 0, 5, 30))
    if (commoncolorrange)
        plot_topoplot!(
            f[1,1], lf1, positions=pos2d, layout=(; use_colorbar=false), visual = (; enlarge = 0.65, label_scatter = false,colorrange=(min,max))
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[1,2], lf2, positions=pos2d, layout=(; use_colorbar=false), visual = (; enlarge = 0.65, label_scatter = false,colorrange=(min,max))
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[2,1], lf2-lf1, positions=pos2d, layout=(; use_colorbar=false), visual = (; enlarge = 0.65, label_scatter = false,colorrange=(min,max))
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[2,2], (lf2-lf1),
            positions=pos2d, layout=(; use_colorbar=false), visual = (; enlarge = 0.65, label_scatter = true,colorrange=(min,max)))
        Colorbar(f[:,3]; limits=(min,max), colormap = Reverse(:RdBu))
    else
        plot_topoplot!(
            f[1,1], lf1, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false,)
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[1,2], lf2, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false,)
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[2,1], lf2-lf1, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false,)
            ,axis = (; xlabel = "",), colorbar = (; height = 200,label="Potential"))
        plot_topoplot!(
            f[2,2], (lf2-lf1),
            positions=pos2d, layout=(; use_colorbar=false), visual = (; enlarge = 0.65, label_scatter = true,))
    end
	return f
end

"""
Calculate orientations from the given positions with respect to the reference. `direction` is by default "towards" the reference point; if a different value is given, orientations are calculated away from the reference point.
"""
function calc_orientations(reference, positions; direction="towards")
    if direction == "towards"
        orientation_vecs = reference .- positions
    else
        orientation_vecs = positions .- reference
    end
    return orientation_vecs ./ norm.(eachrow(orientation_vecs))
end

"""
Calculate the angle between two 3-D vectors.
"""
function angle_between(a,b) 
    return acosd.(dot(a, b)/(norm(a)*norm(b)))
end



"""
Construct the gaze vector in 3-D world coordinates, given the gaze angle (in degrees) as measured from the center gaze (looking straight ahead) in the world x-y plane. Z-component is always 0.  
"""
function gazevec_from_angle(angle_deg)
	# just x,y plane for now. gaze angle measured from front neutral gaze, not from x-axis
	return [sind(angle_deg) cosd(angle_deg) 0]
end

"""
Calculate the gaze vector in 3-D world coordinates, given the horizontal and vertical angles (in degrees) from center gaze direction i.e. looking straight ahead.
"""
function gazevec_from_angle_3d(angle_H, angle_V)
	# angles measured from center gaze position - use complementary angle for θ 
	return Array{Float32}(CartesianFromSpherical()(Spherical(1, deg2rad(90-angle_H), deg2rad(angle_V))))
end

"""
For the given gaze direction, return a weight value for each source point in the model: 1 for a cornea source, 0 for retina sources and all other points in the model. 

# Arguments
- `model`: Head model.
- `sim_idx`: Indices of the (eye) source points for which weights should be calculated.
- `gazedir`: The gaze direction vector.
- `max_cornea_angle_deg`: Angle (in degrees) made by the radial vector containing the cornea point farthest from the cornea center with the radial vector containing the cornea center.

# Returns
- `eyeweights`: Weights of the source points: 1 for a cornea source, 0 for retina sources and all other points in the model.
"""
function weights_from_gazedir(model, sim_idx, gazedir, max_cornea_angle_deg)
	eyeweights = zeros(size(model["pos"])[1]) # all sources other than those defined by sim_idx will be set to zero magnitude 
	eyeweights[sim_idx] .= mapslices(x -> is_corneapoint(x,gazedir,max_cornea_angle_deg), model["orientation"][sim_idx,:],dims=2)
	return eyeweights
end


function is_corneapoint(orientation, gazedir, max_cornea_angle_deg)
	if(angle_between(orientation,gazedir)<=max_cornea_angle_deg)
		return 1
	else 
		return -1
	end
end


function leadfield_from_gazedir(model, sim_idx, gazedir, max_cornea_angle_deg)
	mag_model = magnitude(model["leadfield"],model["orientation"])
	source_weights = zeros(size(model["pos"])[1]) # all sources other than those defined by sim_idx will be set to zero magnitude 
	source_weights[sim_idx] .= mapslices(x -> is_corneapoint(x,gazedir,max_cornea_angle_deg), model["orientation"][sim_idx,:],dims=2)

	# or, indirectly, 
	# weights = weights_from_gazedir(model, sim_idx, gazedir, max_cornea_angle_deg)
	
	weighted_sum = sum(mag_model[:,idx].* source_weights[idx] for idx in sim_idx,dims=2)
	return weighted_sum
end


function equiv_dipole_mag(model,idx,equiv_orientations)
	# take just a selected subset of points in the model, along with new orientations for those points, and calculate the sum of leadfields of just these points with the new orientations. 
	equiv_ori_model = model["orientation"]
	equiv_ori_model[idx,:] .= equiv_orientations[1:length(idx),:]
	mag_eyemodel_equiv = magnitude(eyemodel["leadfield"],equiv_ori_model)
	mag = sum(mag_eyemodel_equiv[:,ii] for ii in idx)
end

# TODO # create gaze direction vectors from 3d angles (azimuth, elevation) and hcat to create a matrix (gazevec_from_angle_3d.() outputs a vector of vectors)
# gazevectors_horiz = hcat(gazevec_from_angle_3d.(gd_horiz[:,1],gd_horiz[:,2]))


function sim_gazevecs_ensemble() # TODO rename this and turn it into a proper function. For now, moved here from pluto notebook
# simulate for gazevectors - ensemble method

    sim_srcs_idx = [eyemodel["eyeleft_idx"]; eyemodel["eyeright_idx"]] # indices in eyemodel, of the points which we want to use to simulate data, i.e. retina & cornea. used for ensemble simulation. 

	# leadfield for centre, to subtract for B-A method
	lf_center = leadfield_from_gazedir(eyemodel, sim_srcs_idx, gazevec_from_angle(0), 54.0384).*10e3

	# leadfields: matrix of dimensions [electrodes x n_gazepoints] 
	leadfields_ensemble = zeros(227,length(gazevectors))
	for ix in eachindex((gazevectors)) # 1:length(gazevectors) #TODO delete this comment once it's proven to work 
		# for each gazepoint, calculate the leadfield and store it in the corresponding column
		leadfields_ensemble[:,ix] = leadfield_from_gazedir(eyemodel, sim_srcs_idx,
			gazevectors[ix], 54.0384)
	end

	# calculate difference from centre gaze
	lf_ensemble_diff = zeros(size(leadfields_ensemble))
	for ix in 1:length(gazevectors)
		lf_ensemble_diff[:,ix] = leadfields_ensemble[:,ix] - lf_center
	end
	
	# "@NOTE calculating ensemble leadfields"
end

function plot_toposeries_lf(lf)
    dat, positions = lf, electrode_pos
    df = UnfoldMakie.eeg_array_to_dataframe(dat[:, :], string.(1:length(positions)))
    bin_width = 5
    f = plot_topoplotseries(
    df;
    bin_num=15,
    nrows=5,
    positions = positions,
    axis = (; xlabel = "Time windows [s]")
    )
end

function plot_potentials_lf(lf, xvals, title)
    fig_sp, ax_sp = series(xvals,lf[electrode_indices,:];labels=hart_small.electrodes["label"][electrode_indices], color=:Set1)
    ax_sp.title = title # "Standing potential for each angle. \nAngles " * string(minimum(xvals), " to ", maximum(xvals)) * sacc_direction
    axislegend(ax_sp;
    position=(1.29,0.5)
    )
    fig_sp
end

# plot into a figure passed in from outside, to get combination plots 
function plot_potentials_lf_fig(lf, xvals, title, fig_sp)
    fig_sp, ax_sp = series(xvals,lf[electrode_indices,:];labels=hart_small.electrodes["label"][electrode_indices], color=:Set1)
    ax_sp.title = title
    axislegend(ax_sp;
    position=(1.29,0.5)
    )
    fig_sp
end


# set_theme!()
# set_theme!(figure_padding = (10,100,10,10)) # for selected electrode plots, the legend overlaps the figure - add padding to accommodate this

function find_avg_gazedir()
    # finding cornea centers and approximate gaze direction (as mean of cornea orientations)
    cornea_center_R = Statistics.mean(eyemodel["pos"][lsi_eyemodel["EyeCornea_right"],:],dims=1)
    cornea_center_L = Statistics.mean(eyemodel["pos"][lsi_eyemodel["EyeCornea_left"],:],dims=1)
    gazedir_R = mean(eyemodel["orientation"][lsi_eyemodel["EyeCornea_right"],:], dims=1).*10
    gazedir_L = mean(eyemodel["orientation"][lsi_eyemodel["EyeCornea_left"],:], dims=1).*10
end

function import_model()

    # labels for which to find source indices
    labels = [
                r"EyeRetina_Choroid_Sclera_left$" # match the end of the search term, or else it also matches "leftright" sources.
				,r"EyeRetina_Choroid_Sclera_right$"
				,"EyeCornea_left" # new spherical eyemodel - only one set of sources per eye and the labels are different
				,"EyeCornea_right" # same as above
				,"EyeCenter_right"
				,"EyeCenter_left"
			]
   
    eyemodel = read_eyemodel(; p="HArtMuT_NYhead_extra_eyemodel_hull_mesh8_2025-03-01.mat")
    remove_indices = [164, 165, 166, 167] # since eyemodel structure doesn't exactly correspond to the main hartmut mat structure expected by the read_new_hartmut function, just get the indices of the electrodes that it drops & drop the same indices from eyemodel directly 
    eyemodel["leadfield"] = eyemodel["leadfield"][Not(remove_indices), :, :]

    lsi_eyemodel = hart_indices_from_labels(eyemodel,labels) 

    # import small headmodel temporarily for electrode positions, since eyemodel does not include them
	hart_small = UnfoldSim.headmodel()
	pos3d = hart_small.electrodes["pos"]
	electrode_pos = pos2dfrom3d(pos3d)

    return eyemodel, electrode_pos, lsi_eyemodel
end

"""
Calculate left/right eye indices, eye centers, orientations and add them to the eyemodel
"""
function setup_eyemodel(eyemodel, lsi_eyemodel)

	eyemodel_left_idx = [ 
		lsi_eyemodel["EyeCornea_left"] ; lsi_eyemodel[r"EyeRetina_Choroid_Sclera_left$"] 
	]
	eyemodel_right_idx = [ 
		lsi_eyemodel["EyeCornea_right"] ; lsi_eyemodel[r"EyeRetina_Choroid_Sclera_right$"] 
	]

	# For calculating orientations: get positions of left and right eye points in eyemodel, and their center (provided directly in spherical model)
	em_positions_L = eyemodel["pos"][eyemodel_left_idx,:]
	em_positions_R = eyemodel["pos"][eyemodel_right_idx,:]
	
	eye_center_L = eyemodel["pos"][lsi_eyemodel["EyeCenter_left"],:]
	eye_center_R = eyemodel["pos"][lsi_eyemodel["EyeCenter_right"],:]

	# calculate orientations away from center, later use negative weightage for the points where the source dipole points towards the center.
	eyemodel["orientation"] = zeros(size(eyemodel["pos"]))
	eyemodel["orientation"][eyemodel_right_idx,:] = calc_orientations(eye_center_R, em_positions_R; direction="away") 
	eyemodel["orientation"][eyemodel_left_idx,:] = calc_orientations(eye_center_L, em_positions_L; direction="away")
    eyemodel["eyeleft_idx"] = eyemodel_left_idx
    eyemodel["eyeright_idx"] = eyemodel_right_idx
    eyemodel["eyecenter_left_pos"] = eye_center_L
    eyemodel["eyecenter_right_pos"] = eye_center_R

    return eyemodel

end

function simulate_crd(gazevectors) # TODO add type & dimensions
    leadfields_crd = zeros(227,length(gazevectors)) # TODO replace hardcoded 227 with number of channels in model?
	eyecenter_idx = [lsi_eyemodel["EyeCenter_left"][1],lsi_eyemodel["EyeCenter_right"][1]] #TODO remove duplication of calculating center indices
	
	for ix in eachindex(gazevectors) # 1:length(gazevectors) #TODO delete this comment once it's proven to work
		# calculate leadfield due to 2 individual CRD sources and add
		leadfields_crd[:,ix] = (
			leadfield_specific_sources_orientations(deepcopy(eyemodel),eyecenter_idx,gazevectors[ix])
		)
	end

    return leadfields_crd
end

function leadfield_specific_sources_orientations(model,idx,equiv_orientations)
	# take just a selected subset of points in the model, along with a new orientation for those points, and calculate the sum of leadfields of just these points with the given orientation. 
    equiv_ori_model = model["orientation"]
    
    for ii in idx
        equiv_ori_model[ii,:] = equiv_orientations[:]
    end
    
    mag_eyemodel_equiv = magnitude(eyemodel["leadfield"],equiv_ori_model)
    mag = sum(mag_eyemodel_equiv[:,ii] for ii in idx)
    return mag
end



# ------------------------ for later reference

# difference wrt CPz (index 48)
# d1 = zeros(size(leadfields))
# for ix in 1:227
# 	d1[ix,:] = leadfields[ix,:] - leadfields[48,:]
# end

# difference between samples (consecutive angles)
# d2 = diff(leadfields,dims=2)
# fig_lineplots5, ax5, sp5 = series(gaze_angles_horiz[30:60],d2[electrode_indices,30:60];labels=hart_small.electrodes["label"][electrode_indices], color=:Set1)
# # series!(,d1[48,:];labels=["CPz"], color=:Set1)
# ax5.title = "Potential difference from prev.sample i.e. angle"
# axislegend(ax5; position=(1.29,0.5))
# fig_lineplots5
# leadfields
# d2
# @info "plotting potential difference from one sample (angle) to the next: just haphazardly went up and down, does not seem to be a good direction to go" 


# ------------------------

# WGLMakie.Page() # to fix issue of 3d plots not rendering properly

# ------------------------


# ------------------------

# ------------------------

# ------------------------