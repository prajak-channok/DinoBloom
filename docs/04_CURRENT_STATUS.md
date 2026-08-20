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

## Known Data Issue to Verify
`velociraptor.tres` ใน ZIP ปัจจุบันไม่มี `attack_interval` ทั้งที่ Design กำหนด 1.0s

## Known Architecture Caution
มีทั้ง:
- `gameplay_scene.gd`
- `m3_gameplay_scene.gd`
- `gameplay_placeholder.gd`

ก่อนแก้ Gameplay ต้องตรวจว่าไฟล์ใดเป็น runtime entry จริง เพื่อไม่ให้แก้ผิดตัวหรือสร้างระบบซ้ำ

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
