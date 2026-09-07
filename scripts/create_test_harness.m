function create_test_harness()
%CREATE_TEST_HARNESS Create simple harness to exercise manual/auto modes.

mdl = 'AC_Fan_Harness';
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl); open_system(mdl);

add_block('simulink/Sources/Constant',[mdl '/DrvFanReq_pct'],'Value','30','Position',[30 40 80 60]);
add_block('simulink/Sources/Constant',[mdl '/PsgFanReq_pct'],'Value','70','Position',[30 80 80 100]);
add_block('simulink/Sources/Sine Wave',[mdl '/CabinTemp_degC'],'Amplitude','5','Bias','24','Frequency','0.2','Position',[30 120 80 145]);
add_block('simulink/Sources/Constant',[mdl '/TempSetpoint_degC'],'Value','22','Position',[30 165 80 185]);

add_block('simulink/Ports & Subsystems/Model',[mdl '/TopRef'],'ModelName','AC_FanControl_Top','Position',[170 70 330 220]);
add_block('simulink/Sinks/Scope',[mdl '/FanCmdScope'],'Position',[390 130 430 160]);

add_line(mdl,'DrvFanReq_pct/1','TopRef/1');
add_line(mdl,'PsgFanReq_pct/1','TopRef/2');
add_line(mdl,'CabinTemp_degC/1','TopRef/3');
add_line(mdl,'TempSetpoint_degC/1','TopRef/4');
add_line(mdl,'TopRef/1','FanCmdScope/1');

set_param(mdl,'StopTime','10');
set_param(mdl,'SolverType','Fixed-step');
set_param(mdl,'Solver','FixedStepDiscrete');
set_param(mdl,'FixedStep','0.01');

save_system(mdl,[mdl '.slx']);
close_system(mdl);

disp('Harness model created: AC_Fan_Harness');
end
