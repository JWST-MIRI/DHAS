// mrs_findOverlap.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib> // EXIT_FAILURE, EXIT_SUCCESS
#include <vector>
#include <algorithm>
#define CP_LEFT 0
#define CP_RIGHT 1
#define CP_BOTTOM 2
#define CP_TOP 3


int calcCondition(int edge,double x1, double y1, double x2, double y2, 
		  double left, double right, double top, double bottom) ;


void solveIntersection(int edge ,double x1,double y1,double x2,double y2,
		       double &x,double &y,
		       double left, double right, double top, double bottom);


void addpoint (double x, double y, double xnew[], double ynew[], int &nVertices2);

double findAreaPoly(int nVertices,double xPixel[],double yPixel[]);

using namespace std;



/**********************************************************************/
// Description: 

/**********************************************************************/


double mrs_SH_findOverlap(const double xcenter, const double ycenter, 
		       const double xlength, const double ylength,
		       double xPixelCorner[],double yPixelCorner[])

                    
  
{
  // user the Sutherland_hedgeman Polygon Clipping Algorithm to solve the overlap region
  // first clip the y-z detector plane by the cube's yz rectangle - find the overlap area
  // Then clip the x-y detector plane by the cube's xy rectangle and find the average x lenghth
  //   overlap: overlap vol = area overlap * x lenght overlap


  double areaClipped = 0.0;
  double top = ycenter + 0.5*ylength;

  double bottom = ycenter - 0.5*ylength;


  double left = xcenter - 0.5*xlength;

  double right = xcenter + 0.5*xlength;

  int nVertices = 4; // input detector pixel vertices

  int MaxVertices = 9;
  double xPixel[9];
  double yPixel[9];
  double xnew[9]; 
  double ynew[9]; 

  // initialize xPixel, yPixel to the detector pixel corners.
  // xPixel,yPixel is become the clipped polygon vertices inside the cube pixel
  for (int i = 0; i < 5; i++) {
    
    xPixel[i] = xPixelCorner[i];
    yPixel[i] = yPixelCorner[i];
  }


  //_______________________________________________________________________
  //cout << " checking pixel x" << xPixel[0] << " " << xPixel[1] << " " <<
  //  xPixel[2] << " " << xPixel[3] << endl;
  
  //cout << "                y" << yPixel[0] << " " << yPixel[1] << " " <<
  //  yPixel[2] << " " << yPixel[3] << endl;

  //cout << "lrtb " << left << " " << right << " " << top << " " << bottom << endl;
  for (int i = 0 ; i < 4; i++) { // 0:left, 1: right, 2: bottom, 3: top
    //cout << " value of i " << i << " " << nVertices << endl;
    int nVertices2 = 0;
    for (int j = 0; j< nVertices; j++){
      //cout << "  value of j " << j << endl;
      double x1 = xPixel[j];
      double y1 = yPixel[j];
      double x2 = xPixel[j+1];
      double y2 = yPixel[j+1];
      
      //cout << " check condition " << x1 << "  " << x2 << " " << y1 << " " << y2 << endl;
      int condition = calcCondition(i,x1,y1,x2,y2,
				    left,right,top,bottom);

      double x = 0;
      double y = 0;
      

      switch(condition)
	{
	case 1:
	  solveIntersection(i,x1,y1,x2,y2,
			    x,y,
			    left,right,top,bottom);
	  
	  
	  //cout << "1:adding x y " << x << " " << y << endl;
	  addpoint (x,y,xnew,ynew,nVertices2);
	  //cout << "1:adding x2 y2 " << x2 << " " << y2 << endl;
	  addpoint (x2,y2,xnew,ynew,nVertices2);
	  break;
	case 2:
	  //cout << "2: adding x2 y2 " << x2 << " " << y2 << endl;
	  addpoint (x2,y2,xnew,ynew,nVertices2);
	  break;
	case 3:
	  //cout << "case 3 " << x1 << " " << x2 << " " << y1 << " " << y2 << endl;
	  solveIntersection(i,x1,y1,x2,y2,
			    x,y,
			    left,right,top,bottom);
	  //cout << "3: adding x y " << x << " " << y << endl;
	  addpoint (x,y,xnew,ynew,nVertices2);
	  break;
	case 4:
	  break;
	}
    }// loop over j  corners

    addpoint (xnew[0],ynew[0],xnew,ynew,nVertices2); // closed polygon
    

    if(nVertices2 >  MaxVertices ) {
      cout << " mrs_SH_findOverlap:: failure in finding the clipped polygon, nVertices2 > 9 " <<endl;
      exit(EXIT_FAILURE);
    }
    nVertices = nVertices2-1;

    for (int k = 0; k< nVertices2; k++){

      xPixel[k] = xnew[k];
      yPixel[k] = ynew[k];
      //cout << " **********New X, Y " << k << " " << xPixel[k] << " " << yPixel[k] << endl;
    }

    //update 
    

  } // loop over top,bottom,left,right
  nVertices++;
  //cout << "calling findArePoly " << nVertices << endl;
  if(nVertices > 0) {
    areaClipped = findAreaPoly(nVertices,xPixel,yPixel);
  }
  
  return areaClipped;
}







//_______________________________________________________________________    
#include <iomanip>
#include <math.h>

int insideWindow(int edge,double x, double y, 
		 double left,double right,double top,double bottom);

int calcCondition(int edge,double x1, double y1, double x2, double y2, 
		  double left, double right, double top, double bottom) 
                    
  
{
  int stat1 = insideWindow(edge,x1,y1,left,right,top,bottom);
  //cout << "stat 1 " << stat1 << endl;
  int stat2 = insideWindow(edge,x2,y2,left,right,top,bottom);
  //cout << " stat  2 " << stat2 << endl;
  if(!stat1 && stat2)	return 1;
  if(stat1  && stat2) 	return 2;
  if(stat1  && !stat2)	return 3;
  if(!stat1 && !stat2)	return 4;
  return 0; //never executed

}


//_______________________________________________________________________    
#include <math.h>
int insideWindow(int edge,double x, double y, 
		 double left,double right,double top,double bottom)
                    
  
{
	switch(edge)
	{
	case CP_LEFT:
	  return (x > left);
	case CP_RIGHT:
	  return (x < right);
	case CP_BOTTOM:
	  return (y > bottom);
	case CP_TOP:
	  return (y < top);
	}
	return 0;
}

//_______________________________________________________________________    
#include <math.h>
void solveIntersection(int edge ,double x1,double y1,double x2,double y2,
		       double &x,double &y,
		       double left, double right, double top, double bottom)
{
  float m = 0;
  if(x2 != x1) m = ((double)(y2-y1)/(double)(x2-x1));
  switch(edge)
    {
    case CP_LEFT:
      x = left;
      y = y1 + m * (x - x1);
      break;
    case CP_RIGHT:
      x = right;
      y = y1 + m * (x - x1);
      break;
    case CP_BOTTOM:
      y = bottom;
      if(x1 != x2)
	x = x1 + (double)(1/m) * (y - y1);
      else
	x = x1;
      break;
    case CP_TOP:
      y = top;
      if(x1 != x2)
	x = x1 + (double)(1/m) * (y - y1);
      else
	x = x1;
      break;
    }
}





//_______________________________________________________________________

#include <math.h>

void addpoint (double x, double y, double xnew[], double ynew[], int &nVertices2){
  xnew[nVertices2] = x;
  ynew[nVertices2] = y;
  nVertices2++;
}



//_______________________________________________________________________

