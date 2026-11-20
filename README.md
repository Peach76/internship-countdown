# ARIA v4.2 — Invite-only Internship Dashboard

เวอร์ชันนี้ให้บริการทั้งหน้าเว็บและ Backend จาก **Render Web Service เพียงตัวเดียว** โดยใช้ Supabase PostgreSQL เป็นฐานข้อมูลถาวร และ Gemini API เป็น AI model

## สิ่งที่มีในเวอร์ชันนี้

- Dashboard: Countdown, Calendar, Work Log, Reports และ Weather
- ARIA: Gemini API + Function Calling สำหรับวันเวลา ปฏิทิน ความคืบหน้า บันทึกงาน และอากาศ
- Invite-only: สมัครสมาชิกได้เฉพาะผู้ที่มีรหัสเชิญจาก Admin
- บัญชีแยกกัน: Work Log และวันหยุดเก็บในฐานข้อมูลโดยผูกกับ `user_id`
- Admin: สร้าง/ยกเลิกรหัสเชิญ ปรับโควตารายบัญชี และระงับ/เปิดใช้งานสมาชิก
- Quota: จำกัดคำถามต่อบัญชี, จำนวนคำถามรวมต่อวัน และจำนวนครั้งที่เรียก Gemini API รวมทั้งระบบ
- Security: รหัสผ่าน hash ด้วย scrypt, session token เก็บเป็น hash, HttpOnly/SameSite cookie, HTTPS Secure cookie บน production, Helmet, rate limits และ same-origin checks
- Browser Voice: เลือกเสียงไทยจากเสียงที่มีในอุปกรณ์ พร้อมทดลองฟัง; ระบบจะไม่ใช้เสียงเริ่มต้นที่ระบุไม่ได้แทนโดยเงียบ ๆ
- Work Log ไม่เก็บสำเนาข้อมูลส่วนตัวใน localStorage อีกต่อไป; ฐานข้อมูลเป็นแหล่งข้อมูลหลัก

## โครงสร้าง

```text
aria-internship-dashboard/
├── public/
│   ├── index.html
│   ├── app.js
│   └── ui-v42.css
├── db/
│   └── schema.sql
├── server.js
├── package.json
├── .env.example
├── .gitignore
└── README.md
```

## ก่อน Deploy: เตรียม Supabase PostgreSQL

ARIA v4.2 ต้องมีฐานข้อมูล PostgreSQL สำหรับบัญชีสมาชิก, invite, sessions, Work Log, ปฏิทิน และสถิติโควตา

1. สร้างโปรเจกต์ที่ <https://supabase.com/dashboard> (Free plan ใช้ทดลองได้)
2. เปิดโปรเจกต์ แล้วกด **Connect**
3. เลือก **Session pooler** และคัดลอก connection string เต็ม
4. ตรวจว่าเป็นพอร์ต `5432` (อย่าเลือก Transaction pooler พอร์ต `6543` สำหรับ Backend ที่ทำงานค้างบน Render)
5. ใส่รหัสผ่านฐานข้อมูลแทน placeholder ใน connection string หากรหัสผ่านมีอักขระพิเศษ เช่น `@`, `#`, `?`, `/`, `&` ให้ URL-encode ก่อน
6. เก็บ connection string นี้ไว้สำหรับ Render Environment Variable ชื่อ `DATABASE_URL` เท่านั้น

Supabase แนะนำ Session pooler สำหรับ persistent backend ที่เชื่อมต่อจากเครือข่าย IPv4-only; เลือกค่าจากหน้า Connect โดยตรง ไม่ต้องเดา Pooler host หรือ username เอง: <https://supabase.com/docs/guides/database/connecting-to-postgres>

**ไม่ต้องรัน SQL เอง** เพราะ `server.js` จะสร้างตารางและ index ที่จำเป็นเมื่อเริ่มทำงานครั้งแรก ไฟล์ `db/schema.sql` เป็น schema reference สำหรับตรวจสอบเท่านั้น

> Free project ของ Supabase มีขนาดฐานข้อมูล 500 MB ต่อโปรเจกต์ และอาจถูก pause เมื่อมี activity ต่ำประมาณ 7 วัน; สามารถ Resume จาก Dashboard ได้ ข้อมูลยังอยู่ตามเงื่อนไขการกู้คืนของ Supabase: <https://supabase.com/docs/guides/platform/free-project-pausing> และ <https://supabase.com/pricing>

## Deploy บน Render (ใช้ Service เดียว)

