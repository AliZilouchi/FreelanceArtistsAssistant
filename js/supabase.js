const { supabaseUrl, supabaseAnonKey } =
  await fetch("/api/public-env").then(r => r.json());

export const supabaseClient = window.supabase.createClient(supabaseUrl, supabaseAnonKey);
