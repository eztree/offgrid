import {
  MapboxExportControl,
  Size,
  PageOrientation,
  Format,
  DPI,
} from "@watergis/mapbox-gl-export";
import "@watergis/mapbox-gl-export/css/styles.css";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

var currentMarkers = [];

const removeAllMarkers = () => {
  if (currentMarkers !== null) {
    for (var i = currentMarkers.length - 1; i >= 0; i--) {
      currentMarkers[i].remove();
    }
  }
};

const removeRouteLine = (map) => {
  var mapLayer = map.getLayer("route");

  if (typeof mapLayer !== "undefined") {
    // Remove map layer & source.
    map.removeLayer("route").removeSource("route");
  }
};

const drawRoute = (data, map) => {
  map.addSource("route", {
    type: "geojson",
    data: {
      type: "Feature",
      properties: {},
      geometry: data.routes[0].geometry,
    },
  });
  map.addLayer({
    id: "route",
    type: "line",
    source: "route",
    layout: {
      "line-join": "round",
      "line-cap": "round",
    },
    paint: {
      "line-color": "#888",
      "line-width": 8,
    },
  });
};

const displayTrailSelect = (trail, map) => {
  const checkpoints = JSON.parse(trail.dataset.checkpoints);
  var coordinatesString = "";
  checkpoints.forEach((checkpoint) => {
    const popup = new mapboxgl.Popup().setHTML(
      `<p class="font-weight-bold mt-2 mb-0">${checkpoint.name}</p>`
    );
    const markerObject = new mapboxgl.Marker({
      color: "tomato",
    });
    markerObject
      .setLngLat([checkpoint.lng, checkpoint.lat])
      .setPopup(popup)
      .addTo(map);
    currentMarkers.push(markerObject);
    coordinatesString += `${checkpoint.lng},${checkpoint.lat};`;
  });
  coordinatesString = coordinatesString.slice(0, -1);
  removeRouteLine(map);
  if (checkpoints.length > 1) {
    fetch(
      `https://api.mapbox.com/directions/v5/mapbox/walking/${coordinatesString}?geometries=geojson&access_token=${mapboxgl.accessToken}`
    )
      .then((response) => response.json())
      .then((data) => {
        drawRoute(data, map);
        setTimeout(
          fitMapToCoordinatesArray(map, data.routes[0].geometry.coordinates),
          1000
        );
      });
  } else if (checkpoints.length > 0) {
    setTimeout(fitMapToMarkers(map, checkpoints), 1000);
  }
};

const disableAllTrailSelectSubmits = () => {
  const labels = document.querySelectorAll(".trail-submit-label");
  const buttons = document.querySelectorAll(".trail-submit-button");
  labels.forEach((label) => {
    label.style.display = "block";
  });
  buttons.forEach((button) => {
    button.style.display = "none";
  });
};

const enableTrailSelectSubmit = (trail) => {
  const label = document.querySelector(`#trail_submit_label_${trail.value}`);
  label.style.display = "none";

  const button = document.querySelector(`#trail_submit_button_${trail.value}`);
  button.style.display = "block";
};

const addMarkersToMap = (map, markers) => {
  markers.forEach((marker) => {
    const popup = new mapboxgl.Popup().setHTML(marker.info_window); // add this

    const markerObject = new mapboxgl.Marker({
      color: "tomato",
    });
    markerObject
      .setLngLat([marker.lng, marker.lat])
      .setPopup(popup) // add this
      .addTo(map);

    currentMarkers.push(markerObject);
  });
};

const fitMapToMarkers = (map, markers) => {
  const bounds = new mapboxgl.LngLatBounds();
  markers.forEach((marker) => bounds.extend([marker.lng, marker.lat]));
  map.fitBounds(bounds, { padding: 90, maxZoom: 15, duration: 3000 });
};

const fitMapToCoordinatesArray = (map, array) => {
  const bounds = new mapboxgl.LngLatBounds();
  array.forEach((coordinates) =>
    bounds.extend([coordinates[0], coordinates[1]])
  );
  map.fitBounds(bounds, { padding: 90, maxZoom: 14, duration: 3000 });
};

const initTrailSelects = (map) => {
  const trailSelects = document.querySelectorAll(".trail-select");
  trailSelects.forEach((trail) => {
    trail.onclick = function () {
      removeAllMarkers();
      displayTrailSelect(trail, map);
      disableAllTrailSelectSubmits();
      enableTrailSelectSubmit(trail);
    };
  });
};

const initMapbox = () => {
  const mapElement = document.getElementById("map");

  if (mapElement) {
    // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
    const map = new mapboxgl.Map({
      container: "map",
      style: "mapbox://styles/suansen88/ckwoursnp9q0v17qvf9ih9gfv",
      terrain: {
        source: "mapbox-raster-dem",
        exaggeration: 2,
      },
    });

    initTrailSelects(map);

    const markers = JSON.parse(mapElement.dataset.markers);
    addMarkersToMap(map, markers);
    map.addControl(new mapboxgl.NavigationControl());
    map.addControl(new mapboxgl.FullscreenControl());
    map.addControl(
      new MapboxExportControl({
        accessToken: mapboxgl.accessToken,
        PageSize: Size.A4,
        PageOrientation: PageOrientation.Landscape,
        Format: Format.PNG,
        DPI: DPI[300],
        Crosshair: true,
        PrintableArea: true,
      }),
      "top-right"
    );

    if (
      mapElement.classList.contains("map-with-route") &&
      mapElement.dataset.coordinateString.split(";").length > 1
    ) {
      fetch(
        `https://api.mapbox.com/directions/v5/mapbox/walking/${mapElement.dataset.coordinateString}?geometries=geojson&access_token=${mapboxgl.accessToken}`
      )
        .then((response) => response.json())
        .then((data) => {
          drawRoute(data, map);
          setTimeout(
            fitMapToCoordinatesArray(map, data.routes[0].geometry.coordinates),
            1000
          );
        });
    } else {
      setTimeout(fitMapToMarkers(map, markers), 1000);
    }
  }
};

export { initMapbox };
