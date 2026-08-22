# DinoBloom — Current Status / Handoff

## Current Milestone
Project อยู่ในช่วง **M5 implementation — Progression / Upgrade**
M4 (Match & Wave) ผ่าน Acceptance Criteria ครบแล้ว ถือว่า Complete

## What M4 Delivered (พร้อมใช้เป็นฐานของ M5)
- 3-Wave Match ต่อ Stage ทำงานครบ (Start → Wave 1–3 → Win/Lose → Reward)
- DNA Reward flow ทำงานตาม Wave/Surrender rule แล้ว — M5 ใช้ DNA นี้เป็นต้นทุน Upgrade ได้เลย
- Ancient Seed, Placement, Pause, 2×, Surrender เสถียรแล้ว ไม่ต้องแตะใน M5 เว้นแต่มีเหตุผลเฉพาะ

## Existing Plant Data (ฐานสำหรับ Upgrade)
มี: Seed Bloom, Thorn Fern — มี Base HP/ATK/Cost ใน `.tres` แล้ว (ดู `02_DATA_AND_BALANCE.md`)
ยังไม่มี Level field ใน Plant Data — ต้องเพิ่มโครงสร้างรองรับ Level 0–5 ตาม M5 scope
ยังไม่ควรสรุปว่า Plant ตัวอื่น (Baobab, Ginkgo ฯลฯ) พร้อมใช้ เพราะยังไม่มี Data/Script รองรับ (อยู่ scope M6)

## Existing Related Scripts
- `upgrade_scene.gd` — มี Scene foundation จาก M1 แล้ว แต่ Upgrade Level logic จริงยังไม่ implement (เป็น M5 scope)
- `save_manager.gd` — รองรับ DNA/Stage progression อยู่แล้ว ต้องตรวจว่ารองรับ Plant Level persistence ไหม ก่อนเริ่ม M5

## Handoff Rule
สถานะด้านบนเป็นภาพจากไฟล์ล่าสุดที่ส่งมา ไม่ใช่ผลจากการรัน Project ในเครื่องของ Agent
Agent ต้อง: เปิด Project → ตรวจ Parser Errors → Run → ตรวจว่า M4 flow ยังทำงานถูกต้อง (regression check) → เริ่มตรวจ M5 systems → อัปเดตไฟล์นี้หลังยืนยันสถานะจริง

## Immediate Next Step
เริ่ม M5: ทำ Plant Unlock + Upgrade Level 0–5 (ดู `docs/06_ACCEPTANCE_CRITERIA.md` section M5)
ลำดับแนะนำ: ตรวจ `upgrade_scene.gd` ที่มีอยู่ก่อน → ตรวจ Data structure รองรับ Level ไหม → ค่อยทำ UI/Logic ต่อ อย่าสร้าง Upgrade Scene ใหม่ซ้ำของเดิม

> หมายเหตุ: รายละเอียดการแก้บั๊ก/Verification/Dead code cleanup ของ M4 ทั้งหมด ย้ายไปเก็บที่ `docs/changelog/2026-08-21.md` แล้ว — ไฟล์นี้แสดงเฉพาะสถานะที่ยัง valid ณ ตอนนี้ อัปเดตทับ (ไม่ต่อท้ายสะสม) ทุกครั้งที่สถานะเปลี่ยน
