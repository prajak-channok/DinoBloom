# DinoBloom — Acceptance Criteria

## Purpose
ใช้ตรวจว่าแต่ละ Milestone เสร็จในระดับที่สามารถไปต่อได้หรือไม่

Acceptance Criteria เป็นเกณฑ์ขั้นต่ำ ไม่ได้หมายความว่า Balance หรือ Presentation ต้อง Final
Agent ต้องตรวจ Project และ Runtime จริงก่อนถือว่า Milestone Complete

---

# M1 — Foundation

## Scene Flow
- [ ] Start Scene เป็นจุดเริ่มเกม
- [ ] Play ไป Select Stage ได้
- [ ] Exit มี Confirmation และทำงานตาม Platform

## Select Stage
- [ ] แสดง Stage ที่มี
- [ ] Locked Stage แสดงสถานะ Locked
- [ ] Stage ที่เลือกมี Visual แตกต่าง
- [ ] มี Back
- [ ] มี DNA Counter
- [ ] มี Upgrade

## Upgrade / Save Foundation
- [ ] เปิด Upgrade Scene ได้
- [ ] แสดง DNA และ Plant
- [ ] Locked Plant มี Locked UI
- [ ] Save/Load ทำงาน
- [ ] DNA และ Stage/Plant progression ที่รองรับคงอยู่หลังเปลี่ยน Scene/Reload

---

# M2 — Stage / Board Foundation

## Stage
- [ ] เข้า Select Stage ครั้งแรกยังไม่มี Stage ถูกเลือก
- [ ] เลือก Stage ได้
- [ ] Current Stage ใหญ่กว่า Stage อื่น
- [ ] Stage เรียงแนวนอน
- [ ] Locked Stage มี Overlay สีดำโปร่งใส
- [ ] Stage 3 เป็น Stage ที่เล่นได้ ไม่ใช่ Story-only

## Background / Board
- [ ] Stage 1 ใช้ FieldBG1
- [ ] Stage 2 ใช้ FieldBG2
- [ ] Stage 3 ใช้ FieldBG3
- [ ] Background แสดงเต็มภาพ ไม่ Crop เพื่อทำ Grid
- [ ] Board = 5 × 8
- [ ] 5 แถว = 5 Lanes
- [ ] 8 คอลัมน์ = พื้นที่แนวนอน
- [ ] Tile เป็น Checkerboard
- [ ] Stage 1 ใช้ TileField1A/B
- [ ] Stage 2 ใช้ TileField2A/B
- [ ] Stage 3 ใช้ TileField1A/B
- [ ] Gameplay Area กำหนดแยกตาม Stage ได้
- [ ] Grid สามารถวางทับ Background ได้

---

# M3 — Combat Foundation

## Placement
- [ ] เลือก Plant จาก Panel ได้
- [ ] Plant ใช้ 1 Grid
- [ ] ตรวจตำแหน่งก่อนวาง
- [ ] ใช้ Ancient Seed ตาม Cost
- [ ] Seed ไม่พอ = วางไม่ได้
- [ ] Placement Cooldown แยกตาม Plant
- [ ] ถอน Plant ได้
- [ ] Refund 50% ของ Cost และปัดลง

## Combat
- [ ] Plant Target Dinosaur ตามกติกา
- [ ] Attack Interval ทำงาน
- [ ] Projectile เคลื่อนที่เป็นเส้นตรง
- [ ] Damage เกิดเมื่อ Projectile ชน Enemy
- [ ] Projectile หายเมื่อชน Enemy
- [ ] Projectile หายเมื่อออกนอก Map
- [ ] Projectile ไม่ชน Plant/Friendly Dinosaur ฝ่ายเดียวกัน
- [ ] Dinosaur เดินขวาไปซ้าย
- [ ] Dinosaur ปกติไม่เปลี่ยน Lane
- [ ] Dinosaur หยุดเมื่อพบ Plant ใน Lane
- [ ] Dinosaur โจมตี Plant
- [ ] Plant ตายแล้ว Dinosaur เดินต่อ
- [ ] Dinosaur ถึงซ้ายสามารถทำให้ Lose
- [ ] Entity ตายแล้วถูกลบ ไม่มี Corpse
- [ ] Base Stats อ่านจาก Data Resource
- [ ] Scaling ไม่แก้ Base Data ถาวร

