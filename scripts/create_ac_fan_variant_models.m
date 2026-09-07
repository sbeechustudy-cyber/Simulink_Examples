function create_ac_fan_variant_models()
%CREATE_AC_FAN_VARIANT_MODELS Programmatically create top and referenced models.

create_manual_model();
create_auto_model();
create_top_model();

disp('Models created/updated: AC_FanCtrl_Manual, AC_FanCtrl_Auto, AC_FanControl_Top');
end

function create_manual_model()
mdl = 'AC_FanCtrl_Manual';
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl); open_system(mdl);

add_block('simulink/Sources/In1',[mdl '/DrvFanReq_pct'],'Position',[40 80 80 100]);
add_block('simulink/Sources/In1',[mdl '/PsgFanReq_pct'],'Position',[40 140 80 160]);
add_block('simulink/Math Operations/MinMax',[mdl '/MaxReq'], ...
    'Function','max','Position',[140 95 200 145]);
add_block('simulink/Discontinuities/Saturation',[mdl '/Sat_0_100'], ...
    'UpperLimit','100','LowerLimit','0','Position',[250 105 320 135]);
add_block('simulink/Signal Attributes/Data Type Conversion',[mdl '/ToUint8'], ...
    'OutDataTypeStr','uint8','Position',[360 105 430 135]);
add_block('simulink/Sinks/Out1',[mdl '/FanCmd_pct'],'Position',[470 110 510 130]);

add_line(mdl,'DrvFanReq_pct/1','MaxReq/1');
add_line(mdl,'PsgFanReq_pct/1','MaxReq/2');
add_line(mdl,'MaxReq/1','Sat_0_100/1');
add_line(mdl,'Sat_0_100/1','ToUint8/1');
add_line(mdl,'ToUint8/1','FanCmd_pct/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl);
end

function create_auto_model()
mdl = 'AC_FanCtrl_Auto';
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl); open_system(mdl);

add_block('simulink/Sources/In1',[mdl '/CabinTemp_degC'],'Position',[40 80 80 100]);
add_block('simulink/Sources/In1',[mdl '/TempSetpoint_degC'],'Position',[40 140 80 160]);
add_block('simulink/Math Operations/Sum',[mdl '/Err'],'Inputs','+-','Position',[130 100 160 140]);
add_block('simulink/Math Operations/Gain',[mdl '/KpGain'],'Gain','Kp','Position',[210 90 270 120]);
add_block('simulink/Math Operations/Gain',[mdl '/KiGain'],'Gain','Ki*Ts','Position',[210 145 280 175]);
add_block('simulink/Discrete/Discrete-Time Integrator',[mdl '/Iterm'], ...
    'InitialCondition','0','gainval','1','Position',[320 145 390 175]);
add_block('simulink/Math Operations/Sum',[mdl '/PI_Sum'],'Inputs','++','Position',[430 105 460 155]);
add_block('simulink/Discontinuities/Saturation',[mdl '/Sat_0_100'], ...
    'UpperLimit','100','LowerLimit','0','Position',[500 115 570 145]);
add_block('simulink/Signal Attributes/Data Type Conversion',[mdl '/ToUint8'], ...
    'OutDataTypeStr','uint8','Position',[610 115 680 145]);
add_block('simulink/Sinks/Out1',[mdl '/FanCmd_pct'],'Position',[720 120 760 140]);

add_line(mdl,'TempSetpoint_degC/1','Err/1');
add_line(mdl,'CabinTemp_degC/1','Err/2');
add_line(mdl,'Err/1','KpGain/1');
add_line(mdl,'Err/1','KiGain/1');
add_line(mdl,'KiGain/1','Iterm/1');
add_line(mdl,'KpGain/1','PI_Sum/1');
add_line(mdl,'Iterm/1','PI_Sum/2');
add_line(mdl,'PI_Sum/1','Sat_0_100/1');
add_line(mdl,'Sat_0_100/1','ToUint8/1');
add_line(mdl,'ToUint8/1','FanCmd_pct/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl);
end

function create_top_model()
mdl = 'AC_FanControl_Top';
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl); open_system(mdl);

