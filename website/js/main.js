document.addEventListener('DOMContentLoaded', () => {
    const header = document.getElementById('header');
    const fadeElements = document.querySelectorAll('.fade-in');

    // Header scroll effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
        
        // Trigger fade-in animations on scroll
        handleScrollAnimations();
    });

    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target); // Only animate once
            }
        });
    }, observerOptions);

    fadeElements.forEach(el => {
        observer.observe(el);
    });

    // Initial check for elements in viewport
    function handleScrollAnimations() {
        // This is a fallback for browsers that don't support IntersectionObserver
        // or for additional scroll-based logic
    }
    
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');
            if (href === '#' || href === '#download') return;
            
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                window.scrollTo({
                    top: target.offsetTop - 80,
                    behavior: 'smooth'
                });
            }
        });
    });

    // --- Download Modal Implementation ---
    
    // 1. Create Modal HTML Structure
    const modalHTML = `
        <div class="modal-overlay" id="downloadModal">
            <div class="modal-card">
                <button class="modal-close" id="closeModal" aria-label="Close modal">
                    <i class="fas fa-times"></i>
                </button>
                <h2 class="modal-title">Download Flowpaisa</h2>
                <p class="modal-subtitle">Choose your platform to get started tracking every paisa</p>
                <div class="modal-options">
                    <div class="modal-option-card android">
                        <div class="modal-option-icon">
                            <i class="fab fa-android"></i>
                        </div>
                        <h3>Android App</h3>
                        <p>Track expenses on the go with our fully featured mobile application.</p>
                        <a href="https://play.google.com/store/apps/details?id=com.tamatasoft.flowpaisa" target="_blank" rel="noopener noreferrer" class="modal-option-btn">
                            <i class="fab fa-google-play" style="margin-right: 6px;"></i> Get it on Google Play
                        </a>
                    </div>
                    <div class="modal-option-card windows">
                        <div class="modal-option-icon">
                            <i class="fab fa-windows"></i>
                        </div>
                        <h3>Windows App</h3>
                        <p>Manage your cashbooks on your PC with our fast, elegant desktop app.</p>
                        <a href="https://github.com/tamatasoft/flowpaisa/releases/latest/download/flowpaisa_setup.exe" target="_blank" rel="noopener noreferrer" class="modal-option-btn">
                            <i class="fas fa-download" style="margin-right: 6px;"></i> Download Installer
                        </a>
                    </div>
                </div>
            </div>
        </div>
    `;

    // 2. Inject Modal into DOM
    document.body.insertAdjacentHTML('beforeend', modalHTML);

    const downloadModal = document.getElementById('downloadModal');
    const closeModal = document.getElementById('closeModal');

    // 3. Open Modal Function
    const openModal = (e) => {
        e.preventDefault();
        downloadModal.classList.add('active');
        document.body.style.overflow = 'hidden'; // Prevent background scrolling
    };

    // 4. Close Modal Function
    const closeDownloadModal = () => {
        downloadModal.classList.remove('active');
        document.body.style.overflow = ''; // Restore background scrolling
    };

    // 5. Attach Click Handlers to Download Buttons
    const downloadBtns = document.querySelectorAll('.download-btn');
    downloadBtns.forEach(btn => {
        btn.addEventListener('click', openModal);
    });

    // 6. Close Modal Event Listeners
    closeModal.addEventListener('click', closeDownloadModal);
    downloadModal.addEventListener('click', (e) => {
        if (e.target === downloadModal) {
            closeDownloadModal();
        }
    });

    // Escape key to close modal
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && downloadModal.classList.contains('active')) {
            closeDownloadModal();
        }
    });
});
