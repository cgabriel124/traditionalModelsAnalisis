% --------------------------------------------------------------------
% This code is based on the paper entitled                     
% "An Energy-based Method for Orientation Correction
% of EMG Bracelet Sensors in Hand Gesture Recognition Systems"
% by Victor Hugo Vimos T.
%
% *Victor Hugo Vimos T / victor.vimos@epn.edu.ec
% --------------------------------------------------------------------

function [] = WM_conversion_newFormat(file,start_at)

data_fix          = load(file);
response          = data_fix.response;
lenght_data_fix   = length(fieldnames(data_fix.response));
user_names_fix    = fieldnames(orderfields(data_fix.response));

assignin('base','response',    response);

for i=1:lenght_data_fix
    
       user_name  = user_names_fix{i,1};
       response  =  evalin('base', 'response');
       
    for  j=start_at:1:300
                      
        if j<=150             
            vectorOfLabels_length          =  length(response.(user_name).vectorOfLabels{j,1});
            vectorOfTimePoints_length      =  length(response.(user_name).vectorOfTimePoints{j,1});           
            
            if vectorOfLabels_length < vectorOfTimePoints_length    
                  
                new_vectorOfLabels        = response.(user_name).vectorOfLabels{j,1};                
                for t =1:vectorOfTimePoints_length-vectorOfLabels_length
                    new_vectorOfLabels    = horzcat(new_vectorOfLabels ,'noGesture');
                end                
                response.training.(user_name).vectorOfLabels{j,1} = categorical(new_vectorOfLabels);                
                clear new_vectorOfLabels     
                
                
            elseif vectorOfLabels_length > vectorOfTimePoints_length                
                new_vectorOfLabels        = response.(user_name).vectorOfLabels{j,1};
                new_vectorOfLabels        = new_vectorOfLabels(:,1:vectorOfTimePoints_length);
                response.training.(user_name).vectorOfLabels{j,1} = categorical(new_vectorOfLabels);                
                clear new_vectorOfLabels   
                
            else   
                
                response.training.(user_name).vectorOfLabels{j,1} = categorical(response.(user_name).vectorOfLabels{j,1});   
                
                
            end  
            
            if isempty(response.(user_name).class{j,1})                
                response.(user_name).class{j,1}='NaN';                
                response.training.(user_name).class{j,1}                   = categorical(cellstr(response.(user_name).class{j,1}));
                
            else
                response.training.(user_name).class{j,1}                   = categorical(cellstr(response.(user_name).class{j,1}));      
            end

            response.training.(user_name).vectorOfTimePoints{j,1}      = cell2mat(response.(user_name).vectorOfTimePoints{j,1});
            response.training.(user_name).vectorOfProcessingTime{j,1}  = cell2mat(response.(user_name).vectorOfProcessingTime{j,1});

        else
            
            vectorOfLabels_length          =  length(response.(user_name).vectorOfLabels{j,1});
            vectorOfTimePoints_length      =  length(response.(user_name).vectorOfTimePoints{j,1});           
            
            if vectorOfLabels_length < vectorOfTimePoints_length               
                new_vectorOfLabels        = response.(user_name).vectorOfLabels{j,1};                
                for t =1:vectorOfTimePoints_length-vectorOfLabels_length
                    new_vectorOfLabels    = horzcat(new_vectorOfLabels ,'noGesture');
                end                
                response.testing.(user_name).vectorOfLabels{j-150,1} = categorical(new_vectorOfLabels);                
                clear new_vectorOfLabels                  
            elseif vectorOfLabels_length > vectorOfTimePoints_length                
                new_vectorOfLabels        = response.(user_name).vectorOfLabels{j,1};
                new_vectorOfLabels        = new_vectorOfLabels(:,1:vectorOfTimePoints_length);
                response.testing.(user_name).vectorOfLabels{j-150,1} = categorical(new_vectorOfLabels);                
                clear new_vectorOfLabels   
            else               
                response.testing.(user_name).vectorOfLabels{j-150,1} = categorical(response.(user_name).vectorOfLabels{j,1});     
            end       
            response.testing.(user_name).class{j-150,1}                   = categorical(cellstr(response.(user_name).class{j,1}));
            response.testing.(user_name).vectorOfTimePoints{j-150,1}      = cell2mat(response.(user_name).vectorOfTimePoints{j,1});
            response.testing.(user_name).vectorOfProcessingTime{j-150,1}  = cell2mat(response.(user_name).vectorOfProcessingTime{j,1});
     
        end
      
    end
    
          response  = rmfield(response,(user_name));  

        assignin('base','response',    response);

end

save(file,'response')

end