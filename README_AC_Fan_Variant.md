# AC Fan Variant Control - Simulink Production-Style Example

This package creates a production-style Simulink architecture for AC FAN control using variants.

## What this includes
- Top model architecture with a variant-based control path
- Two referenced control models:
  - Manual mode (max(driver, passenger) arbitration)
  - Auto mode (temperature-based discrete PI)
- Dedicated data dictionaries and typed data definitions
- Configuration setup targeting fixed-step, discrete, AUTOSAR-oriented code generation
- Basic simulation harness model

## Generated artifacts
- `docs/AC_Fan_Variant_Blueprint.md`
- `scripts/create_data_dictionaries.m`
- `scripts/create_ac_fan_variant_models.m`
- `scripts/setup_variants.m`
- `scripts/configure_autosar_settings.m`
- `scripts/create_test_harness.m`
- `scripts/run_all_setup.m`

## Prerequisites
- MATLAB + Simulink
- Variant Manager capability (base Simulink variant features)
- Embedded Coder (for full AUTOSAR workflow mapping)

## How to run
From MATLAB, in repo root:

```matlab
cd('<repo_root>');
addpath(fullfile(pwd, 'scripts'));
run_all_setup();
```

This will:
1. Create/update dictionaries
2. Create models and referenced models
3. Configure variants and parameters
4. Apply code generation/solver settings
5. Create a simple harness model

## Primary model names
- `AC_FanControl_Top.slx`
- `AC_FanCtrl_Manual.slx`
- `AC_FanCtrl_Auto.slx`
- `AC_Fan_Harness.slx`

## Notes
- Sample time is fixed to `0.01 s`.
- Manual arbitration is `max(driver, passenger)`.
- Output command is saturated to 0..100%.
