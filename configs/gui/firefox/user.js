user_pref(
  "browser.startup.homepage",
  "file:///srv/http/gui/connecting/index.html?auto=1&retry=30"
);
user_pref("startup.homepage_welcome_url", "");
user_pref("browser.privatebrowsing.autostart", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("dom.indexedDB.enabled", false);
user_pref("dom.storage.enabled", false);
user_pref("browser.sessionstore.enabled", false);
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);
user_pref("browser.udc.aboutFeedback.enabled", false);
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.chrome.enabled", true);
console.log("Firefox user.js loaded");