---

# M4 — Match & Wave

## Match
- [ ] Stage 1 เริ่มได้
- [ ] Match ใหม่เริ่ม Wave 1
- [ ] Ancient Seed และ Plant Placement ใช้งานได้

## Wave / Spawn
- [ ] Wave 1 = Normal 20
- [ ] Wave 2 = Normal 25
- [ ] Wave 3 = Normal 30
- [ ] Boss ไม่รวมในจำนวน Normal
- [ ] Stage 1 ใช้ Dryosaurus, Velociraptor, Triceratops ตาม Composition
- [ ] Wave 3 มี T-Rex 1 ตัว
- [ ] Lane หนึ่งมี Dinosaur พร้อมกันไม่เกิน 10
- [ ] Spawn สุ่ม Lane
- [ ] 15 วินาทีแรก Spawn 2–3 ตัวตาม Rule
- [ ] หลังจากนั้น Spawn ทีละตัว
- [ ] Spawn Interval ปกติสุ่ม 1–5 วินาที
- [ ] Spawn ครบตามจำนวน

## Scaling
- [ ] Wave 1 = ×1 HP
- [ ] Wave 2 = ×1.5 HP
- [ ] Wave 3 = ×2.25 HP
- [ ] Stage 1 = ×1 HP
- [ ] Stage 2 = ×2 HP
- [ ] Stage 3 = ×4 HP
- [ ] Scaling เพิ่มเฉพาะ HP
- [ ] Base Data ไม่ถูกแก้ถาวร

## Transition / Result
- [ ] Wave จบเมื่อ Spawn ครบและ Dinosaur ในสนามหมด
- [ ] Wave Transition Popup แสดง
- [ ] Gameplay หยุดระหว่าง Popup
- [ ] พัก 5 วินาที
- [ ] Seed Production และ Placement Cooldown หยุด
- [ ] วาง Plant ไม่ได้ระหว่าง Popup
- [ ] Wave ถัดไปเริ่มถูกต้อง
- [ ] Dinosaur ถึงซ้าย = Lose
- [ ] Wave 3 สำเร็จ = Win
- [ ] Win/Lose Popup แสดง
- [ ] Match ใหม่กลับ Wave 1

## Reward
- [ ] W1/W2: Guaranteed 1 DNA + Random 1–3
- [ ] W3: Guaranteed 3 DNA + Random 1–3
- [ ] Reward ได้ทุกครั้งที่ทำสำเร็จ
- [ ] แพ้ก่อนจบ W1 ไม่ได้ Reward
- [ ] Surrender ไม่ได้ Reward

## Controls
- [ ] Pause หยุด Gameplay Simulation
- [ ] UI/Input สำหรับ Pause ยังทำงาน
- [ ] 2× เร่ง Gameplay Simulation
- [ ] 2× ไม่เร่ง UI/Input
- [ ] Surrender มี Confirmation
- [ ] Confirm Surrender ทำให้ Match เป็นโมฆะ

---

# M5 — Progression / Upgrade

- [ ] Plant ที่ Unlock เริ่ม Level 0
- [ ] Locked Plant Upgrade ไม่ได้
- [ ] Upgrade Level 0 → 5 ได้
- [ ] Level 1–4 เพิ่ม ATK และ HP
- [ ] Level 5 เพิ่ม ATK/HP และลด Placement Cooldown
- [ ] Upgrade มีผลทุก Stage
- [ ] DNA ถูกหักถูกต้อง
- [ ] Plant Unlock/Level ถูก Save
- [ ] Reload แล้ว Progression เดิมกลับมา

---

