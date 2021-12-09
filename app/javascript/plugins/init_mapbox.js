import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import MapboxGeocoder from '@mapbox/mapbox-gl-geocoder';

const addMarkersToMap = (map, markers) => {
	markers.forEach((marker) => {
		const popup = new mapboxgl.Popup().setHTML(marker.info_window); // add this

		new mapboxgl.Marker()
			.setLngLat([marker.lng, marker.lat])
			.setPopup(popup) // add this
			.addTo(map);
	});
};

const fitMapToMarkers = (map, markers) => {
	const bounds = new mapboxgl.LngLatBounds();
	markers.forEach((marker) => bounds.extend([marker.lng, marker.lat]));
	map.fitBounds(bounds, { padding: 100, maxZoom: 15, duration: 0 });
};

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  if (mapElement) { // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
    const map = new mapboxgl.Map({
			container: "map",
			style: "mapbox://styles/mapbox/outdoors-v11",
			terrain: {
				source: "mapbox-raster-dem",
				exaggeration: 2,
			},
		});

    const markers = JSON.parse(mapElement.dataset.markers);
    addMarkersToMap(map, markers)
    map.addControl(new mapboxgl.NavigationControl());
    fitMapToMarkers(map, markers);
    }
};

export { initMapbox };
