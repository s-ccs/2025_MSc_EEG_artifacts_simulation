### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 23857cee-df34-11ef-24e6-0b98415765a5
begin
	import Pkg
    Pkg.activate("../") #Base.current_project()
    # using Revise
	Pkg.develop(path="/home/marathe/Documents/2025IntegratingArtifacts/dev/UnfoldSim")
	# using UnfoldSim
	using UnfoldMakie, CairoMakie, Random, Serialization
end

# ╔═╡ c8dde41e-a694-4964-a978-4f105519d1b2
using UnfoldSim

# ╔═╡ e9ea9e19-1ed6-411f-a862-0bb772a72645
begin
	# Pkg.add("Plots")
	using Plots
end

# ╔═╡ 69d628ba-883f-43bf-9817-77a69053b379
# using Revise

# ╔═╡ 53213770-6d70-40c1-8bd6-7e9a456b9c3f
methods(UnfoldSim.simulate)

# ╔═╡ bf665393-bc7d-446f-a491-8e950324c657
Pkg.status()

# ╔═╡ 06a0bc16-4f38-4d94-8949-2634c4d93ba1
# pkgdir(UnfoldSim)

# ╔═╡ 41a646f1-efa3-42e5-86e5-4481b3b36c9d
@which UnfoldSim


# ╔═╡ 96cb7ba5-a136-4591-ad67-44b4c659b47b
begin
	# Pkg.add("UnfoldMakie")
	# using UnfoldMakie
end

# ╔═╡ 82263ed7-914a-4bd7-9727-d238774c2742
begin
	# Pkg.add("CairoMakie")
	# using CairoMakie
end	

# ╔═╡ b98592bc-2095-4ed1-a7e1-4ab3ab8e5715


# ╔═╡ c5b652ec-667a-456b-b234-a95f611e2647
# using Random

# ╔═╡ b8f869f3-47f4-4939-81e1-794317f78395
methods(UnfoldSim.az_simulation)

# ╔═╡ 4957f22c-ec41-4938-a03d-e4eee05575dd
begin
	combined_eeg_artifacts1, signal1, evts = UnfoldSim.az_simulation()
end

