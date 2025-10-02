export default {
  defaultBrowser: (options) => ({
    name: "Google Chrome",
    profile: "Profile 1",
    args: ["--app=" + options.urlString],
  }),
  handlers: [
    {
      // YouTube, Amazon → Chrome "Privat" profile (app mode - chromeless)
      match: [
        "youtube.com/*",
        "*.youtube.com/*",
        "amazon.com/*",
        "*.amazon.com/*",
      ],
      browser: (options) => ({
        name: "Google Chrome",
        profile: "Profile 4",
        args: ["--app=" + options.urlString],
      }),
    },
    {
      // Jira, Google Docs, Confluence, GitHub, Drupal.org, Amazee → Chrome "Work" profile (app mode - chromeless)
      match: [
        /.*\.atlassian\.net.*/,
        "docs.google.com/*",
        "*.atlassian.com/*",
        "github.com/*",
        "*.github.com/*",
        "drupal.org/*",
        "*.drupal.org/*",
        /.*amazee.*/,
      ],
      browser: (options) => ({
        name: "Google Chrome",
        profile: "Profile 1",
        args: ["--app=" + options.urlString],
      }),
    },
    {
      // Localhost → Chrome "Development" profile (app mode - chromeless)
      match: [
        "localhost*",
        "127.0.0.1*",
        "*.localhost*",
      ],
      browser: (options) => ({
        name: "Google Chrome",
        profile: "Profile 5",
        args: ["--app=" + options.urlString],
      }),
    },
  ],
};