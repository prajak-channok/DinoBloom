# DinoBloom — Architecture Guide

## Principle
Project ใช้แนวคิด Data-driven:
- Static balance/configuration → `.tres`
- Runtime behavior → `.gd`
- Scene composition / UI / Entity hierarchy → `.tscn`

อย่าให้ Entity Script เป็นแหล่งเก็บ Base Balance หลัก ถ้ามี Data Resource อยู่แล้ว

## Current Main Areas

```text
assets/
data/
scenes/
scripts/
```

## Data Resources

### DinosaurData
`res://scripts/data/dinosaur_data.gd`

Data files:
`res://data/dinosaurs/*.tres`

ปัจจุบันมี:
- dryosaurus.tres
- velociraptor.tres
- triceratops.tres
- trex.tres

### PlantData
`res://scripts/data/plant_data.gd`

Data filesปัจจุบัน:
- seed_bloom.tres
- thorn_fern.tres

### StageData
`res://scripts/stage_data.gd`

Stage data:
- stage_01.tres
- stage_02.tres
- stage_03.tres

StageData เก็บ:
- Stage ID
- Display Name
- Background
- Tile A/B
- Gameplay Area normalized
- HP multiplier
- Unlock dependency

## Gameplay Systems

### WaveManager
`res://scripts/wave_manager.gd`

Responsibility:
- Wave configuration
- Dinosaur composition
- Count
- Wave HP multiplier
- DNA reward formula

ไม่ควรเป็นผู้ Spawn Node โดยตรง

### SpawnManager
`res://scripts/spawn_manager.gd`

Responsibility:
- Spawn Dinosaur
- Random Lane
- Spawn timing
- Lane capacity
- เชื่อม Spawn กับ Wave configuration

### MatchManager
`res://scripts/match_manager.gd`

Responsibility:
- Match state
- Win / Lose
- ติดตาม Entity
- ตรวจเงื่อนไขจบ Wave/Match
- Reward flow

## Entity Scripts
ปัจจุบันมี Script สำหรับ:
- Dryosaurus
- Velociraptor
- Triceratops
- T-Rex
- Seed Bloom
- Thorn Fern
- Thorn Projectile

## Save
`res://scripts/save_manager.gd`

Persistent progression เช่น DNA และ Stage/Plant progression ควรอยู่ใน Save System
Current Match / Current Wave ไม่ต้องบันทึก

## Scene Areas
- `start_scene.tscn`
- `select_stage_scene.tscn`
- `gameplay_scene.tscn`
- `upgrade_scene.tscn`
- Plant scenes
- Enemy scenes

## Board
`stage_board.gd` / `stage_board_visual.gd`
ใช้สร้าง Board/Grid จากข้อมูล Stage แทนการวาด Grid ฝังอยู่ใน Background ผูกอยู่กับ Node `PlayArea/World/Board` ใน `gameplay_scene.tscn` โดยตรง

Board:
- 5 rows
- 8 columns
- Checkerboard tile A/B

Background:
- แสดงเต็มภาพ ไม่ crop
- Gameplay Area ใช้ normalized rectangle ของแต่ละ Stage

## Architecture Rules
1. ตรวจระบบเดิมก่อนสร้างระบบใหม่
2. Manager ไม่ควรรับผิดชอบทุกอย่างรวมกัน
3. UI ไม่ควรเป็น Source of Truth ของ Gameplay
4. Data Resource เป็น Source of Truth ของ Base Stats
5. Runtime scaling คำนวณตอนเริ่ม Entity
6. ใช้ Signals/clear contracts สำหรับเหตุการณ์สำคัญ
7. หลีกเลี่ยงการแก้หลายระบบพร้อมกันโดยไม่มีเหตุผล
