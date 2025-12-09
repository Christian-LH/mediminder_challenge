// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"


document.addEventListener("turbo:load", () => {
  const form   = document.querySelector('form[data-role="vaccination-form"]');
  const loader = document.getElementById("vaccination-loader");

  if (!form || !loader) return;

  form.addEventListener("submit", () => {
    loader.classList.remove("d-none");
  });
});
