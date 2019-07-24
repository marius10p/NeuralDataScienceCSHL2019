%Worldwide non-commercial space launches (FAA)
Launches = [54	46	42	50	43	41	46	39	37	45	45	41	54];
% Sociology doctorates awarded (US; NSF)
Degrees = [601	579	572	617	566	547	597	580	536	579	576	601	664];
plot(Launches, Degrees,'o'); grid

%% Simpson's Paradox
x1 = randi(5,20,1); x2 = randi(5,20,1);
spikes = [ 2 + x1; 7 + x2];
performance = [ 5-x1; 10-x2] + rand(40,1);
corr(spikes, performance)
plot(spikes, performance,'o'); grid
