const slides = document.querySelectorAll('.slide');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');
const progress = document.getElementById('progress');

let currentSlide = 0;

function updateSlides() {
    slides.forEach((slide, index) => {
        slide.classList.toggle('active', index === currentSlide);
    });
    
    // Update progress bar
    const percent = ((currentSlide) / (slides.length - 1)) * 100;
    progress.style.width = `${percent}%`;
    
    // Disable/Enable buttons
    prevBtn.disabled = currentSlide === 0;
    nextBtn.disabled = currentSlide === slides.length - 1;
}

nextBtn.addEventListener('click', () => {
    if (currentSlide < slides.length - 1) {
        currentSlide++;
        updateSlides();
    }
});

prevBtn.addEventListener('click', () => {
    if (currentSlide > 0) {
        currentSlide--;
        updateSlides();
    }
});

// Keyboard navigation
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight' || e.key === ' ') {
        if (currentSlide < slides.length - 1) {
            currentSlide++;
            updateSlides();
        }
    } else if (e.key === 'ArrowLeft') {
        if (currentSlide > 0) {
            currentSlide--;
            updateSlides();
        }
    }
});

// Initial update
updateSlides();
