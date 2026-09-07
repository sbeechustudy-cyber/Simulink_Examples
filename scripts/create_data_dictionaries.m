function create_data_dictionaries()
%CREATE_DATA_DICTIONARIES Create shared and model-specific SLDD files.

sharedDict = 'AC_Shared.sldd';
ctrlDict   = 'AC_FanCtrl.sldd';

if ~isfile(sharedDict)
    Simulink.data.dictionary.create(sharedDict);
end
if ~isfile(ctrlDict)
    Simulink.data.dictionary.create(ctrlDict);
end

% Shared dictionary
sharedObj = Simulink.data.dictionary.open(sharedDict);
sharedSec = getSection(sharedObj,'Design Data');

% Create enum class file if missing
if ~isfile('FanCtrlMode_e.m')
    fid = fopen('FanCtrlMode_e.m','w');
    fprintf(fid, 'classdef FanCtrlMode_e < Simulink.IntEnumType\n');
    fprintf(fid, '    enumeration\n');
    fprintf(fid, '        MANUAL(0)\n');
    fprintf(fid, '        AUTO(1)\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    fclose(fid);
end

% Control dictionary
ctrlObj = Simulink.data.dictionary.open(ctrlDict);
ctrlSec = getSection(ctrlObj,'Design Data');

upsertParam(ctrlSec, 'Ts', single(0.01), 'single', 0.001, 0.1);
upsertParam(ctrlSec, 'Kp', single(8.0), 'single', 0, 100);
upsertParam(ctrlSec, 'Ki', single(0.8), 'single', 0, 100);

% Variant control parameter
if ~entryExists(ctrlSec, 'FanCtrlMode')
    p = Simulink.Parameter(FanCtrlMode_e.MANUAL);
    p.DataType = 'Enum: FanCtrlMode_e';
    addEntry(ctrlSec,'FanCtrlMode',p);
else
    e = getEntry(ctrlSec,'FanCtrlMode');
    p = getValue(e);
    p.Value = FanCtrlMode_e.MANUAL;
    p.DataType = 'Enum: FanCtrlMode_e';
    setValue(e,p);
end

saveChanges(sharedObj);
saveChanges(ctrlObj);
close(sharedObj);
close(ctrlObj);

disp('Data dictionaries created/updated.');
end

function upsertParam(sec,name,val,dtype,minv,maxv)
if ~entryExists(sec,name)
    p = Simulink.Parameter(val);
    p.DataType = dtype;
    p.Min = minv;
    p.Max = maxv;
    addEntry(sec,name,p);
else
    e = getEntry(sec,name);
    p = getValue(e);
    p.Value = val;
    p.DataType = dtype;
    p.Min = minv;
    p.Max = maxv;
    setValue(e,p);
end
end

function tf = entryExists(sec,name)
try
    getEntry(sec,name);
    tf = true;
catch
    tf = false;
end
end