**หากมี Web Service ของ ARIA v4.2 อยู่แล้ว ให้แก้ Service เดิม ไม่ต้องกด New Web Service ซ้ำ**

1. Commit ไฟล์ทั้งหมดใน Repository โดยต้องวาง `server.js` และ `package.json` ที่ Root และ `index.html`, `app.js`, `ui-v42.css` ใน `public/`
2. Render → เลือก Web Service เดิม → Settings → Build & Deploy
3. ตั้งค่า:
   - Runtime: Node
   - Root Directory: เว้นว่าง
   - Build Command: `npm install`
   - Start Command: `npm start`
4. ไปที่ Environment แล้วเพิ่มตัวแปรตามด้านล่าง
5. Save Changes / Deploy latest commit
6. ตรวจ Health: `https://YOUR-SERVICE.onrender.com/api/health`

### Environment Variables

| KEY | VALUE / วิธีตั้ง |
|---|---|
| `DATABASE_URL` | Supabase Session pooler connection string เต็ม |
| `GEMINI_API_KEY` | Gemini API Key จาก Google AI Studio |
| `GEMINI_MODEL` | `gemini-3.1-flash-lite` (ต้องเป็นโมเดลที่เปิดให้บัญชี/โควตาของคุณใช้งาน) |
| `ARIA_ADMIN_EMAIL` | อีเมล Admin ที่คุณควบคุม |
| `ARIA_ADMIN_PASSWORD` | รหัสผ่าน Admin แบบไม่ซ้ำที่ยาวอย่างน้อย 12 ตัวอักษร |
| `SESSION_SECRET` | สุ่มอย่างน้อย 32 ตัวอักษร ดูคำสั่งด้านล่าง |
| `ARIA_DEFAULT_DAILY_LIMIT` | `20` — โควตาเริ่มต้นของสมาชิกใหม่ |
| `ARIA_ADMIN_DAILY_LIMIT` | `100` — โควตาบัญชี Admin |
| `ARIA_GLOBAL_DAILY_LIMIT` | `60` — จำนวนคำถามรวมทุกบัญชีต่อวัน |
| `ARIA_GLOBAL_API_CALL_LIMIT` | `120` — จำนวนครั้งที่ Backend เรียก Gemini API รวมทุกบัญชีต่อวัน |
| `NODE_ENV` | `production` |

สร้าง `SESSION_SECRET` ใน Terminal (ไม่ต้องส่งให้ใคร):

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

ห้าม Commit `.env`, `DATABASE_URL`, `GEMINI_API_KEY`, `ARIA_ADMIN_PASSWORD` หรือ `SESSION_SECRET` ขึ้น GitHub

### การสร้าง Admin ครั้งแรก

- เมื่อฐานข้อมูลว่างและ Backend เริ่มต้นสำเร็จ ระบบจะสร้างบัญชี Admin จาก `ARIA_ADMIN_EMAIL` และ `ARIA_ADMIN_PASSWORD`
- เข้าหน้าเว็บด้วยอีเมล/รหัสผ่านนี้ แล้วเปิดเมนู **ผู้ดูแลระบบ**
- สร้าง Invite และส่งรหัสให้เพื่อน สมาชิกต้องกรอก Invite Code ตอนสมัคร
- รหัสเชิญแสดงให้ Admin คัดลอกตอนสร้างเท่านั้น; ฐานข้อมูลเก็บค่า hash ของรหัสเชิญ
- ถ้ามีบัญชีอีเมล Admin อยู่ในฐานข้อมูลแล้ว การเปลี่ยน `ARIA_ADMIN_PASSWORD` ใน Render จะไม่เขียนทับ password hash เดิมโดยอัตโนมัติ

## โควตาและค่า Gemini

- `ARIA_DEFAULT_DAILY_LIMIT`: จำกัดจำนวนคำถามต่อสมาชิกต่อวัน; Admin ปรับโควตาของสมาชิกแต่ละคนจากหน้า Admin ได้
- `ARIA_GLOBAL_DAILY_LIMIT`: จำกัดจำนวนคำถามรวมทั้งระบบต่อวัน
- `ARIA_GLOBAL_API_CALL_LIMIT`: จำกัดจำนวน HTTP API calls ที่ Backend จะส่งไป Gemini ต่อวัน รวมกรณีที่ AI เรียก Tool แล้วต้องถาม Gemini ซ้ำ
- ตัวเลขเหล่านี้เป็น **เพดานภายใน ARIA** ไม่ใช่โควตาที่ Google รับประกัน; Gemini Free Tier อาจมี rate limit/availability ต่ำกว่านี้และเปลี่ยนได้ ระบบจะแจ้งเมื่อ Gemini ตอบ 429
- การใช้งานของสมาชิกทุกคนใช้ Gemini API Key ของเจ้าของระบบ จึงใช้โควตา/เงื่อนไขผู้ให้บริการชุดเดียวกัน

