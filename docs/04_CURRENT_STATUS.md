# DinoBloom — Current Status / Handoff

## Source
สถานะนี้สรุปจาก Project ZIP ที่ส่งต่อใน `BeforeClaudeCode.zip`

## Current Milestone
Project อยู่ในช่วง **M4 implementation / handoff** แต่ต้องทดสอบจริงก่อนถือว่า M4 complete

## Existing Assets
มี Background:
- `assets/BackGround/FieldBG1.png`
- `assets/BackGround/FieldBG2.png`
- `assets/BackGround/FieldBG3.png`
- `assets/BackGround/SelectStageBG2.png`
- `assets/BackGround/select_stageBG.png`
- `assets/BackGround/StartBG.png`

มี Stage tiles:
- TileField1A / 1B
- TileField2A / 2B

Stage 3 ใช้ Tile ของ Stage 1 ตาม Data ปัจจุบัน

มี Dinosaur sprite sheets:
- Dryosaurus Walk/Eat
- Velociraptor Walk/Eat
- Triceratops Walk/Eat

T-Rex ใน Scene ปัจจุบันใช้ ColorRect placeholder

## Existing Dinosaur Data
มีครบสำหรับ Stage 1:
- Dryosaurus
- Velociraptor
- Triceratops
- T-Rex

## Existing Plant Data
มี:
- Seed Bloom
- Thorn Fern

ยังไม่ควรสรุปว่า Plant ตัวอื่น runtime-ready เพียงเพราะมี PNG

## Existing M4-related Scripts
พบ:
- `wave_manager.gd`
- `spawn_manager.gd`
- `match_manager.gd`
- Dinosaur scripts
- `gameplay_scene.gd`

ดังนั้น M4 ไม่ควรเริ่มจากศูนย์ ให้ตรวจและต่อยอดระบบเหล่านี้

## Known Data Issue — Resolved
`velociraptor.tres` ไม่มี `attack_interval` — แก้แล้ว เพิ่ม `attack_interval = 1.0` ตาม Design

## Architecture Caution — Resolved
ตรวจแล้วว่า `scenes/gameplay_scene.tscn` ใช้ script จริงชื่อ `gameplay_scene.gd` (`class_name GameplayScene`, เดิมชื่อ `m3_gameplay_scene.gd` / `M3GameplayScene` — เปลี่ยนชื่อแล้วเพื่อไม่ให้ผูกกับ Milestone เก่า) ผูกกับ WaveManager/SpawnManager/MatchManager ครบ
ไฟล์ M2 leftover เดิมชื่อ `gameplay_scene.gd` และ `gameplay_placeholder.gd` ไม่ถูกอ้างอิงจาก Scene หรือ Script ใดเลย — ลบทั้งสองไฟล์ทิ้งแล้ว (รวม `.uid` sidecar)

## Verified via Headless Run (Godot 4.7, 2026-08-21)
- ไม่มี Parser Error
- Run `gameplay_scene.tscn` แล้วไม่มี Runtime Error (มีแค่ Warning เรื่อง Background aspect ratio ไม่ใช่ 16:9 ซึ่งเป็นเรื่อง Asset ไม่ใช่ Logic)
- WaveManager/SpawnManager/MatchManager wiring ตรวจโค้ดแล้วครบ: Wave composition/count, Lane capacity, Wave HP scaling, Wave Transition popup, Pause, 2×, Surrender, Win/Lose, DNA Reward, Ancient Seed cap/refund

## Balance Data Fixed (Confirmed by Developer, 2026-08-21)
- Dryosaurus movement_speed 50 → 40
- Triceratops movement_speed 35 → 30, attack_interval 1.5s → 3s
- T-Rex movement_speed 25 → 20
- Thorn Fern placement_cooldown 10s → 7s

## Known Intentional Deviation (Kept As-Is)
`spawn_manager.gd` หลัง 15 วินาทีแรกใช้ `randf_range(3.0, 7.0)` แทน 1–5 วินาทีตาม Design doc — Developer confirm ให้คงไว้ตามเดิมเพราะเป็น pacing ที่ balance ไว้แล้ว ไม่ใช่ bug

## Dead Code Cleanup (2026-08-21, Confirmed by Developer)
- ลบ `scripts/main.gd` + `scenes/main.tscn`: เป็น bootstrap ที่แค่ redirect ไป `start_scene.tscn` ตอน `_ready()`, ไม่ถูกอ้างอิงจากที่ใด (project.godot `run/main_scene` ชี้ไป `start_scene.tscn` ตรงอยู่แล้ว)
- ลบ `scenes/stage_board.tscn` (standalone preview scene ของ Board เดี่ยว ๆ — เกมจริงสร้าง Board ผ่าน `gameplay_scene.tscn` อยู่แล้ว, script `stage_board.gd`/`stage_board_visual.gd` ยังใช้งานจริงไม่ได้ลบ)
- ลบ `scripts/thorn_fern_animation_test.gd` + `scenes/plants/thorn_fern_animation_test.tscn` (Harness ทดสอบ Animation ของ Thorn Fern ด้วย Space/Click)
- ทุกไฟล์ที่ลบไม่ถูกอ้างอิงจาก Scene/Script อื่นใดเลย และลบ `.uid` sidecar ที่เกี่ยวข้องไปด้วยแล้ว

## Stage Data
Stage 1:
- `stage_01.tres`
- Background: FieldBG1
- Tiles: TileField1A/B
- HP multiplier: 1.0

Stage 2:
- `stage_02.tres`
- Background: FieldBG2
- Tiles: TileField2A/B
- HP multiplier: 2.0

Stage 3:
- `stage_03.tres`
- Background: FieldBG3
- Tiles: TileField1A/B
- HP multiplier: 4.0
- Stage 3 เป็น Stage ที่เล่นได้ ไม่ใช่ Story-only

## Handoff Rule
สถานะด้านบนเป็นภาพจากไฟล์ล่าสุดที่ส่งมา ไม่ใช่ผลจากการรัน Project ในเครื่องของ Agent
Agent ต้อง:
1. เปิด Project
2. ตรวจ Parser Errors
3. Run
4. ตรวจ Scene Flow
5. ตรวจ M4 systems
6. อัปเดตไฟล์นี้หลังจากยืนยันสถานะจริง

## Immediate Next Step
ตรวจ M4 implementation ที่มีอยู่ แล้วทำให้ Stage 1 สามารถเล่นครบ:
Start → Wave 1 → Wave 2 → Wave 3 → Win/Lose → Reward

อย่าเริ่มทำ Advanced Dinosaur/Plant abilities จนกว่า Core Match Loop จะเสถียร
