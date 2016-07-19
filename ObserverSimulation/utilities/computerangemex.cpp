/*********************************************************************
 * 2D matrices:
 * <> Use 0-based indexing as always in C or C++
 * <> Indexing is column-based as in Matlab (not row-based as in C)
 * <> Use linear indexing.  [x*dimy+y] instead of [x][y]
 ********************************************************************/
#include <matrix.h>
#include <mex.h>   
#include <algorithm>
#include <stdlib.h>
#include <math.h>

/* Definitions to keep compatibility with earlier versions of ML */
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

#if (defined(_LP64) || defined(_WIN64)) && !defined(MX_COMPAT_32)
/* Currently 2^48 based on hardware limitations */
# define MWSIZE_MAX    281474976710655UL
# define MWINDEX_MAX   281474976710655UL
# define MWSINDEX_MAX  281474976710655L
# define MWSINDEX_MIN -281474976710655L
#else
# define MWSIZE_MAX    2147483647UL
# define MWINDEX_MAX   2147483647UL
# define MWSINDEX_MAX  2147483647L
# define MWSINDEX_MIN -2147483647L
#endif
#define MWSIZE_MIN    0UL
#define MWINDEX_MIN   0UL
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

//declare variables
    //input/output stuff
    mxArray *O_in_m, *D_in_m, *pts_in_m, *tri_in_m,
            *intersect_out_m, *range_out_m, *angle_out_m, *ihit_out_m;
    const mwSize *pts_dims, *tri_dims;
    double *O, *D, *pts, *tri, *intersect, *range, *angle, *ihit;
    int pts_dimy, pts_dimx, tri_dimy, tri_dimx, 
        intersect_dimx, intersect_dimy, numdims, 
        range_dimx, range_dimy, angle_dimx, angle_dimy,
        ihit_dimx, ihit_dimy;
    //everything else
    int i,j;
    double nan = _Nan._Double;
    
//associate inputs
    O_in_m = mxDuplicateArray(prhs[0]);
    D_in_m = mxDuplicateArray(prhs[1]);
    pts_in_m = mxDuplicateArray(prhs[2]);
    tri_in_m = mxDuplicateArray(prhs[3]);
//figure out dimensions
    pts_dims = mxGetDimensions(prhs[2]);
    tri_dims = mxGetDimensions(prhs[3]);
    pts_dimy = (int)pts_dims[0];
    pts_dimx = (int)pts_dims[1];
    tri_dimy = (int)tri_dims[0];
    tri_dimx = (int)tri_dims[1];
    numdims = mxGetNumberOfDimensions(prhs[0]);
    intersect_dimy = 1;
    intersect_dimx = 1;
    range_dimy = 1;
    range_dimx = 1;
    angle_dimy = 1;
    angle_dimx = 1;
    ihit_dimx = 1;
    ihit_dimy = 1;
//associate outputs
    intersect_out_m = plhs[0] = mxCreateDoubleMatrix(intersect_dimy,intersect_dimx,mxREAL);
    range_out_m = plhs[1] = mxCreateDoubleMatrix(range_dimy,range_dimx,mxREAL);
    angle_out_m = plhs[2] = mxCreateDoubleMatrix(angle_dimy,angle_dimx,mxREAL);
    ihit_out_m = plhs[3] = mxCreateDoubleMatrix(ihit_dimy,ihit_dimx,mxREAL);
    
//associate pointers
    O = mxGetPr(O_in_m);
    D = mxGetPr(D_in_m);
    pts = mxGetPr(pts_in_m);
    tri = mxGetPr(tri_in_m);
    intersect = mxGetPr(intersect_out_m);
    range = mxGetPr(range_out_m);
    angle = mxGetPr(angle_out_m);
    ihit = mxGetPr(ihit_out_m);
    
