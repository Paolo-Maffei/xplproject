/* This file is originally from embeem's tivovbi 1.03:
   http://tivo.samba.org/download/mbm

   It has been updated since then to allow the OSD to display
   over the Tivo menus */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "osd.h"
#include "font.h"

int mpegfd=0;

#define	XSIZE       720     // Pixels available in X direction  684/720
#define YSIZE       480     // Pixels available in Y direction
#define OFFSET_F    8+512	// Fixed offset (Header + Color Palette)
#define	OFFSET_X    80      // Text offset in pixels from left (X)
#define	OFFSET_Y    6       // Text offset in pixels from top  (Y)

unsigned char *tivbuffer = 0;
int xplcol;

static struct osd cur_osd = {0,0,0};

void DrawString(char *string, int fg, int bg)
{
  unsigned int x, ptr;
  char *bits;
  
  if (!tivbuffer) return;
  while (string[0] != 0) {
    if(osd_x>35 || (string[0]=='\\' && string[1]=='n')) {
      osd_x = xplcol;
      osd_y++;
	string++;
    } else {

      bits = (char *)&textfont[string[0] * (TEXTFONT_X/8) * TEXTFONT_Y];

      if (!tivbuffer) return;
      if ((osd_x) > MAX_CHAR_X) (osd_x) = xplcol, (osd_y)++;
      if ((osd_y) > MAX_CHAR_Y) (osd_y) = 0;

      ptr = OFFSET_F+
            ((osd_x)*(TEXTFONT_X+1))+OFFSET_X+
            ((osd_y)*TEXTFONT_Y+OFFSET_Y)*XSIZE;

      if (!cur_osd.start) cur_osd.start=ptr;	// First write to buffer

      if (ptr < cur_osd.start) {
        cur_osd.len += cur_osd.start-ptr;	// Increase length
        cur_osd.start=ptr;			// Set start to start of char
      }

      for (x = 0; x < TEXTFONT_Y; x++) {
        tivbuffer[(ptr)++] = ((*bits   & 128)?fg:bg);	// Inner-loop for
        tivbuffer[(ptr)++] = ((*bits   &  64)?fg:bg);	//  copying bits from
        tivbuffer[(ptr)++] = ((*bits   &  32)?fg:bg);	//  font array to
        tivbuffer[(ptr)++] = ((*bits   &  16)?fg:bg);	//  screen array
        tivbuffer[(ptr)++] = ((*bits   &   8)?fg:bg);	// This has been
        tivbuffer[(ptr)++] = ((*bits   &   4)?fg:bg);	//  unrolled for
        tivbuffer[(ptr)++] = ((*bits   &   2)?fg:bg);	//  optimization
        tivbuffer[(ptr)++] = ((*bits++ &   1)?fg:bg);	// If TEXTFONT_X is
        tivbuffer[(ptr)++] = ((*bits   & 128)?fg:bg);	//  changed from (16),
        tivbuffer[(ptr)++] = ((*bits   &  64)?fg:bg);	//  this will need to
        tivbuffer[(ptr)++] = ((*bits   &  32)?fg:bg);	//  be recoded
        tivbuffer[(ptr)++] = ((*bits   &  16)?fg:bg);
        tivbuffer[(ptr)++] = ((*bits   &   8)?fg:bg);
        tivbuffer[(ptr)++] = ((*bits   &   4)?fg:bg);
        tivbuffer[(ptr)++] = ((*bits   &   2)?fg:bg);
        tivbuffer[(ptr)++] = ((*bits++ &   1)?fg:bg);
        tivbuffer[(ptr)]   = bg;

        ptr += XSIZE - TEXTFONT_X;	// Next row (Y), start of current char
      }

      osd_x++;

      if (ptr > cur_osd.start+cur_osd.len)	// Use end of char from length
        cur_osd.len = ptr - cur_osd.start;
    }
    string++;
  }
}

void SetupTextOSD(void)
{
  mpegfd = open("/dev/mpeg0v", O_RDWR);
  tivbuffer = (unsigned char *) calloc(1,OFFSET_F + XSIZE * YSIZE);
}

void FreeTextOSD(void)
{
  if (tivbuffer) free(tivbuffer);
  tivbuffer=0;
  close(mpegfd);
}

void ClearOSD(int from_start)
{
  if (!tivbuffer) return;
  if (from_start) {
    cur_osd.start = OFFSET_F;
    cur_osd.len = 0;
  }
  memset(&tivbuffer[cur_osd.start], 0, cur_osd.len);
}

void DrawOSD(void)
{
  if (!tivbuffer) return;
  if (cur_osd.start) {
    cur_osd.start = (cur_osd.start &~7);	// Force start on 8 byte bdy
    cur_osd.len   = (cur_osd.len   &~7)+8;	// Force len   on 8 byte bdy
    cur_osd.buf   = &tivbuffer[cur_osd.start];	// Set buffer based on start

    ioctl(mpegfd, 0x403, &cur_osd);
  }
}
