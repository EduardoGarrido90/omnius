:- set_prolog_flag(verbose, silent).
:- initialization(main).
:- include('priors.pl').
:- include('experiments/real/first_experiment/likelihoods.pl').
:- include('bayesian_utils.pl').

%Box %Mueller %transformation %for %Gaussian %samples.
standard_gaussian_sampler(N, M) :-
    random(U1), random(U2),
    Z0 is sqrt(-2 * log(U1)) * cos(2*pi*U2),
    Z1 is sqrt(-2 * log(U1)) * sin(2*pi*U2),
    N is Z0,
    M is Z1.

%Scale %location %transformation.
%Bayesian %sample.
gaussian_sample(X, Y, Mean, Variance) :- 
	standard_gaussian_sampler(X1,Y1), 
	X is Variance * X1 + Mean,
	Y is Variance * Y1 + Mean.

gaussian_sampler(0, [], _, _):-!.
gaussian_sampler(N, [X,Y|L], Mean, Variance):- 
	M is N-1, 
	gaussian_sampler(M, L, Mean, Variance), 
	gaussian_sample(X, Y, Mean, Variance).

bayesian_inference(PriorDistribution, LikelihoodDistribution, PosteriorDistribution) :-
        multiply_grids(PriorDistribution, LikelihoodDistribution, UnstdPosteriorDistribution),
        sum_grid(UnstdPosteriorDistribution, SumPosteriorDistribution),
        divide_grid(UnstdPosteriorDistribution, PosteriorDistribution, SumPosteriorDistribution).

sample_grid_from_params(DistributionName, [Lambda, Rev], Resolution, PriorDistribution) :-
        DistributionName = 'exponential',
	Rev is -1,
	reverted_exp_pdf(Resolution, PriorDistribution, Lambda).

sample_grid_from_params(DistributionName, [Lambda, Rev], Resolution, PriorDistribution) :-
        DistributionName = 'exponential',
        Rev is 1,
        draw_exp_pdf(Resolution, PriorDistribution, Lambda).	
	
sample_grid_from_params(DistributionName, [Alpha, Beta, Rev], Resolution, PriorDistribution) :-
        DistributionName = 'beta',
	Rev is -1,
	reverted_beta_pdf(Resolution, PriorDistribution, Alpha, Beta).

sample_grid_from_params(DistributionName, [Alpha, Beta, Rev], Resolution, PriorDistribution) :-
        DistributionName = 'beta',
        Rev is 1,
        draw_beta_pdf(Resolution, PriorDistribution, Alpha, Beta).

sample_grid_from_params(DistributionName, [Mean, Variance], Resolution, PriorDistribution) :-
	DistributionName = 'gaussian',
	draw_gaussian_pdf(Resolution, PriorDistribution, Mean, Variance).


loop_through_grid(File, [Head|[]]) :- 
	write(File, Head),!.

loop_through_grid(File, [Head|Tail]) :-
    write(File, Head),
    write(File, ', '),
    loop_through_grid(File, Tail).
	
grid_to_file(Grid, Cause, Effect, Filename, Message) :-	
    open(Filename, append, File),
    write(File, 'Cause: '),
    write(File, Cause),
    write(File, ', Effect: '),
    write(File, Effect),
    write(File, '. '),
    write(File, Message),
    write(File, ' ['),
    loop_through_grid(File, Grid),
    write(File, ']\n'),
    close(File).

%Designed to be called for multiple causals.
multiply_causal_grids_and_print(X,Y,Z,Filename) :-
        multiply_grids(X,Y,Z),
	open(Filename, append, File),
        loop_through_grid(File, Z),
	close(File).

compute_posterior_for_causal(Cause, Effect, PriorDistribution, PosteriorDistribution, LikelihoodId, File, Resolution) :-
	print('Computing partial posterior'),
        likelihood(Cause, Effect, Adverb, LikelihoodId),
        prior(Adverb, DistributionName, Params),
        sample_grid_from_params(DistributionName, Params, Resolution, LikelihoodDistribution),
	print('Performing Bayesian Inference'),
        bayesian_inference(PriorDistribution, LikelihoodDistribution, StepPosteriorDistribution),
	print('Bayesian Inference Performed'),
        grid_to_file(StepPosteriorDistribution, Cause, Effect, File, 'Partial posterior distribution:'),
        NextLikelihood is LikelihoodId + 1,
        compute_posterior_for_causal(Cause, Effect, StepPosteriorDistribution, PosteriorDistribution, NextLikelihood, File, Resolution).

compute_posterior_for_causal(_, _, PosteriorDistribution, PosteriorDistribution, _, _, _):-
	print('All causals analyzed'), !.  %Stop %rule %if %no %new %likelihood %is %found.

