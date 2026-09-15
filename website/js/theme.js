/**
 * SMART MUSLIM — THEME ENGINE (SYSTEM / LIGHT / DARK)
 * Zero dependency • High contrast WCAG 2.2 AA compliant
 */

class ThemeManager {
  constructor() {
    this.storageKey = 'smart_muslim_theme';
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    this.currentTheme = localStorage.getItem(this.storageKey) || 'system';
  }

  init() {
    this.applyTheme(this.currentTheme);
    
    // Listen for OS system theme changes
    this.mediaQuery.addEventListener('change', () => {
      if (this.currentTheme === 'system') {
        this.applyTheme('system');
      }
    });
  }

  setTheme(theme) {
    if (theme !== 'light' && theme !== 'dark' && theme !== 'system') return;
    this.currentTheme = theme;
    localStorage.setItem(this.storageKey, theme);
    this.applyTheme(theme);
  }

  toggleTheme() {
    const isDarkActive = document.documentElement.getAttribute('data-theme') === 'dark';
    const nextTheme = isDarkActive ? 'light' : 'dark';
    this.setTheme(nextTheme);
  }

  applyTheme(theme) {
    const isDark = theme === 'dark' || (theme === 'system' && this.mediaQuery.matches);
    
    if (isDark) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.setAttribute('data-theme', 'light');
    }

    // Update Meta Theme Color for mobile browser address bars
    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', isDark ? '#0D191A' : '#0F5C5E');
    }

    // Update Theme Toggle Button Icon & Label
    const themeBtn = document.getElementById('theme-toggle-btn');
    if (themeBtn) {
      const isArabic = document.documentElement.lang === 'ar';
      themeBtn.innerHTML = isDark ? '☀️' : '🌙';
      themeBtn.setAttribute('aria-label', isDark 
        ? (isArabic ? 'تفعيل المظهر الفاتح' : 'Switch to Light Mode')
        : (isArabic ? 'تفعيل المظهر الداكن' : 'Switch to Dark Mode')
      );
    }

    window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme, isDark } }));
  }
}

window.themeManager = new ThemeManager();
