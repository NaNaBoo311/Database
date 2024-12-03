document.querySelectorAll('.achievements a').forEach(link => {
    link.addEventListener('click', event => {
      event.preventDefault(); 
  
      const targetUrl = link.getAttribute('href'); 
      const contentDiv = document.getElementById('content'); 
  
      fetch(targetUrl)
        .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.text(); 
        })
        .then(html => {
          contentDiv.innerHTML = html; 
        })
        .catch(error => {
          console.error('Error loading content:', error);
          contentDiv.innerHTML = `<p>Failed to load content. Please try again later.</p>`;
        });
    });
  });
  document.addEventListener("DOMContentLoaded", function () {
    const dropdown = document.querySelector('.dropdown');
    dropdown.addEventListener('click', function (event) {
        event.stopPropagation(); 
        dropdown.classList.toggle('active');
    });

    document.addEventListener('click', function () {
        dropdown.classList.remove('active'); 
    });
});