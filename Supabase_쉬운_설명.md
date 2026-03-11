# Supabase로 로또 번호 저장하기 (처음 쓰는 분용)

전혀 몰라도 괜찮아요. 순서대로만 하면 됩니다.

---

## Supabase가 뭐예요?

**인터넷에 데이터를 저장해 주는 서비스**예요.  
로또 추첨기에서 뽑은 번호를 “저장소”에 쌓아 두면, 나중에 다시 꺼내 볼 수 있어요.  
이 프로젝트는 그 저장소로 **Supabase**를 쓰도록 되어 있어요.

---

## 전체 흐름 (3단계)

1. **Supabase 가입하고**, 저장할 **방(테이블)** 만들기  
2. **키 2개** 복사해서 **Vercel에 넣기**  
3. **사이트에서 번호 뽑기** → 자동으로 Supabase에 저장됨  

끝이에요.

---

## 1단계: Supabase 가입 & 테이블 만들기

### 1-1. 가입

1. 브라우저에서 **https://supabase.com** 접속
2. **Start your project** (또는 Sign in) 클릭
3. GitHub로 로그인하거나 이메일로 가입

### 1-2. 새 프로젝트 만들기

1. **New Project** 버튼 클릭
2. **Name**: 아무 이름 (예: lotto)
3. **Database Password**: 비밀번호 하나 정해서 입력 (잊어버리면 안 됨)
4. **Region**: 가까운 곳 선택 (예: Northeast Asia)
5. **Create new project** 클릭  
   → 1~2분 기다리면 프로젝트가 만들어짐

### 1-3. “저장 방” 만들기 (테이블)

1. 왼쪽 메뉴에서 **SQL Editor** 클릭
2. **New query** 클릭
3. 아래 SQL을 **통째로 복사**해서 빈 칸에 **붙여넣기**
4. 오른쪽 아래 **Run** (실행) 클릭

```sql
-- 테이블이 없을 때만 만들기 (이미 있으면 넘어감)
create table if not exists public.lotto_draws (
  id uuid default gen_random_uuid() primary key,
  numbers integer[] not null,
  bonus integer not null check (bonus between 1 and 45),
  created_at timestamptz default now()
);

create index if not exists lotto_draws_created_at_idx on public.lotto_draws (created_at desc);

alter table public.lotto_draws enable row level security;

drop policy if exists "Allow insert for all" on public.lotto_draws;
create policy "Allow insert for all"
  on public.lotto_draws for insert with check (true);

drop policy if exists "Allow select for all" on public.lotto_draws;
create policy "Allow select for all"
  on public.lotto_draws for select using (true);
```

5. **Success**가 나오면 성공.  
   → 테이블이 이미 있어도 이 SQL은 **오류 없이** 끝나요. 그다음 2단계(키 복사)로 가면 됩니다.

---

## 2단계: 키 2개 복사하기

Supabase에서 **이 프로젝트에 접속할 수 있는 주소**와 **비밀번호 같은 키**를 줍니다.  
이 두 개를 Vercel에 알려 주면, 우리 사이트가 Supabase에 저장할 수 있어요.

1. Supabase 왼쪽 아래 **톱니바퀴(Project Settings)** 클릭
2. **API** 메뉴 클릭
3. 아래 두 값을 **각각 복사** (나중에 Vercel에 붙여넣을 거예요)
   - **Project URL**  
     예: `https://abcdefghijk.supabase.co`
   - **anon public** (키가 길게 나옴)  
     예: `eyJhbGciOiJIUzI1NiIsInR5cCI6...` (처음~끝까지 전부)

---

## 3단계: Vercel에 키 넣기

우리 사이트가 Vercel에 배포되어 있으니까, Vercel한테 “Supabase 주소랑 키가 이거야”라고 알려 주는 단계예요.

1. **https://vercel.com** 접속 후 로그인
2. **이 로또 프로젝트** 클릭
3. 위쪽 메뉴에서 **Settings** 클릭
4. 왼쪽에서 **Environment Variables** 클릭
5. **Name**에 `SUPABASE_URL` 입력  
   **Value**에 아까 복사한 **Project URL** 붙여넣기  
   → **Save** 클릭
6. 다시 **Name**에 `SUPABASE_ANON_KEY` 입력  
   **Value**에 아까 복사한 **anon public** 키 붙여넣기  
   → **Save** 클릭
7. **Redeploy** 한 번 하기  
   - **Deployments** 탭 → 맨 위 배포 오른쪽 **⋮** → **Redeploy**  
   - 그래야 방금 넣은 키가 적용돼요.

---

## 4단계: 확인하기

1. Vercel에 배포된 **우리 사이트 주소**로 접속
2. **레버 당겨서** 번호 뽑기
3. Supabase로 돌아가서  
   - 왼쪽 **Table Editor** 클릭  
   - **lotto_draws** 테이블 클릭  
4. 방금 뽑은 **numbers**, **bonus**, **created_at**이 한 줄로 보이면 **저장 성공**이에요.

---

## 정리

| 단계 | 하는 일 |
|------|--------|
| 1 | Supabase 가입 → 프로젝트 생성 → SQL로 `lotto_draws` 테이블 만들기 |
| 2 | Supabase에서 Project URL, anon public 키 복사 |
| 3 | Vercel에서 환경 변수 `SUPABASE_URL`, `SUPABASE_ANON_KEY` 로 넣고 Redeploy |
| 4 | 사이트에서 번호 뽑기 → Table Editor에서 저장된 거 확인 |

이렇게 하면 **로또 번호가 Supabase에 자동으로 저장**됩니다.  
더 자세한 내용은 `SUPABASE_설정.md`를 보면 돼요.

---

## 저장이 안 될 때 체크할 것

1. **Vercel 환경 변수**  
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY` 두 개 다 넣었는지  
   - 값을 넣은 뒤 **Redeploy** 했는지 (한 번 꼭 해야 함)

2. **사이트 주소**  
   - **Vercel에 배포된 주소**로 접속해서 뽑았는지 (로컬 파일만 열어서 뽑으면 저장 안 됨)

3. **Supabase Table Editor**  
   - 왼쪽 **Table Editor** → **lotto_draws** 테이블이 보이는지  
   - 보인다면 테이블은 준비된 거라, 위 1·2번을 확인하면 됨
