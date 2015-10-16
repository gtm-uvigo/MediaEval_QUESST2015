function postprocessKaldiPosteriograms(file1,file2,dirIn,dirOut)

% file1: phone list
% file2: info from transition model
% dirIn: input directory
% dirOut: output directory

fid2 = fopen(file2);
phones = textscan(fid2,'%s %d');
fclose(fid2);

fid1 = fopen(file1);
C = textscan(fid1,'phone = %shmm-state = %dpdf = %d');
fclose(fid1);

phoneNames = phones{1};
pdfs = C{3};
indices = [];

% DIM: NNET output dimension

DIM = max(C{3})+1; % +1 pdfs start in 0

names = C{1};
Data = struct([]);
for i=1:size(phoneNames,1)
    %i
    indices = [];
    
    for j=1:size(names,1)
        %j
        if (strcmp(names(j),phoneNames(i)))
            %disp([names(j) ' ' phoneNames(i)])
            indices = [indices j];
        end
    end

    Data(i).phon = phoneNames(i);
    Data(i).statepdfs = pdfs(indices);
    Data(i).pdfs = unique(sort(pdfs(indices)));
    
end

sampPeriod = 100000;
HTKCode = 9;
filelist = dir(fullfile(dirIn, '*.fea'));
mkdir(dirOut)
for j=1:size(filelist,1)
    
    fileIn = fullfile(dirIn,filelist(j).name);
        fid = fopen(fileIn,'r');
        % Read number of data = nsamples*dim
        ndata = fread(fid,1,'int');
        nSamp = ndata/DIM;
        % Read floating point data
        feats = fread(fid, 'float')';
        fclose(fid);
        
        DATA=reshape(feats,DIM,nSamp)';
        phonposterior1 = zeros(size(DATA,1),size(phoneNames,1));
        for i=1:size(phoneNames,1)
            phone = Data(i).phon;
            pdfsIndex = Data(i).pdfs;
            phonposterior1(:,i) = sum(DATA(:,pdfsIndex+1),2);  % +1 pdfs start in 0
        end
        logphonposterior1 = sqrt(-2.0*log(phonposterior1));
        
        [pathstr,name,ext]=fileparts(fileIn);
        fileOut=fullfile(dirOut,[name '.fea']);
        fid=fopen(fileOut,'w'); % little-endian
        [ nSamp, NCOFS ] = size(phonposterior1);
        sampSize = 4*NCOFS;
        %disp(sprintf('Writing %d frames, dim %d, uncompressed, to %s',nSamp,NCOFS,Filename));
        fwrite(fid,nSamp,'int32');
        fwrite(fid,sampPeriod,'int32');
        fwrite(fid,sampSize,'int16');
        fwrite(fid,HTKCode,'int16');
        % Write uncompressed data
        fwrite(fid, logphonposterior1', 'float');
        fclose(fid);
        
        
end


