function [intersect,range,angle,closest] = computerange(O,D,points,triangles)
    %Möller–Trumbore intersection algorithm
        %calculates range and incidence angle of intersection of ray in
        %direction D from O, with closest of triangles 
    
    %initialise outputs
    intersect = 0;
    range = NaN;
    angle = NaN;
    closest = NaN;
    
    %triangle border settings
    eps = 0;
    zero = 0;
    %zero = eps;    %inclusive
    %zero = -eps;   %exclusive
    
    %vertexes
    V1 = points(triangles(:,1),:); 
    V2 = points(triangles(:,2),:);
    V3 = points(triangles(:,3),:);

    %edges sharing V1
    E1 = V2 - V1;
    E2 = V3 - V1;
    
    %resize origin and direction
    Orep  = repmat(O,size(V1,1),1);
    Drep  = repmat(D,size(E1,1),1);
    
    %vector from V1 to ray origin
    T  = Orep - V1;     
    %begin calculating determinant - also used to calculate u parameter
    P  = cross(Drep,E2,2); 
    %determinant of matrix M = dot(E1,P)
    det   = sum(E1.*P,2); 
    %check if intersection outside triangle
    notinplane = (abs(det)>eps);
    det(~notinplane) = NaN;              % change to avoid division by zero
    
    %barycentric coordinates & intersection
    u   = sum(T.*P,2)./det;    % 1st barycentric coordinate
    Q   = cross(T, E1,2);         % prepare to test V parameter
    v   = sum(Drep.*Q,2)./det;  % 2nd barycentric coordinate
    t   = sum(E2.*Q,2)./det;   % 'position on the line' coordinate
    %test if line/plane intersection is within the triangle
    ok = (notinplane & u>=-zero & v>=-zero & u+v<=1.0+zero);
    %check if distance > 0
    intersectvec = double((ok & t>=-zero));
    
    %find minimum range
    if any(intersectvec)
        intersect = 1;
        intersectvec(~intersectvec) = NaN;  %zeros -> NaN
        %ranges of hit triangles, rest NaN        
        hits = t.*intersectvec;
        %minimum range
        range = min(hits);
        %calculate incidence angle
        closest = find(hits==range,1); 
        E1c = E1(closest,:);
        E2c = E2(closest,:); 
        N = cross(E1c,E2c);    %normal to triangle
        %angle =  pi - atan2(norm(cross(D,N)),dot(D,N)); 
        angle = atan2(norm(cross(D,N)),dot(D,N)); 
        angle = min(angle,pi-angle);
        %intersection coordinates
        %xcoor = V1(closest,:) + E1c*u(closest) + E2c*v(closest); 
    end

    
    
    
    
    
    
    
    
    
    
end

