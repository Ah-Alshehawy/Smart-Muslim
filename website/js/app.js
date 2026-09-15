/**
 * SMART MUSLIM — APPLICATION CONTROLLER & ROUTING
 * SPA Hash-Routing • Accessible Modals • FAQ Accordions • Drawer Menu
 */

class SmartMuslimApp {
  constructor() {
    this.sections = [
      'home-section',
      'features-section',
      'quran-section',
      'privacy-section',
      'sources-section',
      'roadmap-section',
      'faq-section',
      'download-section',
      'about-section',
      'other-apps-section'
    ];
  }

  init() {
    window.i18n.init();
    window.themeManager.init();
    this.setupEventListeners();
    this.handleRoute();
  }

  setupEventListeners() {
    // Hash change listener
    window.addEventListener('hashchange', () => this.handleRoute());

    // Close modal on Escape key
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.hideIosModal();
        this.closeMobileMenu();
      }
    });

    // Close mobile menu on click outside
    document.addEventListener('click', (e) => {
      const menu = document.getElementById('mobile-menu');
      const toggleBtn = document.getElementById('mobile-menu-toggle');
      if (menu && !menu.classList.contains('hidden') && !menu.contains(e.target) && !toggleBtn.contains(e.target)) {
        this.closeMobileMenu();
      }
    });
  }

  handleRoute() {
    const hash = window.location.hash.replace(/^#\/?/, '') || '';
    
    // Map hash to section ID
    const routeMap = {
      '': 'home-section',
      'features': 'features-section',
      'quran': 'quran-section',
      'privacy': 'privacy-section',
      'sources': 'sources-section',
      'roadmap': 'roadmap-section',
      'faq': 'faq-section',
      'download': 'download-section',
      'about': 'about-section',
      'other-apps': 'other-apps-section'
    };

    const targetSection = routeMap[hash] || 'home-section';
    this.showSection(targetSection);
  }

  showSection(sectionId) {
    this.sections.forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        if (id === sectionId) {
          el.classList.remove('hidden-section');
        } else {
          el.classList.add('hidden-section');
        }
      }
    });

    // Update active nav links
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
      const linkHash = link.getAttribute('href') ? link.getAttribute('href').replace(/^#\/?/, '') : '';
      const sectionKey = sectionId.replace('-section', '');
      if (linkHash === sectionKey || (linkHash === '' && sectionKey === 'home')) {
        link.classList.add('active');
      } else {
        link.classList.remove('active');
      }
    });

    // Close mobile menu if open
    this.closeMobileMenu();

    // Scroll to top of section smoothly
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  navigateTo(hash) {
    window.location.hash = hash;
  }

  goToFeatures() {
    // If already on home, scroll to features grid
    const homeSection = document.getElementById('home-section');
    if (homeSection && !homeSection.classList.contains('hidden-section')) {
      const featuresGrid = document.getElementById('features-grid');
      if (featuresGrid) {
        featuresGrid.scrollIntoView({ behavior: 'smooth' });
      }
    } else {
      this.showSection('home-section');
      setTimeout(() => {
        const featuresGrid = document.getElementById('features-grid');
        if (featuresGrid) {
          featuresGrid.scrollIntoView({ behavior: 'smooth' });
        }
      }, 80);
    }
  }

  toggleMobileMenu() {
    const menu = document.getElementById('mobile-menu');
    const toggleBtn = document.getElementById('mobile-menu-toggle');
    if (!menu) return;

    const isHidden = menu.classList.contains('hidden');
    if (isHidden) {
      menu.classList.remove('hidden');
      if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'true');
    } else {
      menu.classList.add('hidden');
      if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
    }
  }

  closeMobileMenu() {
    const menu = document.getElementById('mobile-menu');
    const toggleBtn = document.getElementById('mobile-menu-toggle');
    if (menu) menu.classList.add('hidden');
    if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
  }

  showIosModal() {
    const modal = document.getElementById('ios-modal');
    if (modal) {
      modal.classList.remove('hidden');
      modal.setAttribute('aria-hidden', 'false');
      // Focus close button inside modal for accessibility
      const closeBtn = document.getElementById('ios-modal-close-btn');
      if (closeBtn) closeBtn.focus();
    }
  }

  hideIosModal() {
    const modal = document.getElementById('ios-modal');
    if (modal) {
      modal.classList.add('hidden');
      modal.setAttribute('aria-hidden', 'true');
    }
  }

  toggleFaq(btn) {
    const content = btn.nextElementSibling;
    const icon = btn.querySelector('.faq-icon');
    const isExpanded = btn.getAttribute('aria-expanded') === 'true';

    btn.setAttribute('aria-expanded', !isExpanded);
    if (!isExpanded) {
      content.style.maxHeight = content.scrollHeight + 'px';
      if (icon) icon.style.transform = 'rotate(180deg)';
    } else {
      content.style.maxHeight = '0px';
      if (icon) icon.style.transform = 'rotate(0deg)';
    }
  }
}

window.app = new SmartMuslimApp();
document.addEventListener('DOMContentLoaded', () => window.app.init());
