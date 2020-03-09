function [tMaxTheta, tStepTheta] = angular_hit(ray_origin, ray_direction, current_voxel_ID_theta,...
    num_angular_sections, circle_center, t, verbose)
% Determines whether an angular hit occurs for the given ray.
% Input:
%    ray_origin: vector of the origin of the ray in cartesian coordinate.
%    ray_direction: vector of the direction of the ray in cartesian coordinate.
%    current_voxel_ID_theta: the (angular) ID of current voxel.
%    num_angular_sections: number of total angular sections on the grid.
%    circle_center: The center of the circle.
%    t: The current time parameter of the ray.
%    verbose: Determines whether debug print statements are enabled.
%
% Returns:
%    tMaxTheta: is the time at which a hit occurs for the ray at the next point of intersection.
%    tStepTheta: The direction the theta voxel steps. +1, -1, or 0.
if verbose
    fprintf("\n-- angular_hit --")
end


% First calculate the angular interval that current voxelID corresponds to.
delta_theta = 2 * pi / num_angular_sections;
interval_theta = [current_voxel_ID_theta * delta_theta, (current_voxel_ID_theta + 1) * delta_theta];

if verbose
    fprintf("\nCurrent Voxel ID Theta: %d\n", current_voxel_ID_theta)
end


% Calculate the x and y components that correspond to the angular
% boundary for the angular interval.
xmin = cos(min(interval_theta));
xmax = cos(max(interval_theta));
ymin = sin(min(interval_theta));
ymax = sin(max(interval_theta));

if (single(tan(min(interval_theta))) == ray_direction(2)/ray_direction(1) ...
        && single(tan(max(interval_theta))) == ray_direction(2)/ray_direction(1))
    if verbose
        fprintf("parallel");
    end
    tMaxTheta = inf;
    tStepTheta = 0;
    return;
end


% Solve the systems Az=b to check for intersection.
tol = 10^-12;
Amin = [xmin, -ray_direction(1); ymin, -ray_direction(2)]
Amax = [xmax, -ray_direction(1); ymax, -ray_direction(2)]
b = [ray_origin(1)-circle_center(1), ray_origin(2)-circle_center(2)]';
%if (single(tan(min(interval_theta))) == ray_direction(2)/ray_direction(1))
if (det(Amin) < tol)
    zmax = Amax \ b
    zmin = [0 ; 0]
%elseif (single(tan(max(interval_theta))) == ray_direction(2)/ray_direction(1))
elseif (det(Amax) < tol)
    zmin = Amin\b
    zmax = [0 ; 0]
else
    zmin = Amin\b
    zmax = Amax\b
end
pause
% If we hit the min boundary then we decrement theta, else increment;
% assign tMaxTheta.
if abs(zmin(1)) > tol && zmin(2) > t
    tStepTheta = -1;
    tMaxTheta = zmin(2);
    fprintf("hit min bound\n")
elseif abs(zmax(1)) > tol && zmax(2) > t
    % 
    abs(zmax(1)) > tol
    abs(zmax(1))
    tol
    tStepTheta = 1;
    tMaxTheta = zmax(2);
    fprintf("hit max bound\n")
elseif abs(zmax(1) - zmin(1)) < tol && zmax(2) -t > tol
        tMaxTheta = zmax(2);
        fprintf("hit origin max t\n")
    if (ray_direction(2)>0)
        interval_theta = interval_theta - pi;
        interval_theta(1)/delta_theta
        tStepTheta = - abs(current_voxel_ID_theta - interval_theta(1)/delta_theta);
    else
        interval_theta = interval_theta + pi;
        tStepTheta = abs(current_voxel_ID_theta - interval_theta(1)/delta_theta);
    end
elseif abs(zmax(1) - zmin(1)) < tol && zmin(2) -t > tol
        tMaxTheta = zmin(2);
        fprintf("hit origin min t\n")
    if (ray_direction(2)>0)
        interval_theta = interval_theta - pi;
        interval_theta(1)/delta_theta
        tStepTheta = - abs(current_voxel_ID_theta - interval_theta(1)/delta_theta);
    else
        interval_theta = interval_theta + pi;
        tStepTheta = abs(current_voxel_ID_theta - interval_theta(1)/delta_theta);
    end
else
    tStepTheta = 0;
    tMaxTheta = inf;
    fprintf("no hit\n")
end
% If we hit the min & max boundary simultaneously, then the change in theta
% is dependent on the slope of the line


if verbose
    fprintf(['\ntMaxTheta: %d \n' ...
        'tStepTheta: %d \n'], tMaxTheta, tStepTheta);
end
end
