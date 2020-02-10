// miri_constants.h

#ifndef CONSTANTS_H
#define CONSTANTS_H

#define MAX_FILENAME_LENGTH 500
#define MAX_SAVE_SEGMENTS 4

#define SUBCHANNEL_A 0
#define SUBCHANNEL_B 1
#define SUBCHANNEL_C 2

#define  IM "IM"
#define  IC "IC"
#define  MIRIIM "MIRIMAGE"
#define  SW "SW"
#define  MIRISW "MIRIFUSHORT"
#define  LW "LW"
#define  MIRILW "MIRIFULONG"

// define the various identifications values for reads

#define NO_SLOPE_FOUND -1  

#define CDP_DONOT_USE 1
#define CDP_NODARK 2
#define CDP_NORESET 2
#define CDP_NOLINEARITY 2 // does not exist at the moment


#define BAD_PIXEL_ID 1  // set DEAD_PIXEL_ID & HOT_PIXEL_ID DO_NOT_PROCESS 
#define HIGHSAT_ID 2
#define COSMICRAY_ID 4
#define NOISE_SPIKE_DOWN_ID 8
#define NOISE_SPIKE_UP_ID 8
#define COSMICRAY_NEG_ID 16

#define NO_RSCD_CORRECTION 32
#define UNRELIABLE_DARK 64
#define UNRELIABLE_LIN 128
#define NOLASTFRAME 256
#define MIN_FRAME_FAILURE 512
#define UNRELIABLE_RESET 1024

#define SKIP_FRAME -1 // Skip frames in beginning or end of integration
#define BADFRAME -2 // electric problem with Frame
#define REJECT_AFTER_NOISE_SPIKE -8 // not used in determining DATA QUALITY FLAG 
#define REJECT_AFTER_CR -4 // not used in determining DATA QUALITY FLAG 
#define COSMICRAY_SLOPE_FAILURE -16 // (turned into COSMICRAY_ID) for Final DATA Quality flag
#define SEG_MIN_FAILURE -32 // if num_segments > 1 turned into COSMICRAY_ID for Final DATA Quality flag
                            // if num_segments =1 turned into MIN_FRAME_FAILURE for Final DATA Quality flag

#endif
