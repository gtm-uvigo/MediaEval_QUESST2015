function generateStdlist(inDir,outputFile,list)

threshold=0;

fOut = fopen(outputFile,'w');
fprintf(fOut,'<stdlist termlist_filename=\"%s\" indexing_time=\"1.000\" language=\"spanish\" index_size=\"1\" system_id=\"system\">\n',outputFile);

queries = textread(list,'%s');

for i=1:length(queries)
fprintf(fOut,'<detected_termlist termid=\"%s\" term_search_time=\"24.3\" oov_term_count=\"1\">\n',queries{i});
[files,scores] = textread([inDir queries{i} '.out'],'%f %f');
documents = unique(files);

scores = 1-scores;

maxScores = zeros(length(documents),1);
for j=1:length(documents)
	scoresDocument = scores(find(files == documents(j)));
scoresDocument = scoresDocument(scoresDocument < 1);
	maxScores(j) = max(scoresDocument);
end

mean_maxScores = mean(maxScores);
std_maxScores = std(maxScores);
newScores = (maxScores-mean_maxScores)./std_maxScores;

for j=1:length(documents)
	if(newScores(j) >= threshold)
	  fprintf(fOut,'<term file=\"quesst2015_%05d\" channel=\"1\" tbeg=\"0\" dur=\"10\" score=\"%f\" decision=\"YES\"/>\n',documents(j),newScores(j));
 else
   fprintf(fOut,'<term file=\"quesst2015_%05d\" channel=\"1\" tbeg=\"0\" dur=\"10\" score=\"%f\" decision=\"NO\"/>\n',documents(j),newScores(j));
end
end
fprintf(fOut,'</detected_termlist>\n');
end
fprintf(fOut,'</stdlist>\n');

fclose(fOut);
