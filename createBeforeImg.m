% Tom Crossland
function [beforeImage] = createBeforeImg(source,mask,target,Px,Py,destFile)
 
[m n d] = size(source);

for i = 1:m
    for j = 1:n
        if mask(i,j) == 1
            target(i+Py-1,j+Px-1,:) = source(i,j,:);
        end
    end
end

beforeImage = target;

end