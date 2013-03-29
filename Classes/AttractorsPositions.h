/*  GIMP header image file format (INDEXED): /Users/baptistebohelay/dev/test lulu 2 copy/Classes/AttractorsPositions.h  */

static unsigned int width = 17;
static unsigned int height = 8;

/*  Call this macro repeatedly.  After each use, the pixel data can be extracted  */

#define HEADER_PIXEL(data,pixel) {\
pixel[0] = header_data_cmap[(unsigned char)data[0]][0]; \
pixel[1] = header_data_cmap[(unsigned char)data[0]][1]; \
pixel[2] = header_data_cmap[(unsigned char)data[0]][2]; \
data ++; }

static char Luli[] = {
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	1,
	0,1,1,1,0,1,1,0,1,0,1,1,1,0,1,1,
	0,
	0,1,1,1,0,1,1,0,1,0,1,1,1,0,1,1,
	0,
	0,1,1,1,0,1,1,0,1,0,1,1,1,0,1,1,
	0,
	0,1,1,1,0,1,1,0,1,0,1,1,1,0,1,1,
	0,
	0,1,1,1,0,1,1,0,1,0,1,1,1,0,1,1,
	0,
	0,0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,
	1,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	1
	};
