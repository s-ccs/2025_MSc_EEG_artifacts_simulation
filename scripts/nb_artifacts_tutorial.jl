### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 3765244f-6300-48bc-9430-e0be3df919c5
begin
	import Pkg
	Pkg.activate("../")
	Pkg.develop(path="/home/marathe/Documents/2025IntegratingArtifacts/dev/UnfoldSim")
end

# ╔═╡ c9f74a3a-69e8-4f20-ad1d-46b4a6480f2d
begin
		Pkg.add([ "Random", "Revise", "UnfoldMakie", "CairoMakie"])
		using Random, Revise, UnfoldMakie, CairoMakie
end

# ╔═╡ 21bb1ba0-fd31-43dd-8119-dd3d23eb954d
using UnfoldSim

# ╔═╡ 272803be-0eab-4986-9b59-b9f890690fab
begin
	design = SingleSubjectDesign(; conditions = Dict(:cond_A => ["level_A", "level_B"])) |> x -> RepeatDesign(x, 10);
    signal = LinearModelComponent(;
    basis = [0, 0, 0, 0.5, 1, 1, 0.5, 0, 0],
    formula = @formula(0 ~ 1 + cond_A),
    β = [1, 0.5],
    );
    hart = Hartmut();
    mc = UnfoldSim.MultichannelComponent(signal, hart => "Left Postcentral Gyrus");
    onset = UniformOnset(; width = 20, offset = 4);
    noise = PinkNoise(; noiselevel = 0.2);
	"Create design, component, onset, noise objects"
end

# ╔═╡ a0ba8c98-09cd-4784-a6c0-5bbea31b5b39
begin
	# import hartmut model - modified with new eye points
    eyemodel = UnfoldSim.import_eyemodel()

    # import eyegaze coordinates (in head-referenced angle units) for controlsignal
    sample_data = UnfoldSim.example_data_eyemovements()
    href_trajectory = sample_data[1:2,1:300].*(180/pi) # convert to degrees
end

# ╔═╡ 4c45ef48-c569-4dd3-905e-e6c174c1d6b9
@info "SECTION 1: Simulate EEG + noise + artifacts"

# ╔═╡ 50b41b96-2764-482a-bac5-1a0181855bf7
begin
# Simulate EEG with multiple artifacts (all three kinds, together)

eeg_artifacts, events, split_elements = 
	simulate(MersenneTwister(1), design, mc, onset, 
			 [noise; UnfoldSim.EyeMovement(UnfoldSim.HREFCoordinates(href_trajectory), eyemodel, "crd"); 
			  # UnfoldSim.PowerLineNoise(); 
			  UnfoldSim.PowerLineNoise(base_freq=50, harmonics=[1 3], weights_harmonics=[0.5 0.1], sampling_rate=1000); 
			  UnfoldSim.DCDriftNoise(scaling_factor=20); UnfoldSim.LinearDriftNoise(scaling_factor=20);UnfoldSim.ARDriftNoise()]);
end

