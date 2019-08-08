% Analysis for Expt 2;
%filepath = 'C:\Users\deand\Documents\Creative processes\ELAN lab\Projects\Funded projects\2018 Royal Society Open Science\Scripts\ET processing scripts\'

filepath = '/home/dan/Projects/InfantBilingualism';

% These variables define the start and end triggers for the epoch analysed
% (See MarkerInfo doc for details of markers used)
StartMarker = 'StimOnset';
EndMarker = 'rewardOffset';

cd(filepath)

addpath('Results')
outputName = sprintf('Expt2Output_%s.csv', datestr(datetime, 30));

header = {'Participant ID', 'Counter Balance', 'Block', 'Trial', 'Reward Side', 'Look away',...
    'Left Look time', 'Centre Look time', 'Right Look time',...
    'Left Look prop', 'Centre Look prop', 'Right Look prop\n'};

headerStr = strjoin(header, ',');
fid = fopen(outputName,'w');
fprintf(fid, headerStr);

files = dir(fullfile('Results', 'eventBuffer*.mat'));

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
    
    ExptN = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'Experiment3'));
    %anticip = ~cellfun('isempty', strfind(temp.allEvents(:,3), 'anticipOnset'));
    trialStart = ~cellfun('isempty', strfind(temp.allEvents(:,3), StartMarker));
    trialEnd = ~cellfun('isempty', strfind(temp.allEvents(:,3), EndMarker));
    
    %temp.specificEvents = temp.allEvents(Expt1 & anticip,:);
    
    temp.eventStarts = temp.allEvents(ExptN & trialStart,:);
    temp.eventEnds = temp.allEvents(ExptN & trialEnd,:);
    
    for event_n = 1:size(temp.eventStarts,1)
        
        eventDetails = strsplit(temp.eventStarts{event_n,3},'_');
        
        windowStart = temp.eventStarts{event_n,2};
        windowEnd   = temp.eventEnds{event_n,2};
        
        winStartIdx = find(temp.allData > windowStart, 1);
        winEndIdx = find(temp.allData(:,1) < windowEnd, 1, 'last');
        
        if isempty(winStartIdx) || isempty(winEndIdx)
            continue
        end
        
        eventData = func_preprocessData(temp.allData(winStartIdx:winEndIdx,:));
        
        looksaway = isnan(eventData(:,3:end));
        leftlook = mean(eventData(:,3:4),2)<0.33;
        centrelook = mean(eventData(:,3:4),2)>0.33 & mean(eventData(:,3:4),2)<0.66;
        rightlook = mean(eventData(:,3:4),2)>0.66;
        
        leftLookProp = sum(leftlook)/length(eventData);
        centreLookProp = sum(centrelook)/length(eventData);
        rightLookProp = sum(rightlook)/length(eventData);
         
        fprintf(fid,'%s,%s,%s,%s,%s,%d,%d,%d,%d,%d,%d,%d\n',...
                    pID,...
                    eventDetails{2},...
                    eventDetails{3},...
                    eventDetails{4},...
                    eventDetails{5},...
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