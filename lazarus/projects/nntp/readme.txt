xpl_nntp

Pre-requisite : xpl timer must be present

0.8 This tools allows to monitor a nntp thread



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