# ╔═╡ 4029ee6d-656f-461d-9923-8604800436c7
begin
	f1 = UnfoldMakie.plot_butterfly(split_elements[1].+split_elements[2], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (samples)", title = "UnfoldSim: EEG with noise (all channels)"))
	# vlines!(events.latency; color = ["orange", "teal"][1 .+ (events.cond_A.=="level_B")]) # mark the events 
	f1
end

# ╔═╡ 8c09f46b-513a-490f-ba93-eafddde7e481
begin
	f2_1 = Figure()
	ax2_1 = f2_1[1, 1] = Axis(f2_1)

	lines!(href_trajectory[1,:], label = "eye gaze x";)
	lines!(href_trajectory[2,:], label = "eye gaze y";)
	

	axislegend( position = :lb)
	
	ax2_1.title = "Eye tracking data: Left eye, head referenced (HREF) angles"
	ax2_1.xlabel = "Time (samples)"
	ax2_1.ylabel = "Angle (degrees)"
	
	f2_1
end

# ╔═╡ 25e7f2ee-d396-46ae-a00f-36f9164c5d0c
begin
	f2 = UnfoldMakie.plot_butterfly(split_elements[3][:,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (samples)", title = "Eye movement artifact (all channels)"))
	f2
end

# ╔═╡ 395e3932-0420-438d-b535-e2bb3cdc54b1
begin
	f3 = UnfoldMakie.plot_butterfly(split_elements[4], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (samples)", title = "50Hz Power Line Noise (identical for all channels):\n1st and 3rd harmonics relatively weighted 5 and 1 respectively"))
	f3
end

# ╔═╡ 55de3606-780d-4537-9a6e-67e3e6a96cc6
begin
	# save("../plots/results_2_eyemovement.svg",f2)
	# save("../plots/results_2_1_eyetraces.svg",f2_1)
	# save("../plots/results_3_pln.svg",f3)
	# save("../plots/results_4_drift_alltogether.svg",f4)
	# save("../plots/results_4_drift_split.svg",f_drift)	
end

# ╔═╡ 1ff80611-ed03-4bb2-b05b-15bfb19d6775
begin
	f4 = UnfoldMakie.plot_butterfly(split_elements[5].+split_elements[6].+split_elements[7], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (samples)", title = "Drift: all channels, combined DC+Linear+Autoregressive"))
	f4
end

# ╔═╡ 2564031b-5638-48cf-af52-b7bf022fa1fa
begin
	f5 = UnfoldMakie.plot_butterfly(eeg_artifacts[:,:], axis = (; ylabel = "Voltage level (relative)", xlabel = "Time (samples)", title = "Final EEG with artifacts"))
	
	# vlines!(events.latency; color = ["orange", "teal"][1 .+ (events.cond_A.=="level_B")])
	f5
end

# ╔═╡ b04b7b83-fa63-4304-a4fd-1133575ca314
begin
	save("../plots/results_5_all_together.svg",f5)
	# save("../plots/results_1_eeg_noise.svg",f1)
end

# ╔═╡ 935c79c3-23ad-4aaa-8f40-352e28c87b5e
begin
	f_drift = Figure()
	ax = f_drift[1, 1] = Axis(f_drift)

	lines!(split_elements[5][1, :], label = "DC";)
	lines!(split_elements[6][1, :], label = "Linear";)
	lines!(split_elements[7][1, :], label = "Autoregressive";)
	lines!(split_elements[5][1, :].+split_elements[6][1, :].+split_elements[7][1, :], label = "Combined drift noise";)
	

	axislegend( position = :lb)
	
	ax.title = "Simulated drift artifact, single channel"
	ax.xlabel = "Time (samples)"
	ax.ylabel = "Voltage level (relative)"
	
	f_drift
end

# ╔═╡ 12fbf10e-e88f-429d-a887-8f905e94ac76
begin
	# lines(eeg_artifacts[1,:]; color="green")
	# current_axis().title = "Simulated EEG data with all artifacts: single channel"
	# current_axis().xlabel = "Time [samples]"
	# current_axis().ylabel = "Amplitude [μV]"
	
	# current_figure()
	"Sample code to plot single channel of the combined eeg+artifacts"
end

# ╔═╡ 25fa0151-817f-4710-b471-b070a87dc1e3


# ╔═╡ b5e187ed-52fe-4fe4-8359-febf2ba52793
@info "SECTION 2: Simulate once, store to file, retrieve from file instead of re-simulating each time (e.g. EEG, noise, power line noise)"

# ╔═╡ e949cda8-cdad-4256-9c49-afe1c51d740f
begin
	# combined_eeg_artifacts, signal, pln, evts = simulate(
	# 	Random.MersenneTwister(1), design, mc, onset,
	# 	[UnfoldSim.EyeMovement(UnfoldSim.HREFCoordinates(href_trajectory), eyemodel, "crd"); 
	# 	 noise; 
	# 	 UnfoldSim.PowerLineNoise(base_freq=50, harmonics=[1, 3], weights_harmonics=[0.1, 0.1], sampling_rate=1000)
	# 	 ]);
	# # serialize("combined_eeg_artifacts", combined_eeg_artifacts) 
	# # serialize("signal", signal) 
	# # serialize("pln", pln)
	"Here is how you simulate then save the data to files"
end

# ╔═╡ 159dd214-7157-4fa0-b2e3-0976f9925fbd
begin
	# combined_eeg_artifacts = deserialize("combined_eeg_artifacts") 
	# signal = deserialize("signal") 
	# pln = deserialize("pln")
	"Here is how you retrieve data from the file"
end

# ╔═╡ Cell order:
# ╠═3765244f-6300-48bc-9430-e0be3df919c5
# ╠═21bb1ba0-fd31-43dd-8119-dd3d23eb954d
# ╠═c9f74a3a-69e8-4f20-ad1d-46b4a6480f2d
# ╠═272803be-0eab-4986-9b59-b9f890690fab
# ╠═a0ba8c98-09cd-4784-a6c0-5bbea31b5b39
# ╠═4c45ef48-c569-4dd3-905e-e6c174c1d6b9
# ╠═50b41b96-2764-482a-bac5-1a0181855bf7
# ╠═4029ee6d-656f-461d-9923-8604800436c7
# ╠═8c09f46b-513a-490f-ba93-eafddde7e481
# ╠═25e7f2ee-d396-46ae-a00f-36f9164c5d0c
# ╠═395e3932-0420-438d-b535-e2bb3cdc54b1
# ╠═b04b7b83-fa63-4304-a4fd-1133575ca314
# ╠═55de3606-780d-4537-9a6e-67e3e6a96cc6
# ╠═1ff80611-ed03-4bb2-b05b-15bfb19d6775
# ╠═2564031b-5638-48cf-af52-b7bf022fa1fa
# ╠═935c79c3-23ad-4aaa-8f40-352e28c87b5e
# ╟─12fbf10e-e88f-429d-a887-8f905e94ac76
# ╠═25fa0151-817f-4710-b471-b070a87dc1e3
# ╟─b5e187ed-52fe-4fe4-8359-febf2ba52793
# ╠═e949cda8-cdad-4256-9c49-afe1c51d740f
# ╟─159dd214-7157-4fa0-b2e3-0976f9925fbd
