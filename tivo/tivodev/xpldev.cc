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

#include "xpldev.h"

unsigned short xplport = 50000;
char xpl_interface[33]="eth0";
char xplmyip[16];
unsigned int xplmybc;

char mesg[MAX_MESSAGE_SIZE+1] = "";
char msgout[MAX_MESSAGE_SIZE+1] = "";

xpl_msg_struc xpl_msg[MAX_MESSAGE_ITEMS+1], *pxpl_msg=&xpl_msg[0];

xpl_filter_type xpl_filters[MAX_FILTERS+1];
unsigned int xpl_filtercount=0;

char xpl_targets[MAX_TARGETS+1][35];
unsigned int xpl_targetcount=0;

xpl_config_type xpl_configs[MAX_CONFIGS+1];
unsigned int xpl_configcount=0;

char xpl_instance[17]="DEFAULT"; // set default instance here (16 max) @@@
int xpl_interval = 5; // if changed then amend default value in config processing @@@
char xpl_hbeat[34]="config.app"; // change to hbeat.basic for immediate start @@@
bool xpl_hbeatend=false;
								// or to config.basic/hbeat.basic if no hub required @@@
char xpl_schemaclass[34]=""; // set default hbeat status schema if required @@@
char xpl_schemamsg[MAX_MESSAGE_SIZE+1]=""; // set initial hbeat status msg if required @@@
bool xpl_configured=false;
bool xpl_passhbeat=false; // set to true to process hbeat.* @@@
bool xpl_passconfig=false; // set to true to process config.* @@@
bool xpl_passnomatch=false; // set to true to process targetted messages not targetted at me @@@

unsigned int xPLParser(const char* xplmsg, struct xpl_msg_struc * pxpl_msg) {

	int y, z, c;
	int w;
	char xpl_section[35];
	char xpl_name[17];
	char xpl_value[129];
	unsigned int xpl_msg_index = 0;

	#define XPL_IN_SECTION 0
	#define XPL_IN_NAME 1
	#define XPL_IN_VALUE 2

	w = XPL_IN_SECTION;
	z = 0;
	y = strlen(xplmsg);
	for (c=0;c<y;c++) {
	
		switch(w) {
		case XPL_IN_SECTION:
			if((xplmsg[c] != 10) && (z != 34)) {
				xpl_section[z]=xplmsg[c];
				z++;
			}
			else {
				c++;
				c++;
				w++;
				xpl_section[z]='\0';
				z=0;
			}
			break;
		case XPL_IN_NAME:
			if((xplmsg[c] != '=') && (xplmsg[c] != '!') && (z != 16)) {
				if(z<16) {
					xpl_name[z]=xplmsg[c];
					z++;
				}
			}
			else {
				w++;
				xpl_name[z]='\0';
				z=0;
			}
			break;
		case XPL_IN_VALUE:
			if((xplmsg[c] != 10) && (z != 128)) {
				if(z<128) {
					xpl_value[z]=xplmsg[c];
					z++;
				}
			}
			else {
				w++;
				xpl_value[z]='\0';
				z=0;
				if(xpl_msg_index > MAX_MESSAGE_ITEMS) {
					return(0);
				} 
				strcpy(pxpl_msg[xpl_msg_index].section, xpl_section);
				strcpy(pxpl_msg[xpl_msg_index].name, xpl_name);
				strcpy(pxpl_msg[xpl_msg_index].value, xpl_value);
				xpl_msg_index++;
				if(xplmsg[c+1] != '}') {
					w=XPL_IN_NAME;
				}
				else {
					w=XPL_IN_SECTION;
					c++;
					c++;
				}
			}	
			break;
		}
	}
	if(xpl_msg_index<3) {
		xpl_msg_index = 0;
	}
	return xpl_msg_index;
}

