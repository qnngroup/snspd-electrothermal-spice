function W = myLambertW(x)
% myLambertW  Compute the principal branch W0 of the Lambert W function
%
%   W = myLambertW(x) returns the principal branch W0(x) such that
%       W0(x)*exp(W0(x)) = x,
%   for real (or complex) x.  For real x, this branch is defined for 
%       x >= -1/exp(1), 
%   and W0(-1/exp(1)) = -1.
%
%   This implementation uses Halley’s iteration:
%       W_{n+1} = W_n - f(W_n) / (f'(W_n) - (f(W_n) * f''(W_n)) / (2 f'(W_n))),
%   where f(W) = W*exp(W) - x, f'(W)=exp(W)*(W+1), f''(W)=exp(W)*(W+2).
%
%   Inputs:
%     x  — scalar, vector, or matrix of real (or complex) values
%   Outputs:
%     W  — same size as x, containing W0(x)
%
%   Examples:
%     myLambertW( 0 )       % returns 0
%     myLambertW( 1 )       % ≈ 0.56714329
%     myLambertW( -0.1 )    % ≈ -0.11183256
%     myLambertW( -1/exp(1) )  % exactly -1
%
%   Notes:
%   - For x < -1/e, W0(x) is not real—this code will still iterate, but 
%     you’ll get a complex result. 
%   - Tolerance is set to 1e-12 by default; maximum 50 iterations.
%
%   Author: [Your Name], Date: [2025-05-20]

   %---------------------------------------------------------------------------%
   % PARAMETERS
   tol  = 1e-12;    % convergence tolerance on |W*exp(W) - x|
   maxIters = 50;   % maximum number of Halley iterations
   %---------------------------------------------------------------------------%

   % Preallocate output same size as x
   W = zeros(size(x));

   % Define the “special” point x = -1/e → W = -1 exactly
   % To avoid division by zero (or slow convergence), handle it explicitly
   xm1e = -1/exp(1);

   % Flatten indices for easy looping
   x_flat = x(:);
   W_flat = zeros(size(x_flat));

   for k = 1:numel(x_flat)
       xi = x_flat(k);

       % --- INITIAL GUESS FOR W0 ---
       if xi == 0
           wi = 0;
       elseif xi == xm1e
           wi = -1;
       elseif real(xi) > 0
           % For positive real xi, a good initial guess is log(x)
           wi = log(xi);
           % But if xi is small (< 1), we can use xi itself
           if abs(xi) < 1
               wi = xi;
           end
       else
           % For -1/e < xi < 0, try a linear approximation near -1
           wi = -1 + sqrt(2*(exp(1)*xi + 1));  
           % If this is complex or fails, fallback to xi
           if ~isfinite(wi)
               wi = xi;
           end
       end

       % If xi is exactly -1/e, we already set wi = -1
       if xi == xm1e
           W_flat(k) = -1;
           continue
       end

       % --- HALLEY ITERATION ---
       for iter = 1:maxIters
           % compute f(w) = w * exp(w) - x
           ew = exp(wi);
           fw = wi*ew - xi;
           % derivative f'(w) = exp(w)*(w + 1)
           f1 = ew*(wi + 1);
           % second derivative f''(w) = exp(w)*(w + 2)
           f2 = ew*(wi + 2);

           % Halley update:
           denom = f1 - (fw * f2)/(2*f1);
           delta = fw / denom;
           wi_new = wi - delta;

           % check convergence |f(w)| = |wi*exp(wi) - x|
           if abs(wi_new*exp(wi_new) - xi) < tol
               wi = wi_new;
               break
           end

           wi = wi_new;
       end

       W_flat(k) = wi;
   end

   % Reshape back to original dimensions
   W = reshape(W_flat, size(x));
end