# ╔═╡ 3c16ed10-2719-459f-b920-876175353e42
begin
	Plots.plot(combined_eeg_artifacts1[2][1:10,:]', label =  ["AF3" "AF3h" "AF4" "AF4h" "AF5h" "AF6h" "AF7" "AF8" "AFF1h" "AFF2h"], legend=:outerright)
	Plots.title!("Eye Movement simulation")
	Plots.ylabel!("Voltage level (relative)")
	Plots.xlabel!("Time (ms)")
end

# ╔═╡ fa79b974-cc89-4f76-bd51-c6e9afeed74c
# sum_eeg_artifacts = reduce(+,combined_eeg_artifacts); "Adding eeg and Eyemovement artifacts"

# ╔═╡ 1a851868-5cc7-4e40-9e26-8c4f3f664e2c
# plot(combined_eeg_artifacts[1][:,:]') # only eeg

# ╔═╡ 16ac7ae0-163d-46de-90fc-3272260906e1
# ╠═╡ disabled = true
#=╠═╡
begin
	fff = UnfoldMakie.plot_butterfly(combined_eeg_artifacts[2][1:10,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Eye Movement simulation")) # only eyemovement artifact
end
  ╠═╡ =#

# ╔═╡ e4d85860-333e-4763-88c6-75db34d60409
# UnfoldMakie.plot_butterfly(combined_eeg_artifacts[1][:,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "EEG simulation")) # only eeg

# ╔═╡ 555d4efa-e6c7-4e46-8569-b13e476c8370
# plot(pln[1:100]) # only power line noise + drift

# ╔═╡ 00435898-445c-4000-a4d1-b1a6d16822f6
# plot(sum_eeg_artifacts[1:10,:]') # eeg + artifacts.

# ╔═╡ 635b2f46-02a7-4ab1-a9b7-3469bba170f5
# plot(signal[[157, 72, 154, 151, 48],:]') # selected channels

# ╔═╡ da2e6e47-bce1-4b29-8582-c2117c43205e
# plot(signal[:,:]') # eeg + artifacts + PLN + noise

# ╔═╡ a638178a-6e03-4a18-816d-f3062e539b04
# using Serialization

# ╔═╡ 1dfcdc02-2a87-4a7e-9397-d4b255df1d23
begin
	# eyemodel = UnfoldSim.import_eyemodel()
	# href_trajectory = UnfoldSim.example_data_eyemovements()[1:2,1:600].*(180/pi)
	# combined_eeg_artifacts, signal, pln, evts = simulate(
	# 	Random.MersenneTwister(1), design, mc, onset,
	# 	[UnfoldSim.EyeMovement(UnfoldSim.HREFCoordinates(href_trajectory), eyemodel, "crd"); 
	# 	 noise; 
	# 	 UnfoldSim.PowerLineNoise([0. 0; 0 0], 50., [1, 3, 5], [0.1, 0.1, 0], 1000.)
	# 	 ]); #PLN
	"Simulating with UnfoldSimArtifacts"
end

# ╔═╡ 86ffe632-f3e3-47c1-bc61-d5741e8732cd
begin
	# mydata = (combined_eeg_artifacts, signal, pln, evts) 
	# # serialize("combined_eeg_artifacts", combined_eeg_artifacts) 
	# # serialize("signal", signal) 
	# # serialize("pln", pln)
end

# ╔═╡ c5bf6b4e-5638-4155-b328-8512f8123cec
begin
	combined_eeg_artifacts = deserialize("combined_eeg_artifacts") 
	signal = deserialize("signal") 
	pln = deserialize("pln")
end

# ╔═╡ 70c3213a-e075-49f9-9908-9e5b62672cf0
begin
	# lbls = hart.electrodes["label"][1:10]
	# @show lbls
	Plots.plot(combined_eeg_artifacts[2][1:10,:]', label =  ["AF3" "AF3h" "AF4" "AF4h" "AF5h" "AF6h" "AF7" "AF8" "AFF1h" "AFF2h"], legend=:outerright)
	Plots.title!("Eye Movement simulation")
	Plots.ylabel!("Voltage level (relative)")
	Plots.xlabel!("Time (ms)")
end

# ╔═╡ 7f03ba8a-5f3a-4b1a-b08d-28388398b7d9
begin
	ffff = UnfoldMakie.plot_butterfly(combined_eeg_artifacts[2][1:10,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Eye Movement simulation")) # only eyemovement artifact
end

# ╔═╡ 8cf37efd-3275-450a-9070-d5a0c8446071
begin
	ff = UnfoldMakie.plot_erp(combined_eeg_artifacts[2][1:10,:]', layout = (; use_legend = true), axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Eye Movement simulation"), ) # only eyemovement artifact channel=hart.electrodes["label"][1:10],
	# Legend(f[1,1],label=hart.electrodes["label"][1:10])
end

# ╔═╡ 9127815b-1f2f-4016-b2e9-84a1d8aeebbc
UnfoldMakie.plot_butterfly(signal[:,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Combined simulation")) # everything combined

# ╔═╡ 75ecd944-9687-421e-bd02-166816ad4fe3
UnfoldMakie.plot_butterfly(signal.-combined_eeg_artifacts[1].-combined_eeg_artifacts[2], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Noise")) # everything combined

# ╔═╡ 1caca80d-2544-4b8c-83be-80089dfaecec
UnfoldMakie.plot_erp(pln, axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Power Line Noise - identical for all channels"), layout = (; use_colorbar = false), legend = (;label="noise"))

# ╔═╡ d75076c6-3a8d-4e84-b580-e24fb2dc9e86
begin
	f = Figure()

	ax = Axis(f[1, 1], ylabel = "Voltage level (relative)", xlabel = "Time (ms)", title = "Power Line Noise - identical for all channels")

	CairoMakie.lines!(pln[:])
	f
end

# ╔═╡ 3359cb69-ff23-4b2a-8a7d-4a7576c70ac4
# methods(UnfoldMakie.plot_erp)

# ╔═╡ 09f8f2df-15ff-44ff-809f-88e2deb17994
# plot(signal.-combined_eeg_artifacts[1].-combined_eeg_artifacts[2])

# ╔═╡ d5e9125b-ba15-42a5-a3b3-de7abece08e9
begin
	# design = SingleSubjectDesign(; conditions = Dict(:cond_A => ["level_A", "level_B"])) |> x -> RepeatDesign(x, 10);
 #    component = LinearModelComponent(;
 #    basis = [0, 0, 0, 0.5, 1, 1, 0.5, 0, 0],
 #    formula = @formula(0 ~ 1 + cond_A),
 #    β = [1, 0.5],
 #    );
    hart = Hartmut();
 #    mc = UnfoldSim.MultichannelComponent(component, hart => "Left Postcentral Gyrus");
 #    onset = UniformOnset(; width = 20, offset = 4);
 #    noise = PinkNoise(; noiselevel = 0.2);
	# data, events = simulate(design, mc, onset);
	@show "manual simulation"
end

# ╔═╡ ab734329-3815-4f2d-8eed-f32f899f203a
sampledata = UnfoldSim.example_data_eyemovements().*(180/pi)

# ╔═╡ 344358bf-9c69-4601-985a-7dfa57ce9f8b
begin
	lbls = ["eyegaze x" "eyegaze y"]
	@show lbls
	Plots.plot(sampledata[[1,2],1:600]', label = ["x" "y"], titlefont = font(10),)
	Plots.title!("Eye tracking data, left eye")
	Plots.ylabel!("Angle (degrees)")
	Plots.xlabel!("Time (ms)")
end

# ╔═╡ 7e42b9cc-97f3-44cf-af13-11f00273d35d
combined_eeg_artifacts

# ╔═╡ cb75543c-0098-48e9-a4fd-94b12e8aa6e6
begin
	# plot(sampledata[[1,2],:]') # HREF traces left eye
	# fig = Figure()
	# ax = Axis(fig[1, 1],
 #    title = "Simulated eye movements",
 #    xlabel = "Time (ms)",
 #    ylabel = "Value",
	# )
	# fig, ax, sp = series(combined_eeg_artifacts[2][1:7,:], labels=["label $i" for i in 1:7]) #, labels=["label $i" for i in 1:4]
	# axislegend(ax)
	# fig
	# lines(sampledata[2,:])
	# HREF traces left eye
	# fig
end

# ╔═╡ 6a1cb618-b564-4471-875c-668175bcbf90
UnfoldMakie.plot_erp(combined_eeg_artifacts[2])

# ╔═╡ 0722f13a-d0f3-4137-b1af-b12e3b652e1e
# plot(combined_eeg_artifacts[2]')
# size(combined_eeg_artifacts[2])

# ╔═╡ 0c236147-c862-410b-bd17-8a8321090249
# plot(combined_eeg_artifacts[2][[157, 72, 154, 151, 48],:]') # only artifact

# ╔═╡ 27c1828d-4e9d-44e4-82c4-4b9372d38ba7
# plot(combined_eeg_artifacts[2][[ 157],:]') # only artifact

# ╔═╡ c55a1849-17b3-4654-8ab6-5fe800749fdf
# plot(combined_eeg_artifacts[2][[ 72],:]')

# ╔═╡ ab0c17f6-f0c8-4260-9b87-a169b911e5df
begin
	# veog = combined_eeg_artifacts[2][157,:] - combined_eeg_artifacts[2][72,:]
	# plot(veog)
end

# ╔═╡ ebb871f3-e3f4-453e-8e49-f164c6799149
begin
	# heog = combined_eeg_artifacts[2][154,:] - combined_eeg_artifacts[2][151,:]
	# plot([heog, veog])
end

# ╔═╡ 7b68914d-1494-4efe-b5a3-4e3b584010ff
begin
	electrode_indices = [157, 72, 154, 151, 48]  # Fp1, Ex33, FT9, FT10 as VEOGU/L and HEOGL/R
	# hart.electrodes["label"][electrode_indices]
end

# ╔═╡ Cell order:
# ╠═23857cee-df34-11ef-24e6-0b98415765a5
# ╠═69d628ba-883f-43bf-9817-77a69053b379
# ╠═c8dde41e-a694-4964-a978-4f105519d1b2
# ╠═53213770-6d70-40c1-8bd6-7e9a456b9c3f
# ╠═bf665393-bc7d-446f-a491-8e950324c657
# ╠═06a0bc16-4f38-4d94-8949-2634c4d93ba1
# ╠═41a646f1-efa3-42e5-86e5-4481b3b36c9d
# ╠═96cb7ba5-a136-4591-ad67-44b4c659b47b
# ╠═e9ea9e19-1ed6-411f-a862-0bb772a72645
# ╠═82263ed7-914a-4bd7-9727-d238774c2742
# ╠═b98592bc-2095-4ed1-a7e1-4ab3ab8e5715
# ╠═c5b652ec-667a-456b-b234-a95f611e2647
# ╠═b8f869f3-47f4-4939-81e1-794317f78395
# ╠═4957f22c-ec41-4938-a03d-e4eee05575dd
# ╠═3c16ed10-2719-459f-b920-876175353e42
# ╠═fa79b974-cc89-4f76-bd51-c6e9afeed74c
# ╠═1a851868-5cc7-4e40-9e26-8c4f3f664e2c
# ╠═70c3213a-e075-49f9-9908-9e5b62672cf0
# ╠═344358bf-9c69-4601-985a-7dfa57ce9f8b
# ╠═16ac7ae0-163d-46de-90fc-3272260906e1
# ╠═7f03ba8a-5f3a-4b1a-b08d-28388398b7d9
# ╠═8cf37efd-3275-450a-9070-d5a0c8446071
# ╠═e4d85860-333e-4763-88c6-75db34d60409
# ╠═9127815b-1f2f-4016-b2e9-84a1d8aeebbc
# ╠═75ecd944-9687-421e-bd02-166816ad4fe3
# ╠═1caca80d-2544-4b8c-83be-80089dfaecec
# ╠═d75076c6-3a8d-4e84-b580-e24fb2dc9e86
# ╠═555d4efa-e6c7-4e46-8569-b13e476c8370
# ╠═00435898-445c-4000-a4d1-b1a6d16822f6
# ╠═635b2f46-02a7-4ab1-a9b7-3469bba170f5
# ╠═da2e6e47-bce1-4b29-8582-c2117c43205e
# ╠═a638178a-6e03-4a18-816d-f3062e539b04
# ╠═1dfcdc02-2a87-4a7e-9397-d4b255df1d23
# ╠═86ffe632-f3e3-47c1-bc61-d5741e8732cd
# ╠═c5bf6b4e-5638-4155-b328-8512f8123cec
# ╠═3359cb69-ff23-4b2a-8a7d-4a7576c70ac4
# ╠═09f8f2df-15ff-44ff-809f-88e2deb17994
# ╠═d5e9125b-ba15-42a5-a3b3-de7abece08e9
# ╠═ab734329-3815-4f2d-8eed-f32f899f203a
# ╠═7e42b9cc-97f3-44cf-af13-11f00273d35d
# ╠═cb75543c-0098-48e9-a4fd-94b12e8aa6e6
# ╠═6a1cb618-b564-4471-875c-668175bcbf90
# ╠═0722f13a-d0f3-4137-b1af-b12e3b652e1e
# ╠═0c236147-c862-410b-bd17-8a8321090249
# ╠═27c1828d-4e9d-44e4-82c4-4b9372d38ba7
# ╠═c55a1849-17b3-4654-8ab6-5fe800749fdf
# ╠═ab0c17f6-f0c8-4260-9b87-a169b911e5df
# ╠═ebb871f3-e3f4-453e-8e49-f164c6799149
# ╠═7b68914d-1494-4efe-b5a3-4e3b584010ff
