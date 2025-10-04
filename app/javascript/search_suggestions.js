// Search suggestions functionality
document.addEventListener('turbo:load', function() {
  const searchInput = document.getElementById('search-input');
  const suggestionsContainer = document.getElementById('search-suggestions');
  
  if (!searchInput || !suggestionsContainer) return;

  let debounceTimer;
  let currentRequest = null;

  searchInput.addEventListener('input', function() {
    const query = this.value.trim();
    
    // Clear previous timer
    clearTimeout(debounceTimer);
    
    // Hide suggestions if query is too short
    if (query.length < 2) {
      suggestionsContainer.style.display = 'none';
      return;
    }

    // Debounce the request
    debounceTimer = setTimeout(() => {
      fetchSuggestions(query);
    }, 300);
  });

  // Hide suggestions when clicking outside
  document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !suggestionsContainer.contains(e.target)) {
      suggestionsContainer.style.display = 'none';
    }
  });

  // Handle suggestion clicks
  suggestionsContainer.addEventListener('click', function(e) {
    if (e.target.classList.contains('list-group-item')) {
      searchInput.value = e.target.textContent;
      suggestionsContainer.style.display = 'none';
      searchInput.closest('form').submit();
    }
  });

  function fetchSuggestions(query) {
    // Cancel previous request if still pending
    if (currentRequest) {
      currentRequest.abort();
    }

    // Create new request
    currentRequest = new AbortController();
    
    fetch(`/students/search_suggestions?q=${encodeURIComponent(query)}`, {
      signal: currentRequest.signal
    })
    .then(response => response.json())
    .then(suggestions => {
      displaySuggestions(suggestions);
    })
    .catch(error => {
      if (error.name !== 'AbortError') {
        console.error('Error fetching suggestions:', error);
      }
    })
    .finally(() => {
      currentRequest = null;
    });
  }

  function displaySuggestions(suggestions) {
    if (suggestions.length === 0) {
      suggestionsContainer.style.display = 'none';
      return;
    }

    suggestionsContainer.innerHTML = suggestions.map(suggestion => 
      `<a href="#" class="list-group-item list-group-item-action">${suggestion}</a>`
    ).join('');
    
    suggestionsContainer.style.display = 'block';
  }
});
