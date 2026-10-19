# cloud-lab


## 2026-10-19 Server slow, website returns 200 OK
- Symptom: website works, but server is slow (high load average)
- How I found it: `top` showed 5 `dd` processes using ~40% CPU each
- Fix: `sudo pkill dd`
- Lesson: if a server is slow, run `top` first
