xpl_nntp

Pre-requisite : xpl timer must be present

0.8 This tools allows to monitor a nntp thread


TODO : 
	Le module ne semble plus répondre aux hbeat request une fois qu'il a lancé un check des groupes pour la première fois
	
Start the monitoring of a group : 
xpl-cmnd
{
hop=0
source=clinique-logger.lapfr0005
target=*
}
control.basic
{
device=proxad.free.annonces
current=start
}