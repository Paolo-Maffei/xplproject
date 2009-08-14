// **************************************
// * xPL Tivo Dev
// *
// * Copyright (C) 2003 Tony Tofts
// * http://www.xplhal.com
// *
// * This program is free software; you can redistribute it and/or
// * modify it under the terms of the GNU General Public License
// * as published by the Free Software Foundation; either version 2
// * of the License, or (at your option) any later version.
// *
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program; if not, write to the Free Software
// * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// **************************************

#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

typedef struct xpl_msg_struc {
	char section[34];
	char name[18];
	char value[130];
};

typedef struct xpl_filter_type {
	char msgtype[10];
	char vendor[10];
	char device[10];
	char instance[18];
	char schemaclass[18];
	char schematype[18];
};

typedef struct xpl_config_type {
	char item[18];
	char type[8];
	int number;
};

#define MAX_MESSAGE_SIZE 1500
#define MAX_MESSAGE_ITEMS 30
#define MAX_FILTERS 16 // set maximum number of filters required here @@@
#define MAX_TARGETS 16 // set maximum number of targets required here @@@
#define MAX_CONFIGS 10 // set the number of config items needed here, allow 4 for standard items @@@

unsigned int xPLParser(const char*, struct xpl_msg_struc *);
void XplSend(const unsigned short, const char*);
void sendxpl(const char*, const char*, const char*, const char*);
void xPLValue(const char*, char*, struct xpl_msg_struc *, unsigned int);
void xplheartbeat(int);
void QuitxPL(int sig);

