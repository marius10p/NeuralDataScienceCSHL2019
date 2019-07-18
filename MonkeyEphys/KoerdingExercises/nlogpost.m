% Negative log posterior for Multinomial logit with smoothness prior on B
% B = matrix of the params, columns are the linear kernels for a particular
%       class
% X = matrix of datapoints, each row is a datapoint, first column should be
%       a constant column of ones (Spike counts on each trial)
% Y = column of class values for each datapoint, must be numbered 1 to max
%     class. use consecutive integers (Stimulus category)
% For j > 1,  
%    P(Y(i) = j|X(i,:), B) = e^(X(:,i)*B(:,j))/(1+sum_k(X(:,i)*B(:,k)))
%    P(Y(i) = 1|X(i,:), B) = 1/(1+sum_k(X(:,i)*B(:,k)))
% sLambda = constant multiplier for smoothness prior
%           smoothness is defined over the terms (B(i,j+1)-B(i,j))^2
%           Expects consecutive class numbers to have similarity
%               (consecutively numbers neurons can be expected to respond
%               differently to the same stimulus, but the same neuron
%               shouldn't change too drastically over, say, neighboring
%               stimulus orienations)
%
%
% Outputs:
%   f = function value
%   g = gradient (note: size(g) = size(B): this is not a normal column
%       vector for a gradient. does not matter for f. Just reshape to a
%       column vector for it to make sense with the Hessian)
%   h = Hessian
%   fb = f - sm (base f)
%   sm = smoothness. how unsmooth the function is according to the prior

function [f,g,h,fb,sm] = nlogpost(B,X,y,sLambda)

if(nargin < 4)
    sLambda = 0.1;
end
sizeB = size(B);

B = [zeros(size(B,1),1) B ];

s = sum(sum(X.*B(:,y)'));


eXB = exp(X*B  );
d   = sum( eXB ,2);

%e   = 1 ./ d;

if(nargout >= 2)
    eXBd = bsxfun(@(tt,vv) tt./vv, eXB, d);
end

if(nargout >= 3)
    %e2   = e.^2;
    XeXBd = zeros([size(X) size(B,2)]);
end


fb = -1*(s - sum(log(max(d,1e-10)),1));


sg = diff(B,1,2);
sg(1,:) = 0;
sm = sLambda*sum(sum(sg(:,1:sizeB(2)).^2));
f = fb + sm;


if(nargout >= 2)
    %g = zeros(sizeB);
    g = -X'*eXBd(:,2:end);%bsxfun(@(tt,vv) tt./vv, eXB(:,2:end), d);
    h = zeros(prod(sizeB),prod(sizeB));
    
    for ii = 2:size(B,2) 
        
        g(:,ii-1) = g(:,ii-1) + sum(X(y == ii,:  ),1)' ; %- sum(bsxfun(@(tt,vv)tt.*vv,X,e.*eXB(:,i)),1))'
        
        if(nargout >= 3)
            for jj = ii:size(B,2)
                if(ii == 2)
                    XeXBd(:,:,jj) = bsxfun(@(tt,vv)tt.*vv,X,eXBd(:,jj));
                end
                
                if(ii == jj)
%                     h1 = bsxfun(@(t,v)t.*v,X,e2.*(d.*eXB(:,j)  - eXB(:,j).^2))'*X;
                    h1 = bsxfun(@(tt,vv)tt.*vv,X, eXBd(:,jj)  - (eXBd(:,jj)).^2 )'*X;
                    
                    sh = 4*ones(size(h1,1),1);
                    sh(1) = 2;
                    sh(end) = 2;
                    h1 = h1+sLambda*diag(sh);
                    
                else
                    %h1 = bsxfun(@(t,v)t.*v,X,e2.*eXB(:,j))'*X; 
                    %h1 = bsxfun(@(tt,vv)tt.*vv,X,eXBd(:,jj).*eXBd(:,ii))'*X; 
                    h1 = XeXBd(:,:,jj)'*XeXBd(:,:,ii); 
                    
                    if(abs(jj-ii) == 1)
                        sh = -2*ones(size(h1,1),1);
                        sh(1) = 0;
                        sh(end) = 0;
                        h1 = h1+sLambda*diag(sh);
                    end
                end
                
                if(sum(sum(isnan(h1))) > 0)
                    display('NaNs found!');
                end
                
                h(((ii-2)*sizeB(1)+1):((ii-1)*sizeB(1)),((jj-2)*sizeB(1)+1):((jj-1)*sizeB(1))) = h1;
                h(((jj-2)*sizeB(1)+1):((jj-1)*sizeB(1)),((ii-2)*sizeB(1)+1):((ii-1)*sizeB(1))) = h1';
            end
        end
    end


    g  = -1*g + 2*sLambda*sg(:,1:sizeB(2));
    % g = reshape(g(:,2:(sizeB(2)+1)),oSizeB);
    
end