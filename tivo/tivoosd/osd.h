/* This file is originally from embeem's tivovbi 1.03:
   http://tivo.samba.org/download/mbm

   It has been changed/updated since then to allow OSD to
   display over the tivo menus */

#ifndef OSD_H
#define OSD_H

#define MAX_CHAR_X  34  // Maximum cols in X direction
#define MAX_CHAR_Y  15  // Maximum rows in Y direction

struct osd {
    unsigned start;
    unsigned len;
    void *buf;
};

extern int mpegfd;

extern unsigned char *tivbuffer;

extern void DrawString(int cur_x, int cur_y, char *string, int fg, int bg);

extern void SetupTextOSD(void);
extern void FreeTextOSD(void);
extern void ClearOSD(int from_start);
extern void DrawOSD(void);

#endif
