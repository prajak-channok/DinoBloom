# DinoBloom — Milestone Roadmap

## M1 — Foundation
เป้าหมายหลัก:
- Start Scene
- Select Stage
- Upgrade Scene foundation
- Save / Load foundation
- Persistent DNA / progression foundation

สถานะ: ทำไปแล้วใน Project รุ่นปัจจุบัน

## M2 — Stage / Board Foundation
เป้าหมาย:
- Select Stage flow
- Stage selection behavior
- Stage background
- Full background display
- Generated 5×8 gameplay board
- Checkerboard tiles
- Stage-specific Gameplay Area
- Stage 1/2/3 data
- Stage 3 เป็น playable stage

สถานะ: ทำไปแล้วใน Project รุ่นปัจจุบัน แต่ควรตรวจ runtime ก่อนถือว่า final

## M3 — Combat Foundation
เป้าหมาย:
- Plant placement foundation
- Plant HP / ATK
- Dinosaur movement
- Dinosaur attack
- Plant attack
- Projectile
- Collision / Damage
- Death / Removal
- Stage 1 Dinosaur entities
- Data-driven combat foundation

สถานะ: มี implementation อยู่ใน Project ปัจจุบัน

## M4 — Match & Wave
เป้าหมาย:
- 3-Wave Match
- Stage 1 Wave composition
- Spawn timing
- Lane capacity
- Wave HP scaling
- Wave transition
- Pause
- 2×
- Surrender
- Win / Lose
- DNA Reward
- Match reset to Wave 1 on new play

Stage 1 scope:
- Dryosaurus
- Velociraptor
- Triceratops
- T-Rex

สถานะ: **Current**

Acceptance:
Start Stage 1 → complete/lose Match reliably → correct Reward → return to normal flow.

## M5 — Progression / Upgrade
วางแผน:
- Plant unlock
- Plant upgrade level 0–5
- DNA costs
- ATK/HP upgrades
- Level 5 placement cooldown reduction
- Upgrade UI
- Persistent plant level

## M6 — Remaining Plants / Advanced Mechanics
วางแผน:
- Baobab Guardian
- Ginkgo Cannon
- Horsetail
- Sticky Moss
- Blast Cone
- Advanced mechanics เช่น conversion/traps

## M7 — Remaining Dinosaur Mechanics / Content
วางแผน:
- Deinonychus
- Parasaurolophus
- Ankylosaurus
- Advanced abilities
- Future lane-changing dinosaur architecture

## M8 — Polish / Balance
วางแผน:
- Balance testing
- VFX
- Audio
- Animation improvements
- UI polish
- Web build testing
- Performance cleanup

## Rule
Milestone ไม่ได้หมายความว่าต้องสร้างทุกอย่างในครั้งเดียว
แต่ละ M ต้องมี Acceptance Criteria ที่สามารถทดสอบได้ และ Milestone ถัดไปไม่ควรกลบปัญหาพื้นฐานของ Milestone ก่อนหน้า
