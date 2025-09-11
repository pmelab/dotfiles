import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

/**
 * Quartz 4 Configuration
 *
 * See https://quartz.jzhao.xyz/configuration for more information.
 */
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Second Brain",
    pageTitleSuffix: "",
    enableSPA: true,
    enablePopovers: true,
    analytics: {
      provider: "plausible",
    },
    locale: "en-US",
    baseUrl: "localhost:8080",
    ignorePatterns: ["private", "templates", ".obsidian", ".zk", ".git"],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Schibsted Grotesk",
        body: "Source Sans Pro",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#eff1f5",        // Catppuccin Latte base
          lightgray: "#e6e9ef",    // Catppuccin Latte surface0
          gray: "#9ca0b0",         // Catppuccin Latte overlay0
          darkgray: "#5c5f77",     // Catppuccin Latte subtext1
          dark: "#4c4f69",         // Catppuccin Latte text
          secondary: "#8839ef",    // Catppuccin Latte mauve
          tertiary: "#1e66f5",     // Catppuccin Latte blue
          highlight: "rgba(136, 57, 239, 0.15)",   // Catppuccin Latte mauve with transparency
          textHighlight: "#8839ef88",  // Catppuccin Latte mauve semi-transparent
        },
        darkMode: {
          light: "#1e1e2e",        // Catppuccin Mocha base
          lightgray: "#313244",    // Catppuccin Mocha surface0
          gray: "#6c7086",         // Catppuccin Mocha overlay0
          darkgray: "#bac2de",     // Catppuccin Mocha subtext1
          dark: "#cdd6f4",         // Catppuccin Mocha text
          secondary: "#cba6f7",    // Catppuccin Mocha mauve
          tertiary: "#89b4fa",     // Catppuccin Mocha blue
          highlight: "rgba(203, 166, 247, 0.15)",  // Catppuccin Mocha mauve with transparency
          textHighlight: "#cba6f788",  // Catppuccin Mocha mauve semi-transparent
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false, mermaid: true }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.Favicon(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
