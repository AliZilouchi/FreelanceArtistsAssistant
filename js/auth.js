async function login(email, password) {
  return await supabaseClient.auth.signInWithPassword({
    email,
    password
  });
}

async function getSession() {
  const { data } = await supabaseClient.auth.getSession();
  return data.session;
}

async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "login.html";
}
