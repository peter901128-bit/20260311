# Supabase로 로또 추첨 번호 저장하기

## 1. Supabase 프로젝트 만들기

1. [https://supabase.com](https://supabase.com) 접속 후 로그인
2. **New Project** → 조직 선택 → 프로젝트 이름 입력, 비밀번호 설정, 리전 선택 후 생성

---

## 2. 테이블 생성

Supabase 대시보드에서 **SQL Editor** 열고 아래 SQL **전체 복사** → 붙여넣기 → **Run** 실행.

- 테이블이 **없으면** 만들고, **이미 있으면** 건너뜁니다. 여러 번 실행해도 오류 나지 않습니다.

```sql
-- 테이블 (없을 때만 생성)
create table if not exists public.lotto_draws (
  id uuid default gen_random_uuid() primary key,
  numbers integer[] not null,
  bonus integer not null check (bonus between 1 and 45),
  created_at timestamptz default now()
);

-- 인덱스 (없을 때만)
create index if not exists lotto_draws_created_at_idx on public.lotto_draws (created_at desc);

-- RLS 활성화
alter table public.lotto_draws enable row level security;

-- 정책 (있으면 삭제 후 다시 생성)
drop policy if exists "Allow insert for all" on public.lotto_draws;
create policy "Allow insert for all"
  on public.lotto_draws for insert with check (true);

drop policy if exists "Allow select for all" on public.lotto_draws;
create policy "Allow select for all"
  on public.lotto_draws for select using (true);
```

---

## 3. API 키 확인

1. Supabase 대시보드 → **Project Settings** (왼쪽 하단 톱니바퀴)
2. **API** 메뉴
3. 아래 두 값 복사:
   - **Project URL** (예: `https://xxxxx.supabase.co`)
   - **anon public** 키 (예: `eyJhbGc...`)

---

## 4. Vercel 배포 시 – 환경 변수로 설정 (권장)

Vercel에 배포했다면 **환경 변수**만 넣으면 됩니다. 코드 수정 없이 가능합니다.

1. **Vercel 대시보드** → 본인 프로젝트 선택
2. **Settings** → **Environment Variables**
3. 아래 두 개 추가:

| Name | Value | 환경 |
|------|--------|------|
| `SUPABASE_URL` | `https://xxxxx.supabase.co` (Supabase Project URL) | Production, Preview, Development |
| `SUPABASE_ANON_KEY` | Supabase **anon public** 키 | Production, Preview, Development |

4. **Save** 후 **Redeploy** (Deployments → ⋮ → Redeploy)

로컬 테스트: `vercel dev` 실행 후 접속하거나, `.env.local`에 같은 변수 추가.

---

## 5. 저장되는 데이터 형식

| 컬럼     | 타입        | 설명                    |
|----------|-------------|-------------------------|
| id       | uuid        | 자동 생성               |
| numbers  | integer[]   | 본 번호 6개 배열        |
| bonus    | integer     | 보너스 번호 (1~45)      |
| created_at | timestamptz | 추첨 시각 (자동)      |

한 번에 여러 세트를 뽑으면 **세트마다 1행**씩 저장됩니다.

---

## 6. 저장된 데이터 조회 (SQL 예시)

Supabase **SQL Editor** 또는 **Table Editor**에서:

```sql
-- 최근 추첨 10건
select numbers, bonus, created_at
from public.lotto_draws
order by created_at desc
limit 10;
```

---

## 7. 문제 해결

- **저장이 안 돼요**: 브라우저 개발자도구(F12) → Console 탭에서 에러 확인. URL/키 오타, RLS 정책 확인.
- **몇 개만 쌓이다가 갑자기 안 쌓여요**  
  - 화면에 **"저장 실패: …"** 메시지가 뜨면 그 문구를 확인하세요. (예: RLS 정책 위반, 네트워크 오류 등)  
  - **로컬에서 `index.html`만 연 경우** `/api/config`가 없어 설정이 안 불러와질 수 있습니다. **Vercel에 배포된 URL**에서 열거나, 로컬에서는 `vercel dev` 실행 후 접속하세요.  
  - Supabase 대시보드 → Table Editor → **RLS policy**: INSERT용 정책이 **"Allow insert for all"** (with check true) 인지 확인. 위 2번 SQL을 다시 실행해도 됩니다.
- **CORS 에러**: Supabase는 기본적으로 브라우저 요청을 허용합니다. URL이 `https://xxxxx.supabase.co` 형식인지 확인.
- **테이블이 없어요**: 위 2번 SQL을 반드시 한 번 실행했는지 확인.
