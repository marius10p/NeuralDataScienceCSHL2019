%% Means and medians
% Sample medians represent 'typical' values better
randvars = -log(rand(1000,1)); % illustrate exponential
histogram(randvars)
figure
N = 100; K = 1e5; % sample size; number of simulations
xx = mean(-log(rand(N,K))); % 1000 instances of 9
yy = median(-log(rand(N,K)));
hold on
edges = 0:.1:3;
histogram(xx,edges)
histogram(yy,edges)
plot(edges,K/4*exp(-edges),'r') % show true density
grid; legend('means','medians','density')
hold off

%% why use average at all?
% illustrate 
N = 100; K = 1e5; % sample size; number of simulations
xx = mean(randn(N,K));
yy = median(randn(N,K));
hold on
edges = -.6:.05:.6;
histogram(xx,edges)
histogram(yy,edges)
grid;legend('means','medians')
hold off