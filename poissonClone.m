%Tom Crossland
%Masood Malekghassemi (rewrite)
function [target] = poissonClone(source,mask,target)
if sum((size(source) ~= size(mask)) | (size(source) ~= size(target)));
  error('Source, mask, and target image sizes must all be the same.');
end

[m n] = size(source);

mask = logical(mask);
if sum(mask(1,:)) + sum(mask(end,:)) + sum(mask(:,1)) + sum(mask(:,end))
  error('Mask must have a border of unselected pixels.');
end

maskLeftEdge = (mask(:,[2:end end]) - mask) > 0;
maskRightEdge = (mask(:,[1 1:end-1]) - mask) > 0;
maskTopEdge = (mask([2:end end],:) - mask) > 0;
maskBottomEdge = (mask([1 1:end-1],:) - mask) > 0;

maskEdges = maskLeftEdge | maskRightEdge | maskTopEdge | maskBottomEdge;

maskAll = maskEdges | mask;

nSourcePix = sum(sum(mask));
nEdgePix = sum(sum(maskEdges));
PXindexToAindex = reshape(cumsum(maskAll(:)), m, n);
nEquations = nSourcePix*2+nEdgePix;
A = sparse(nEquations,nSourcePix);
b = zeros(nEquations,1);

bIndex = 1;
for i=1:m
  for j=1:n
    if maskLeftEdge(i,j) || maskTopEdge(i,j)
      Aindex = PXindexToAindex(i,j);
      
      % S'(edge) = target(edge)
      A(bIndex,Aindex) = 1;
      b(bIndex) = target(i,j);
      bIndex = bIndex + 1;
    elseif maskRightEdge(i,j)
      Aindex = PXindexToAindex(i,j);
      AindexLeft = PXindexToAindex(i,j-1);
      
      % S'(edge) = target(edge)
      A(bIndex,Aindex) = 1;
      b(bIndex) = target(i,j);
      bIndex = bIndex + 1;
      
      % dS'/dx = dT/dx
      A(bIndex,[Aindex AindexLeft]) = [1 -1];
      b(bIndex) = source(i,j) - source(i,j-1);
      bIndex = bIndex + 1;
    elseif maskBottomEdge(i,j)
      Aindex = PXindexToAindex(i,j);
      AindexTop = PXindexToAindex(i-1,j);
      
      % S'(edge) = target(edge)
      A(bIndex,Aindex) = 1;
      b(bIndex) = target(i,j);
      bIndex = bIndex + 1;
      
      % dS'/dy = dT/dy
      A(bIndex,[Aindex AindexTop]) = [1 -1];
      b(bIndex) = source(i,j) - source(i-1,j);
      bIndex = bIndex + 1;
    elseif mask(i,j)
      Aindex = PXindexToAindex(i,j);
      AindexLeft = PXindexToAindex(i,j-1);
      AindexRight = PXindexToAindex(i,j+1);
      AindexTop = PXindexToAindex(i-1,j);
      AindexBottom = PXindexToAindex(i+1,j);
      
      % dS'/dx = dT/dx
      A(bIndex,[Aindex AindexLeft]) = [1 -1];
      b(bIndex) = (source(i,j) - source(i,j-1));
      bIndex = bIndex + 1;
      
      % dS'/dy = dT/dy
      A(bIndex,[Aindex AindexTop]) = [1 -1];
      b(bIndex) = (source(i,j) - source(i-1,j));
      bIndex = bIndex + 1;
    end
  end
end

%Find inverse and solve systems of equation
x = A\b;

for i=1:m
  for j=1:n
    if mask(i,j)
      target(i,j) = x(PXindexToAindex(i,j));
    end
  end
end
