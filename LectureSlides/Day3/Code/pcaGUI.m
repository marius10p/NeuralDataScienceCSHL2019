function varargout = pcaGUI(varargin)
% PCAGUI MATLAB code for pcaGUI.fig
%      PCAGUI, by itself, creates a new PCAGUI or raises the existing
%      singleton*.
%
%      H = PCAGUI returns the handle to a new PCAGUI or the handle to
%      the existing singleton*.
%
%      PCAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCAGUI.M with the given input arguments.
%
%      PCAGUI('Property','Value',...) creates a new PCAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pcaGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pcaGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%Illustrates PCA with GUI
%Pascal Wallisch
%07/15/2019
% Edit the above text to modify the response to help pcaGUI

% Last Modified by GUIDE v2.5 15-Jul-2019 17:43:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pcaGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @pcaGUI_OutputFcn, ...
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


% --- Executes just before pcaGUI is made visible.
function pcaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pcaGUI (see VARARGIN)

% Choose default command line output for pcaGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pcaGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pcaGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load SPIKES
handles.DATA = session;
set(handles.channel,'Visible','On');
set(handles.pickChannel,'Visible','On');
set(handles.statusUpdate,'String','Data loaded...');
handles.mS = 12; 
guidata(hObject, handles);


% --- Executes on button press in visualizeWaveforms.
function visualizeWaveforms_Callback(hObject, eventdata, handles)
% hObject    handle to visualizeWaveforms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.wfs);
hold off
%A = zeros(1,1);
%B = ones(1,1);
%C = [A B A];
oneByOne = get(handles.oneByOne,'Value');
plotNum = str2num(get(handles.wfsToPlot,'String'));
plotSet = randi(handles.numSpikes,[plotNum,1]);

xlim([1 48]);
ylim([-150 150]);
if oneByOne == 0
plot(handles.DATA(handles.whichChannel).chan48.wf(:,plotSet),'color','k')
xlim([1 48]);
ylim([-150 150]);
set(gca,'xtick',[]);
box off
set(handles.wfs,'Visible','On')
else
xlim([1 48]);
ylim([-150 150]);
set(gca,'xtick',[])
box off
set(handles.wfs,'Visible','On');

for ii = 1:plotNum
plot(handles.DATA(handles.whichChannel).chan48.wf(:,plotSet(ii)),'color','k')
xlim([1 48]);
ylim([-150 150]);
hold on
%soundsc(C)
if get(handles.pcaPlot,'Visible') == 1 %If PCA was done
%axes(handles.pcaPlot)
%h = plot(handles.rotVals(handles.plotSet(ii),1),handles.rotVals(handles.plotSet(ii),2),'.','color','k');
%set(h,'markersize',handles.mS);


end
pause(0.01)    
end
hold off
end
set(handles.doPCA,'Visible','On');
handles.plotSet = plotSet;
set(handles.statusUpdate,'String',['Visualized ',num2str(plotNum),' WFs...' ]);

guidata(hObject, handles);



function wfsToPlot_Callback(hObject, eventdata, handles)
% hObject    handle to wfsToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wfsToPlot as text
%        str2double(get(hObject,'String')) returns contents of wfsToPlot as a double


% --- Executes during object creation, after setting all properties.
function wfsToPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wfsToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channel_Callback(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel as text
%        str2double(get(hObject,'String')) returns contents of channel as a double
set(handles.visualizeWaveforms,'Visible','On');
set(handles.howMany,'Visible','On');
set(handles.wfsToPlot,'Visible','On');
set(handles.oneByOne,'Visible','On');
guidata(hObject, handles);

handles.whichChannel = str2num(get(handles.channel,'String'));

numSpikes = length(handles.DATA(handles.whichChannel).chan48.wf);
handles.currentData = zscore(double(handles.DATA(handles.whichChannel).chan48.wf)');
handles.numSpikes = numSpikes;

set(handles.nWFS,'String',num2str(numSpikes));
set(handles.numWaveforms,'Visible','On');
set(handles.nWFS,'Visible','On');

plotNum = str2num(get(handles.wfsToPlot,'String'));
plotSet = randi(handles.numSpikes,[plotNum,1]);

set(handles.statusUpdate,'String',['Picked channel ',get(handles.channel,'String'),'...' ]);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in oneByOne.
function oneByOne_Callback(hObject, eventdata, handles)
% hObject    handle to oneByOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oneByOne


% --- Executes on button press in doPCA.
function doPCA_Callback(hObject, eventdata, handles)
% hObject    handle to doPCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.pcaPlot)
hold off
set(handles.pcaPlot,'Visible','On')
[handles.loadings handles.rotVals handles.eigVals] = pca(handles.currentData);
handles.subSet = handles.rotVals(handles.plotSet,1:3); 

if get(handles.threeD,'Visible') == 0
h1 = plot(handles.rotVals(handles.plotSet,1),handles.rotVals(handles.plotSet,2),'.','color','k');
set(h1,'markersize',handles.mS);
else
    if get(handles.threeD,'Value') == 0
    h2 = plot(handles.subSet(:,1),handles.subSet(:,2),'.','color','k');    
    %h2 = plot(handles.rotVals(handles.plotSet,1),handles.rotVals(handles.plotSet,2),'.','color','k');
    set(h2,'markersize',handles.mS);
    else
    h3 = plot3(handles.subSet(:,1),handles.subSet(:,2),handles.subSet(:,3),'.','color','k');    
    %h3 = plot3(handles.rotVals(handles.plotSet,1),handles.rotVals(handles.plotSet,2),handles.rotVals(handles.plotSet,3),'.','color','k');
    set(h3,'markersize',handles.mS);
    end
end
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);
set(handles.threeD,'Visible','On');
set(handles.statusUpdate,'String','Principal components extracted...');
set(handles.kMeansClustering,'Visible','On');
set(handles.numClusters,'Visible','On');
set(handles.nC,'Visible','On');
set(handles.useAll,'Visible','On');
set(handles.kMeansClustering,'Visible','On');
set(handles.cutCluster,'Visible','On');

