# Supabase로 로또 추첨 번호 저장하기

## 1. Supabase 프로젝트 만들기

1. [https://supabase.com](https://supabase.com) 접속 후 로그인
2. **New Project** → 조직 선택 → 프로젝트 이름 입력, 비밀번호 설정, 리전 선택 후 생성

---

## 2. 테이블 생성

Supabase 대시보드에서 **SQL Editor** 열고 아래 SQL 실행:

```sql
-- 로또 추첨 기록 테이블
create table public.lotto_draws (
  id uuid default gen_random_uuid() primary key,
  numbers integer[] not null,   -- 본 번호 6개 (예: {10,15,19,27,30,33})
  bonus integer not null check (bonus between 1 and 45),
  created_at timestamptz default now()
);

-- 인덱스: 최신순 조회용
create index lotto_draws_created_at_idx on public.lotto_draws (created_at desc);

-- RLS 활성화 (보안)
alter table public.lotto_draws enable row level security;

-- 정책: 누구나 INSERT 가능 (추첨 저장), SELECT는 누구나 가능 (내 기록 조회 등)
create policy "Allow insert for all"
  on public.lotto_draws for insert
  with check (true);

create policy "Allow select for all"
  on public.lotto_draws for select
  using (true);
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

이 프로젝트는 **Vercel 환경 변수**로 Supabase를 설정합니다. 코드에 키를 넣지 않아도 됩니다.

1. **Vercel 대시보드** → 본인 프로젝트 선택
2. **Settings** → **Environment Variables**
3. 아래 두 개 추가:

| Name | Value | 환경 |
|------|--------|------|
| `SUPABASE_URL` | `https://xxxxx.supabase.co` (Supabase Project URL) | Production, Preview, Development |
| `SUPABASE_ANON_KEY` | Supabase **anon public** 키 | Production, Preview, Development |

4. **Save** 후 필요하면 **Redeploy** (Deployments → ⋮ → Redeploy)

동작 방식:
- 페이지 로드 시 `/api/config`를 호출해 위 환경 변수 값을 받아옵니다.
- 추첨 완료 시 그 값으로 Supabase에 저장합니다.

**로컬에서 테스트:** 터미널에서 `vercel dev` 실행 후 접속하면 같은 환경 변수를 사용합니다. `.env.local`에 `SUPABASE_URL`, `SUPABASE_ANON_KEY`를 넣어도 됩니다.

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
- **CORS 에러**: Supabase는 기본적으로 브라우저 요청을 허용합니다. URL이 `https://xxxxx.supabase.co` 형식인지 확인.
- **테이블이 없어요**: 위 2번 SQL을 반드시 한 번 실행했는지 확인.
