const SUPABASE_URL = "https://biuohuzmtvclqqwsmgkp.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpdW9odXptdHZjbHFxd3NtZ2twIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3NDcyMDAsImV4cCI6MjA4MDMyMzIwMH0.POOa9mTwFTgOfoXeb1-9DNNbT-QaGla-W-5b6WXO12w";
window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// console.log("[supabase.js] loaded ✅");
// console.log("[supabase.js] window.supabase =", window.supabase);

// if (!window.supabase) {
//   console.error("[supabase.js] Supabase CDN NOT loaded. Check script order + Network tab.");
// }

// window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// console.log("[supabase.js] client created ✅", window.supabaseClient);
