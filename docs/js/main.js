(function () {
  "use strict";

  // 1. Mobile navigation toggle
  const navToggle = document.getElementById("nav-toggle");
  const navLinks = document.getElementById("nav-links");
  if (navToggle && navLinks) {
    navToggle.addEventListener("click", () => {
      const isOpen = navLinks.classList.toggle("open");
      navToggle.setAttribute("aria-expanded", String(isOpen));
    });
    navLinks.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", () => {
        navLinks.classList.remove("open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // 2. Generic accessible tab controller
  function initTabGroup(groupSelector) {
    document.querySelectorAll(groupSelector).forEach((group) => {
      const buttons = group.querySelectorAll("[data-tab-target]");
      const panels = group.querySelectorAll("[data-tab-panel]");
      buttons.forEach((btn) => {
        btn.addEventListener("click", () => {
          const target = btn.getAttribute("data-tab-target");
          buttons.forEach((b) => {
            const active = b === btn;
            b.classList.toggle("active", active);
            b.setAttribute("aria-selected", String(active));
          });
          panels.forEach((panel) => {
            const match = panel.getAttribute("data-tab-panel") === target;
            panel.classList.toggle("active", match);
          });
        });
      });
    });
  }

  initTabGroup("[data-tab-group]");

  // 3. Copy-to-clipboard for code blocks
  document.querySelectorAll(".copy-btn").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const wrapper = btn.closest(".code-block-wrap");
      const codeEl = wrapper ? wrapper.querySelector("pre code") : null;
      if (!codeEl) return;
      try {
        await navigator.clipboard.writeText(codeEl.textContent || "");
        const prev = btn.textContent;
        btn.textContent = "Copied!";
        window.setTimeout(() => {
          btn.textContent = prev || "Copy";
        }, 1600);
      } catch (_err) {
        btn.textContent = "Select & Ctrl+C";
      }
    });
  });

  // 4. Screenshot Lightbox
  const lightbox = document.getElementById("lightbox");
  const lightboxImg = document.getElementById("lightbox-img");
  const lightboxTitle = document.getElementById("lightbox-title");
  const lightboxClose = document.getElementById("lightbox-close");

  function closeLightbox() {
    if (!lightbox) return;
    lightbox.classList.remove("open");
    lightbox.setAttribute("aria-hidden", "true");
  }

  if (lightbox && lightboxImg && lightboxTitle) {
    document.querySelectorAll("[data-lightbox-src]").forEach((trigger) => {
      trigger.addEventListener("click", () => {
        const src = trigger.getAttribute("data-lightbox-src") || "";
        const title = trigger.getAttribute("data-lightbox-title") || "";
        lightboxImg.src = src;
        lightboxImg.alt = title;
        lightboxTitle.textContent = title;
        lightbox.classList.add("open");
        lightbox.setAttribute("aria-hidden", "false");
        if (lightboxClose) lightboxClose.focus();
      });
    });

    if (lightboxClose) {
      lightboxClose.addEventListener("click", closeLightbox);
    }
    lightbox.addEventListener("click", (ev) => {
      if (ev.target === lightbox) closeLightbox();
    });
    document.addEventListener("keydown", (ev) => {
      if (ev.key === "Escape" && lightbox.classList.contains("open")) {
        closeLightbox();
      }
    });
  }

  // 5. Auto-detect GitHub repository URL when hosted on *.github.io/<repo>/
  const host = window.location.hostname;
  const pathParts = window.location.pathname.split("/").filter(Boolean);
  if (host.endsWith(".github.io") && pathParts.length > 0) {
    const owner = host.replace(".github.io", "");
    const repo = pathParts[0];
    const repoUrl = `https://github.com/${owner}/${repo}`;
    const cloneUrl = `${repoUrl}.git`;
    document.querySelectorAll("[data-repo-link]").forEach((el) => {
      el.setAttribute("href", repoUrl);
    });
    const cloneCode = document.getElementById("clone-command-code");
    if (cloneCode) {
      cloneCode.textContent = `git clone ${cloneUrl}\ncd ${repo}\ngodot --headless --path . --import\ngodot --headless --path . -s res://scripts/ci/smoke_test.gd`;
    }
  }

  // 6. Subtle gothic ember particles on background canvas
  const canvas = document.getElementById("ember-canvas");
  const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (canvas && !prefersReducedMotion) {
    const ctx = canvas.getContext("2d");
    if (ctx) {
      let width = 0;
      let height = 0;
      const embers = [];
      const EMBER_COUNT = 28;

      function resize() {
        width = window.innerWidth;
        height = window.innerHeight;
        canvas.width = width;
        canvas.height = height;
      }

      function spawnEmber(randomY) {
        return {
          x: Math.random() * (width || 1280),
          y: randomY ? Math.random() * (height || 720) : (height || 720) + 12,
          r: 1.2 + Math.random() * 2.2,
          vy: 14 + Math.random() * 24,
          vx: (Math.random() - 0.5) * 10,
          alpha: 0.2 + Math.random() * 0.45,
          gold: Math.random() > 0.35
        };
      }

      resize();
      window.addEventListener("resize", resize);
      for (let i = 0; i < EMBER_COUNT; i += 1) {
        embers.push(spawnEmber(true));
      }

      let lastTs = performance.now();
      function frame(ts) {
        const dt = Math.min(0.05, (ts - lastTs) / 1000);
        lastTs = ts;
        ctx.clearRect(0, 0, width, height);
        for (let i = 0; i < embers.length; i += 1) {
          const e = embers[i];
          e.y -= e.vy * dt;
          e.x += e.vx * dt;
          if (e.y < -12) {
            embers[i] = spawnEmber(false);
            continue;
          }
          ctx.fillStyle = e.gold
            ? `rgba(245, 214, 122, ${e.alpha})`
            : `rgba(232, 72, 77, ${e.alpha * 0.85})`;
          ctx.beginPath();
          ctx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
          ctx.fill();
        }
        window.requestAnimationFrame(frame);
      }
      window.requestAnimationFrame(frame);
    }
  }
})();
