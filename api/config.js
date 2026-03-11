// Vercel Serverless Function: 환경 변수를 클라이언트에 전달
// Vercel 대시보드에서 SUPABASE_URL, SUPABASE_ANON_KEY 설정 필요

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate');

  const url = process.env.SUPABASE_URL || '';
  const key = process.env.SUPABASE_ANON_KEY || '';

  res.status(200).json({
    supabaseUrl: url,
    supabaseAnonKey: key
  });
};
