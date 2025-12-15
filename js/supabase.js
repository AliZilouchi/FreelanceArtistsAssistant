const supabaseUrl = process.env.SUPABASE_URL
const supabaseKey = process.env.SUPABASE_ANON_KEY
const supabaseClient = window.supabase.createClient(
  supabaseUrl,
  supabaseKey
);
