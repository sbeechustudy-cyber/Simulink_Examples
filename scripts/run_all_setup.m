function run_all_setup()
%RUN_ALL_SETUP End-to-end setup for AC FAN variant Simulink example.

clc;
disp('--- AC FAN Variant setup started ---');

scripts = {
    @create_data_dictionaries, ...
    @create_ac_fan_variant_models, ...
    @setup_variants, ...
    @configure_autosar_settings, ...
    @create_test_harness ...
    };

for i = 1:numel(scripts)
    f = scripts{i};
    disp(['Running: ', func2str(f), ' ...']);
    f();
end

disp('--- Setup completed successfully ---');
end
