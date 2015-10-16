function postprocessBUTPosteriograms(dirIn,dirOut)

filesIn=dir([dirIn '*.lop']);

for k=1:length(filesIn)
    
    filename=filesIn(k).name;
    [pathstr,name,ext] = fileparts(filename);
    fileOut=[dirOut name '.post'];
    fileIn=[dirIn filename];
    fid = fopen(fileIn,'r','b'); % big-endian
    % Read number of frames
    nSamp = fread(fid,1,'int32');
    % Read sampPeriod
    sampPeriod = fread(fid,1,'int32');
    % Read sampSize
    sampSize = fread(fid,1,'int16');
    % Read HTK Code
    HTKCode = fread(fid,1,'int16');
    % Dimension
    DIM=sampSize/4;
    %disp(sprintf('htkread: Reading %d frames, dim %d, uncompressed, from %s',nSamp,DIM,Filename));
    % Read floating point data
    DATA = fread(fid, [DIM nSamp], 'float')';
    fclose(fid);
    
    DATA_S2 = DATA(:,2:3:end-3);
    
    fid=fopen(fileOut,'w'); % little-endian
    [ nSamp, NCOFS ] = size(DATA_S2);
    sampSize = 4*NCOFS;
    %disp(sprintf('htkwrite: Writing %d frames, dim %d, uncompressed, to %s',nSamp,NCOFS,Filename));
    fwrite(fid,nSamp,'int32');
    fwrite(fid,sampPeriod,'int32');
    fwrite(fid,sampSize,'int16');
    fwrite(fid,HTKCode,'int16');
    % Write uncompressed data
    fwrite(fid, DATA_S2', 'float');
    fclose(fid);
end

