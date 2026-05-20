(function () {
  const storageKey = "cloudtape-language";

  const translations = {
    en: {
      "meta.title": "CloudTape - iCloud Drive Music Player",
      "meta.description": "CloudTape is a lightweight iOS music player for owned audio files stored in iCloud Drive or the Files app.",
      "nav.home": "Home",
      "nav.privacy": "Privacy",
      "nav.privacyPolicy": "Privacy Policy",
      "nav.support": "Support",
      "footer.tagline": "Made for owned music libraries.",
      "home.eyebrow": "iCloud Drive music player",
      "home.tagline": "A simple iOS player for the music files you already own.",
      "home.intro": "CloudTape plays audio from iCloud Drive and the Files app with a native, fast, and private iOS experience. It is made for personal music libraries, not subscriptions, feeds, or recommendation systems.",
      "home.featuresEyebrow": "Features",
      "home.featuresTitle": "Built for a personal library.",
      "home.feature1Title": "iCloud Drive first",
      "home.feature1Body": "Choose a folder from iCloud Drive or Files and keep your music where you already manage it.",
      "home.feature2Title": "Native playback",
      "home.feature2Body": "Uses iOS media controls, background audio, lock screen controls, and a focused SwiftUI interface.",
      "home.feature3Title": "Fast and quiet",
      "home.feature3Body": "No accounts, no analytics, no ads, and no heavy web stack. Just your files and playback controls.",
      "home.screenshotsEyebrow": "Screenshots",
      "home.screenshotsTitle": "Real screenshots from the demo library.",
      "home.linksTitle": "Links",
      "home.githubLink": "GitHub repository",
      "privacy.title": "Privacy Policy",
      "privacy.updated": "Last updated: May 20, 2026",
      "privacy.overviewTitle": "Overview",
      "privacy.overviewBody": "CloudTape is designed as a private, local-first music player for audio files selected from iCloud Drive or the iOS Files app.",
      "privacy.dataTitle": "Data Collection",
      "privacy.dataBody": "CloudTape does not include analytics, advertising SDKs, account systems, or third-party tracking. The app does not sell personal data.",
      "privacy.fileTitle": "File Access",
      "privacy.fileBody": "CloudTape only accesses folders and files that you choose through iOS document picker permissions. The app may store a security-scoped bookmark so it can reopen the selected folder later.",
      "privacy.contactTitle": "Contact",
      "privacy.contactBody": "For privacy questions, use the",
      "privacy.supportPage": "Support page",
      "privacy.contactSuffix": "for contact details.",
      "support.title": "Support",
      "support.intro": "CloudTape is a lightweight iOS player for owned music files stored in iCloud Drive or the Files app.",
      "support.checksTitle": "Common Checks",
      "support.check1": "Confirm the selected folder is available in iCloud Drive or Files.",
      "support.check2": "Wait for iCloud files to download locally before playback.",
      "support.check3": "If folder access stops working, choose the folder again in the app.",
      "support.check4": "Make sure the file format is supported by iOS playback.",
      "support.contactTitle": "Contact",
      "support.contactBody": "For support, open an issue in the GitHub repository or contact the developer through the App Store support channel after release."
    },
    ja: {
      "meta.title": "CloudTape - iCloud Drive 音楽プレイヤー",
      "meta.description": "CloudTape は、iCloud Drive や Files アプリにある自分の音源を再生する軽量な iOS 音楽プレイヤーです。",
      "nav.home": "ホーム",
      "nav.privacy": "プライバシー",
      "nav.privacyPolicy": "プライバシーポリシー",
      "nav.support": "サポート",
      "footer.tagline": "自分の音源を持つ人のための音楽プレイヤー。",
      "home.eyebrow": "iCloud Drive 音楽プレイヤー",
      "home.tagline": "自分の音源を、iPhone でシンプルに。",
      "home.intro": "CloudTape は、iCloud Drive や Files アプリに保存した音楽ファイルを、軽く、速く、プライベートに再生する iOS プレイヤーです。サブスクやおすすめではなく、手元の音楽ライブラリを大切にしたい人のために作られています。",
      "home.featuresEyebrow": "特徴",
      "home.featuresTitle": "個人の音楽ライブラリに寄り添う設計。",
      "home.feature1Title": "iCloud Drive から再生",
      "home.feature1Body": "iCloud Drive や Files のフォルダを選ぶだけ。普段管理している場所のまま音楽を扱えます。",
      "home.feature2Title": "Native iOS 体験",
      "home.feature2Body": "バックグラウンド再生、ロック画面、Control Center に対応。SwiftUI らしい自然な操作感です。",
      "home.feature3Title": "軽く、静かに",
      "home.feature3Body": "アカウント、広告、分析、重い Web 依存はありません。自分のファイルと再生操作だけに集中できます。",
      "home.screenshotsEyebrow": "スクリーンショット",
      "home.screenshotsTitle": "デモライブラリで撮影した実画面。",
      "home.linksTitle": "リンク",
      "home.githubLink": "GitHub リポジトリ",
      "privacy.title": "プライバシーポリシー",
      "privacy.updated": "最終更新日: 2026年5月20日",
      "privacy.overviewTitle": "概要",
      "privacy.overviewBody": "CloudTape は、iCloud Drive または iOS の Files アプリで選択した音楽ファイルを再生する、プライベートでローカル優先の音楽プレイヤーです。",
      "privacy.dataTitle": "データ収集",
      "privacy.dataBody": "CloudTape には、分析、広告 SDK、アカウント機能、第三者トラッキングは含まれていません。個人データの販売も行いません。",
      "privacy.fileTitle": "ファイルアクセス",
      "privacy.fileBody": "CloudTape がアクセスするのは、iOS のフォルダ選択でユーザーが明示的に選んだフォルダとファイルだけです。次回以降に同じフォルダを開けるよう、security-scoped bookmark を保存する場合があります。",
      "privacy.contactTitle": "連絡先",
      "privacy.contactBody": "プライバシーに関する問い合わせは、",
      "privacy.supportPage": "サポートページ",
      "privacy.contactSuffix": "をご確認ください。",
      "support.title": "サポート",
      "support.intro": "CloudTape は、iCloud Drive や Files アプリにある自分の音源を再生する軽量な iOS プレイヤーです。",
      "support.checksTitle": "よくある確認項目",
      "support.check1": "選択したフォルダが iCloud Drive または Files で利用可能か確認してください。",
      "support.check2": "iCloud 上のファイルは、再生前に端末へダウンロードされるまで待ってください。",
      "support.check3": "フォルダにアクセスできなくなった場合は、アプリ内でもう一度フォルダを選び直してください。",
      "support.check4": "音声ファイル形式が iOS の再生に対応しているか確認してください。",
      "support.contactTitle": "連絡先",
      "support.contactBody": "サポートが必要な場合は、GitHub リポジトリで issue を作成するか、リリース後は App Store のサポート窓口から連絡してください。"
    }
  };

  function savedLanguage() {
    try {
      const value = localStorage.getItem(storageKey);
      return value === "ja" || value === "en" ? value : null;
    } catch (_error) {
      return null;
    }
  }

  function preferredLanguage() {
    const stored = savedLanguage();
    if (stored) return stored;
    return navigator.language && navigator.language.toLowerCase().startsWith("ja") ? "ja" : "en";
  }

  function setLanguage(language) {
    const dictionary = translations[language] || translations.en;
    document.documentElement.lang = language;

    document.querySelectorAll("[data-i18n]").forEach((element) => {
      const key = element.getAttribute("data-i18n");
      if (key && dictionary[key]) {
        element.textContent = dictionary[key];
      }
    });

    const title = dictionary["meta.title"];
    if (title && document.body.querySelector("[data-i18n='home.tagline']")) {
      document.title = title;
    }

    const description = document.querySelector("meta[name='description']");
    if (description && dictionary["meta.description"]) {
      description.setAttribute("content", dictionary["meta.description"]);
    }

    document.querySelectorAll("[data-language-option]").forEach((button) => {
      const isSelected = button.getAttribute("data-language-option") === language;
      button.setAttribute("aria-pressed", String(isSelected));
    });

    try {
      localStorage.setItem(storageKey, language);
    } catch (_error) {
      // Ignore storage failures; the current page still updates.
    }
  }

  document.querySelectorAll("[data-language-option]").forEach((button) => {
    button.addEventListener("click", () => {
      const language = button.getAttribute("data-language-option");
      if (language === "ja" || language === "en") {
        setLanguage(language);
      }
    });
  });

  setLanguage(preferredLanguage());
})();
