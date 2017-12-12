// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//     ms_2pt_diff_quick.cpp
//
// Purpose:
//
// The routine is called by ms_process_data.cpp
 
// The program is called if cosmic ray testing is being perormed or if the
// diagnostic flag was set. This program finds the 2 pt difference between
// adjacent frame values for a pixel (adjacent sample-up-the-ramp values).
// If cosmic ray testing is being performed the the 2 pt differences are sorted
// and the largest "jumps" in the data are tested to see if they met the limits
// set by the:
// a. cr_sigma_reject parameter: (control.cr_sigma_reject) # of sigmas 
// above median for which a jump is a cosmic ray
// b.  cr_min_good_diffs: (control.cr_min_good_diffs) minimum # of good differences 
// to do cosmic ray detection
// If just the diagnostic flag is set the 2 pt differences, maximum 2pt difference,
// frame # of the maximum 2 pt difference, standard deviation of the 2 pt differences,
// and slope of the 2 pt differences are returned. 
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//
//void ms_2pt_diff_quick(const int verbose_jump,
//		       const int do_cosmic_id,
//		       const int istart_fit,
//		       miri_pixel &pixel,
//		       const float cr_sigma_reject,       
//		       const int  cr_min_good_diffs,      
//		       const int n_frames_reject_after_cr,
//		       const int max_iterations,
//		       long &num_found_cr,
//                     long &num_found_noise_spike_up,
//                     long &num_found_noise_spike_down,
//                     long &num_found_cr_neg,)
//
//
//
// Arguments:
//      verbose: print extra information to the screen- a special verbose for Jumps on Ramp
//      do_cosmic_id: do cosmic ray testing.
//      istart_fit: frame number to start the fit on
//      pixel (class miri_pixel): holds information on each pixel
//      cr_sigma_reject (control.cr_sigma_reject): # of sigmas 
//          away from the median for which a jump is a cosmic ray
//      cr_min_good_diffs (control.cr_min_good_diffs): minimum # of good differences 
//          needed to do  cosmic ray detection
//      n_frames_reject_after_cr: if a cosmic ray is found then this value sets
//          the number of frames to also reject from the fitting.
//      max_iterations: maximum number of iterations to do in cosmic ray iding
//      num_found_cr: number of possible cosmic rays found 
//      num_found_noise_spike_down: number of negative noise spikes
//      num_found_noise_spike_up: number of positive noise spikes
//      num_found_cr_neg: number of cases ramp jumped down and stayed down

// Return Value/ Variables modified:
//      No return value.
//      If cosmic rays testing is done: 
//        the class pixel is modified is any cosmic rays are found. The ID flag
//        is set to 32 and n_frames_reject_after_cr is flagged.
//        num_found contains the number of cosmic rays found 
//      If the diagnostic flag is set then the vectors in class pixel holding
//        the 2pt difference information is filled in. 
//
// Other programs that are needed:
//  FindMedian3.cpp is part of the general program library found in:
//       DHAS/MPipeline/DAT/src_gen
//       FindMedian3.cpp find the median of a sorted vector. Where the median
//       is limited to an lower and upper element in the vector.
// 
//  piksrt3.cpp is part of the general program library found in:
//       DHAS/MPipeline/DAT/src_gen. 
//       piksrt3.cpp sorts an array and returned and index of the sorted array.
// History:
//
//	Written by Jane Morrison 2007
//      July 22, 2009 added splitting jumps into:
//             noise_spike_down, noise_spike_up, noise_stay_down. Break ramp into segments
//             only for cosmic rays or noise_stay_down

//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <vector>
#include <algorithm>
#include <cmath>
#include "miri_constants.h"
#include "miri_pixel.h"
#include "miri_sloper.h"


  
void FindMedian3(vector<float> flux,int istart, int iend, float& Median); // finds the median of a vector

void piksrt3(vector <float> &arr, vector <long> &indx); // sorting routine