## ความเป็นส่วนตัวของข้อมูล

- Work Log และปฏิทินเก็บบน PostgreSQL และ query โดย `user_id` ของ session ปัจจุบัน; สมาชิกอื่นเรียกดูข้อมูลของกันและกันผ่าน API ไม่ได้
- Admin dashboard แสดงอีเมล สถานะ โควตา และจำนวนการใช้ API เท่านั้น ไม่แสดง Work Log ของสมาชิก
- บทสนทนา ARIA อยู่ในหน่วยความจำของหน้าเว็บระหว่าง session และไม่ได้บันทึกเป็น history ในฐานข้อมูล
- ARIA จะอ่าน Work Log ให้ AI เฉพาะเมื่อผู้ใช้ติ๊กยินยอมในหน้า ARIA; tool response ส่งเฉพาะวันที่ หัวข้อ หมวดหมู่ ชั่วโมง และสถานะ ไม่ส่งรายละเอียดงาน
- ตำแหน่งเพื่อ Weather ขออนุญาตจาก Browser และส่งเฉพาะคำขออากาศ ไม่บันทึกพิกัดลงฐานข้อมูล
- **ห้ามบันทึกหรือส่งชื่อผู้ป่วย เลขประจำตัว ข้อมูลสุขภาพ หรือข้อมูลลับของโรงพยาบาลเข้า Work Log หรือ Gemini**
- Gemini API Free Tier อาจนำข้อมูลที่ส่งไปใช้ปรับปรุงผลิตภัณฑ์ตามเงื่อนไขของ Google; จึงควรใช้กับข้อมูลทั่วไปที่ไม่อ่อนไหวเท่านั้น ตรวจเงื่อนไขปัจจุบันก่อนเปิดให้ผู้อื่นใช้: <https://ai.google.dev/gemini-api/docs/pricing>

## เสียงผู้หญิง

Browser Speech API ให้รายการเสียงของอุปกรณ์ผ่าน `getVoices()` และแสดงชื่อ/ภาษา/URI แต่ไม่มี property มาตรฐานสำหรับระบุเพศเสียง จึงเลือกเสียงที่ชื่อบ่งชี้ว่าเป็นเสียงผู้หญิงเป็นค่าเริ่มต้นเมื่อพบ; ผู้ใช้สามารถเลือกและทดลองเสียงเองได้ หากเครื่องไม่มีเสียงผู้หญิงภาษาไทย จะไม่มีการแอบใช้ default voice ที่อาจเป็นผู้ชาย ระบบจะแจ้งให้เลือกเสียงอื่นหรือใช้ข้อความแทน ดู API: <https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisVoice>

หากต้องการเสียงผู้หญิงเหมือนกันทุกอุปกรณ์ ต้องต่อบริการ Cloud Text-to-Speech ภายหลัง ซึ่งอาจมีค่าใช้จ่าย

## Health Check และ Troubleshooting

เปิด `https://YOUR-SERVICE.onrender.com/api/health` ควรได้ `ok: true` และ `ready: true` พร้อม checks:

- `database: true` — ตรวจ `DATABASE_URL` และ Supabase Session pooler
- `geminiConfigured: true` — ตรวจว่ามี `GEMINI_API_KEY` (ไม่ได้ยืนยันว่า Key ใช้งานได้จริงจนกว่าจะทดสอบ Chat)
- `adminConfigured: true` — Admin bootstrap สำเร็จ
- `sessionSecretConfigured: true` — `SESSION_SECRET` ยาวอย่างน้อย 32 ตัวอักษร

ถ้า `database=false` ให้ตรวจ connection string, password URL encoding, port 5432 และ Supabase project status
ถ้า Server บอก `Cannot find package 'express'` ให้ตรวจ Build Command เป็น `npm install` ไม่ใช่ `echo "No build step required"`
ถ้า Browser แสดงหน้าเก่า ให้ hard refresh (Ctrl+F5) หลัง Render Deploy สำเร็จ

## Local development

```bash
cp .env.example .env
# ใส่ค่า local ใน .env; อย่า commit ไฟล์นี้
npm install
npm run dev
```

เปิด <http://localhost:10000>
