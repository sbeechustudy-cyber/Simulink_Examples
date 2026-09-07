# AC FAN Variant Control Blueprint (Production-Style)

## Objective
Create an automotive-style Simulink model for AC FAN control demonstrating variant-based feature behavior:
- Manual FAN control from driver/passenger requests
- Automatic FAN control from cabin temperature and requested setpoint

## Repository branch
- Branch: `AC_Control`
- Repo: `sbeechustudy-cyber/Simulink_Examples`

## Model architecture

### Top model
- `AC_FanControl_Top.slx`
- Inports:
  - `DrvFanReq_pct` (uint8, 0..100)
  - `PsgFanReq_pct` (uint8, 0..100)
  - `CabinTemp_degC` (single, -40..85)
  - `TempSetpoint_degC` (single, 16..30)
- Variant selection:
  - `FanCtrlMode` is the enum-valued dictionary parameter that selects the active variant
  - Manual active: `FanCtrlMode == FanCtrlMode_e.MANUAL`
  - Auto active: `FanCtrlMode == FanCtrlMode_e.AUTO`
- Variant subsystem/model behavior:
  - **Manual path** references `AC_FanCtrl_Manual.slx`
  - **Auto path** references `AC_FanCtrl_Auto.slx`
- Outport:
  - `FanCmd_pct` (uint8, 0..100)

### Referenced model: Manual
- `AC_FanCtrl_Manual.slx`
- Behavior:
  - `FanReqRaw = max(DrvFanReq_pct, PsgFanReq_pct)`
  - Saturate to 0..100
  - Optional discrete rate limiting

### Referenced model: Auto
- `AC_FanCtrl_Auto.slx`
- Behavior:
  - Error: `e = TempSetpoint_degC - CabinTemp_degC`
  - Discrete PI:
    - `u = Kp*e + I`
    - `I(k+1) = I(k) + Ki*Ts*e`
  - Saturate `u` to 0..100
  - Cast to uint8 output

## Data dictionaries

### `AC_Shared.sldd`
Contains shared definitions:
- Enum: `FanCtrlMode_e`
  - `MANUAL = 0`
  - `AUTO = 1`
- Optional shared constants/units conventions

### `AC_FanCtrl.sldd`
Contains control-specific data:
- `Ts = 0.01` (Simulink.Parameter, single)
- `Kp = 8.0` (Simulink.Parameter, single)
- `Ki = 0.8` (Simulink.Parameter, single)
- `FanCtrlMode` (Simulink.Parameter, enum)
- Signal metadata (type/min/max) for key interfaces

## Variant conditions
- Manual active: `FanCtrlMode == FanCtrlMode_e.MANUAL`
- Auto active: `FanCtrlMode == FanCtrlMode_e.AUTO`
- The active variant is selected from the model data dictionary parameter, not from a top-level signal input.

## Configuration set requirements
Applied to top and referenced models:
- Solver type: `Fixed-step`
- Solver: `discrete (no continuous states)`
- Fixed-step size: `0.01`
- System target file: AUTOSAR-oriented (fallback to ert if unavailable)
- Code interface packaging prepared for component-style mapping

## Test harness
- Model: `AC_Fan_Harness.slx`
- Stimulus for:
  - Manual mode step requests
  - Auto mode temperature disturbances
- Checks:
  - Output in 0..100
  - Mode switching behavior

## Acceptance criteria
- Models build without unresolved symbols
- Variant switching works using enum control variable
- Type/range constraints are explicit
- Fixed-step discrete simulation runs
- Code generation settings applied for production-style workflow
