% Analysis for Expt 4;
%filepath = 'C:\Users\Dean\Documents\RESEARCH\RSOS\Processing scripts\';
%filepath = 'C:\Users\deand\Documents\Creative processes\ELAN lab\Projects\Funded projects\2018 Royal Society Open Science\Scripts\ET processing scripts\'

filepath = 'C:\Users\am919155\Documents\InfantBilingualism';

cd(filepath)

addpath('Results\')
outputName = sprintf('Expt4Output_%s.csv', datestr(datetime, 30));

header = {'Participant ID', 'Trial', 'Switches', 'Left Look time', 'Right Look time\n'};
headerStr = strjoin(header, ',');

fid = fopen(outputName,'w');
fprintf(fid, headerStr);

files = dir('Results\eventBuffer*.mat');

for fileName = {files.name}
    
    pID = strsplit(fileName{:},{'_', '.'});
    
    pID = pID{2};
    
    evBuffName = fileName{:};
    mainBuffName = strrep(fileName{:}, 'event', 'main');
    timeBuffName = strrep(fileName{:}, 'event', 'time');
    
    load(evBuffName)
    load(mainBuffName)
    load(timeBuffName)
    
    temp.allData   = [double(timeBuffer) mainBuffer];
    temp.allEvents = eventBuffer;
    
    clear *Buffer
    
    ExptN = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'Experiment2'));
    anticip = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'StimulusOnset'));
    
    temp.specificEvents = temp.allEvents(ExptN & anticip,:);
    
    for event_n = 1:size(temp.specificEvents,1)
        
        eventDetails = strsplit(temp.specificEvents{event_n,3},'_');
        
        windowStart = temp.specificEvents{event_n,2};
        windowEnd   = temp.specificEvents{event_n,2}+4000*1000;
        
        winStartIdx = find(temp.allData > windowStart, 1);
        winEndIdx = find(temp.allData > windowEnd, 1);
        
        eventData = func_preprocessData(temp.allData(winStartIdx:winEndIdx,:));
        
        looksaway = isnan(eventData(:,3:end));
        leftlook = mean(eventData(:,3:4),2)<0.40;
        rightlook = mean(eventData(:,3:4),2)>0.60;
        centrelook = ~(leftlook|rightlook);
        
        if sum(leftlook) == 0 || sum(rightlook) == 0
            switches = 0;
        else
            lookchange = zeros(length(centrelook),1);
            lookchange(leftlook) = -1;
            lookchange(rightlook) = 1;
            lookchange = diff(lookchange);
            lookchange(lookchange == 0) = [];
            switches = sum(abs(lookchange(1:end-1)+lookchange(2:end))==2);
        end
        
        fprintf(fid,'%s,%s,%d,%d,%d\n',...
                    pID,...
                    eventDetails{3},...
                    switches,...
                    sum(leftlook),...
                    sum(rightlook));
        
    end
    
end

fclose(fid);