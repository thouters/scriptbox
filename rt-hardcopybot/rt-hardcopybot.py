#!/usr/bin/python
# -*- coding: utf-8 -*-
from subprocess import *
import os.path
import sys
from string import Template
from textwrap import wrap

templatestring = """<right><b>$Queue</b>
<h1>#$id</h1></right>
<center><h2>$Subject</h2></center>

$body

<right><u>$LastUpdated</u></right>

.
"""
printer = "ticketprinter"
queues = "queue1,queue2"
ticketdb = os.path.expanduser("~/.rt-tickets")

class Ticket:
    def __init__(self,tid,data):
        self.data = data
        self.tid = tid

        data["id"] = tid
        data["body"]=""
        for aid in rt.listattachments(tid)[0:1]:
            #only first attachment is used due to [0:1]
            aid = aid.strip()
            body = rt.getattachment(tid,aid)
            if body !="":
                data["body"] = body.strip()
        data["body"] = '\n'.join(wrap(data["body"],42))
        data["Subject"] = '\n'.join(wrap(data["Subject"],21))
        self.data = data


class TicketDB(list):
    def __init__(self,fn):
        self.fname = fn
        fd = open(self.fname,'r')
        x= fd.read().strip().split(" ")
        fd.close()
        map(self.append,x)
    def write(self):
        fd = open(self.fname,'w')
        fd.write(' '.join(self))
        fd.close()

class RtGlue:
    def listqueues(self,queues):
        if len(queues) == 0:
            return []
        listcmd = "rt ls -f Ticket -q %s" % (','.join(queues))
        output = Popen(listcmd.split(), stdout=PIPE).communicate()[0]
        return map(str.strip,output.strip().split('\n')[1:])
    def retrieveticket(self,tid):
        cmd = "rt show -s %s" % (tid)
        params = Popen(cmd.split(), stdout=PIPE).communicate()[0]
        data = map(lambda x: map(str.strip,str.split(x,":",1)),params.strip().split('\n'))
	data = filter(lambda x: len(x)>1,data)
        return Ticket(tid,dict(data))
    def listattachments(self,tid):
        cmd = "rt show ticket/%s/attachments/" % tid
        output = Popen(cmd.split(), stdout=PIPE).communicate()[0]
        aments = output.strip().split("\n")
        aments = map(lambda s: str.split(s,":",1)[0],aments)
        return map(str.strip,aments)
    def getattachment(self,tid,aid):
        cmd = "rt show ticket/%s/attachments/%s" % (tid,aid)
        return Popen(cmd.split(), stdout=PIPE).communicate()[0].strip()


class LinePrinter:
    def __init__(self,name):
        self.name=name
    def write(self,data):
        printcmd = "lp -d ticketprinter"
        o,e = Popen(printcmd.split(), stdin=PIPE,stdout=PIPE,stderr=PIPE).communicate(data)
        if len(e) >0:
            raise Exception

if __name__=="__main__":
    argv = sys.argv[1:]
    switches = ["-n","-u"]

    if "-t" in argv:
        tfile = argv.pop(argv.index("-t")+1)
	templatestring = open(tfile,'r').read()
        argv.remove("-t")

    if "-q" in argv:
        queues = argv.pop(argv.index("-q")+1)
        argv.remove("-q")
    
    if "-d" in argv:
        printer = argv.pop(argv.index("-d")+1)
        argv.remove("-d")

    if "-f" in argv:
        ticketdb = argv.pop(argv.index("-f")+1)
        argv.remove("-f")

    tpl = Template(templatestring)
    lp = LinePrinter(printer)
    rt = RtGlue()
    queues = queues.split(',')
    printed = []

    todo = filter(lambda x: x not in switches,argv)

    if "-u" in argv:#update
        printed = TicketDB(ticketdb)
        todo = rt.listqueues(queues)
        todo = filter(lambda x: x not in printed,todo)

    for tid in sorted(set(todo)):
        ticket = rt.retrieveticket(tid)
        tmsg = tpl.substitute(ticket.data)
        if not "-n" in argv:#dry-run
            lp.write(tmsg)
        else:
            print "dry-run: not printing"

        print tmsg

        if tid not in printed:
            printed.append(tid)
            if (getattr(printed,"write",0)!=0):
                printed.write()

