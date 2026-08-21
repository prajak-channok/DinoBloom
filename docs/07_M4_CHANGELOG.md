# DinoBloom — M4 Changelog (2026-08-21)

สรุปคร่าว ๆ ของสิ่งที่ทำระหว่าง Session แก้ไข M4 วันนี้ (ต่อจาก `04_CURRENT_STATUS.md` ที่ Freeze ไว้ ณ จุดก่อนเริ่ม Session นี้)
ไฟล์นี้เป็น Log/Changelog ไม่ใช่ Handoff Doc — ดูสถานะล่าสุดที่ยัง valid อยู่จาก `04_CURRENT_STATUS.md` + Milestone Roadmap เป็นหลัก

## T-Rex Boss — AnimatedSprite2D
- ผู้พัฒนาเพิ่ม `AnimatedSprite2D` ของ T-Rex เองใน `trex.tscn` (SpriteFrames จาก `SPT-RexWalk.png` / `SPT-RexEat.png`, ทั้งสอง animation "walk"/"eat")
- แก้ `trex.gd` ให้ตรงกับ Node ใหม่ (เดิมยังอ้าง `$Visual/ColorRect` ที่ไม่มีแล้ว) โดยใช้ pattern เดียวกับ `dryosaurus.gd`: `_play_walk()` / `_play_eat()` idempotent helper, flash สีตอนโจมตีผ่าน `sprite.modulate` แทนการสลับสี ColorRect เดิม

## T-Rex Boss — Roar เมื่อเข้าสนาม
- เพิ่ม Animation `"rumbling"` ใน `trex.tscn` (จาก `SPT-RexRumbling.png`, ตั้งเป็น non-looping)
- `trex.gd`: เมื่อเดินถึงกริดคอลัมน์ที่ 2 จากขวา (คอลัมน์ index 6 จาก 8 คอลัมน์) จะหยุดเคลื่อนที่ เล่นท่าคำรามหนึ่งรอบ (ผ่านสัญญาณ `animation_finished`) แล้วเดิน/โจมตีต่อตามปกติ — trigger ครั้งเดียวต่อตัวด้วย flag `_rumble_triggered`

## Gameplay UI — Pause / Abandon
- ย้ายปุ่ม ABANDON จาก TopBar เข้าไปอยู่ใน Popup Pause เท่านั้น (คู่กับปุ่ม RESUME ใหม่ในป็อปอัพเดียวกัน)
- Pause popup เปลี่ยนจาก Label "PAUSED" เดิม เป็น Panel/VBox ที่มีปุ่ม RESUME + ABANDON
- ปุ่ม RESUME เรียก `toggle_pause()` เดียวกับปุ่ม PauseButton บน TopBar เพื่อยกเลิก Pause ได้

## Gameplay UI — ปุ่มถอนพืช
- เพิ่มปุ่ม "ถอนพืช" (RemovePlantButton) มุมซ้ายบนของ TopBar (แทนที่ LeftSpacer เดิม)
- เป็น Toggle mode: กดเข้าโหมดถอนพืชแล้วคลิกพืชบนสนามเพื่อถอน (refund logic เดิม, คืนครึ่งราคา), กดอีกครั้งเพื่อออกจากโหมด
- เลือก Plant Card จะยกเลิกโหมดถอนพืชโดยอัตโนมัติ (mutual exclusivity); คลิกขวายังคงถอนพืชได้เสมอไม่ว่าจะอยู่โหมดใด (shortcut เดิมไม่เปลี่ยน)

## Speed 2× — Reset อัตโนมัติเมื่อจบ Wave
- เมื่อ Wave จบและ UI (Wave Clear / Win) ขึ้น จะรีเซ็ต `Engine.time_scale` กลับเป็น 1× ให้อัตโนมัติ (`match_manager.gd: _reset_speed()` เรียกจาก `_on_wave_finished()`)
- ผู้เล่นต้องกดปุ่ม 2× เองใหม่ทุกครั้งที่ Wave ใหม่เริ่ม (ไม่ auto-carry speed ข้าม Wave)

## Spawn Pacing — แยกตาม Wave
- `spawn_manager.start_wave()` รับพารามิเตอร์ `is_first_wave` เพิ่ม (ส่งมาจาก `match_manager._begin_playing()` ด้วย `current_wave == 1`)
- **Wave 1 ของทุกด่าน**: ใช้ pacing เดิมทั้งหมด (ไม่เปลี่ยน — ดู `04_CURRENT_STATUS.md` หัวข้อ Known Intentional Deviation)
- **Wave 2 เป็นต้นไปของทุกด่าน**: สุ่มช่วงเวลาระหว่างการ Spawn แต่ละตัวที่ 0.5–3.0 วินาที (`randf_range(0.5, 3.0)`) ตลอดทั้ง Wave ไม่มี phase พิเศษ 15 วินาทีแรกแบบ Wave 1

## Data / Dead Code (สืบเนื่องจากช่วงก่อน Session นี้)
- แก้ `velociraptor.tres` ที่ไม่มี `attack_interval`
- เปลี่ยนชื่อ `m3_gameplay_scene.gd` (`M3GameplayScene`) → `gameplay_scene.gd` (`GameplayScene`) ไม่ให้ผูกกับ Milestone เก่า
- ลบไฟล์ M2 leftover ที่ไม่ถูกอ้างอิงแล้ว: `scripts/main.gd`, `scenes/main.tscn`, `scenes/stage_board.tscn`, `scripts/thorn_fern_animation_test.gd` + scene คู่กัน (รวม `.uid` sidecar)
- ปรับ Balance: Dryosaurus/Triceratops/T-Rex movement_speed, Triceratops attack_interval, Thorn Fern placement_cooldown (ยืนยันโดย Developer)

## Verification
- Headless Parser Check (Godot 4.7, `--editor --quit-after 20`): ไม่มี Parser Error
- Headless Runtime Check: `gameplay_scene.tscn` และ `scenes/enemies/trex.tscn` รันได้ไม่มี Runtime Error ใหม่ (มีแค่ Warning เรื่อง Background aspect ratio ที่เป็นเรื่อง Asset เดิม ไม่เกี่ยวกับโค้ด)
- ยังไม่ได้ทดสอบ Roar trigger กับสถานการณ์จริงที่มีพืชขวางก่อนถึงคอลัมน์ trigger (ต้องรอเทส Wave 3 boss spawn ระหว่างเล่นจริง) — เป็น edge case ที่รับทราบไว้ ยังไม่ใช่ bug ที่ยืนยันแล้ว