void XplSend(const unsigned short xplports, const char* xplmessage) {

	int xplsent;
	struct sockaddr_in sendxpl = { 0 };
	unsigned int sendxpllen;
	int xplSocket = 0;
	int optval;
	int optlen;

	sendxpl.sin_family = AF_INET;
	sendxpl.sin_port=htons(xplports);
	sendxpl.sin_addr.s_addr=htonl(xplmybc);
	xplSocket=socket(PF_INET, SOCK_DGRAM, 0);
	optval=1;
	optlen=sizeof(int);
	if(setsockopt(xplSocket, SOL_SOCKET, SO_BROADCAST, (char*)&optval, optlen)) { return; }
	sendxpllen=sizeof(struct sockaddr_in);
	if(strlen(xplmessage)>MAX_MESSAGE_SIZE) { return; }
	xplsent=sendto(xplSocket, xplmessage, strlen(xplmessage),0, (struct sockaddr *) &sendxpl, sendxpllen);
	close(xplSocket);
}

void sendxpl(const char* xpltype, const char* xpltarget, const char* xplschema, const char* xplbody) {
	
	char xplmsg[MAX_MESSAGE_SIZE+1];

	// check i should send
	if(xpl_configured==true || strncasecmp(xplschema,"CONFIG.",7)==0) {

		// build message header
		strcpy(xplmsg,xpltype);
		strncat(xplmsg,"\n{\nhop=1\nsource=",16);
		strncat(xplmsg,xpl_targets[0],strlen(xpl_targets[0]));
		strncat(xplmsg,"\ntarget=",8);
		strncat(xplmsg,xpltarget,strlen(xpltarget));
		strncat(xplmsg,"\n}\n",3);
	    	
		// build message body
		strncat(xplmsg,xplschema,strlen(xplschema));
		strncat(xplmsg,"\n{\n",3);
		if((strlen(xplmsg)+strlen(xplbody)+3)>MAX_MESSAGE_SIZE) { return; }
		strncat(xplmsg,xplbody,strlen(xplbody));
		if(xplmsg[strlen(xplmsg)-1]!='\n') { strncat(xplmsg,"\n",1); }
		strncat(xplmsg,"}\n",2);

		// send message
		XplSend(3865,xplmsg);

	}
}

void xPLValue(const char* xpl_name, char* xpl_value, struct xpl_msg_struc * pxpl_msg, unsigned int xpl_msg_index) {

	unsigned int x, c;

	x=0;
	c=0;
	xpl_value[0]='\0';
	while ((!x) && (c<xpl_msg_index)) {
		if(strcasecmp(pxpl_msg[c].name,xpl_name)==0) {
			x=1;
			strcpy(xpl_value, pxpl_msg[c].value);
		}
		c++;
	}
	return;
}

void xplheartbeat(int signum) {

	char xplmsg[MAX_MESSAGE_SIZE+1];
	char values[7];

	// build hearbeat
	strcpy(xplmsg,"xpl-stat\n{\nhop=1\nsource=");
	strncat(xplmsg,xpl_targets[0],strlen(xpl_targets[0]));
	strncat(xplmsg,"\ntarget=*\n}\n",12);
	if(xpl_hbeatend==true) {
		if(strcasecmp(xpl_hbeat,"config.app")==0) {
			strncat(xplmsg,"config.end",10);
		}
		else {
			strncat(xplmsg,"hbeat.end",9);
		}
	}
	else {
		strncat(xplmsg,xpl_hbeat,strlen(xpl_hbeat));
	}
	strncat(xplmsg,"\n{\ninterval=",12);
	sprintf(values,"%d",xpl_interval);
	strncat(xplmsg,values,strlen(values));
	strncat(xplmsg,"\n",1);
	if((strcasecmp(xpl_hbeat,"config.app")==0) || (strcasecmp(xpl_hbeat,"hbeat.app")==0)) {
		// add port= and remote-ip= for .app
		strncat(xplmsg,"port=",5);
		sprintf(values,"%d",xplport);
		strncat(xplmsg,values,strlen(values));
		strncat(xplmsg,"\n",1);
		strncat(xplmsg,"remote-ip=",10);
		strncat(xplmsg,xplmyip,strlen(xplmyip));
		strncat(xplmsg,"\n",1);
	}
	if((strlen(xpl_schemaclass)!=0) && (strlen(xpl_schemamsg)!=0) && (strncasecmp(xpl_hbeat,"HBEAT.",6)==0)) {
		// add schema to hbeat
		strncat(xplmsg,"schema=",7);
		strncat(xplmsg,xpl_schemaclass,strlen(xpl_schemaclass));
		strncat(xplmsg,"\n",1);
		strncat(xplmsg,xpl_schemamsg,strlen(xpl_schemamsg));
		if(xplmsg[strlen(xplmsg)]!='\n') { strncat(xplmsg,"\n",1); }
	}
	strncat(xplmsg,"}\n",2);

	// send heartbeat
	XplSend(3865,xplmsg);	
}