compute_posterior_for_causal(Cause, Effect, PosteriorDistribution, Resolution, File, PosteriorAdverb, PriorEntropy, PosteriorEntropy) :-
	print('Computing posterior for causal initial method'),
	likelihood(Cause, Effect, Adverb, 1), 
	prior(Adverb, DistributionName, Params),
	sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	grid_to_file(PriorDistribution, Cause, Effect, File, 'Prior Distribution:'),
	compute_posterior_for_causal(Cause, Effect, PriorDistribution, PosteriorDistribution, 2, File, Resolution),
	grid_to_file(PosteriorDistribution, Cause, Effect, File, 'Posterior Distribution:'),
	print('Posterior computed'),
	compute_min_adverb_KL_divergence(PosteriorDistribution, Resolution, PosteriorAdverb),
	normalize_distribution(PriorDistribution, Npri),
	normalize_distribution(PosteriorDistribution, Npos),
	compute_entropy(Npri, PriorEntropy),	
	compute_entropy(Npos, PosteriorEntropy),
	print('END OF THE BAYESIAN INFERENCE').	

compute_KL_divergence([], [], 0).

compute_KL_divergence([X|ProposalDistribution], [Y|ObjectiveDistribution], KLDivergence) :-
	compute_KL_divergence(ProposalDistribution, ObjectiveDistribution, KLStepPrevious),
	KLDivergence is KLStepPrevious + ( X * log( (X+0.00000001) / (Y+0.00000001) ) ).

priv_compute_entropy([], 0).
priv_compute_entropy([X|Distribution], Entropy) :-
	priv_compute_entropy(Distribution, PreviousEntropy),
	Entropy is PreviousEntropy + ( X + 0.000000001 )*( log(X + 0.000000001) ).

compute_entropy(D,E) :-
	priv_compute_entropy(D,E1),
	E is - E1.

biggest_entropy(Resolution, Maximum, [], PriorId, ChosenPrior, Adverb, _) :-
	PriorId > 14,
	prior(Adverb, DistributionName, Params, ChosenPrior),
	prior(_, DistributionName, Params, ChosenPrior),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	normalize_distribution(PriorDistribution, NormalizedDistribution),
        compute_entropy(NormalizedDistribution, Maximum), !.

biggest_entropy(Resolution, Maximum, [Entropy|Entropies], PriorId, _, Adverb, CurrentMaximum) :-
	NextPrior is PriorId + 1,
	prior(_, DistributionName, Params, PriorId),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	normalize_distribution(PriorDistribution, NormalizedDistribution),
        compute_entropy(NormalizedDistribution, Entropy),
	Entropy > CurrentMaximum,
	biggest_entropy(Resolution, Maximum, Entropies, NextPrior, PriorId, Adverb, Entropy).
	
biggest_entropy(Resolution, Maximum, [Entropy|Entropies], PriorId, ChosenPrior, Adverb, CurrentMaximum) :-
        NextPrior is PriorId + 1,
        prior(_, DistributionName, Params, PriorId),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	normalize_distribution(PriorDistribution, NormalizedDistribution),
        compute_entropy(NormalizedDistribution, Entropy),
        Entropy < CurrentMaximum,
        biggest_entropy(Resolution, Maximum, Entropies, NextPrior, ChosenPrior, Adverb, CurrentMaximum).

compute_biggest_entropy(Resolution, Maximum, Entropies, Adverb) :-
	biggest_entropy(Resolution, Maximum, Entropies, 1, 1, Adverb, 0).

compute_normalized_distribution([],_,[]):-!.

compute_normalized_distribution([X|D],S,[Y|N]):-
	compute_normalized_distribution(D,S,N),
	Y is X / (S+0.000000001).

normalize_distribution(Distribution, NormalizedDistribution) :-
	sum_grid(Distribution, Sum),
	compute_normalized_distribution(Distribution, Sum, NormalizedDistribution).

%Es importante si se van a usar mas priores aumentar el numero de priores ahí en la primera linea del consecuente.
traverse_prior_adverbs(_, _, Adverb, _, PriorId, ChosenPrior):-
	PriorId > 14,
        prior(Adverb, _, _, ChosenPrior).

traverse_prior_adverbs(ProposalDistribution, Resolution, Adverb, KLDivergence, PriorId, ChosenPrior):-
	NextPrior is PriorId + 1,
        prior(_, DistributionName, Params, PriorId),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
        compute_KL_divergence(ProposalDistribution, PriorDistribution, KLDivergenceProposed),
        KLDivergenceProposed >= KLDivergence,
	traverse_prior_adverbs(ProposalDistribution, Resolution, Adverb, KLDivergence, NextPrior, ChosenPrior).

traverse_prior_adverbs(ProposalDistribution, Resolution, Adverb, KLDivergence, PriorId, _):-
	NextPrior is PriorId + 1,
	prior(_, DistributionName, Params, PriorId),
	sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	compute_KL_divergence(ProposalDistribution, PriorDistribution, KLDivergenceProposed),
	KLDivergenceProposed < KLDivergence,
	traverse_prior_adverbs(ProposalDistribution, Resolution, Adverb, KLDivergenceProposed, NextPrior, PriorId).

traverse_prior_adverbs_max(ProposalDistribution, Resolution, Max, _, PriorId, ChosenPrior):-
        PriorId > 14,
	prior(_, DistributionName, Params, ChosenPrior),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
        compute_KL_divergence(ProposalDistribution, PriorDistribution, Max).

