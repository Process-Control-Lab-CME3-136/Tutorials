clear all; clc; close all

% load twotankdata
load(fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'data', 'mrdamper.mat'));  % nonlinear data
y = F;
u = V;

%%
figure()
tiledlayout(2,1)
nexttile
plot(y)
ylabel('Y (output)')
nexttile
plot(u)
ylabel('U (input)')
  
%%
xtt= y(2:end);         % shift to get x_{t+1}
xt = y(1:end-1);       % shift to get x_{t}
ut = u(1:end-1);       % shift to get u_{t}
xhat = xt*0.98;        % an arbitrary model
figure()
tiledlayout(2,1)
nexttile
plot(xt, xtt, '.')
hold on
plot(xt, xhat, '.')
ylabel('X_{t+1}')
xlabel('X_{t}')
legend('Experimental', 'x_{t+1}=0.98 x_t', location='best')
  
%%
nexttile
scatter3(xt, ut, xtt)
hold on
scatter3(xt, ut, xhat)
xlabel('X_{t}')
ylabel('U_{t}')
zlabel('X_{t+1}')
  
  
%% optimization function
% f = @(A, B) sum((xtt-(A*xt+B*ut)).^2);  % integral square error between the experimental output and the model prediction. Note the timeshift in outputs. We were also talking about taking a particular range.
% this is not robost to outliers/noise


% f = @(A, B) sum(abs(xtt-(A*xt+B*ut)));  % abs error between the experimental output and the model prediction.
% more robust to outliers


f = @(A, B) log(sum((xtt-(A*xt+B*ut)).^2))+0.5*sum(abs(xtt-(A*xt+B*ut)))+0.5*abs(A)+0.5*abs(B);  % regularized error between the experimental output and the model prediction. Note the timeshift in outputs. We were also talking about taking a particular range.
%robust to outliers and results in sparse (or low magnitude) A & B


figure()
fsurf(f,[-5,5],'ShowContours','on')                                                                     % shows how the loss function looks like. I assume A and B should be positive.
title("Optimization surface")
colormap(copper)

  
%% optimize
fun = @(x) f(x(1),x(2));                                                               % initiates/simplifies the function
x0 = [.85; .02];                                                                       % initial conditions
options = optimoptions('fminunc','Algorithm','quasi-newton');                          % optimization options
options.Display = 'iter';                                                              % shows the iterations
[x, fval, exitflag, output] = fminunc(fun,x0,options);                                 % optimizes and outputs the ARX parameters as x.

  
%% visualize
yhat = x(1)*xt+ x(2)*ut;    
figure()
tiledlayout(2,1)
nexttile
plot(xt, xtt, '.')
hold on
plot(xt, yhat, '.')
ylabel('X_{t+1}')
xlabel('X_{t}')
modelname = sprintf('x_{t+1} = %4.2f x_t + %4.2f u_t', x(1), x(2));
legend('Experimental', modelname, location='best')
nexttile
scatter3(xt, ut, xtt)
hold on
scatter3(xt, ut, yhat)
xlabel('X_{t}')
ylabel('U_{t}')
zlabel('X_{t+1}')
legend('Experimental', modelname, location='best')
