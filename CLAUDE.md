# DinoBloom — Project Instructions

## Project
- Engine: Godot 4.7 / GDScript
- Game: วางพืชต่อสู้ไดโนเสาร์บน Grid 5 Lanes × 8 คอลัมน์ (Dinosaur เดินขวา→ซ้าย)
- โครงสร้างหลัก: `assets/`, `data/` (`.tres`), `scenes/` (`.tscn`), `scripts/` (`.gd`)

## Source of Truth (ลำดับความเชื่อถือ)
1. Project files จริง (`.gd` / `.tscn`)
2. `.tres` Data Resources ที่ใช้งานจริง
3. เอกสารใน `docs/`
4. ข้อสันนิษฐานของ Agent — ใช้เมื่อไม่มีข้อมูลข้างต้นเท่านั้น

ห้ามสรุปว่าอะไร "เสร็จ" จากเอกสารเพียงอย่างเดียว ต้องตรวจ Project จริงก่อนเสมอ

## กฎสำคัญ (คุมทุก task)
- อย่าสร้างระบบซ้ำกับของเดิมโดยไม่ตรวจก่อน
- อย่า Hard-code Base Stat ใน Entity ถ้ามี Data Resource (`.tres`) อยู่แล้ว
- อย่าเปลี่ยนชื่อ Asset โดยพลการ
- อย่าลบไฟล์เพื่อแก้ Error โดยไม่ตรวจ Dependency ก่อน
- แก้แบบ Minimal, รักษา Data-driven Architecture (`.tres` = balance, `.gd` = behavior, `.tscn` = composition)
- หลังแก้โค้ดต้องทดสอบ Parser + Runtime อย่างน้อยแบบ headless ก่อนถือว่าเสร็จ

## ก่อนแก้ Code — อ่านแบบมีเงื่อนไข (ห้ามอ่านทุกไฟล์ทุกครั้ง)
อ่านเฉพาะไฟล์ที่เกี่ยวกับระบบที่กำลังแก้จริงๆ ตามตารางนี้ ไม่ใช่อ่านทั้งหมดเป็นกิจวัตร:

| งานที่ทำ | ไฟล์ที่ควรอ่าน |
|---|---|
| แก้/เพิ่มระบบ Combat, Wave, Movement | `docs/01_GAMEPLAY_RULES.md` |
| แก้ Stat, Balance, ตัวเลข | `docs/02_DATA_AND_BALANCE.md` + `.tres` จริงที่เกี่ยวข้อง |
| ไม่แน่ใจว่าไฟล์/ระบบไหนรับผิดชอบอะไร | `docs/03_ARCHITECTURE.md` |
| ต้องรู้ว่าตอนนี้ระบบไหนพร้อม/ไม่พร้อมใน Milestone ปัจจุบัน | grep หา section ที่เกี่ยวข้องใน `docs/04_CURRENT_STATUS.md` (อย่าอ่านทั้งไฟล์ถ้าไม่จำเป็น) |
| ต้องรู้ขอบเขต Milestone ปัจจุบัน/ถัดไป | `docs/05_MILESTONE_ROADMAP.md` |
| ต้องเช็คว่างานผ่านเกณฑ์หรือยัง | grep หา section ของ Milestone ปัจจุบันใน `docs/06_ACCEPTANCE_CRITERIA.md` เท่านั้น |
| ต้องดูเหตุผล/root cause ของบั๊กที่เคยแก้ | `docs/changelog/` เฉพาะไฟล์วันที่ล่าสุดที่เกี่ยวข้อง |

ถ้า task เล็กและอยู่ในระบบที่ยังไม่เริ่มทำ (เช่น Scene ที่ยังไม่มี logic) ไม่จำเป็นต้องอ่าน `04_CURRENT_STATUS.md` เลย เพราะไฟล์นั้นสรุปสถานะของ Milestone ที่กำลังทำอยู่เท่านั้น

## เอกสารในชุดนี้ (`docs/`)
- `01_GAMEPLAY_RULES.md` — กติกาเกม (เสถียร อ่านเมื่อแตะ Gameplay)
- `02_DATA_AND_BALANCE.md` — ตัวเลข Balance (sync กับ `.tres` เสมอ ถ้าไม่ตรงให้เชื่อ `.tres`)
- `03_ARCHITECTURE.md` — แผนที่ระบบ/ไฟล์ (ห้ามใส่ Log/วันที่ในไฟล์นี้ — ย้ายไป changelog แทน)
- `04_CURRENT_STATUS.md` — สถานะปัจจุบันเท่านั้น (ห้ามใส่หัวข้อ "Resolved"/ประวัติ — ย้ายไป changelog)
- `05_MILESTONE_ROADMAP.md` — แผน Milestone ทั้งหมดแบบสรุปสั้น
- `06_ACCEPTANCE_CRITERIA.md` — Checklist ตรวจรับต่อ Milestone
- `changelog/YYYY-MM-DD.md` — บันทึกละเอียดของแต่ละ session/วัน (ไม่รวมไฟล์เดียวข้ามวัน)

รายละเอียดเชิงลึกที่ไม่จำเป็นต่องานปัจจุบันไม่ควรถูกเติมเอง — ให้ตรวจจาก Project หรือถามผู้พัฒนาเมื่อจำเป็น