% Inports
add_block('simulink/Sources/In1',[mdl '/DrvFanReq_pct'],'Position',[30 70 70 90]);
add_block('simulink/Sources/In1',[mdl '/PsgFanReq_pct'],'Position',[30 120 70 140]);
add_block('simulink/Sources/In1',[mdl '/CabinTemp_degC'],'Position',[30 170 70 190]);
add_block('simulink/Sources/In1',[mdl '/TempSetpoint_degC'],'Position',[30 220 70 240]);

% Variant subsystem
add_block('simulink/Ports & Subsystems/Variant Subsystem',[mdl '/FanCtrl_Variant'], ...
    'Position',[140 80 470 260]);

% Outport
add_block('simulink/Sinks/Out1',[mdl '/FanCmd_pct'],'Position',[540 160 580 180]);

% Configure variant internals
open_system([mdl '/FanCtrl_Variant']);

% Clean default content
blk = find_system([mdl '/FanCtrl_Variant'],'SearchDepth',1,'Type','Block');
for i=2:numel(blk)
    try delete_block(blk{i}); catch, end
end

add_block('simulink/Ports & Subsystems/In1',[mdl '/FanCtrl_Variant/DrvFanReq_pct'],'Position',[25 35 55 50]);
add_block('simulink/Ports & Subsystems/In1',[mdl '/FanCtrl_Variant/PsgFanReq_pct'],'Position',[25 70 55 85]);
add_block('simulink/Ports & Subsystems/In1',[mdl '/FanCtrl_Variant/CabinTemp_degC'],'Position',[25 105 55 120]);
add_block('simulink/Ports & Subsystems/In1',[mdl '/FanCtrl_Variant/TempSetpoint_degC'],'Position',[25 140 55 155]);
add_block('simulink/Ports & Subsystems/Out1',[mdl '/FanCtrl_Variant/FanCmd_pct'],'Position',[405 105 435 120]);

% Manual choice subsystem
add_block('simulink/Ports & Subsystems/Subsystem',[mdl '/FanCtrl_Variant/ManualPath'],'Position',[110 35 250 95]);
set_param([mdl '/FanCtrl_Variant/ManualPath'],'VariantControl','FanCtrlMode == FanCtrlMode_e.MANUAL');

% Auto choice subsystem
add_block('simulink/Ports & Subsystems/Subsystem',[mdl '/FanCtrl_Variant/AutoPath'],'Position',[110 120 250 180]);
set_param([mdl '/FanCtrl_Variant/AutoPath'],'VariantControl','FanCtrlMode == FanCtrlMode_e.AUTO');

% Model blocks in choices
add_block('simulink/Ports & Subsystems/Model',[mdl '/FanCtrl_Variant/ManualRef'], ...
    'ModelName','AC_FanCtrl_Manual','Position',[280 40 370 90]);
add_block('simulink/Ports & Subsystems/Model',[mdl '/FanCtrl_Variant/AutoRef'], ...
    'ModelName','AC_FanCtrl_Auto','Position',[280 125 370 175]);

% Wiring top to variant
add_line(mdl,'DrvFanReq_pct/1','FanCtrl_Variant/1');
add_line(mdl,'PsgFanReq_pct/1','FanCtrl_Variant/2');
add_line(mdl,'CabinTemp_degC/1','FanCtrl_Variant/3');
add_line(mdl,'TempSetpoint_degC/1','FanCtrl_Variant/4');
add_line(mdl,'FanCtrl_Variant/1','FanCmd_pct/1');

% Wiring internals
add_line([mdl '/FanCtrl_Variant'],'DrvFanReq_pct/1','ManualRef/1');
add_line([mdl '/FanCtrl_Variant'],'PsgFanReq_pct/1','ManualRef/2');
add_line([mdl '/FanCtrl_Variant'],'CabinTemp_degC/1','AutoRef/1');
add_line([mdl '/FanCtrl_Variant'],'TempSetpoint_degC/1','AutoRef/2');
add_line([mdl '/FanCtrl_Variant'],'ManualRef/1','FanCmd_pct/1');
add_line([mdl '/FanCtrl_Variant'],'AutoRef/1','FanCmd_pct/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl);
end
