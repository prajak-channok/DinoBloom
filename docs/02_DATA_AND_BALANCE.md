# DinoBloom — Data & Balance

## Base Reference
Plant Base HP มาตรฐานที่ตกลง:
- Seed Bloom HP = 50
- Seed Bloom ATK = 0

Dinosaur Base Reference:
- Dryosaurus HP = 200
- Dryosaurus ATK = 15
- Dryosaurus Attack Interval = 1 sec

## Stage
- Stage 1 HP multiplier = ×1
- Stage 2 HP multiplier = ×2
- Stage 3 HP multiplier = ×4

## Wave
- W1 = ×1
- W2 = ×1.5
- W3 = ×2.25

## Dinosaur — Stage 1 Scope

| Dinosaur | Base HP | ATK | Attack Interval | Move Speed | Role |
|---|---:|---:|---:|---:|---|
| Dryosaurus | 200 | 15 | 1.0s | 40 px/s | Basic |
| Velociraptor | 150 | 10 | 1.0s | 80 px/s | Fast |
| Triceratops | 400 | 15 | 3s | 30 px/s | Tank |
| T-Rex | 1000 | 200 | 4.0s | 20 px/s | Boss |

T-Rex:
- Boss
- Cannot be converted by Ginkgo Cannon
- Has Boss HP Bar

## Final HP examples — Stage 1

| Dinosaur | Wave 1 | Wave 2 | Wave 3 |
|---|---:|---:|---:|
| Dryosaurus | 200 | 300 | 450 |
| Velociraptor | 150 | 225 | 337.5 |
| Triceratops | 400 | 600 | 900 |
| T-Rex | — | — | 2250 |

## Plant Data currently present

### Seed Bloom
- HP 50
- Cost 50
- Placement Cooldown 5s
- Production 50
- Production Interval 5s

### Thorn Fern
- HP 75
- ATK 25
- Attack Interval 2s
- Cost 100
- Placement Cooldown 7s

Other Plants are defined by the game design but are not all present as complete runtime Data in the current Project. Do not assume that a Plant is implemented merely because an image exists.

## Data Rule
Base values belong in `.tres` Data Resources.
Runtime scaling must be calculated by gameplay systems.
Do not modify Base HP inside `.tres` for Wave scaling.
