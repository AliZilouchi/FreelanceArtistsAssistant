(async () => {
  const supabaseClient = window.supabaseClient;
  if (!supabaseClient) {
    console.error("[guard] supabaseClient not found. Check script order.");
    return;
  }

  const { data, error } = await supabaseClient.auth.getSession();
  if (error) console.error("[guard] getSession error:", error);

  if (!data.session) {
    window.location.href = "login.html";
  }
})();
