const { supabaseUrl, supabaseAnonKey } =
  await fetch("/api/public-env").then(r => r.json());

const supabaseClient = window.supabase.createClient(supabaseUrl, supabaseAnonKey);