// 2 pt difference routine 
void ms_2pt_diff_quick(const int verbose_jump,
		       const int do_cosmic_id,
		       const int istart_fit,
		       const int NRamps,
		       miri_pixel &pixel,
		       const float cr_sigma_reject,       // cosmic ray rejection sigma
		       const int  cr_min_good_diffs,      // min # of good 2 pt diffs needed to search for CR
		       const int n_frames_reject_after_cr,
		       const int max_iterations,
		       const float cosmic_ray_noise_level,
		       long &num_found_cr,
		       long &num_found_noise_spike_up,
		       long &num_found_noise_spike_down,
		       long &num_found_cr_neg)

{  

  float WithHold = 0.02;  // default - withhold % of data 

  num_found_cr = 0;
  num_found_noise_spike_up = 0;
  num_found_noise_spike_down = 0;
  num_found_cr_neg = 0;
  int iter_num = 0;
  vector<float> diff;
  vector<float> true_diff;
  vector<float> diff_org;
  vector<long> index;
  vector<long> ipixel;

  diff.reserve(NRamps-1);
  true_diff.reserve(NRamps-1);
  diff_org.reserve(NRamps-1);
  index.reserve(NRamps-1);
  ipixel.reserve(NRamps-1);

  int n_good = 0; // number of good 2pt differences
  int n_frames_reject_after_noise = n_frames_reject_after_cr; 
  float xtemp =  pixel.GetX();
  float ytemp = pixel.GetY();
  int debug = 0;
  //   if(xtemp == 285 && ytemp == 57) debug = 1;


  // find 2 pt differences  for only the good data points 
  // also finds the max 2pt difference

  pixel.Get2ptDiffIndexP(istart_fit,diff,true_diff,index,ipixel,n_good);

  // true_diff = 2 pt difference
  // diff = absolute value of tru_diff - used for sorting and finding largest differences

  diff_org.assign(true_diff.begin(),true_diff.end()); // save 2pt differences to later find slope of 2 pt differences

  if(debug ==1) {
    int dsize = diff.size();
    for (int li = 0; li < dsize; li++){
      cout << " Before Two pt diff " << diff[li] << " " << index[li] <<  " " << ipixel[li] << endl;
    }
  }
  if(do_cosmic_id== 1  &&  n_good > cr_min_good_diffs);
  if(debug ==1) cout << diff.size() << " " <<  index.size() << endl;

  piksrt3(diff,index); // sort differences and associated index array

  if(debug ==1) {
    int dsize = diff.size();
    for (int li = 0; li < dsize; li++){
      cout << "Two pt diff " << diff[li] << " " << index[li] << " " << ipixel[index[li]] << endl;
    }
  }


  //***********************************************************************
      // cosmic ray testing 
  //***********************************************************************
  bool iterate = true;
  while(iterate) { //test a
    //-----------------------------------------------------------------------
    // The rest of the code is only for cosmic ray identification

    if(do_cosmic_id== 0  || n_good < cr_min_good_diffs) iterate = false;

    if(iterate) { //test b
      int numwithhold = int(n_good*WithHold);
      if(numwithhold >3 ) numwithhold = 3; // limits on number of pts to withhold
      if(numwithhold < 1) numwithhold = 1;   // have to withhold at least 1 point
      int icut = n_good - numwithhold;
    //_______________________________________________________________________
    // we only want to look at the values below icut

      float std_dev = 0.0;
      float median_diff=0;
	// diff is already a sorted array  - find Median only on 0 to icut values
      FindMedian3(diff,0,icut,median_diff); // using absolute value 2pt diff (up & down jumps)

      for (int i = 0; i< icut;i++){ // find the standard dev based on Median of diff
                                      // again - only looking at 0 to icut values
	float mdiff = 0;
	mdiff = fabs(median_diff - diff[i]);
	std_dev += mdiff*mdiff;
      }
      std_dev = sqrt( std_dev/(icut-1));
	// now test most deviant pt
	//-----------------------------------------------------------------------

      float testvalue = true_diff[index[n_good-1]] - median_diff;
      float testlimit = cr_sigma_reject*std_dev;
      float testlimit_small = testlimit*0.60;
      float testamp = 0.60;
      float testlimit_large = testlimit*2.0;

      // check if 2pt diff in question was not flagged already (sometimes 2 frames spike)


      int ibad_index = index[n_good-1]; // indexed to 2 pt difference
      int ibad_frame = ipixel[index[n_good-1]] + 1;   // indexed to frame value

      int id_test = 0;
      id_test = pixel.GetIDData(ibad_frame);
      if(id_test !=0 && debug == 1) cout << " ID test not 0 " << id_test << " " << xtemp << " " << 
	ytemp << " " << ibad_frame << endl;


      // Check if frame before or frame after is corrupt frame - skip this difference
      
      int skip = 0; 
      int id_testa = pixel.GetIDData(ibad_frame-1);
      int id_testb = pixel.GetIDData(ibad_frame+1);

      if(id_testa == BADFRAME || id_testb  == BADFRAME) {
	//cout << " Skip this 2pt diff " << xtemp << " " << ytemp << " " << ibad_frame << " " <<
	//  id_testa << " " << id_testb << endl;
	skip = 1;
      }


      if(debug == 1) {
	cout << "************************************************************" << endl;
	cout << "most deviant point " << diff[n_good-1] << " " << true_diff[index[n_good-1]] << endl;;
	cout << " x y " << xtemp << " " << ytemp << endl; 
	cout << "index " << index[n_good-1] << " frame" << ipixel[index[n_good-1]] + 1  << endl;
	cout << " id test " << id_test << " " << id_testa << " " << id_testb << endl;
	cout << "standard deviation " << std_dev << endl;
	cout << "testing " << testvalue << " limit " << testlimit  << endl;
	cout << true_diff[index[n_good-1]]  << " " << cosmic_ray_noise_level << endl; 
      }

	//look at absolute value - noise and cosmic rays
	
      if(id_test !=0 || skip ==1) {
	n_good--;
	icut++;
      } else if(fabs(testvalue) > testlimit && abs(testvalue) > cosmic_ray_noise_level && id_test==0 ){

	// look at next 2pt difference (it this a spike or a jump that stays up/down)

	int ID = 0; 

	float next_2pt_diff = 0.0;
	float next_next_2pt_diff = 0.0;
	float previous_2pt_diff = 0.0;
	float previous_previous_2pt_diff = 0.0;

	if(ibad_index+1 < n_good) next_2pt_diff = true_diff[ibad_index+1] - median_diff;
	if(ibad_index+2 < n_good) next_next_2pt_diff = true_diff[ibad_index+2] - median_diff;
	 

	if(ibad_index-1 >= 0) previous_2pt_diff = true_diff[ibad_index-1] - median_diff;
	if(ibad_index-2 >= 0) previous_previous_2pt_diff = true_diff[ibad_index-2] - median_diff;


	float testlimit2 = 0; 

	  //_______________________________________________________________________
	     // first check if diff> limit

	  //-----------------------------------------------------------------------
	if(testvalue > testlimit)  {      // positive jump between test point and next point
	  
	  testlimit2 = testamp * testvalue; 
	  if(debug ==1) cout << "testlimit_small testlimit2 " << testlimit_small << " " << testlimit2 << endl;
	  if(testlimit_small > testlimit2)  testlimit2 = testlimit_small;

	  //___________________________________________________________________________________________
	  // case 1: next point is large jump downward: 
	  if( fabs(next_2pt_diff) >  testlimit2 && next_2pt_diff < 0 ) { 
	    pixel.SetID(ibad_frame, NOISE_SPIKE_UP_ID);

	    pixel.RejectAfterEvent(ibad_frame,NOISE_SPIKE_UP_ID,
				   n_frames_reject_after_noise, 
				   n_frames_reject_after_cr); 

	    num_found_noise_spike_up++;

	    if(verbose_jump ==1) {
	      cout << " Found a noise jump up (next) case 1: "<<pixel.GetX()<< " "<<pixel.GetY() <<endl;
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " "<<next_2pt_diff <<" "<<  
		std_dev  << " " << ibad_frame << endl;
	      }
	  
	  //___________________________________________________________________________________________
	  // case 2: test if previous point was a jump down 
	  } else if(fabs(previous_2pt_diff) > testlimit2 && previous_2pt_diff < 0 ) {

	    ID = pixel.GetIDData(ibad_frame-1);
	    if(ID != 0){
	      cout << " ID ne 0 (64) case 2  " << ID << " " << xtemp << " " 
		   << ytemp << "  " << ibad_frame-1 << endl;
	    }else  { 
	      pixel.SetID(ibad_frame-1, NOISE_SPIKE_DOWN_ID);

	      pixel.RejectAfterEvent(ibad_frame-1,NOISE_SPIKE_DOWN_ID,
				     n_frames_reject_after_noise, 
				     n_frames_reject_after_cr); 
	      num_found_noise_spike_down++;

	      if(verbose_jump ==1) {
		cout << " Found a noise jump down (previous) case 2: "<<
		  pixel.GetX()<<" "<<pixel.GetY()<< endl;
		cout << diff[n_good-1] << " " << testvalue << " " <<testlimit<<" "<< previous_2pt_diff 
		     <<" "<<  ibad_frame-1 << endl;
	      }
	    }
	  
	  //___________________________________________________________________________________________
	  // case 3: next point small diff but the point after that is a is large jump downward (2 noise spikes up)
	  } else if( fabs(next_2pt_diff) < testlimit2 && fabs(next_next_2pt_diff) > 
		     testlimit2 && next_next_2pt_diff < 0 ) { 

	    ID = pixel.GetIDData(ibad_frame+1);
	    if(ID != 0) {
	      cout << " ID ne 0 (128) case 3 " <<ID<< " " << xtemp << " " << ytemp <<"  "<<ibad_frame+1<<endl;
	      pixel.SetID(ibad_frame, NOISE_SPIKE_UP_ID);
	    } else { 
	      pixel.SetID(ibad_frame, NOISE_SPIKE_UP_ID);
	      pixel.SetID(ibad_frame+1, NOISE_SPIKE_UP_ID);

	      pixel.RejectAfterEvent(ibad_frame+1,NOISE_SPIKE_UP_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 

	      num_found_noise_spike_up++;
	      if(verbose_jump ==1) {
		cout << " Found a noise jump up (2 frames): case 3 "
		     <<pixel.GetX()<< " "<< pixel.GetY()<<endl;
		cout << diff[n_good-1] << " " << testvalue << " " <<testlimit<<" "<<next_2pt_diff<< " " <<  
		  next_next_2pt_diff << " " << ibad_frame << " " << ibad_frame+1 << endl;
	      }
	  
	    }
	  //___________________________________________________________________________________________
	  // case 4:previous point small but previous previous large (2 noise spikes downward)
	  }else if( fabs(previous_2pt_diff) < testlimit2 && fabs(previous_previous_2pt_diff) > testlimit2 && previous_previous_2pt_diff < 0 ) { 


	    ID = pixel.GetIDData(ibad_frame-1);
	    if(ID != 0) {
	      cout << " ID ne 0 (64) case 3 " << ID << " " << xtemp << " " << ytemp << "  " << ibad_frame-1 << endl;
	    }
	    else {
	       pixel.SetID(ibad_frame-1, NOISE_SPIKE_DOWN_ID); 
	       pixel.RejectAfterEvent(ibad_frame-1,NOISE_SPIKE_UP_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 
	      num_found_noise_spike_down++;
	    }
	    
	    ID = pixel.GetIDData(ibad_frame-2);
	    if(ID != 0){
	      cout << " ID ne 0 (64) case 4" << ID << " " << xtemp << " " << ytemp << "  " << ibad_frame-2 << endl;
	        pixel.SetID(ibad_frame-2, NOISE_SPIKE_DOWN_ID);
	    }
	    
	      
 


	    if(verbose_jump ==1) {
	      cout << " Found a noise jump down (2 frames): case 4  " 
		   <<pixel.GetX() << " " << pixel.GetY() << endl;
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << next_2pt_diff << " " <<  
		next_next_2pt_diff << " " << ibad_frame-1 << " " << ibad_frame-2 << endl;
	    }
	  
	  //___________________________________________________________________________________________
	  // case 5<: COSMIC RAY!
	  // next point small diff & next_next point small diff
	  } else if( fabs(next_2pt_diff) < testlimit2 && fabs(next_next_2pt_diff) < testlimit2 &&
	      fabs(previous_2pt_diff) < testlimit2 && fabs(previous_2pt_diff) < testlimit2) { 
	     pixel.SetID(ibad_frame, COSMICRAY_ID);
	    num_found_cr++;

	    pixel.RejectAfterEvent(ibad_frame,COSMICRAY_ID,
	    			   n_frames_reject_after_noise, 
	   			   n_frames_reject_after_cr); 

	    if(verbose_jump ==1) {
	      cout << " Found a cosmic ray: case 5 " << pixel.GetX() << " " << pixel.GetY() << endl;
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << 
		next_2pt_diff << " " << ibad_frame <<  endl;
	    }
	  }else {
	    
	    if(testvalue > testlimit_large) {
	      if(verbose_jump ==1) cout << " Flagged as cosmic ray (case 5 b)  " << 
		xtemp << " " << ytemp << " " << ibad_frame << endl;
	        pixel.SetID(ibad_frame, COSMICRAY_ID);
	      pixel.RejectAfterEvent(ibad_frame,COSMICRAY_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 

	      num_found_cr++;
	    } else{
	      // call it noise spike up 
	      pixel.SetID(ibad_frame, NOISE_SPIKE_UP_ID);
	      if(verbose_jump ==1) cout << " Called it noise spike up (case 5c)  " 
					<< xtemp << " " << ytemp << " " << ibad_frame << endl;
	            pixel.RejectAfterEvent(ibad_frame,NOISE_SPIKE_UP_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 
	      num_found_noise_spike_up++;

	    }
	  }
	  
	}
	//-----------------------------------------------------------------------
	// Now look at negative JUMPS
	//-----------------------------------------------------------------------
	if(testvalue < testlimit) {    // negative jump
	  //___________________________________________________________________________________________
	  //case 6:  Jump down followed by a Jump up - point in question if a Noise Spike Down 
	  
	  testlimit2 = fabs(testvalue) * testamp; 

	  testlimit2 = testamp * testvalue; 
	  if(testlimit_small > testlimit2)  testlimit2 = testlimit_small;
	  if(next_2pt_diff > testlimit2 ){ // 
	      
	     pixel.SetID(ibad_frame, NOISE_SPIKE_DOWN_ID);
	    pixel.RejectAfterEvent(ibad_frame,NOISE_SPIKE_DOWN_ID,
	    			   n_frames_reject_after_noise, 
	    			   n_frames_reject_after_cr); 
	    num_found_noise_spike_down++;
	    if(verbose_jump ==1) {
	      cout << " Found a Noise Spike down: case 6 " << pixel.GetX()<< " "<< pixel.GetY() << endl; 
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << ibad_frame << endl;
	    }
	  
	    //___________________________________________________________________________________________
	    //case 7:  Jump down, But previous was a jump up   - point in question if a Noise Spike UP 

	  } else if(previous_2pt_diff > testlimit2 ){ // 
	    ID = pixel.GetIDData(ibad_frame-1);
	    if(ID != 0) {
	      //cout << " ID ne 0 (128) case 7 " << ID << " " <<xtemp<< " " << ytemp << "  " << ibad_frame-1 << endl;
	    } else {
	       
	        pixel.SetID(ibad_frame-1, NOISE_SPIKE_UP_ID);
	      pixel.RejectAfterEvent(ibad_frame-1,NOISE_SPIKE_UP_ID,
	      			   n_frames_reject_after_noise, 
	      			   n_frames_reject_after_cr); 

	      num_found_noise_spike_up++;
	    }
	    
	    if(verbose_jump ==1) {
	      cout << " Found a Noise Spike up: case 7 " << pixel.GetX()<<" "<< pixel.GetY()<<" "<< endl;
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << ibad_frame-1 << endl; 
	    }
	  
	    //___________________________________________________________________________________________
	    //case 8:  Jump down, next small but next next is jump up  - 2 frames spike down  

	  } else if( fabs(next_2pt_diff) <  testlimit2 && next_next_2pt_diff > testlimit2 ){ // 

	    pixel.SetID(ibad_frame, NOISE_SPIKE_DOWN_ID);

	    ID = pixel.GetIDData(ibad_frame+1);
	    num_found_noise_spike_down++;

	    if(ID != 0){
	      // cout << " ID ne 0 (64) case 8 " << ID << " " << xtemp << " " << ytemp << "  " << ibad_frame+1 << endl;
	    } else {

	       pixel.SetID(ibad_frame+1, NOISE_SPIKE_DOWN_ID);
	      pixel.RejectAfterEvent(ibad_frame,NOISE_SPIKE_DOWN_ID,
	      			   n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 
	    }
	    

	    if(verbose_jump ==1) {
	      cout << " Found a Noise Spike down: case 8 (2 frames) " 
		   <<pixel.GetX()<<" "<<pixel.GetY()<<endl; 
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << ibad_frame << " " <<
		ibad_frame+1  << endl;
	    }
	  
	    //___________________________________________________________________________________________
	    //case 9:  Jump down, previous small but previous revious was large - 2 frames spike up 

	  } else if( fabs(previous_2pt_diff) <  testlimit2 && previous_previous_2pt_diff > testlimit2 ){ // 


	    ID = pixel.GetIDData(ibad_frame-1);
	    if(ID != 0){
	      cout << " ID ne 0 (128) case 9 " << ID << " " << xtemp << " " << ytemp << "  " << ibad_frame-1 <<endl;
	    } else {

	       pixel.SetID(ibad_frame-1, NOISE_SPIKE_UP_ID);	      
	      pixel.RejectAfterEvent(ibad_frame-1,NOISE_SPIKE_UP_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 
	      num_found_noise_spike_up++;
	    }
	     
	     
	    ID = pixel.GetIDData(ibad_frame-2);
	    if(ID != 0) {
	      cout << " ID ne 0 (128) " << ID << " " << xtemp << " " << ytemp << "  " << ibad_frame-2<< endl;
	    } else{
	       
	      pixel.SetID(ibad_frame-2, NOISE_SPIKE_UP_ID);
	    }


	    if(verbose_jump ==1) {
	      cout << " Found a Noise Spike up (2 frames) : case 9  " << 
		pixel.GetX() <<" " <<pixel.GetY()<<endl; 
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << 
		ibad_frame-1 << " " <<ibad_frame-2  << endl;
	    }
	  

	    //___________________________________________________________________________________________
	    // case 10: COSMIC RAY NEG
	    // next point small diff & next_next point small diff
	  } else if( fabs(next_2pt_diff) < testlimit2 && fabs(next_next_2pt_diff) < testlimit2 && 
	      fabs(previous_2pt_diff) < testlimit2  && fabs(previous_previous_2pt_diff) < testlimit2) { 
	    pixel.SetID(ibad_frame, COSMICRAY_NEG_ID);

	    pixel.RejectAfterEvent(ibad_frame,COSMICRAY_NEG_ID,
	    			   n_frames_reject_after_noise, 
	    			   n_frames_reject_after_cr); 

	    num_found_cr_neg++;
	    if(verbose_jump ==1) {
	      cout << " Found a cosmic ray negative: case 10 " <<pixel.GetX()<<" "<<pixel.GetY() << endl;
	      cout << diff[n_good-1] << " " << testvalue << " " << testlimit << " " << next_2pt_diff << " " <<
		ibad_frame <<  endl;
	    }
	     
	  }else {

	    if(fabs(testvalue) > testlimit_large) {
	      //cout << " Flagged as cosmic negative ray  " <<xtemp << " " << ytemp << " " << ibad_frame << endl;
	      pixel.SetID(ibad_frame, COSMICRAY_NEG_ID);
	      pixel.RejectAfterEvent(ibad_frame,COSMICRAY_NEG_ID,
	      			   n_frames_reject_after_noise, 
	      			   n_frames_reject_after_cr); 
	      num_found_cr_neg++;
	    } else {
	      // call it noise
	      pixel.SetID(ibad_frame, NOISE_SPIKE_DOWN_ID);
	      pixel.RejectAfterEvent(ibad_frame,NOISE_SPIKE_DOWN_ID,
	      			     n_frames_reject_after_noise, 
	      			     n_frames_reject_after_cr); 
	      //cout << " Called it noise spike down (case 10)  " <<xtemp << " " << ytemp <<" " << ibad_frame<<  endl;
	      num_found_noise_spike_down++;
	    }
	  }

	}
	  //-----------------------------------------------------------------------
	  n_good--;
	  icut--;
	} else { // fabs(testvalue) < testlimit 
	  iterate = false;
	}
	iter_num++;
	if(iter_num > max_iterations) iterate = false;

    } // end iterate test b

  }// done while iterate
  //_______________________________________________________________________
  // 
  
  // remove the flagged values (noise & cosmic rays) and get a new 2 pt difference vector
  //cout << " done cosmic ray ids" << endl;


  long num_found = num_found_cr + num_found_noise_spike_up + num_found_noise_spike_down +
    num_found_cr_neg;


  if(num_found !=0){
    vector<long> index_new;
    index_new.reserve(NRamps-1);

    diff.erase(diff.begin(),diff.end());
    true_diff.erase(true_diff.begin(),true_diff.end());
    diff_org.erase(diff_org.begin(),diff_org.end());
    
    pixel.Get2ptDiffIndex(istart_fit,diff,true_diff,index_new,n_good);
    diff_org.assign(true_diff.begin(),true_diff.end()); 

  }

  //true diff and diff_org are only as large as ngood
  // This part is also done if -diagnostic flag is set. 

  // find 2pt diff with cosmic rays removed (and n_frames_after_cr) 
    // get vector of valid 2 pt differences
  float sum_diff= 0.0;
  float diff2 = 0.0;
  int ii=0;
  for(int i = 0; i< n_good-1;i++){
    sum_diff += diff_org[i];
    diff2 += diff_org[i]*diff_org[i];
    ii++;
  }
  

  float std_dev = (diff2 - (sum_diff*sum_diff)/ii)/(ii-1);
  pixel.SetStdDev2ptDiff(std_dev); // standard deviation of 2 pt diff with cosmic rays removed

  // _______________________________________________________________________


  float s(0.0);
  float sx(0.0);
  float sxx(0.0);
  float sy(0.0);
  float sxy(0.0);
  int num_good = 0;
  vector<float>::iterator iter = diff_org.begin();
  vector<float>::iterator iter_start = diff_org.begin();
  vector<float>::iterator iter_end = diff_org.end();

  int istart = -1;
  for(; iter != iter_end; ++iter){
    //  for( ; iter!=diff_org.end()-num_found;++iter){
    int i = iter - iter_start;
    if(istart == -1)  istart = i;
    int i1 = i+1;
    num_good++;
    s+= 1.0;
    sx += i1 ;
    sy += (*iter);
    sxx += (i1)*(i1);
    sxy += (i1)* (*iter);
    
  }   

  float delta = s*sxx - sx*sx;
  float Slope = 0.0;

    
  if(num_good < 2) {
    Slope = NO_SLOPE_FOUND;
  }else{
    Slope = (s*sxy - sx*sy)/delta;
  }
    
  pixel.SetSlope2ptDiff(Slope); // standard deviation of 2 pt diff with cosmic rays removed


}
