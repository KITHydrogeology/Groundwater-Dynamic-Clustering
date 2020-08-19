% function labels = sgraph(k,dataname)
%
% copyright (c) 1998-2002 by Alexander Strehl

function labels = sgraph(k,dataname) 

if strcmp(computer,'PCWIN'),
   scriptfile = ['c:\winnt\temp\partgraph' num2str(sum(dataname=='0')) num2str(sum(dataname=='1')) num2str(sum(dataname=='2')) num2str(sum(dataname=='3')) '.bat'];
else
   scriptfile = ['/tmp/partgraph' num2str(sum(dataname=='0')) num2str(sum(dataname=='1')) num2str(sum(dataname=='2')) num2str(sum(dataname=='3'))];
end;

if ~exist('dataname'),
   if strcmp(computer,'PCWIN'),
      dataname = 'c:\winnt\temp\graph0';
   else
      dataname = '/tmp/graph0';
   end;
end;
resultname = [dataname '.part.' num2str(k)];

lastchar = str2num(dataname(length(dataname)));
if (isempty(lastchar)),
  disp('sgraph: file does not comply to name convention');
  lastchar = 0;
end;
fid = fopen(scriptfile,'w');
if (lastchar<2),
   fprintf(fid,'%s\n',['pmetis ' dataname ' ' num2str(k)]);
else
   ubfactor = 5;
   fprintf(fid,'%s\n',['shmetis ' dataname ' ' num2str(k) ' ' num2str(ubfactor)]);
end;
fclose(fid);
if strcmp(computer,'PCWIN'),
  dos(scriptfile);
else
  unix(['chmod 755 ' scriptfile]);
  unix(scriptfile);
end;
delete(scriptfile);

fid = fopen(resultname,'r');
if (fid == -1),
  disp('sgraph: partitioning not successful due to external error');
  fid = fopen(dataname);
  if (fid == -1),
    disp('sgraph: graph file is not accessible');
  else
    if lastchar>=2,
      junk = fscanf(fid,'%d',1); 
    end;
    labels = ones(1,fscanf(fid,'%d',1));
    if isempty(labels),
      disp('sgraph: empty label vector - suspecting file system full');
    end;
    fclose(fid);
  end;
else
  disp(['sgraph: ' scriptfile ' completed - loading ' resultname]);
  labels = (fscanf(fid,'%d')+1)';
  fclose(fid);
end;

fid = fopen(resultname,'r');
if (fid ~= -1),
  fclose(fid);
  delete(resultname);
end;