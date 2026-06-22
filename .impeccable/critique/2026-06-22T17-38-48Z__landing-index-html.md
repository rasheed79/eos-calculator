---
target: landing/index.html
total_score: 27
p0_count: 1
p1_count: 3
timestamp: 2026-06-22T17-38-48Z
slug: landing-index-html
---
## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | زر الحساب لا يعطي feedback أثناء التنفيذ |
| 2 | Match System / Real World | 4 | عربي RTL، مصطلحات صحيحة، ممتاز |
| 3 | User Control and Freedom | 3 | إعادة الإدخال حرة |
| 4 | Consistency and Standards | 3 | ثلاثة gradients متطابقة تلغي التمييز |
| 5 | Error Prevention | 2 | months يقبل >11 بدون validation |
| 6 | Recognition Rather Than Recall | 4 | كل الحقول ظاهرة، labels واضحة |
| 7 | Flexibility and Efficiency | 3 | Enter لا يشغّل الحساب |
| 8 | Aesthetic and Minimalist Design | 2 | بطاقات features مكررة |
| 9 | Error Recovery | 1 | alert() بدائي |
| 10 | Help and Documentation | 2 | لا شرح لنسب الاستقالة |

Total: 27/40

## P0
- Identical card grids (absolute ban): 3 feature cards icon+heading+text

## P1
- alert() validation — inline errors needed
- IBM Plex Sans — reflex-reject font
- Triple gradient: hero + button + result all identical

## P2
- Enter key doesn't trigger calculation
- months accepts >11 silently

## P3
- Cloudflare token = YOUR_CF_TOKEN (dead analytics)
- og:image missing
- script in head without defer
