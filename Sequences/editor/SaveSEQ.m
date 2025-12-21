function SaveSEQ(SEQ)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Written by Jeronimo Maze, July 2007 %%%%%%%%%%%%%%%%%%
%%%%%%%%%% Harvard University, Cambridge, USA  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% modified 22 July 2008, jhodges
SEQ.file
fid = fopen(SEQ.file,'wt');
%fid = fopen('test.txt','wt');
for ichn=1:numel(SEQ.CHN)
    fprintf(fid,'PB%.0f\t%.0f',SEQ.CHN(ichn).PBN,SEQ.CHN(ichn).NRise);
    fprintf(fid,'\n');
    fprintf(fid,'%.10f\t',SEQ.CHN(ichn).T);    
    fprintf(fid,'\n');
    fprintf(fid,'%.10f\t',SEQ.CHN(ichn).DT);  
    fprintf(fid,'\n');
    fprintf(fid,'%d\t',SEQ.CHN(ichn).Phase);
    fprintf(fid,'\n');
    fprintf(fid,'%s\t',SEQ.CHN(ichn).Type{:});    
    fprintf(fid,'\n');    
    fprintf(fid,'%.10f\t',SEQ.CHN(ichn).Delays);    
    fprintf(fid,'\n');    
end
fprintf(fid,'\n');
fprintf(fid,'Comments:');
    
fclose(fid);