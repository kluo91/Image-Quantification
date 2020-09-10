%%Total Intensity of VPC nuclei
%check folder is correct
%you must have this script in the same folder as "Output", which contains
%individiual subfolders with the following mat files: cpDataTracked.mat and
%guiTracked.mat-->segmentation, tracking, and manual curation as described de la
%Cova, et al. 2017 must be performed prior to running this script.  You do
%NOT need to label cells as "good" or "bad," just label "ignore" to get rid of
%cells with poor segmentation.
A=dir('Output/Pos*');
TotalPos=length(A);

for a=1:TotalPos
B=0;
    disp(a);
    display(A(a).name);
    %check folder is correct
    load(['Output/',A(a).name,'/guiTracked.mat']);
    load(['Output/',A(a).name,'/cpDataTracked.mat']);
    %change last number (currently set to 2) to the number corresponding
    %with desired channel-->check data.imageSetNames to figure out number
    IntegratedIntensity=data.nuclei.IntegratedIntensity(:,:,2);
    IntegratedIntensity(IntegratedIntensity<=0)=NaN;
    IntegratedIntensity(events.ignore.store==1)=NaN;
    %MeanIntensity(events.ignore.store(properties.goodbad.store==1,:)==1)=NaN;
    
    VPCi=properties.VPC.store;
    %display(size(VPCi,1));
    %display(size(IntegratedIntensity,1));
    
    %checks to see if number of VPCs and segmented VPCs are greater than 3
    if size (VPCi,1)>0 && size(IntegratedIntensity,1)>0
        VPC{a}(1:6,1:size(IntegratedIntensity,2))=NaN;
        
        
        uniqueVPC = unique(VPCi);
        %{
        count=histcounts(VPCi, uniqueVPC);
        indexVPCRep=(count~=1);
        VPCrepeat=uniqueVPC(indexVPCRep);
        %}
        
        %puts VPCrepeats into an array (aka curated VPCs with multiple
        %tracked objects assigned)
        %cpDatatracked.mat file
        VPCrepeat=[];
        for mayberep=nanmin(VPCi):nanmax(VPCi)
            if size(find(VPCi==mayberep),1)>1
                VPCrepeat=[mayberep VPCrepeat];
                %display(VPCrepeat);
            end
        end
        
        %assigns tracked objects Integrated Intensity data to curated VPCs
        for b=nanmin(VPCi):nanmax(VPCi)
            %display(b);
            
            %checks to see that curated VPC in VPCi does not consist of multipe
            %tracked objects
            %sums up top 5 z-section values and assigns to VPC{a}
            if nanmax(VPCi)>0 && ~isempty(find(VPCi==b, 1)) && sum(VPCi==b)==1 &&~ismember(b,VPCrepeat)&&b>0
                VPCarray=IntegratedIntensity(VPCi==b,:);
                %display(b);
                VPCarray(find(isnan(VPCarray)))=[];
                sortedVPCarray=sort(VPCarray, 'descend');
                %display(sortedVPCarray);
                if size(sortedVPCarray,2)<5
                    VPC{a}(b+1,:)=0;
                else
                    maxFive=sum(sortedVPCarray(1:5));
                    VPC{a}(b+1,:)=maxFive;
                end
                %display(IntegratedIntensity(VPCi==b,:));
                
                %if curated VPC consists of multiple tracked objects,
                %nansums all objects and then assigns sum of top 5 values
                %from z-sections to VPC{a}
            elseif b>0 
                repTotal=zeros(1,size(IntegratedIntensity,2));
                indexRep=find(VPCi==b);
                for boo=1:size(indexRep,1)
                    rep=indexRep(boo);
                    %display(nansum(repTotal,1));
                    %display(nansum(IntegratedIntensity(rep,:), 1));
                    repTotal=nansum(repTotal,1)+nansum(IntegratedIntensity(rep,:), 1);
                    %display(repMean);
                    if b==4
                        display(repTotal);
                        display(rep);
                    end
                end
                VPCReparray=repTotal;
                VPCReparray(find(isnan(VPCReparray)))=[];
                sortedVPCReparray=sort(VPCReparray, 'descend');
                if size(sortedVPCReparray,2)<5
                    VPC{a}(b+1,:)=0;
                else
                    maxFiveRep=sum(sortedVPCReparray(1:5));
                    VPC{a}(b+1,:)=maxFiveRep;
                end
                
                %VPC{a}(b+1,:)=repTotal;
                %display(VPC{a});
                %display(repMean);
            end
          
        end 
        
    
        VPC{a}(VPC{a}==0)=NaN;
        
        
        %display(VPC{a});
        
        VPCData(a,:)=nanmean(VPC{a},2);
        VPCData(a,1)=a;
    
    end
    
    
end 


% clearvars -except VPC VPCData;


