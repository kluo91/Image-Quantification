A=dir('Output/Pos*');
TotalPos=length(A);

for a=1:TotalPos
B=0;
    disp(a);
    display(A(a).name);
    load(['Output/',A(a).name,'/guiTracked.mat']);
    load(['Output/',A(a).name,'/cpDataTracked.mat']);
    IntegratedIntensity=data.nuclei.IntegratedIntensity(:,:,3);
    IntegratedIntensity(IntegratedIntensity<=0)=NaN;
    IntegratedIntensity(events.ignore.store==1)=NaN;
    %MeanIntensity(events.ignore.store(properties.goodbad.store==1,:)==1)=NaN;
    
    Gonadi=properties.Gonad.store;
    %display(size(Gonadi,1));
    %display(size(IntegratedIntensity,1));
    
    %checks to see if number of Gonads and segmented Gonads are greater than 3
    if size (Gonadi,1)>3 && size(IntegratedIntensity,1)>3
        Gonad{a}(1:5,1:size(IntegratedIntensity,2))=NaN;
        
        
        uniqueGonad = unique(Gonadi);
        %{
        count=histcounts(Gonadi, uniqueGonad);
        indexGonadRep=(count~=1);
        Gonadrepeat=uniqueGonad(indexGonadRep);
        %}
        
        %puts Gonadrepeats into an array (aka curated Gonads with multiple
        %tracked objects assigned)
        %cpDatatracked.mat file
        Gonadrepeat=[];
        for mayberep=nanmin(Gonadi):nanmax(Gonadi)
            if size(find(Gonadi==mayberep),1)>1
                Gonadrepeat=[mayberep Gonadrepeat];
                %display(Gonadrepeat);
            end
        end
        
        %assigns tracked objects Integrated Intensity data to curated Gonads
        for b=nanmin(Gonadi):nanmax(Gonadi)
            %display(b);
            
            %checks to see that curated Gonad in Gonadi does not consist of multipe
            %tracked objects
            %sums up top 5 z-section values and assigns to Gonad{a}
            if nanmax(Gonadi)>0 && ~isempty(find(Gonadi==b, 1)) && sum(Gonadi==b)==1 &&~ismember(b,Gonadrepeat)&&b>0
                Gonadarray=IntegratedIntensity(Gonadi==b,:);
                %display(b);
                Gonadarray(find(isnan(Gonadarray)))=[];
                sortedGonadarray=sort(Gonadarray, 'descend');
                %display(sortedGonadarray);
                if size(sortedGonadarray,2)<5
                    Gonad{a}(b+1,:)=0;
                else
                    maxFive=sum(sortedGonadarray(1:5));
                    Gonad{a}(b+1,:)=maxFive;
                end
                %display(IntegratedIntensity(Gonadi==b,:));
                
                %if curated Gonad consists of multiple tracked objects,
                %nansums all objects and then assigns sum of top 5 values
                %from z-sections to Gonad{a}
            elseif b>0 
                repTotal=zeros(1,size(IntegratedIntensity,2));
                indexRep=find(Gonadi==b);
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
                GonadReparray=repTotal;
                GonadReparray(find(isnan(GonadReparray)))=[];
                sortedGonadReparray=sort(GonadReparray, 'descend');
                if size(sortedGonadReparray,2)<5
                    Gonad{a}(b+1,:)=0;
                else
                    maxFiveRep=sum(sortedGonadReparray(1:5));
                    Gonad{a}(b+1,:)=maxFiveRep;
                end
                
                %Gonad{a}(b+1,:)=repTotal;
                %display(Gonad{a});
                %display(repMean);
            end
          
        end 
        
    
        Gonad{a}(Gonad{a}==0)=NaN;
        
        
        %display(Gonad{a});
        
        GonadData(a,:)=nanmean(Gonad{a},2);
        
    
    end
    
    
end 


% clearvars -except Gonad GonadData;


