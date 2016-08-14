function varargout = subsref(f, index)
%SUBSREF   SEPARABLEAPPROX subsref.
% ( )
%   F(X, Y) returns the values of the SEPARABLEAPPROX F evaluated at (X,Y). See
%   CHEBFUN/FEVAL for further details. F(:, Y) returns a chebfun representing
%   the function F along that column slice, and F(X, :) returns a chebfun
%   representing F along that row slice. F(:, :) returns F.
%
%   F(G), where G is a CHEBFUN with two columns, or a CHEBMATRIX, CHEBFUN2V or
%   CHEBFUN3V with two components, computes the composition of F and G.  If G is
%   a CHEBFUN, CHEBFUN2 or CHEBFUN3, it is interpreted as F([real(G); imag(G)]),
%   regardles of G being real or complex.
%
%   F(X, Y) where X and Y are CHEBFUN2 objects returns the SEPARABLEAPPROX
%   representing the composition.  If X and Y are CHEBFUN3 objects, then F(X, Y)
%   is a CHEBFUN3.  If X and Y are CHEBFUNs, then F(X, Y) is a CHEBFUN.
%
% .
%   F.PROP returns the property PROP of F as defined by GET(F, 'PROP').
%
% {}
%   F{S1, S2, S3, S4} restricts F to the domain [S1, S2, S3, S4]. See
%   SEPARABLEAPPROX/RESTRICT for further details. Note that F{[S1,S2, S3, S4]}
%   is not supported due to the behaviour of the MATLAB subsref() command.
%
% See also FEVAL, GET, RESTRICT, SUBSREF.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

idx = index(1).subs;
switch index(1).type

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEVAL / COMPOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case '()'
        
        % Where to evaluate:
        x = idx{1};
        if ( length(idx) == 2 )
            y = idx{2};
        
        elseif ( isa(x, 'chebfun') )
            % Composition F(X(t)):
            if ( size(x, 2) == 1 )
                % Interpret as F(real(X(t)), iag(X(t))):
                out = compose([ real(x); imag(x) ], f);
            elseif ( size(x, 2) == 2 )
                % Composition F([X(t), Y(t)]):
                out = compose([ x(:,1); x(:,2) ], f);
            else
                error('CHEBFUN:CHEBFUN2:subsref:ChebfunSize', ...
                    'Can compose only with a CHEBFUN with values in C or R^2.')
            end
            varargout = {out};
            return
            
        elseif ( isa(x, 'chebfun2') || isa(x, 'chebfun3') )
            % Composition F(X) where X is a CHEBFUN2 or CHEBFUN3, interpreted
            % as [real(X), imag(X)], regardless whether G is real or complex.
            out = compose(x, f);
            varargout = {out};
            return
            
        elseif ( isa(x, 'chebmatrix') || isa(x, 'chebfun2v') || ...
                isa(x, 'chebfun3v') )
            % Composition F(CHEBMATRIX), F(CHEBFUN2V) or F(CHEBFUN3V):
            out = compose(x, f);
            varargout = {out};
            return
            
        elseif ( length(idx) == 1 )
            x = real(idx{1});
            y = imag(idx{1});
            out = feval(f, x, y);
            varargout = {out};
            return

        else
            error('CHEBFUN:SEPARABLEAPPROX:subsref:inputs', ...
                'Can only evaluate at functions (X,Y)')
        end
        
        % Two inputs x and y:
        if ( strcmp(y, ':') && strcmp(x, ':'))
            % Return column slice at y
            out =  f;
        elseif ( strcmp(y, ':') && isnumeric(x) )
            out =  feval(f, x, ':');
        elseif ( strcmp(x, ':') && isnumeric(y) )
            out = feval(f, ':', y);
        elseif ( isnumeric(x) && isnumeric(y) )
            out = feval(f, x, y);
            
        % If x, y are CHEBFUN, CHEBFUN2 or CHEBFUN3, concatenate (also
        % checks that domains are compatible) and call compose.
        elseif ( isa(x, 'chebfun') && isa(y, 'chebfun') )
            out = compose([ x; y ], f);
        elseif ( isa(x, 'chebfun2') && isa(y, 'chebfun2') )
            out = compose([ x; y ], f);
        elseif ( isa(x, 'chebfun3') && isa(y, 'chebfun3') )
            out = compose([ x; y ], f);
        else
            error('CHEBFUN:SEPARABLEAPPROX:subsref:nonnumeric',...
                'Cannot evaluate chebfun2 for these inputs type.');
        end
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case '.'
        
        % Call GET() for .PROP access.
        out = get(f, idx);
        if ( numel(index) > 1 )
            % Recurse on SUBSREF():
            index(1) = [];
            out = subsref(out, index);
        end
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESTRICT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case '{}'
        
        if ( length(idx) == 4 )
            out = restrict( f, [ idx{ : } ] );
        else
            error('CHEBFUN:SEPARABLEAPPROX:subsref:dimensions', ...
                'Index exceeds chebfun dimensions.')
        end
        
    otherwise
        
        error('CHEBFUN:SEPARABLEAPPROX:subsref:unexpectedType',...
            ['??? Unexpected index.type of ', index(1).type]);
end

% Convert to cell:
varargout = {out};

end
