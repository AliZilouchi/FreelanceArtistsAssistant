// js/lang.js



const translations = {
      fa: {
        feature1Title: 'مدیریت پروژه',
        feature1Text: 'ردیابی پروژه‌ها و ددلاین‌ها',
        feature2Title: 'مالی هوشمند',
        feature2Text: 'صورتحساب و پیگیری درآمد',
        feature3Title: 'مدیریت مشتری',
        feature3Text: 'سازماندهی اطلاعات مشتریان'
      },
      en: {
        feature1Title: 'Project Management',
        feature1Text: 'Track projects and deadlines',
        feature2Title: 'Smart Finance',
        feature2Text: 'Invoicing and income tracking',
        feature3Title: 'Client Management',
        feature3Text: 'Organize client information'
      }
    };

function getInitialLang() {
  return localStorage.getItem("lang")
    || (navigator.language.startsWith("fa") ? "fa" : "en");
}

let currentLang = getInitialLang();

function switchLanguage(lang) {
  currentLang = lang;
  localStorage.setItem("lang", lang);

  const html = document.documentElement;
  html.setAttribute("lang", lang);
  html.setAttribute("dir", lang === "fa" ? "rtl" : "ltr");

  document.querySelectorAll(".lang-btn").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });

  updateContent();
}

function updateContent() {
  const elements = document.querySelectorAll("[data-i18n]");
  elements.forEach(el => {
    const key = el.getAttribute("data-i18n");
    if (translations[currentLang]?.[key]) {
      el.textContent = translations[currentLang][key];
    }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  switchLanguage(currentLang);
});

window.switchLanguage = switchLanguage;
