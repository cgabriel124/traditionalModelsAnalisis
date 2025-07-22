function [emg_mod,i] = WM_Extraction_mod_test(user_,gestures_,electrode_ref,ventana,new_order)
% --------------------------------------------------------------------
% This code is based on the paper entitled                     
% "An Energy-based Method for Orientation Correction
% of EMG Bracelet Sensors in Hand Gesture Recognition Systems"
% by Victor Hugo Vimos T.
%
% *Victor Hugo Vimos T / victor.vimos@epn.edu.ec
% --------------------------------------------------------------------

 userData  =  evalin('base', 'userData');
 indices   =  evalin('base', 'indices');
 gestureLocation  =  evalin('base', 'gestureLocation');
 
 v=1;

 start_at=26;
 end_at=50;

 for i=start_at:1:end_at
     
     
     if electrode_ref==0
         
         
         
         if i<=25
             loc=gestureLocation.(user_).training.(gestures_){i,1};
             Matrix=userData.training{loc,1}.emg;
         else
             loc=gestureLocation.(user_).testing.(gestures_){i-25,1};
             Matrix=userData.testing{loc-150,1}.emg;
             
         end


     else
         
         if i<=25
             loc=gestureLocation.(user_).training.(gestures_){i,1};
             Matrix_=userData.training{loc,1}.emg;
         else
             loc=gestureLocation.(user_).testing.(gestures_){i-25,1};
             Matrix_=userData.testing{loc-150,1}.emg;
             
         end
         
        
        switch electrode_ref
            
            case 1
                Matrix=Matrix_(:,[1,2,3,4,5,6,7,8]);
            case 2
                Matrix=Matrix_(:,[2,3,4,5,6,7,8,1]);
            case 3
                Matrix=Matrix_(:,[3,4,5,6,7,8,1,2]);
            case 4
                Matrix=Matrix_(:,[4,5,6,7,8,1,2,3]);
            case 5
                Matrix=Matrix_(:,[5,6,7,8,1,2,3,4]);
            case 6
                Matrix=Matrix_(:,[6,7,8,1,2,3,4,5]);
            case 7
                Matrix=Matrix_(:,[7,8,1,2,3,4,5,6]);
            case 8
                Matrix=Matrix_(:,[8,1,2,3,4,5,6,7]);
            otherwise
        end

          
     end

 
 relax_add=zeros(400,8);
 Matrix=vertcat(Matrix,relax_add);
   
   % ====================== Wmoos Default options =====================   
   
   check_size=size(Matrix);
   indicest_low=indices.(user_){loc,1};
   indicest_high=indices.(user_){loc,2};   

    if check_size(1,1)<=600        
        % ------------------------- EMG POINTS -------------------- [1000]        
        %
        %                              [600]
        %             ______________   |   
        %            |              |  |   
        %------------|              |X-|
        %            |______________|  |   
        %                              |       
        led=0;
    else
        led=1;
    end 
    
    
    
    if led==1
        %        _________|____                    |                   |
        %       |         |    |                   |                   |
        %------X|         |    |-------------------|-------------------|
        %       |_________|____|                   |                   |
        %                 |                        |                   |
        
        %                 |     ______________     |                   |
        %                 |    |              |    |                   |
        %-----------------|---X|              |----|-------------------|
        %                 |    |______________|    |                   |
        %                 |                        |                   |
        
        %                 |                        |          _________|_____
        %                 |                        |         |         |     |
        %-----------------|------------------------|--------X|         |     |
        %                 |                        |         |_________|_____|
        %                 |                        |                   |
        
        %                 |                        |  ______________   |
        %                 |                        | |              |  |
        %-----------------|------------------------|-|              |X-|
        %                 |                        | |______________|  |
        %                 |                        |                   |

        low_  = indicest_low;
        high_ = indicest_low+ventana;
    else
        low_  = indicest_high-ventana;
        high_ = indicest_high;
    end
    
    step_=25;
    signals_per_gesture=7;
    
    for x=1:signals_per_gesture
        
        if gestures_~="noGesture"
            switch x
                case 1
                    emg_mod{1,v}=Matrix(low_:high_,:);
                case 2
                    emg_mod{1,v}=Matrix(low_+(1)*step_:high_+(1)*step_,:);
                case 3
                    emg_mod{1,v}=Matrix(low_+(2)*step_:high_+(2)*step_,:);
                case 4
                    emg_mod{1,v}=Matrix(low_+(3)*step_:high_+(3)*step_,:);
                case 5
                    emg_mod{1,v}=Matrix(low_-(1)*step_:high_-(1)*step_,:);
                case 6
                    emg_mod{1,v}=Matrix(low_-(2)*step_:high_-(2)*step_,:);
                case 7
                    emg_mod{1,v}=Matrix(low_-(3)*step_:high_-(3)*step_,:);
                    
                otherwise
            end
        else
            switch x
                case 1
                    emg_mod{1,v}=Matrix(low_:high_,:);
                case 2
                    emg_mod{1,v}=Matrix(low_+(1)*step_:high_+(1)*step_,:);
                case 3
                    emg_mod{1,v}=Matrix(low_+(2)*step_:high_+(2)*step_,:);
                case 4
                    emg_mod{1,v}=Matrix(low_+(3)*step_:high_+(3)*step_,:);
                case 5
                    emg_mod{1,v}=Matrix(low_+(4)*step_:high_+(4)*step_,:);
                case 6
                    emg_mod{1,v}=Matrix(low_+(5)*step_:high_+(5)*step_,:);
                case 7
                    emg_mod{1,v}=Matrix(low_+(6)*step_:high_+(6)*step_,:);
                    
                otherwise
            end

        end
        
        
        v=v+1;
    end
    
 end
 i=(i-25)*signals_per_gesture;
 
end

