# DinoBloom — Gameplay Rules

เอกสารนี้เป็นกติกาหลักของ Gameplay ที่ตกลงไว้

## 1. Board
- Grid = 5 × 8
- 5 แถวคือ 5 Lanes
- 8 คอลัมน์คือพื้นที่แนวนอน
- Plant 1 ต้นใช้ 1 Grid
- Dinosaur 1 ตัวสามารถอยู่ใน Grid เดียวกับ Plant ได้
- Dinosaur ปกติอยู่ Lane เดิมและยังไม่มี Lane Change
- ระบบอนาคตต้องรองรับ Dinosaur ที่เปลี่ยน Lane ได้

## 2. Dinosaur Movement
- Dinosaur เดินจากขวาไปซ้าย
- ถ้าพบ Plant ใน Lane เดียวกัน จะหยุดและโจมตี
- เมื่อ Plant ตาย Dinosaur เดินต่อทันที
- ถ้า Dinosaur ถึงขอบซ้ายของ Gameplay Area = Lose ทันที
- Dinosaur สามารถโจมตี Trap ได้
- Dinosaur หยุดระหว่างการโจมตี

## 3. Dinosaur Attack
- Default attack interval = 1 วินาที
- Damage เป็น DPS แบบเป็นครั้ง ๆ ตาม Attack Interval
- T-Rex เป็นข้อยกเว้นตาม Stat ของมัน
- Dinosaur โจมตีเฉพาะ Plant ใน Lane ของตัวเอง

## 4. Plant Targeting / Projectile
- Plant เล็ง Enemy Dinosaur ที่ใกล้ที่สุดใน Lane ที่เกี่ยวข้อง
- Damage เกิดเมื่อ Projectile ชน
- Projectile เคลื่อนที่เป็นเส้นตรง
- เมื่อชน Enemy แล้ว Projectile หาย
- Projectile หายเมื่อออกนอก Map
- Projectile ทะลุ Plant และ Friendly Dinosaur
- Projectile ไม่ควรทะลุ Enemy ที่ถูกชน

## 5. Wave
- หนึ่ง Stage มี 3 Waves
- Wave 1 = 20 Normal Dinosaur
- Wave 2 = 25 Normal Dinosaur
- Wave 3 = 30 Normal Dinosaur + Boss ตาม Stage
- จำนวน Normal Dinosaur ไม่รวม Boss
- Lane หนึ่งมี Dinosaur พร้อมกันได้ไม่เกิน 10 ตัว
- Spawn แบบสุ่ม Lane และสุ่มช่วงเวลา
- Wave จะจบเมื่อ Spawn ครบและไม่มี Enemy เหลือในสนาม

## 6. Wave / Stage HP Scaling
Wave multiplier:
- Wave 1 = ×1
- Wave 2 = ×1.5
- Wave 3 = ×2.25

Stage multiplier:
- Stage 1 = ×1
- Stage 2 = ×2
- Stage 3 = ×4

Final HP:
`Base HP × Stage Multiplier × Wave Multiplier`

Wave/Stage scaling เพิ่มเฉพาะ HP

## 7. Wave Transition
เมื่อ Wave จบ:
- หยุด Gameplay
- แสดง Popup
- พัก 5 วินาที
- ระหว่าง Popup ห้ามวาง Plant
- Ancient Seed Production หยุด
- Plant Placement Cooldown หยุด
- Spawn หยุด
- จากนั้นเริ่ม Wave ถัดไป

## 8. Pause
Pause หยุด Gameplay Simulation ทั้งหมด:
- Movement
- Attack
- Projectile
- Cooldown
- Seed Production
- Spawn

UI / Input สำหรับควบคุม Pause ยังทำงาน

## 9. 2× Speed
เร่ง Gameplay Simulation เป็น 2×:
- Movement
- Attack timers
- Projectile
- Spawn
- Cooldown
- Seed Production

ไม่เร่ง UI / Input / Pause

## 10. Surrender
- ปุ่ม Surrender อยู่ด้านขวาบน
- ต้องมี Confirmation
- แจ้งชัดเจนว่าจะไม่ได้ Reward
- ยืนยันแล้ว Match เป็นโมฆะ
- ไม่มี DNA Reward จาก Match นั้น

## 11. Reward
Wave 1 และ Wave 2:
- Guaranteed 1 DNA
- Bonus random 1–3 DNA
- รวม 2–4 DNA

Wave 3:
- Guaranteed 3 DNA
- Bonus random 1–3 DNA
- รวม 4–6 DNA

Reward เป็นทุกครั้งที่ทำสำเร็จ ไม่ใช่ One-time Reward

ถ้าแพ้ก่อนจบ Wave แรก จะไม่ได้ Reward ของ Match นั้น
เมื่อเล่น Match ใหม่ ต้องเริ่ม Wave 1 ใหม่เสมอ

## 12. Ancient Seed
- เริ่มเกม = 100
- Maximum = 1000
- Seed Bloom ผลิต 50 ทุก 5 วินาที
- เมื่อ Seed Bloom ตาย Seed ที่กำลังผลิตหาย
- การฆ่า Dinosaur มีโอกาส 10% ได้ +25 Ancient Seed
- Storage ห้ามเกิน 1000

## 13. Refund
ถอน Plant:
- คืน 50% ของ Cost
- ปัดลง
- คืน Ancient Seed ทันที
- Plant ที่ถูกโจมตีจนเหลือ HP 1 แล้วถอน ยังคืน 50%
- Trap ที่ Trigger แล้วไม่มี Refund

## 14. Death
Entity ที่ตายหายออกจากสนาม ไม่มี Corpse
สามารถใช้ Effect เลือดแบบ Block สีแดงเป็น Placeholder VFX ได้

## 15. Current Advanced Mechanics
ยังไม่ใช่ Scope หลักของ M4:
- Ginkgo Cannon conversion
- Friendly Dinosaur
- Deinonychus jump
- Lane-changing Dinosaur
- Advanced Trap behavior
