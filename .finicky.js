export default {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      // YouTube → Chrome "Privat" profile
      match: [
        "youtube.com/*",
        "*.youtube.com/*",
      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 4",
        args: ["--new-window"],
      },
    },
    {
      // Jira, Google Docs, Confluence, GitHub, Drupal.org → Chrome "Work" profile
      match: [
        /.*\.atlassian\.net.*/,
        "docs.google.com/*",
        "*.atlassian.com/*",
        "github.com/*",
        "*.github.com/*",
        "drupal.org/*",
        "*.drupal.org/*",
      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 1",
        args: ["--new-window"],
      },
    },
    {
      // Localhost → Chrome "Development" profile
      match: [
        "localhost*",
        "127.0.0.1*",
        "*.localhost*",
      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 5",
        args: ["--new-window"],
      },
    },
  ],
};