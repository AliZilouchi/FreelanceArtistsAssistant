async function uploadArtifactMainImage({ artifactId, file }) {
  const { data: u } = await supabaseClient.auth.getUser();
  if (!u.user) throw new Error("Not logged in");

  const userId = u.user.id;

  const ext = file.name.split(".").pop()?.toLowerCase() || "jpg";
  const path = `users/${userId}/artifacts/${artifactId}/main.${ext}`;

  const { error } = await supabaseClient
    .storage
    .from("artifacts")
    .upload(path, file, { upsert: true, contentType: file.type });

  if (error) throw error;

  return path; // store this in artifacts.main_image
}



const imagePath = await uploadArtifactMainImage({ artifactId, file });
await fetch("https://YOURPROJECT.functions.supabase.co/artifact-upsert", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${(await supabaseClient.auth.getSession()).data.session.access_token}`,
  },
  body: JSON.stringify({ id: artifactId, main_image: imagePath }),
});

function getPublicImageUrl(path) {
  return supabaseClient.storage.from("artifacts").getPublicUrl(path).data.publicUrl;
}

