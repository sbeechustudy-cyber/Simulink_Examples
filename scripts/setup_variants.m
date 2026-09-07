function setup_variants()
%SETUP_VARIANTS Attach dictionaries and setup variant activation context.

models = {'AC_FanControl_Top','AC_FanCtrl_Manual','AC_FanCtrl_Auto'};
for i = 1:numel(models)
    mdl = models{i};
    load_system(mdl);
    set_param(mdl,'DataDictionary','AC_FanCtrl.sldd');
    set_param(mdl,'StopTime','10');
    set_param(mdl,'SolverType','Fixed-step');
    set_param(mdl,'Solver','FixedStepDiscrete');
    set_param(mdl,'FixedStep','0.01');
    save_system(mdl);
    close_system(mdl);
end

disp('Variants and dictionary bindings configured.');
end
