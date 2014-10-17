classdef poisson_clone_process < handle
  % Output Flags
  properties
    
  end
  
  % Filenames
  properties
    source_filename = [];
    target_filename = [];
  end
  
  % Base Images
  properties
    source_image = [];
    target_image = [];
  end
  
  % User Calculation Parameters
  properties
    mask = [];
    mask_ij_source_base = [];
    mask_ij_target_base = [];
    source_angle_on_target = 0; % radians
    source_scale_on_target = 1; % normalized
    source_flip_on_target = 0; % true/false
  end
  properties(Dependent = true) % Derived User Calculation Parameters
    mask_ij_target_center;
  end
  
  % Derived Images
  properties
    result_image = [];
  end
  
  % Decorators
  properties
    user_data = [];
  end
  
  % Accessors
  methods
    function [ij] = get.mask_ij_target_center(P)
      ij = round(P.mask_ij_target_base + size(P.mask)/2);
    end
    function set.mask_ij_target_center(P, val)
      P.mask_ij_target_base = round(val - size(P.mask)/2);
    end
  end
  
  % Effectors
  methods
    function [source,target,trmask,trmask_base] = trafo_images(P)
      source = P.source_image(P.mask_ij_source_base(1)+(1:size(P.mask,1)), P.mask_ij_source_base(2)+(1:size(P.mask,2)), :);
      if P.source_flip_on_target
        source = flipdim(source,2);
        trmask = flipdim(P.mask,2);
      else
        trmask = P.mask;
      end
      source = imrotate(source, radtodeg(-P.source_angle_on_target));
      source = imresize(source, P.source_scale_on_target);
      trmask = imrotate(trmask, radtodeg(-P.source_angle_on_target)) > 0.5;
      trmask = imresize(trmask, P.source_scale_on_target);
      
      
      trmask_base = round(P.mask_ij_target_center - size(trmask)/2);
      target = P.target_image(trmask_base(1)+(1:size(trmask,1)), trmask_base(2)+(1:size(trmask,2)), :);
    end
    
    function [R] = clone(P, save_in_result)
      if nargin < 2
        save_in_result = 0;
      end
      [source, target, trmask, trmask_base] = P.trafo_images();
      source = im2double(source);
      target = im2double(target);
      for k=1:size(source,3)
        srck = source(:,:,k);
        trgk = target(:,:,k);
        srck(~trmask) = trgk(~trmask);
        source(:,:,k) = srck;
      end
      if save_in_result
        P.result_image = P.target_image;
        P.result_image(trmask_base(1)+(1:size(trmask,1)), trmask_base(2)+(1:size(trmask,2)), :) = uint8(255*source);
      end
      R = P.target_image;
      R(trmask_base(1)+(1:size(trmask,1)), trmask_base(2)+(1:size(trmask,2)), :) = uint8(255*source);
    end
    function [R] = poisson_clone(P, save_in_result)
      if nargin < 2
        save_in_result = 0;
      end
      [source, target, trmask, trmask_base] = P.trafo_images();
      source = im2double(source);
      target = im2double(target);
      for k=1:size(target,3)
        target(:,:,k) = poissonClone(source(:,:,k), trmask, target(:,:,k));
      end
      if save_in_result
        P.result_image = P.target_image;
        P.result_image(trmask_base(1)+(1:size(trmask,1)), trmask_base(2)+(1:size(trmask,2)), :) = uint8(255*target);
      end
      R = P.target_image;
      R(trmask_base(1)+(1:size(trmask,1)), trmask_base(2)+(1:size(trmask,2)), :) = uint8(255*target);
    end
  end
end