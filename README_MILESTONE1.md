# DinoBloom — Milestone 1 (Clean Rebuild)

This is a clean Godot 4.7 project generated from the latest DinoBloom requirements.

## Implemented
- Full-screen-ready 1280×720 viewport with canvas-item stretch.
- Start Scene: StartBG + LogoGameNBG + Play + Exit confirmation.
- Select State Scene: SelectStateBG2 + horizontal Stage 1/2/3 selection.
- Stage 1 starts unlocked; Stage 2/3 are locked until their prerequisite is completed.
- Selected/current stage is visually larger.
- Locked stage uses darkened presentation and a disabled Start state.
- DNA counter uses DNANBG.
- Upgrade entry and Back navigation.
- SaveManager foundation using user://dinobloom_save.json.
- Save data stores DNA, completed stages, unlocked plants and plant levels.
- Save intentionally does NOT store current wave/run state.
- Stage .tres resources for Stage 1/2/3.
- Gameplay placeholder exists only to verify scene flow.

## Important asset decision
The gameplay field is NOT treated as a background image containing a baked 5×8 grid. The new architecture reserves the board/grid for Godot-generated cells. Stage backgrounds remain presentation-only. Tile assets can be added in the gameplay milestone once the dedicated per-State floor tiles are available.

## Not implemented yet
- 5×8 board/grid runtime.
- Plant placement/removal.
- Ancient Seed economy.
- Dinosaur movement/combat.
- Projectile system.
- Waves/spawning.
- Win/Lose.
- Upgrade cards and DNA costs.
- Plant/dinosaur gameplay data resources.

## Checkpoint
Treat this folder as the stable Milestone 1 checkpoint before gameplay implementation.
