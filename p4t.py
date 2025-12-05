from P4 import P4,P4Exception
import pprint
import shutil
import os.path
import tempfile
import sys

p4 = P4()
p4.connect()

class Impact:
    def __init__(self, p4):
        self.p4 = p4
    def repoToLocal(self,fileref):
        x = self.p4.run("fstat",fileref)[0]
        return x["clientFile"]
    def localToRepo(self,fileref):
        x = self.p4.run("fstat",fileref)[0]
        return x["depotFile"]

class ImpactPerforceChange:
	def __init__(self,changelist, depotFile, rev, fileSize, digest, type_,action):
            self.changelist = changelist
            self.depotFile = depotFile
            self.rev = int(rev)
            self.fileSize = fileSize
            self.digest = digest
            self.type_ = type_
            self.action = action
	    self.localfile = self.changelist.impact.repoToLocal(depotFile)

class ImpactPerforceChangeList:
    def __init__(self,impact,change):
        self.impact = impact
        self.change = change
    def updateFields(self,p4dict):
        self.change = p4dict["change"]
        self.changeType = p4dict["changeType"]
        self.client = p4dict["client"]
        self.desc = p4dict["desc"]
        self.shelved = p4dict.get("shelved",None)
        self.status = p4dict["status"]
        self.time = p4dict["time"]
        self.user = p4dict["user"]
        self.depotFile = p4dict.get("depotFile",[])
        self.changes = []
    def update(self):
        details = self.impact.p4.run("describe",self.change)[0]
        self.updateFields(details)
	filedetails = zip(
          details['depotFile'],
          details['rev'],
          details['fileSize'],
          details['digest'],
          details['type'],
          details['action'],
        )

        self.changes = map(lambda t: ImpactPerforceChange(self,*t),filedetails)

def p4t_change(cl_nr):
    impact = Impact(p4)
    l = ImpactPerforceChangeList(impact, cl_nr) 
    l.update()
    tempdir = tempfile.mkdtemp("p4t")
    scriptpath=tempdir+os.path.sep+"script"
    summarypath=tempdir+os.path.sep+"summary.txt"
    scriptcontent = ""
    def to_tmp_local(depotpath, tempdir):
        return depotpath.replace("//depot",tempdir)
    for c in l.changes:
        newpath = None
        oldpath = None

        localfile = to_tmp_local(c.depotFile,tempdir)
        try:
            os.makedirs(os.path.dirname(localfile))
        except:
            pass
        if c.action == "add" or c.action == "edit":
            (name,ext) = os.path.splitext(localfile)
            newrev = c.rev
            newpath = "{}#{}{}".format(name,newrev,ext)
            p4.run("print","-o"+newpath,c.depotFile+ "#{}".format(newrev))
            scriptcontent += ":tabnew {}\n".format(newpath.replace("#","\#"))
        if c.action == "edit":
            (name,ext) = os.path.splitext(localfile)
            oldrev = c.rev-1
            oldpath = "{}#{}{}".format(name,oldrev,ext)
            p4.run("print","-o"+oldpath,c.depotFile+ "#{}".format(oldrev))
            scriptcontent += ":vert diffsplit {}\n".format(oldpath.replace("#","\#"))
            
    summarycontent=os.popen('p4 describe -s {}'.format(cl_nr)).read()
    open(summarypath,'w').write(summarycontent)
    open(scriptpath,'w').write(scriptcontent)
    os.system("vim {} -s {}".format(summarypath,scriptpath))
    shutil.rmtree(tempdir)

if __name__ == "__main__":
    if "change" in sys.argv:
        p4t_change(sys.argv[2])
