// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "chartkick/chart.js";
import AerisWeather from "@aerisweather/javascript-sdk";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

// Internal imports, e.g:
// import { initSelect2 } from '../components/init_select2';
import { initMapbox } from "../plugins/init_mapbox";
import { initAerisWeather } from "../plugins/init_aerisweather";

document.addEventListener("turbolinks:load", () => {
  initMapbox();
  initAerisWeather();
  const clickables = document.querySelectorAll('.clickable');

  clickables.forEach((button) => {
    button.addEventListener('click', (event) => {
      event.currentTarget.classList.toggle('active');
    });
  });

  const editTrip = document.querySelector(".edit_trip")

  if (editTrip) {
    const upload = editTrip.onchange = function () {
      editTrip.submit();
    }
  }
})

import "controllers"
