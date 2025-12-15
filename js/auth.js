import { supabaseClient } from "./supabase.js";

export async function login(email, password) {
  return await supabaseClient.auth.signInWithPassword({ email, password });
}

export async function getSession() {
  const { data } = await supabaseClient.auth.getSession();
  return data.session;
}

export async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "login.html";
}
