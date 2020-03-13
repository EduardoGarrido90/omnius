prior('always', 'exponential', [40,-1]).
prior('constantly', 'beta', [10, 2, 1]).
prior('usually', 'gaussian', [0.85, 0.1]).
prior('normally', 'gaussian', [0.8, 0.2]).
prior('frequently', 'gaussian', [0.7, 0.25]).
prior('regularly', 'gaussian', [0.8, 0.1]).
prior('often', 'gaussian', [0.75, 0.2]).
prior('sometimes', 'gaussian', [0.5, 0.5]).
prior('occasionally', 'gaussian', [0.4, 0.2]).
prior('rarely', 'gaussian', [0.25, 0.2]).
prior('infrequently', 'gaussian', [0.3, 0.1]).
prior('seldom', 'gaussian', [0.2, 0.1]).
prior('hardly ever', 'beta', [10, 2, -1]).
prior('never', 'exponential', [40, 1]).

prior('always', 'exponential', [40,-1], 1).
prior('constantly', 'beta', [10, 2, 1], 2).
prior('usually', 'gaussian', [0.85, 0.1], 3).
prior('normally', 'gaussian', [0.8, 0.2], 4).
prior('frequently', 'gaussian', [0.7, 0.25], 5).
prior('regularly', 'gaussian', [0.8, 0.1], 6).
prior('often', 'gaussian', [0.75, 0.2], 7).
prior('sometimes', 'gaussian', [0.5, 0.5], 8).
prior('occasionally', 'gaussian', [0.4, 0.2], 9).
prior('rarely', 'gaussian', [0.25, 0.2], 10).
prior('infrequently', 'gaussian', [0.3, 0.1], 11).
prior('seldom', 'gaussian', [0.2, 0.1], 12).
prior('hardly ever', 'beta', [10, 2, -1], 13).
prior('never', 'exponential', [40, 1], 14).
