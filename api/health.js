export default function handler(req, res) {
  res.status(200).json({
    ok: true,
    now: new Date().toISOString(),
    version: process.env.VERCEL_GIT_COMMIT_SHA?.slice(0, 7) || 'dev'
  });
}
