# DinoBloom — AI Agent Context

## Purpose
เอกสารชุดนี้ใช้สำหรับส่งต่อ Project DinoBloom ให้ AI Agent ตัวอื่นพัฒนาต่อ โดยให้ Agent ใช้เอกสารร่วมกับ Project จริงเป็นหลัก

## Project
- Engine: Godot 4.7
- Language: GDScript
- Game: เกมวางพืชต่อสู้กับไดโนเสาร์บน Grid
- Board: 5 แถว (Lanes) × 8 คอลัมน์
- Dinosaur เดินจากขวาไปซ้าย
- Plant ใช้พื้นที่ 1 Grid
- Dinosaur และ Plant สามารถอยู่ใน Grid เดียวกันได้เมื่อเกิดการต่อสู้

## Current Handoff
Project ที่ส่งมาพร้อม Context นี้มีระบบและไฟล์ของ M1–M3 และมี implementation ของระบบ M4 บางส่วนอยู่แล้ว เช่น WaveManager, SpawnManager และ MatchManager

**ห้ามสรุปจากเอกสารนี้เพียงอย่างเดียวว่า M4 เสร็จสมบูรณ์** ต้องตรวจ Project จริงและทดสอบก่อน

## Source of Truth
ให้ยึดลำดับดังนี้:
1. Project files จริง
2. Data `.tres` และ Scene `.tscn` ที่ใช้งานจริง
3. เอกสาร Context นี้
4. ข้อสันนิษฐานของ Agent — ใช้ได้เฉพาะเมื่อไม่มีข้อมูลข้างต้น

## ก่อนแก้ Code
1. ตรวจไฟล์และ Dependency ที่มีอยู่
2. อ่าน `03_ARCHITECTURE.md`
3. อ่าน `04_CURRENT_STATUS.md`
4. ตรวจระบบเดิมก่อนสร้างระบบใหม่
5. แก้แบบ Minimal และรักษา Data-driven Architecture

## กฎสำคัญ
- อย่าสร้างระบบซ้ำกับของเดิมโดยไม่จำเป็น
- อย่าเปลี่ยนชื่อ Asset โดยพลการ
- อย่า Hard-code Base Stat ใน Entity ถ้ามี Data Resource อยู่แล้ว
- อย่าลบไฟล์เพื่อแก้ Error โดยไม่ตรวจ Dependency
- หลังแก้ต้องทดสอบ Parser และ Runtime

## เอกสารในชุดนี้
- `01_GAMEPLAY_RULES.md` — กติกาเกม
- `02_DATA_AND_BALANCE.md` — ตัวเลขและ Data ที่ตกลงไว้
- `03_ARCHITECTURE.md` — แนวทางโครงสร้างระบบ
- `04_CURRENT_STATUS.md` — สถานะจาก Project ล่าสุดที่ส่งต่อ
- `05_MILESTONE_ROADMAP.md` — แผน Milestone

รายละเอียดเชิงลึกที่ไม่จำเป็นต่อการทำงานปัจจุบันไม่ควรถูกเติมเอง ให้ตรวจจาก Project หรือถามผู้พัฒนาเมื่อจำเป็น
