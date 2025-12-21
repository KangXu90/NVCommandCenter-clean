function SaveSeqAs
global gEditSEQ gSEQ;

SEQ = gEditSEQ;
file = SEQ.file;
[file, path, filterindex] = uiputfile('Sequence*.*', 'Save Sequence As',file);

SEQ.file = [path file];
SaveSEQ(SEQ);

gSEQ = SEQ;
gEditSEQ = SEQ;