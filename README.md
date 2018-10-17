# miscellaneous
## `mdo`
It's a tool anyone can use to operate multiple remote hosts from the host where this mdo.sh resides.   
It can be very useful in an intranet enviroment.  
> First, you need to provide your hosts' list by adding alias:hostname(or ip) formatted lines into the file "hlist" which is (and should be) at the same dir as mdo.sh.    
> `e.g.` foo:192.168.0.123   

> Second, run ./mdo.sh init   

All supported operations are as follows:
> run command under the specified dir on a remote host   
> `e.g.` ./mdo.sh ls foo /home

> transfer a file to a remote host  
> `e.g.` ./mdo.sh put foo file  
> file should be at rootpath which is /home/mdo by default, and it will be transfered to a same rootpath of the remote host which is known as foo  

> download a file from a remote host  
> `e.g.` ./mdo.sh get foo file  

> request an url on a remote host, store the response as a timestamped file, and transfer it back  
> `e.g.` ./mdo.sh html foo http://localhost/...  