//FINDRANGE FUNCTION - Möller–Trumbore intersection algorithm, then find MIN
    //constants
    const double pi = 3.1415926535897;

    //initialise outputs
    intersect[0] = 0;
    range[0] = nan;
    angle[0] = nan;
    ihit[0] = nan;
    
    //triangle border settings
    double eps = 0;
    double zero = 0;
    //zero = eps;    %inclusive
    //zero = -eps;   %exclusive
    
    double *V1, *V2, *V3, *E1, *E2,
            *Orep,*Drep,*T,*P,*Q,
            *det,/**notinplane,*/*u,*v,*t,/**ok,*/
            *intersectvec,*hits,*E1c,*E2c,*N,*DxN;
    int closest;
    double theta;
    bool *notinplane, *ok;
    V1      = new double [tri_dimy*tri_dimx];
    V2      = new double [tri_dimy*tri_dimx];
    V3      = new double [tri_dimy*tri_dimx];
    E1      = new double [tri_dimy*tri_dimx];
    E2      = new double [tri_dimy*tri_dimx];
    Orep    = new double [tri_dimy*tri_dimx];
    Drep    = new double [tri_dimy*tri_dimx];
    T       = new double [tri_dimy*tri_dimx];
    P       = new double [tri_dimy*tri_dimx];
    Q       = new double [tri_dimy*tri_dimx];
    det             =  new double [tri_dimy];
    //notinplane      =  new double [tri_dimy];
    u               =  new double [tri_dimy];
    v               =  new double [tri_dimy];
    t               =  new double [tri_dimy];
    //ok              =  new double [tri_dimy];
    intersectvec    =  new double [tri_dimy];
    hits            =  new double [tri_dimy];
    E1c             =  new double [pts_dimx];
    E2c             =  new double [pts_dimx];
    N               =  new double [pts_dimx];
    DxN             =  new double [pts_dimx];
    notinplane  = new bool [tri_dimy];
    ok          = new bool [tri_dimy];
    //Vertexes
        //V1 = points(triangles(:,1),:); 
        //V2 = points(triangles(:,2),:);
        //V3 = points(triangles(:,3),:);
    for(i=0;i<tri_dimx;i++)
    {
        for(j=0;j<tri_dimy;j++)
        {
            *(V1+i*tri_dimy+j) = pts[((int)(tri[(int)(0*tri_dimy+j)])-1)+i*pts_dimy];
            *(V2+i*tri_dimy+j) = pts[((int)(tri[(int)(1*tri_dimy+j)])-1)+i*pts_dimy];
            *(V3+i*tri_dimy+j) = pts[((int)(tri[(int)(2*tri_dimy+j)])-1)+i*pts_dimy];
        }
    }
    
    //resize origin and direction
        //Orep  = repmat(O,size(V1,1),1);
        //Drep  = repmat(D,size(E1,1),1);
    for(i=0;i<tri_dimy;i++)
    {
        *(Orep+i)               = O[0];
        *(Orep+i+tri_dimy)      = O[1];
        *(Orep+i+2*tri_dimy)    = O[2];
        *(Drep+i)               = D[0];
        *(Drep+i+tri_dimy)      = D[1];
        *(Drep+i+2*tri_dimy)    = D[2];
    }
    
    //edges sharing V1
        //E1 = V2 - V1;
        //E2 = V3 - V1;
    //vector from V1 to ray origin
        //T  = Orep - V1; 
    for(i=0;i<tri_dimx*tri_dimy;i++)
    {
        *(E1+i) = *(V2+i) - *(V1+i);
        *(E2+i) = *(V3+i) - *(V1+i);
        *(T+i)  = *(Orep+i) - *(V1+i);
    }
        
    for(i=0;i<tri_dimy;i++)
        
    {
        //begin calculating determinant - also used to calculate u parameter
        //P  = cross(Drep,E2,2); 
        *(P+i)              = ((*(Drep+i+tri_dimy))*(*(E2+i+2*tri_dimy)))
                                -((*(Drep+i+2*tri_dimy))*(*(E2+i+tri_dimy)));
        *(P+i+tri_dimy)     = ((*(Drep+i+2*tri_dimy))*(*(E2+i)))
                                -((*(Drep+i))*(*(E2+i+2*tri_dimy)));
        *(P+i+2*tri_dimy)   = ((*(Drep+i))*(*(E2+i+tri_dimy)))
                                -((*(Drep+i+tri_dimy))*(*(E2+i)));
        //determinant of matrix M = dot(E1,P)
        //det   = sum(E1.*P,2);   
        *(det+i) = ((*(P+i))*(*(E1+i))) 
                   + ((*(P+i+tri_dimy))*(*(E1+i+tri_dimy)))
                   + ((*(P+i+2*tri_dimy))*(*(E1+i+2*tri_dimy)));
        //check if intersection outside triangle
        //notinplane = (abs(det)>eps);
        //det(~notinplane) = NaN;   % change to avoid division by zero
        *(notinplane+i) = (bool)(abs(*(det+i))>eps);
        if(*(notinplane+i)==0)
        {
            *(det+i) = nan;                    
        }   
        //barycentric coordinates & intersection
        //u   = sum(T.*P,2)./det;    % 1st barycentric coordinate
        *(u+i) = (((*(T+i))*(*(P+i))) 
                   + ((*(T+i+tri_dimy))*(*(P+i+tri_dimy)))
                   + ((*(T+i+2*tri_dimy))*(*(P+i+2*tri_dimy))))/(*(det+i));
        //Q   = cross(T, E1,2);         % prepare to test V parameter
        *(Q+i)              = ((*(T+i+tri_dimy))*(*(E1+i+2*tri_dimy)))
                                -((*(T+i+2*tri_dimy))*(*(E1+i+tri_dimy)));
        *(Q+i+tri_dimy)     = ((*(T+i+2*tri_dimy))*(*(E1+i)))
                                -((*(T+i))*(*(E1+i+2*tri_dimy)));
        *(Q+i+2*tri_dimy)   = ((*(T+i))*(*(E1+i+tri_dimy)))
                                -((*(T+i+tri_dimy))*(*(E1+i)));
        //v   = sum(Drep.*Q,2)./det;  % 2nd barycentric coordinate
        //t   = sum(E2.*Q,2)./det;   % 'position on the line' coordinate
        *(v+i) = (((*(Drep+i))*(*(Q+i))) 
                   + ((*(Drep+i+tri_dimy))*(*(Q+i+tri_dimy)))
                   + ((*(Drep+i+2*tri_dimy))*(*(Q+i+2*tri_dimy))))/(*(det+i));
        *(t+i) = (((*(E2+i))*(*(Q+i))) 
                   + ((*(E2+i+tri_dimy))*(*(Q+i+tri_dimy)))
                   + ((*(E2+i+2*tri_dimy))*(*(Q+i+2*tri_dimy))))/(*(det+i));
        //test if line/plane intersection is within the triangle
        //ok = (notinplane & u>=-zero & v>=-zero & u+v<=1.0+zero);
        //check if distance > 0
        //intersectvec = double((ok & t>=-zero));
        *(ok+i) = (*(notinplane+i)) 
                    & (*(u+i)>=-zero) 
                    & (*(v+i)>=-zero) 
                    & ((*(u+i))+(*(v+i))<=1.0+zero);
        *(intersectvec+i) = (double)(*(ok+i) & ((*(t+i))>=-zero) );
    }
        
    //FIND MINIMUM RANGE
    //check if any intersectvec nonzero and convert 0s to NaN
    for(i=0;i<tri_dimy;i++)
    {
        if(*(intersectvec+i))
        {
            intersect[0] = 1;
            break;
        }
    }
    
    if(intersect[0])
    {
        closest = 0;
        double smallest = std::numeric_limits<double>::infinity();
        //range is min of hits besides 0
            //hits = t.*intersectvec;
        for(i=0;i<tri_dimy;i++)
        {
            *(hits+i) = abs((*(t+i))*(*(intersectvec+i)));
            if((*(intersectvec+i)!=0) & (*(hits+i)<smallest))
            {
                smallest = *(hits+i);
                closest = i;
                ihit[0] = (double)(i+1);
            }
        }
        range[0] = smallest;
        //E1c = E1(closest,:);
        //E2c = E2(closest,:); 
        *(E1c)   = *(E1+closest);
        *(E1c+1) = *(E1+closest+tri_dimy);
        *(E1c+2) = *(E1+closest+2*tri_dimy);
        *(E2c)   = *(E2+closest);
        *(E2c+1) = *(E2+closest+tri_dimy);
        *(E2c+2) = *(E2+closest+2*tri_dimy);
        //N = cross(E1c,E2c);    %normal to triangle
        *(N)   = ((*(E1c+1))*(*(E2c+2)))-((*(E1c+2))*(*(E2c+1)));
        *(N+1) = ((*(E1c+2))*(*(E2c)))-((*(E1c))*(*(E2c+2)));
        *(N+2) = ((*(E1c))*(*(E2c+1)))-((*(E1c+1))*(*(E2c)));
        //DxN
        *(DxN)   = ((D[1])*(*(N+2)))-((D[2])*(*(N+1)));
        *(DxN+1) = ((D[2])*(*(N)))-((D[0])*(*(N+2)));
        *(DxN+2) = ((D[0])*(*(N+1)))-((D[1])*(*(N)));
        //angle =  pi - atan2(norm(cross(D,N)),dot(D,N));
        theta = atan2(sqrt((*(DxN))*(*(DxN))+(*(DxN+1))*(*(DxN+1))+(*(DxN+2))*(*(DxN+2))),
                             ((D[0])*(*(N)))+((D[1])*(*(N+1)))+((D[2])*(*(N+2))));
        angle[0] = std::min(theta,pi-theta);
        
    }
                
    return;
}