traverse_prior_adverbs_max(ProposalDistribution, Resolution, Max, Current, PriorId, ChosenPrior):-
        NextPrior is PriorId + 1,
        prior(_, DistributionName, Params, PriorId),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	normalize_distribution(PriorDistribution, N),
        compute_KL_divergence(ProposalDistribution, N, KLDivergenceProposed),
        KLDivergenceProposed >= Current,
        traverse_prior_adverbs_max(ProposalDistribution, Resolution, Max, Current, NextPrior, ChosenPrior).

traverse_prior_adverbs_max(ProposalDistribution, Resolution, Max, Current, PriorId, _):-
        NextPrior is PriorId + 1,
        prior(_, DistributionName, Params, PriorId),
        sample_grid_from_params(DistributionName, Params, Resolution, PriorDistribution),
	normalize_distribution(PriorDistribution, N),
        compute_KL_divergence(ProposalDistribution, N, KLDivergenceProposed),
        KLDivergenceProposed < Current,
        traverse_prior_adverbs_max(ProposalDistribution, Resolution, Max, KLDivergenceProposed, NextPrior, PriorId).

compute_min_adverb_KL_divergence(ProposalDistribution, Resolution, Adverb) :-
	traverse_prior_adverbs(ProposalDistribution, Resolution, Adverb, 0, 1, 1).

compute_max_KL_divergence(ProposalDistribution, Resolution, Kl):-
        traverse_prior_adverbs_max(ProposalDistribution, Resolution, Kl, 0, 1, 1).

prob_fake_new(PriorDistribution, _, PosteriorDistribution, 0, _) :-
	normalize_distribution(PriorDistribution, Npri),
	normalize_distribution(PosteriorDistribution, Npos),
	compute_entropy(Npri, PriorEntropy),
	compute_entropy(Npos, PosteriorEntropy),
	PosteriorEntropy > PriorEntropy, !.
	
prob_fake_new(_, LikelihoodDistribution, PosteriorDistribution, ProbFakeNew, Resolution) :-
        normalize_distribution(LikelihoodDistribution, Lpos),
        normalize_distribution(PosteriorDistribution, Npos),
        compute_entropy(Npos, PosteriorEntropy),
	compute_biggest_entropy(Resolution, Maximum, _, _),
	compute_max_KL_divergence(Lpos, Resolution, MaxKl),
	compute_KL_divergence(Npos, Lpos, Kl),
	DivergenceFactor is Kl / MaxKl,
	EntropyFactor is 1.0 - (PosteriorEntropy / Maximum), 
	ProbFakeNew is sqrt(sqrt(DivergenceFactor * EntropyFactor)).
	
compute_prob_fake_new(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, 1, Resolution) :-
	prob_fake_new(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, P, Resolution),
	P > 1,!.

compute_prob_fake_new(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, P, Resolution) :-
        prob_fake_new(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, P, Resolution),!.

learn_causal(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, Resolution, Threshold, 0) :-
	prob_fake_new(PriorDistribution, LikelihoodDistribution, PosteriorDistribution, ProbFakeNew, Resolution),
	ProbFakeNew > Threshold, !.

learn_causal(_, _, _, _, _, 1).

max_list(Lst, Max, Ind) :-
   member(Max, Lst),
   \+((member(N, Lst), N > Max)),
   % Now, with SWI-Prolog, (may be with other Prolog)
   % nth0/3 gives you the index of an element in a list
   nth0(Ind, Lst, Max).

get_MAP(PosteriorDistribution, Map, Argmax) :-
	max_list(PosteriorDistribution, Map, Argmax).

main :-
	current_prolog_flag(argv, Argv),
	nth0(0,Argv,Cause),
	nth0(1,Argv,Effect),
	nth0(2,Argv,ResolutionString),
	atom_number(ResolutionString, Resolution),
	nth0(3,Argv,File),
	nth0(4,Argv,FileR),
	print('Inferring the posterior distribution between the causals'),
        nl,
        print(Cause),
        print(Effect),
        compute_posterior_for_causal(Cause, Effect, PosteriorDistribution, Resolution, File, PosteriorAdverb, PriorEntropy, PosteriorEntropy),
	nl,
        print('Estimating MAP'),
        get_MAP(PosteriorDistribution, MAP, Argmax),
        nl,
        print('Point Estimation probability'),
        nl,
        put('0'),
        put('.'),
        print(Argmax),
        nl,
        print('Probability'),
        nl,
        print(MAP),
        nl,
        print('End of the inferring process'),
        open(FileR, append, FilePointer),
        loop_through_grid(FilePointer, PosteriorDistribution),
	write(FilePointer, "\n"),
	close(FilePointer),
	atom_concat('_extra_', FileR, FileRExtra),
        open(FileRExtra, append, FilePointerExtra),
	write(FilePointerExtra, PosteriorAdverb),
	write(FilePointerExtra,','),
	write(FilePointerExtra, PriorEntropy),
	write(FilePointerExtra,','),
	write(FilePointerExtra, PosteriorEntropy),
	write(FilePointerExtra, "\n"),
        close(FilePointerExtra),
	halt.

main :-
    halt(1).
