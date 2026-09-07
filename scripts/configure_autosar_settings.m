function configure_autosar_settings()
%CONFIGURE_AUTOSAR_SETTINGS Apply AUTOSAR-oriented config where available.

models = {'AC_FanControl_Top','AC_FanCtrl_Manual','AC_FanCtrl_Auto'};
for i = 1:numel(models)
    mdl = models{i};
    load_system(mdl);

    % Core simulation/codegen settings
    set_param(mdl,'SystemTargetFile','autosar.tlc');
    set_param(mdl,'SolverType','Fixed-step');
    set_param(mdl,'Solver','FixedStepDiscrete');
    set_param(mdl,'FixedStep','0.01');
    set_param(mdl,'ProdEqTarget','on');
    set_param(mdl,'GenCodeOnly','off');

    % Fallback if AUTOSAR target not available in installation
    try
        cs = getActiveConfigSet(mdl);
        stf = get_param(cs,'SystemTargetFile'); %#ok<NASGU>
    catch
        set_param(mdl,'SystemTargetFile','ert.tlc');
    end

    save_system(mdl);
    close_system(mdl);
end

disp('AUTOSAR-oriented configuration applied.');
end
