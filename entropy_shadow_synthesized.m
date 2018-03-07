function varargout = entropy_shadow_synthesized(varargin)
% ENTROPY_SHADOW_SYNTHESIZED MATLAB code for entropy_shadow_synthesized.fig
%      ENTROPY_SHADOW_SYNTHESIZED, by itself, creates a new ENTROPY_SHADOW_SYNTHESIZED or raises the existing
%      singleton*.
%
%      H = ENTROPY_SHADOW_SYNTHESIZED returns the handle to a new ENTROPY_SHADOW_SYNTHESIZED or the handle to
%      the existing singleton*.
%
%      ENTROPY_SHADOW_SYNTHESIZED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENTROPY_SHADOW_SYNTHESIZED.M with the given input arguments.
%
%      ENTROPY_SHADOW_SYNTHESIZED('Property','Value',...) creates a new ENTROPY_SHADOW_SYNTHESIZED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before entropy_shadow_synthesized_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to entropy_shadow_synthesized_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help entropy_shadow_synthesized

% Last Modified by GUIDE v2.5 09-Dec-2016 15:40:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @entropy_shadow_synthesized_OpeningFcn, ...
                   'gui_OutputFcn',  @entropy_shadow_synthesized_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before entropy_shadow_synthesized is made visible.
function entropy_shadow_synthesized_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to entropy_shadow_synthesized (see VARARGIN)

% Choose default command line output for entropy_shadow_synthesized
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes entropy_shadow_synthesized wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = entropy_shadow_synthesized_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% mask
row=360; column=270;
    mask = zeros(row, column);
    for x=1:row
        for y=1:column
             if mask(x,y) < y-0.53*x+52.99
                 if mask(x,y) > y-16*x+2882    % 圖上的xy和計算上的xy,列式xy交換
                    mask(x,y)=1;
                 end
             end
        end
    end


str='new';
for t=1:29
    cc=0; %boundingbox又歸零

    A=imread([str,num2str(t),'.jpg']); 
    img_gray=rgb2gray(A);  %灰階
    thresh = 0.5*0.15;  %參數可以調整
    
%     entropy

    g = 0;
    for i=1:3:360
        for j=1:3:270
            if mask(i,j) == 1
            g = g + 1;
            k=mean(A(i:i+2,j:j+2));
            m=mean(k);
            total(1,g) = m;
            end
%             total(i,j)=m;
        end
    end
    
    H = hist(total,1:8:255);
    normal=H/3331; %normal=H/g
   
    
    E = 0;
    entropy_temp = 0;
    for a = 1:32
        if normal(a) ~= 0
            E = -(normal(a).*log2(normal(a)));
            entropy_temp = entropy_temp + E;
        end
    end
    
    
       ans(1,t) = entropy_temp;
       
       axes(handles.axes3);
       axis([1 841 2 5]);
       line([0 800],[3 3],'Color','b','LineWidth',1); %門檻線
       
       if t>2
% %         plot;
% %         subplot(2,1,2);

%         line([t-1 t],[ans(t-1) ans(t)],'Color','r','LineWidth',1);

   %   entropy門檻警示
            if ans(t)>3
                hold on;
                line([t t],[ans(t-1) ans(t)],'Color','g','LineWidth',2); %line([x1 x2],[y1,y2],
                hold off;
            end
            if ans(t)<=3
               line([t-1 t],[ans(t-1) ans(t)],'Color','r','LineWidth',1);
            end
        
        end
    
    
    
%    shadow

%     原圖直接shadow(不好)
%     img_shadow =~ im2bw(img_gray,thresh); %灰階轉二值化
%     shRadow_orignal = img_shadow; % shadow影像

%     只要mask做shadow
for i=1:3:360
        for j=1:3:270
            if mask(i,j) == 1
                img_shadow(i:i+2,j:j+2)=~ im2bw(img_gray(i:i+2,j:j+2),thresh);
                               
            end
        end
end

    [L,m]=bwlabel(img_shadow,8);  %r或img_shadow
    stats=regionprops(L,'boundingbox');

    
%     原圖

    axes(handles.axes1);imshow(A);
    
%     原圖放mask線&框框&警示
    hold on;
    
%     框陰影 看test9.m
    for kk=1:m
        if stats(kk).BoundingBox(:,3)>=40&&stats(kk).BoundingBox(:,4)<50
          rectangle('Position',stats(kk).BoundingBox,'LineWidth',2,'EdgeColor','g');
          cc=1;%至少有個boundingbox
        end
    end
    
%         畫LINE 看LINE.m
% 圖上的xy和計算上的xy,列式xy交換

c=[44 137]; %兩點的x (圖上的xy!!)
d=[183 359]; %兩點的y
plot(c,d,'b','LineWidth',2)

e=[44 270];
f=[183 197];
plot(e,f,'b','LineWidth',2)

%             合併 if >3 且 shadow= 則原圖亮
if ans(t)>3&&cc==1
   rectangle('Position',[1,1,270,360],'LineWidth',5,'EdgeColor','r'); %rectangle:[x1,y1,x2,y2] 
    
end

%         drawnow; %連續出圖   
 
    hold off;
  

%     影子圖

    axes(handles.axes2);imshow(img_shadow);
    hold on;
    for kk=1:m
        if stats(kk).BoundingBox(:,3)>=40&&stats(kk).BoundingBox(:,4)<50
          rectangle('Position',stats(kk).BoundingBox,'LineWidth',2,'EdgeColor','g');
        end
    end
      
    hold off;
    
    

    
    
    
    
end