guidata(hObject, handles);


% --- Executes on button press in threeD.
function threeD_Callback(hObject, eventdata, handles)
% hObject    handle to threeD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate3d on


% --- Executes on button press in kMeansClustering.
function kMeansClustering_Callback(hObject, eventdata, handles)
% hObject    handle to kMeansClustering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.pcaPlot)
hold off

%Calculating
numClusters = str2num(get(handles.numClusters,'String'));
if get(handles.threeD,'Value') == 0
if get(handles.useAll,'Value') == 1
[cId, ctr] = kmeans(handles.rotVals(:,1:2),numClusters);
else
[cId, ctr] = kmeans(handles.rotVals(handles.plotSet,1:2),numClusters);    
end
else
if get(handles.useAll,'Value') == 1
[cId, ctr] = kmeans(handles.rotVals(:,1:3),numClusters);
else
[cId, ctr] = kmeans(handles.rotVals(handles.plotSet,1:3),numClusters);
end
end
set(handles.statusUpdate,'String',['Identified ', num2str(numClusters), ' clusters...']);

indexVector = 1:length(unique(cId));


%Plotting

if get(handles.useAll,'Value') == 0
    
if get(handles.threeD,'Value') == 0

clusterColors = zeros(length(indexVector),3);      
for ii = indexVector
plotIndex = find(cId == ii);
hLine = plot(handles.subSet(plotIndex,1),handles.subSet(plotIndex,2),'.','markersize',handles.mS);
clusterColors(ii,:) = get(hLine,'Color'); 
hold on
h = plot(ctr(ii,1),ctr(ii,2),'.','markersize',40,'color','k'); 
set(gca,'xtick',[]);
set(gca,'ytick',[]);

end
else

    for ii = indexVector
plotIndex = find(cId == ii);
hLine = plot3(handles.subSet(plotIndex,1),handles.subSet(plotIndex,2),handles.subSet(plotIndex,3),'.','markersize',handles.mS);
clusterColors(ii,:) = get(hLine,'Color'); 

hold on
h = plot3(ctr(ii,1),ctr(ii,2),ctr(ii,3),'.','markersize',40,'color','k'); 
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);

end
    
end
else
    if get(handles.threeD,'Value') == 0

for ii = indexVector
plotIndex = find(cId == ii);
hLine = plot(handles.rotVals(plotIndex,1),handles.rotVals(plotIndex,2),'.','markersize',handles.mS);
clusterColors(ii,:) = get(hLine,'Color'); 

hold on
h = plot(ctr(ii,1),ctr(ii,2),'.','markersize',40,'color','k'); 
set(gca,'xtick',[]);
set(gca,'ytick',[]);
%set(h,'facecolor','k')
%set(h,'edgecolor','k')

end
else

    for ii = indexVector
plotIndex = find(cId == ii);
hLine = plot3(handles.rotVals(plotIndex,1),handles.rotVals(plotIndex,2),handles.rotVals(plotIndex,3),'.','markersize',handles.mS);
clusterColors(ii,:) = get(hLine,'Color'); 

hold on
h = plot3(ctr(ii,1),ctr(ii,2),ctr(ii,3),'.','markersize',40,'color','k'); 
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);

end
    
    end
end
%clusterColors
%Re-plotting the spikes
axes(handles.wfs)
hold off
    for ii = indexVector
    plotIndex = find(cId == ii);
    if get(handles.useAll,'Value') == 0
    plot(handles.DATA(handles.whichChannel).chan48.wf(:,handles.plotSet(plotIndex)),'color',clusterColors(ii,:))
    else
        try %This is buggy
    plot(handles.DATA(handles.whichChannel).chan48.wf(:,handles.plotSet(plotIndex)),'color',clusterColors(ii,:))
        catch
        end
    end
    hold on
    xlim([1 48]);
ylim([-150 150]);
set(gca,'xtick',[]);
box off
    end
    


set(handles.az5,'Visible','On');

function numClusters_Callback(hObject, eventdata, handles)
% hObject    handle to numClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numClusters as text
%        str2double(get(hObject,'String')) returns contents of numClusters as a double


% --- Executes during object creation, after setting all properties.
function numClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useAll.
function useAll_Callback(hObject, eventdata, handles)
% hObject    handle to useAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useAll


% --- Executes on button press in az5.
function az5_Callback(hObject, eventdata, handles)
% hObject    handle to az5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of az5
set(handles.statusUpdate,'String','Quenching reactor...');
pause(1)
close


% --- Executes on button press in cutCluster.
function cutCluster_Callback(hObject, eventdata, handles)
% hObject    handle to cutCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vertices = ginput(5);
vertices(end+1,:) = vertices(1,:);
Q = inpolygon(handles.subSet(:,1),handles.subSet(:,2),vertices(:,1),vertices(:,2));
R = find(Q);
axes(handles.pcaPlot)
hold on
plot(handles.subSet(R,1),handles.subSet(R,2),'.','color','r','markersize',round(handles.mS*1.5))
set(handles.statusUpdate,'String','Cluster has been cut!');
axes(handles.pcaPlot)
axes(handles.wfs)
hold on
plot(handles.DATA(handles.whichChannel).chan48.wf(:,handles.plotSet(R)),'color','r')

% Hint: get(hObject,'Value') returns toggle state of cutCluster