void QuitxPL(int sig)
{
	// tidy stuff up here @@@
	(void) signal(SIGINT,SIG_IGN);
	xpl_hbeatend=true;
	xplheartbeat(0);
	exit(0);
}

int main(int argc, char* argv[]) {

	int size = 0; 
	
	unsigned int xpl_msg_index = 0;

	struct sockaddr_in *sinp;
	struct ifreq ifr;
	int s;

	xpl_filter_type source;
	char target[35]="";
	char xpl_param[129]="";
	unsigned int x,y,z,c;
	unsigned int process;
	unsigned int confcounts[9];
	xpl_filter_type wrkfilter;

	// parse command line for interface
	if(!(argc<2)) {
		if(!(strlen(argv[1])>16)) { strcpy(xpl_instance,argv[1]); }
	}
	if(!(argc<3)) {
		strncpy(xpl_interface, argv[2], sizeof(xpl_interface)-1);
	}

	// get my ip address and broadcast address
	if((s=socket(AF_INET,SOCK_DGRAM,0))<0) {
		printf("xPL ERROR: Unable to Initialise!\n");
		exit(-1);
	}
	else {
		strcpy(ifr.ifr_name,xpl_interface);
		if(ioctl(s,SIOCGIFADDR,&ifr)<0) {
			printf("xPL ERROR: Unable to find %s!\n",xpl_interface);
			exit(-1);
		}
		else {
			sinp=(struct sockaddr_in *)&ifr.ifr_addr;
			strcpy(xplmyip,inet_ntoa(sinp->sin_addr));
			if(ioctl(s,SIOCGIFBRDADDR,&ifr)<0) {
				printf("xPL ERROR: Unable to determine Broadcast address!\n");
				exit(-1);
			}
			else
			{
				sinp=(struct sockaddr_in *)&ifr.ifr_broadaddr;
				xplmybc=inet_addr(inet_ntoa(sinp->sin_addr));
			}
		}
		close(s);
	}

	// initialise interface
	int udpSocket = 0;
	struct sockaddr_in inSocket = { 0 }, FromName = { 0 };
	unsigned int inSocketLen = 0;
	unsigned int FromNameLen = 0;		
	udpSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if(udpSocket < 0) {
		printf("xPL ERROR: Unable to open socket on %s!\n",xplmyip);
		exit(-1);
     	}
    	inSocket.sin_family = AF_INET;
    	inSocket.sin_addr.s_addr =  inet_addr(xplmyip);
    	inSocket.sin_port = htons(xplport);
		inSocketLen=sizeof(struct sockaddr);
		while(bind(udpSocket, (struct sockaddr *) &inSocket, inSocketLen) < 0) {
			xplport++;
			if(xplport>59999) { 
				printf("xPL ERROR: Unable to bind socket on any port!\n");
				exit(-1); 
			}
			inSocket.sin_port=htons(xplport);
    	}
		FromNameLen=sizeof(struct sockaddr);

	// xpl initialise 
	if(strncasecmp(xpl_hbeat,"HBEAT.",6)==0) { xpl_configured=true; }

	// initialise filters
	strcpy(xpl_filters[0].msgtype,"*");
	strcpy(xpl_filters[0].vendor,"TONYT"); // set vendor here (8 max) @@@
	strcpy(xpl_filters[0].device,"TDEV"); // set device here (8 max) @@@
	strcpy(xpl_filters[0].instance,xpl_instance); 
	strcpy(xpl_filters[0].schemaclass,"*");
	strcpy(xpl_filters[0].schematype,"*");

	// any amendments to this filter should also be made in the code to restore defaults in config processing @@@
	strcpy(xpl_filters[1].msgtype,"*"); // amend as required (xpl-cmnd, xpl-stat or xpl-trig) @@@
	strcpy(xpl_filters[1].vendor,"*"); // amend as required (8 max) @@@
	strcpy(xpl_filters[1].device,"*"); // amend as required (8 max) @@@
	strcpy(xpl_filters[1].instance,"*"); // amend as required (16 max) @@@
	strcpy(xpl_filters[1].schemaclass,"*"); // amend as required (16 max) @@@
	strcpy(xpl_filters[1].schematype,"*"); // amend as required (16 max) @@@
	// add additional filters as required & add code to restore defaults in config processing @@@
	xpl_filtercount=1; // set to highest defined filter - 16 max unless xpldev.hh amended @@@
	
	// initialise primary target
	strcpy(xpl_targets[0],xpl_filters[0].vendor);
	strncat(xpl_targets[0],"-",1);
	strncat(xpl_targets[0],xpl_filters[0].device,strlen(xpl_filters[0].device));
	strncat(xpl_targets[0],".",1);
	strncat(xpl_targets[0],xpl_filters[0].instance,strlen(xpl_filters[0].instance));
	xpl_targetcount=0;

	// initialise groups if required & add code to restore defaults in config processing @@@
	// strcpy(xpl_targets[1],"XPL-GROUP.???"); // set required group name (XPL-GROUP.16 max) @@@
	// xpl_targetcount=1; // set to highest defined group/target - 16 max unless xpldev.hh amended @@@

	// initialise configs
	strcpy(xpl_configs[1].item,"NEWCONF");
	strcpy(xpl_configs[1].type,"RECONF");
	if(strncasecmp(xpl_hbeat,"HBEAT.",6)==0) { strcpy(xpl_configs[1].type,"OPTION"); }
	xpl_configs[1].number=1;
	strcpy(xpl_configs[2].item,"INTERVAL");
	strcpy(xpl_configs[2].type,"RECONF");
	xpl_configs[2].number=1;
	strcpy(xpl_configs[3].item,"GROUP");
	strcpy(xpl_configs[3].type,"OPTION");
	xpl_configs[3].number=MAX_TARGETS;
	strcpy(xpl_configs[4].item,"FILTER");
	strcpy(xpl_configs[4].type,"OPTION");
	xpl_configs[4].number=MAX_FILTERS;
	xpl_configcount=4; // set to highest defined config - 16 max unless xpldev.hh amended @@@

	// user defined configs here & add code to restore defaults in config processing @@@
	// if adding extra 'list' type configs then remember to assign storage space
	// strcpy(xpl_configs[5].item,"MCONFIG");
	// strcpy(xpl_configs[4].type,"OPTION");
	// xpl_configs[4].number=MAX_MYCONFIGS;
	// xpl_configcount=5; 

	// install timer
	struct sigaction sa;
	struct itimerval timer;
	memset(&sa,0,sizeof(sa));
	sa.sa_handler=&xplheartbeat;
	sigaction(SIGALRM,&sa,NULL);
	timer.it_value.tv_sec=1;
	timer.it_value.tv_usec=0;
	timer.it_interval.tv_sec=60;
	timer.it_interval.tv_usec=0;
	setitimer(ITIMER_REAL,&timer,NULL);

	// install ctl-c handler
	(void) signal (SIGINT, QuitxPL);
	(void) signal (SIGTERM, QuitxPL);

	// listen and process
    while(1) {

		size=-1;
		while(size==-1) {
			size = recvfrom(udpSocket, mesg, MAX_MESSAGE_SIZE, 0,(struct sockaddr *)&FromName, &FromNameLen);
       		if(size<-1) {
				exit(-1);
       		}
		}
		mesg[size]=0;
		process=1;

		// parse message
		xpl_msg_index=xPLParser(mesg, pxpl_msg);
		if(xpl_msg_index > 0) {
			
			// store message type
			strcpy(source.msgtype,pxpl_msg[0].section);
			// get source
			xPLValue("SOURCE",xpl_param, pxpl_msg, xpl_msg_index);
			// store vendor
			for(x=0;xpl_param[x]!='-';x++) {
				source.vendor[x]=xpl_param[x];
			}
			source.vendor[x]='\0';
			// store device
			y=0;
			for(x++;xpl_param[x]!='.';x++) {
				source.device[y++]=xpl_param[x];
			}
			source.device[y]='\0';
			// store instance
			y=0;
			for(x++;x<=strlen(xpl_param);x++) {
				source.instance[y++]=xpl_param[x];
			}
			source.instance[y]='\0';
			
			// get schema
			strcpy(xpl_param,pxpl_msg[3].section);
			// store schema class
			for(x=0;xpl_param[x]!='.';x++) {
				source.schemaclass[x]=xpl_param[x];
			}
			source.schemaclass[x]='\0';
			// store schematype
			y=0;
			for(x++;x<=strlen(xpl_param);x++) {
				source.schematype[y++]=xpl_param[x];
			}
			source.schematype[y]='\0';
			
			// get target
			xPLValue("TARGET",target, pxpl_msg, xpl_msg_index);

			// check i didnt send it
			if(strcasecmp(source.vendor,xpl_filters[0].vendor)==0 && strcasecmp(source.device,xpl_filters[0].device)==0 && strcasecmp(source.instance,xpl_filters[0].instance)==0) { process=0; }

			// is it a config command
			if((process!=0) && (strcasecmp(source.schemaclass,"CONFIG")==0) && (strcasecmp(source.msgtype,"XPL-CMND")==0)) {
				// process config response
				if(strcasecmp(source.schematype,"RESPONSE")==0) {
					// is it a response to me
					if(strcasecmp(target,xpl_targets[0])==0) { 
						// process items
						confcounts[0]=0;
						confcounts[1]=0;
						for(x=3;x<xpl_msg_index;x++) {
							// find item
							for(z=1;z<=xpl_configcount;z++) {
								if(strcasecmp(pxpl_msg[x].name,xpl_configs[z].item)==0) { break; }
							}
							if(z<=xpl_configcount) {
								// process item
								switch(z) {
									case 1: // NEWCONF
											strcpy(xpl_filters[0].instance,pxpl_msg[x].value);
											strcpy(xpl_targets[0],xpl_filters[0].vendor);
											strncat(xpl_targets[0],"-",1);
											strncat(xpl_targets[0],xpl_filters[0].device,strlen(xpl_filters[0].device));
											strncat(xpl_targets[0],".",1);
											strncat(xpl_targets[0],xpl_filters[0].instance,strlen(xpl_filters[0].instance));
											break;
									case 2: // INTERVAL
											xpl_interval=atoi(pxpl_msg[x].value);
											if(xpl_interval<5) { xpl_interval=5; } // set default here @@@
											if(xpl_interval>30) { xpl_interval=30; }
											break;
									case 3: // GROUP
											if(strlen(pxpl_msg[x].value)==0) {
												// clear
												xpl_targetcount=0;
												confcounts[1]=0;
												
												// restore any default groups here @@@
												// strcpy(xpl_targets[1],"XPL-GROUP.MYGROUP");
												xpl_targetcount=0; // set correct number of groups here @@@
												confcounts[1]=xpl_targetcount;

											}
											else {
												if(strncasecmp(pxpl_msg[x].value,"XPL-GROUP.",10)==0) {
													if(confcounts[1]==0) {
														xpl_targetcount=1;
														strcpy(xpl_targets[1],pxpl_msg[x].value);
														confcounts[1]++;
													}
													else {
														xpl_targetcount++;
														if(xpl_targetcount<=MAX_TARGETS) {
															strcpy(xpl_targets[xpl_targetcount],pxpl_msg[x].value);
															confcounts[1]++;
														}
														else {
															xpl_targetcount--;
														}
													}
												}	
											}
											break;	
									case 4: // FILTER
											if(strlen(pxpl_msg[x].value)==0) {
												// clear
												xpl_filtercount=0;
												confcounts[0]=0;

												// restore default filters @@@
												strcpy(xpl_filters[1].msgtype,"*"); // set to correct default @@@
												strcpy(xpl_filters[1].vendor,"*"); // set to correct default @@@
												strcpy(xpl_filters[1].device,"*"); // set to correct default @@@
												strcpy(xpl_filters[1].instance,"*"); // set to correct default @@@
												strcpy(xpl_filters[1].schemaclass,"*"); // set to correct default @@@
												strcpy(xpl_filters[1].schematype,"*"); // set to correct default @@@@
												// add additional filters here
												xpl_filtercount=1; // set correct number of filters here @@@
												confcounts[0]=xpl_filtercount;

											}
											else {
												for(y=0,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<8;y++) {
													wrkfilter.msgtype[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.msgtype[c]='\0';
												if(strlen(wrkfilter.msgtype)==0) { strcpy(wrkfilter.msgtype,"*"); }
												for(y++,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<8;y++) {
													wrkfilter.vendor[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.vendor[c]='\0';
												if(strlen(wrkfilter.vendor)==0) { strcpy(wrkfilter.vendor,"*"); }
												for(y++,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<8;y++) {
													wrkfilter.device[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.device[c]='\0';
												if(strlen(wrkfilter.device)==0) { strcpy(wrkfilter.device,"*"); }
												for(y++,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<16;y++) {
													wrkfilter.instance[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.instance[c]='\0';
												if(strlen(wrkfilter.instance)==0) { strcpy(wrkfilter.instance,"*"); }
												for(y++,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<16;y++) {
													wrkfilter.schemaclass[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.schemaclass[c]='\0';
												if(strlen(wrkfilter.schemaclass)==0) { strcpy(wrkfilter.schemaclass,"*"); }
												for(y++,c=0;(pxpl_msg[x].value[y]!='.') && (y<strlen(pxpl_msg[x].value)) && c<16;y++) {
													wrkfilter.schematype[c++]=pxpl_msg[x].value[y];
												}
												wrkfilter.schematype[c]='\0';
												if(strlen(wrkfilter.schematype)==0) { strcpy(wrkfilter.schematype,"*"); }
												if(confcounts[0]==0) {
													xpl_filtercount=1;
												}
												else {
													xpl_filtercount++;
													if(xpl_filtercount>MAX_FILTERS) { xpl_filtercount--; }
												}
												strcpy(xpl_filters[xpl_filtercount].msgtype,wrkfilter.msgtype);
												strcpy(xpl_filters[xpl_filtercount].vendor,wrkfilter.vendor);
												strcpy(xpl_filters[xpl_filtercount].device,wrkfilter.device);
												strcpy(xpl_filters[xpl_filtercount].instance,wrkfilter.instance);
												strcpy(xpl_filters[xpl_filtercount].schemaclass,wrkfilter.schemaclass);
												strcpy(xpl_filters[xpl_filtercount].schematype,wrkfilter.schematype);
												confcounts[0]++;
											}
											break;
									// add user defined config handling here @@@
									// if value sent is blank then remember to restore default values @@@
								}
							}
						}
						// configured
						if(strcasecmp(xpl_hbeat,"config.basic")==0) { strcpy(xpl_hbeat,"hbeat.basic"); }
						if(strcasecmp(xpl_hbeat,"config.app")==0) { strcpy(xpl_hbeat,"hbeat.app"); }
						if(xpl_configured==false) {
							// add stuff to be done when configured FOR FIRST TIME here @@@
						}
						else {
							// add stuff to be done when re-configured here @@@
						}
						xpl_configured=true;
						sigaction(SIGALRM,&sa,NULL);
						timer.it_value.tv_sec=1;
						timer.it_value.tv_usec=0;
						timer.it_interval.tv_sec=60*xpl_interval;
						timer.it_interval.tv_usec=0;
						setitimer(ITIMER_REAL,&timer,NULL);					
					}
				}
				// process config request
				if(strcasecmp(source.schematype,"LIST")==0) {
					// is it a request to me
					if(strcasecmp(target,xpl_targets[0])==0) { 
						xPLValue("COMMAND",xpl_param, pxpl_msg, xpl_msg_index);
						if(strcasecmp(xpl_param,"REQUEST")==0) {
							msgout[0]=0;
							for(x=1;x<=xpl_configcount;x++) {
								strncat(msgout,xpl_configs[x].type,strlen(xpl_configs[x].type));
								strncat(msgout,"=",1);
								strncat(msgout,xpl_configs[x].item,strlen(xpl_configs[x].item));
								if(xpl_configs[x].number>1) {
									sprintf(xpl_param,"[%d]",xpl_configs[x].number);
									strncat(msgout,xpl_param,strlen(xpl_param));
								}
								strncat(msgout,"\n",1);
							}
							sendxpl("xpl-stat","*","config.list",msgout);
						}
					}
				}
				// process config current request
				if(strcasecmp(source.schematype,"CURRENT")==0) {
					// is it a request to me
					if(strcasecmp(target,xpl_targets[0])==0) { 
						xPLValue("COMMAND",xpl_param, pxpl_msg, xpl_msg_index);
						if(strcasecmp(xpl_param,"REQUEST")==0) {
							msgout[0]=0;
							for(x=1;x<=xpl_configcount;x++) {
								switch (x) {
									case 1: // newconf
										sprintf(xpl_param,"NEWCONF=%s\n",xpl_filters[0].instance);
										strncat(msgout,xpl_param,strlen(xpl_param));
										break;
									case 2: // interval
										sprintf(xpl_param,"INTERVAL=%d\n",xpl_interval);
										strncat(msgout,xpl_param,strlen(xpl_param));
										break;
									case 3: // group
										if(xpl_targetcount>0) {
											for(y=1;y<=xpl_targetcount;y++) {
												sprintf(xpl_param,"GROUP=%s\n",xpl_targets[y]);
												strncat(msgout,xpl_param,strlen(xpl_param));
											}
										}
										else {
											sprintf(xpl_param,"GROUP=\n");
											strncat(msgout,xpl_param,strlen(xpl_param));
										}
										break;
									case 4: // filter
										if(xpl_filtercount>0) {
											for(y=1;y<=xpl_filtercount;y++) {
												sprintf(xpl_param,"FILTER=%s.%s.%s.%s.%s.%s\n",xpl_filters[y].msgtype,xpl_filters[y].vendor,xpl_filters[y].device,xpl_filters[y].instance,xpl_filters[y].schemaclass,xpl_filters[y].schematype);
												strncat(msgout,xpl_param,strlen(xpl_param));
											}
										}
										else {
											sprintf(xpl_param,"FILTER=\n");
											strncat(msgout,xpl_param,strlen(xpl_param));
										}
										break;
									case 5: // add user defined items from here on @@@
										// must return value for all config items even if blank @@@
										break;
								}
							}
							sendxpl("xpl-stat","*","config.current",msgout);
						}
					}
				}
			}

			// decide whether to process
			if(xpl_configured==false) { process=0; }
			if(strncasecmp(xpl_hbeat,"CONFIG.",7)==0) { process=0; }
			if((strcasecmp(source.schemaclass,"CONFIG")==0) && (xpl_passconfig==false)) { process=0; }
			if((strcasecmp(source.schemaclass,"HBEAT")==0) && (xpl_passhbeat==false)) { process=0; }

			// check if message is targetted
			if((process!=0) && (target[0]!='*')) {
				process=0;
				if(strcasecmp(target,xpl_targets[0])==0) { 
					process=2; 
				} 
				else {
					for(x=1;x<=xpl_targetcount;x++) {
						if(strcasecmp(target,xpl_targets[x])==0) {
							process=1;
							break;
						}
					}
				}
				if(xpl_passnomatch!=false) { process=1; }
			}

			if(process==1) {
				// check filters
				for(x=1;x<=xpl_filtercount;x++) {
					process=2;
					if(xpl_filters[x].msgtype[0]!='*' && strcasecmp(source.msgtype,xpl_filters[x].msgtype)!=0) { process = 0; }
					if(xpl_filters[x].vendor[0]!='*' && strcasecmp(source.vendor,xpl_filters[x].vendor)!=0) { process = 0; }
					if(xpl_filters[x].device[0]!='*' && strcasecmp(source.device,xpl_filters[x].device)!=0) { process = 0; }
					if(xpl_filters[x].instance[0]!='*' && strcasecmp(source.instance,xpl_filters[x].instance)!=0) { process = 0; }
					if(xpl_filters[x].schemaclass[0]!='*' && strcasecmp(source.schemaclass,xpl_filters[x].schemaclass)!=0) { process = 0; }
					if(xpl_filters[x].schematype[0]!='*' && strcasecmp(source.schematype,xpl_filters[x].schematype)!=0) { process = 0; }
					if(process==2) { break; }
				}
			}

			if(process==2) {
				// this is where you do your stuff based on incoming messages @@@
				printf("%s\n",mesg);
			}
		}
	}
}
