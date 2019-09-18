/* 
    To show marker on map, we should raise 'meta-ui-map-add-marker' event as it is shown below
    If user provided custom icon URL, we need to get the correct URL using GetImageResource.
    THIS FUNCTION IS CALLED DIRECTLY FROM NAVISION
*/

function ShowIconMarker(marker) {
	console.log(marker);
	if (marker.settings) {
		if (marker.settings.iconUrl) {
			var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(marker.settings.iconUrl);
			marker.settings.iconUrl = actualIconUrl;
		}

		if (marker.settings.shadowUrl) {
			var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(marker.settings.iconUrl);
			marker.settings.shadowUrl = actualShadowUrl;
		}
	}
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-add-icon-marker', true, true, marker);
	window.dispatchEvent(event);
}

function ShowIconMarkerArray(markers) {
	for (var i = 0; i < markers.length; i++) {
		var marker = markers[i];
		if (marker.settings.iconUrl) {
			var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(marker.settings.iconUrl);
			markers[i].settings.iconUrl = actualIconUrl;
		}

		if (marker.settings.shadowUrl) {
			var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(marker.settings.iconUrl);
			markers[i].settings.shadowUrl = actualShadowUrl;
		}
	}
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-add-icon-marker-array', true, true, markers);
	window.dispatchEvent(event);
}

function ShowCircleMarker(marker) {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-add-circle-marker', true, true, marker);
	window.dispatchEvent(event);
}

function ShowCircleMarkerArray(markers) {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-add-circle-marker-array', true, true, markers);
	window.dispatchEvent(event);
}

/* 
    To show route on map, we should raise 'meta-ui-map-add-route' event as it is shown below

    THIS FUNCTION IS CALLED DIRECTLY FROM NAVISION
*/
function ShowRoute(route) {
	var event = document.createEvent('CustomEvent');
	if (route.coordinates) {
		route.coordinates.forEach(function(element, index) {
			var coord = route.coordinates[index];
			if (coord.marker && coord.marker.settings) {
				if (coord.marker.settings.iconUrl) {
					var actualUrl = Microsoft.Dynamics.NAV.GetImageResource(coord.marker.settings.iconUrl);
					coord.marker.settings.iconUrl = actualUrl;
				}

				if (coord.marker.settings.shadowUrl) {
					var actualUrl = Microsoft.Dynamics.NAV.GetImageResource(coord.marker.settings.shadowUrl);
					coord.marker.settings.shadowUrl = shadowUrl;
				}
			}
		});
	}
	event.initCustomEvent('meta-ui-map-add-route', true, true, route);
	window.dispatchEvent(event);
}

/* 
    To clear the map, we should raise 'meta-ui-map-clear-map' event as it is shown below
    IMPORTANT: due to the old version of IE being used in Dynamics NAV desktop application,
    arguments in initCustomEvent method aren't optional

    THIS FUNCTION IS CALLED DIRECTLY FROM NAVISION
*/
function ClearMap() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-clear-map', true, true, null);
	window.dispatchEvent(event);
}

/* 
    After the publishing, images NAV stores images somewhere. So we need to get the correct URL for map component using GetImageResource.
*/
function SetSettings(settings) {
	console.log(settings);
	if (settings.defaultMarkerSettings && settings.defaultMarkerSettings.iconMarker) {
		if (settings.defaultMarkerSettings.iconMarker.iconUrl) {
			var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(settings.defaultMarkerSettings.iconMarker.iconUrl);
			settings.defaultMarkerSettings.iconMarker.iconUrl = actualIconUrl;
		}

		if (settings.defaultMarkerSettings.iconMarker.shadowUrl) {
			var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(settings.defaultMarkerSettings.iconMarker.shadowUrl);
			settings.defaultMarkerSettings.iconMarker.shadowUrl = actualShadowUrl;
		}
	}

	if (settings.providerSettings) {
		if (settings.providerSettings.subdomains) {
			settings.providerSettings.subdomains = settings.providerSettings.subdomains.split(',');
		}
	}

	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-set-settings', true, true, settings);
	window.dispatchEvent(event);
}

function EnableLasso() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-enable-lasso', true, true, null);
	window.dispatchEvent(event);
}

function EnableHeatmap() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-enable-heatmap', true, true, null);
	window.dispatchEvent(event);
}

function UpdateHeatmap() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-update-heatmap', true, true, null);
	window.dispatchEvent(event);
}

function DisableHeatmap() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-disable-heatmap', true, true, null);
	window.dispatchEvent(event);
}

function EnableFitMarkersBounds() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-enable-fit-markers-bounds', true, true, null);
	window.dispatchEvent(event);
}

function DisableFitMarkersBounds() {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-disable-fit-markers-bounds', true, true, null);
	window.dispatchEvent(event);
}

function SetZoomAround(zoomObject) {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-disable-fit-markers-bounds', true, true, zoomObject);
	window.dispatchEvent(event);
}

function RemoveMarker(markerId) {
	var event = document.createEvent('CustomEvent');
	event.initCustomEvent('meta-ui-map-remove-marker', true, true, markerId);
	window.dispatchEvent(event);
}