# M6 — Remaining Plants / Advanced Mechanics

- [ ] Baobab Guardian ทำงานเป็น Tank
- [ ] Ginkgo Cannon ทำงานตาม Conversion Mechanic
- [ ] Horsetail ทำงานตาม Data
- [ ] Sticky Moss ทำงานเป็น Trap
- [ ] Blast Cone ทำงานเป็น Trap
- [ ] Ginkgo ไม่สามารถ Convert T-Rex
- [ ] Ginkgo Conversion Cooldown = 40s
- [ ] Friendly Dinosaur เดินไปทางขวาและไม่กิน Plant
- [ ] Friendly/Enemy Dinosaur ต่อสู้กันได้
- [ ] Triggered Trap หายและไม่มี Refund
- [ ] Blast Cone ระเบิดครั้งเดียว
- [ ] Blast Cone ไม่ทำ Damage Friendly Dinosaur
- [ ] Explosion ไม่ทำลาย Plant ฝ่ายเดียวกัน
- [ ] Sticky Moss ใช้ Area/Duration ตาม Design

---

# M7 — Remaining Dinosaur Mechanics / Content

- [ ] Parasaurolophus
- [ ] Deinonychus
- [ ] Ankylosaurus
- [ ] Advanced Dinosaur abilities
- [ ] Deinonychus กระโดดข้าม Plant ตัวแรก
- [ ] ข้าม Plant ทุกประเภท รวม Trap/Baobab
- [ ] ระหว่าง Jump ไม่รับ Projectile Damage
- [ ] ไม่ Trigger Trap ที่กระโดดข้าม
- [ ] ข้ามได้เพียง 1 Plant
- [ ] ลงหลัง Plant ที่ข้าม
- [ ] Armor รับ Damage ก่อน HP
- [ ] Armor แตกแล้วไม่กลับมา
- [ ] Ginkgo Convert แล้วคงสถานะ Armor เดิม

---

# M8 — Polish / Balance / Deployment

## Balance
- [ ] Playtest ทุก Stage
- [ ] ตรวจ Difficulty Progression
- [ ] ตรวจ DNA Economy
- [ ] ตรวจ Ancient Seed Economy
- [ ] ตรวจ Plant Cost/Cooldown
- [ ] ตรวจ Dinosaur HP/Damage/Speed
- [ ] Balance ปรับผ่าน Data ไม่ Hard-code

## Polish
- [ ] Animation พร้อมแทน Placeholder ตามความพร้อม
- [ ] Projectile Visual พร้อม
- [ ] VFX
- [ ] UI Polish
- [ ] Audio
- [ ] Win/Lose/Wave Presentation

## Deployment
- [ ] Fullscreen/Window behavior ตรวจแล้ว
- [ ] Save/Load บน Target Platform ตรวจแล้ว
- [ ] Web Build ตรวจแล้ว
- [ ] Reload Page แล้วยังมี Persistent Save
- [ ] ไม่มี Parser Error
- [ ] ไม่มี Runtime Error สำคัญ
- [ ] ไม่มี Broken Scene Reference

---

# Definition of Done

Milestone ถือว่า Complete เมื่อ:
1. Acceptance Criteria ของ Milestone นั้นผ่านตาม Scope
2. Project ไม่มี Parser Error ที่เกี่ยวข้อง
3. Runtime Flow ทดสอบได้จริง
4. ระบบใหม่ไม่ทำลาย Milestone ก่อนหน้า
5. Data ที่ควรเป็น Data Resource ไม่ถูก Hard-code ซ้ำโดยไม่จำเป็น
6. `04_CURRENT_STATUS.md` ถูกอัปเดตตามสถานะจริง
7. ปัญหาที่ยังไม่ผ่านถูกระบุชัดเจน และไม่ถูกทำเครื่องหมาย Complete

Acceptance Criteria เป็นเกณฑ์ตรวจงาน ไม่ใช่ข้อบังคับให้ Implement ทุก Feature ในครั้งเดียว
