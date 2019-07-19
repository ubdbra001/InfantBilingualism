% Analysis for Expt 1;

%filepath = 'C:\Users\deand\Documents\Creative processes\ELAN lab\Projects\Funded projects\2018 Royal Society Open Science\Scripts\ET processing scripts\')
filepath = 'C:\Users\am919155\Documents\InfantBilingualism';

cd(filepath)
addpath('Results\')
outputName = sprintf('Expt1Output_%s.csv', datestr(datetime, 30));

header = {'Participant ID', 'Counter Balance', 'Block', 'Trial', 'Look away',...
    'Left Look time', 'Centre Look time', 'Right Look time',...
    'Left Look prop', 'Centre Look prop', 'Right Look prop\n'};

headerStr = strjoin(header, ',');
fid = fopen(outputName,'w');
fprintf(fid, headerStr);

files = dir('Results/eventBuffer*.mat');


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
    
    Expt1 = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'Experiment1'));
    %anticip = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'anticipOnset'));
    trialStart = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'stim3Onset'));
    trialEnd = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'rewardOffset'));
    
    %temp.specificEvents = temp.allEvents(Expt1 & anticip,:);
    
    temp.eventStarts = temp.allEvents(Expt1 & trialStart,:);
    temp.eventEnds = temp.allEvents(Expt1 & trialEnd,:);
    
    for event_n = 1:size(temp.eventStarts,1)
        
        eventDetails = strsplit(temp.eventStarts{event_n,3},'_');
        
        windowStart = temp.eventStarts{event_n,2};
        windowEnd   = temp.eventEnds{event_n,2};
        
        winStartIdx = find(temp.allData > windowStart, 1);
        winEndIdx = find(temp.allData > windowEnd, 1);
        
        eventData = func_preprocessData(temp.allData(winStartIdx:winEndIdx,:));
        
        looksaway = isnan(eventData(:,3:end));
        leftlook = mean(eventData(:,3:4),2)<0.33;
        centrelook = mean(eventData(:,3:4),2)>0.33 & mean(eventData(:,3:4),2)<0.66;
        rightlook = mean(eventData(:,3:4),2)>0.66;
        
        leftLookProp = sum(leftlook)/length(eventData);
        centreLookProp = sum(centrelook)/length(eventData);
        rightLookProp = sum(rightlook)/length(eventData);
         
        fprintf(fid,'%s,%s,%s,%s,%d,%d,%d,%d,%d,%d,%d\n',...
                    pID,...
                    eventDetails{2},...
                    eventDetails{3},...
                    eventDetails{4},...
                    any(looksaway(:)),...
                    sum(leftlook),...
                    sum(centrelook),...
                    sum(rightlook),...
                    leftLookProp,...
                    centreLookProp,...
                    rightLookProp);
        
    end
    
end

fclose(fid);