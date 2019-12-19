/***
 * @typedef Point
 * @type {object}
 * @property {number} latitude
 * @property {number} longitude
 *
 *
 * @typedef Popup
 * @type {object}
 * @property {string} text
 * @property {boolean} autoClose
 * @property {boolean} closeOnClick
 *
 *
 * @typedef IconMarker
 * @type {object}
 * @property {string} id
 * @property {string} layerId
 * @property {Point} coordinates
 * @property {Popup} popup
 * @property {Tooltip} tooltip
 * @property {IconMarkerSettings} settings
 *
 *
 * @typedef IconMarkerSettings
 * @type {object}
 * @property {string} [iconUrl='']
 * @property {string} [shadowUrl='']
 * @property {[number,number]} iconAnchor
 * @property {[number,number]} popupAnchor
 * @property {[number,number]} iconSize
 * @property {[number,number]} shadowSize
 * @property {[number,number]} shadowAnchor
 *
 *
 * @typedef CircleMarker
 * @type {object}
 * @property {string} id
 * @property {string} layerId
 * @property {Point} coordinates
 * @property {Popup} popup
 * @property {Tooltip} tooltip
 * @property {CircleMarkerSettings} settings
 *
 *
 * @typedef CircleMarkerSettings
 * @type {object}
 * @property {string} [fillColor='#FFA524']
 * @property {number} [fillOpacity=1]
 * @property {number} [radius=10]
 * @property {string} [strokeColor='#4f90ca']
 * @property {number} [strokeOpacity=1]
 * @property {number} [strokeWidthPx=2]
 *
 *
 * @typedef AddGeoJSONLayerRequest
 * @type {object}
 * @property {string} id
 *
 *
 * @typedef AddMarkerClusterLayerRequest
 * @type {object}
 * @property {string} id
 * @property {boolean} [showCoverageOnHover=true] When you mouse over a cluster it shows the bounds of its markers
 * @property {boolean} [zoomToBoundsOnClick=true] When you click a cluster we zoom to its bounds.
 * @property {boolean} [spiderfyOnMaxZoom=true] When you click a cluster at the bottom zoom level we spiderfy it so you can see all of its markers
 * @property {boolean} [removeOutsideVisibleBounds=true] Clusters and markers too far from the viewport are removed from the map for performance.
 * @property {boolean} [animate=true] Smoothly split / merge cluster children when zooming and spiderfying. May not have any effect in IE.
 * @property {boolean} [animateAddingMarkers=false] If set to true (and animate option is also true) then adding individual markers to the MarkerClusterGroup after it has been added to the map will add the marker and animate it into the cluster
 * Defaults to false as this gives better performance when bulk adding markers.
 * addLayers does not support this, only addLayer with individual Markers.
 * @property {boolean} [disableClusteringAtZoom=18] If set, at this zoom level and below markers will not be clustered. This defaults to disabled.
 * @property {number} [maxClusterRadius=80] The maximum radius that a cluster will cover from the central marker (in pixels).
 * Decreasing will make more, smaller clusters.
 * You can also use a function that accepts the current map zoom and returns the maximum cluster radius in pixels
 * @property {boolean} [singleMarkerMode=false] If set to true, overrides the icon for all added markers to make them appear as a 1 size cluster.
 * @property {boolean} [spiderfyDistanceMultiplier=1] Increase from 1 to increase the distance away from the center that spiderfied markers are placed.
 * Use if you are using big marker icons.
 * @property {boolean} [chunkedLoading=false] Boolean to split the addLayers processing in to small intervals so that the page does not freeze.
 * @property {number} [chunkDelay=50] Time delay (in ms) between consecutive periods of processing for addLayers.
 * @property {number} [chunkInterval=200] Time interval (in ms) during which addLayers works before pausing to let the rest of the page process.
 * In particular, this prevents the page from freezing while adding a lot of markers.
 *
 *
 * @typedef AddHeatLayerRequest
 * @type {object}
 * @property {string} id
 * @property {number} [minOpacity=0.05] The minimum opacity the heat will start at.
 * @property {number} [maxZoom=18] Zoom level where the points reach maximum intensity (as intensity scales with zoom), equals maxZoom of the map by default.
 * @property {number} [max=1.0] Maximum point intensity.
 * @property {number} [radius=25] Radius of each "point" of the heatmap.
 * @property {number} [blur=15] Amount of blur.
 * @property {object} [gradient={0.4: 'blue', 0.65: 'lime', 1: 'red'}] Color gradient config, e.g. {0.4: 'blue', 0.65: 'lime', 1: 'red'}
 *
 *
 * @typedef RemoveLayerRequest
 * @type {object}
 * @property {string} id Layer id
 *
 *
 * @typedef ShowLayerRequest
 * @type {object}
 * @property {string} id Layer id
 *
 *
 * @typedef HideLayerRequest
 * @type {object}
 * @property {string} id Layer id
 *
 * @typedef ClearLayerRequest
 * @type {object}
 * @property {string} id Layer id
 *
 * @typedef FitLayerBoundsRequest
 * @type {object}
 * @property {string} id Layer id
 *
 *
 * @typedef RemoveMarkerRequest
 * @type {object}
 * @property {string} id
 * @property {string} layerId
 *
 *
 * @typedef AddHeatPointRequest
 * @type {object}
 * @property {Point} coordinates
 * @property {number} intensity
 * @property {string} layerId
 *
 *
 * @typedef RouteSegment
 * @type {object}
 * @property {Point[]} points
 * @property {string} color
 *
 *
 * @typedef DecoratorSettings
 * @type {object}
 * @property {string} value
 * @property {boolean} [repeat=false] Specifies if the text should be repeated along the polyline.
 * @property {boolean} [center=false] Centers the text according to the polyline's bounding box.
 * @property {boolean} [below=false] Show text below the path.
 * @property {number} [offset=6] Set an offset to position text relative to the polyline.
 * @property {number | 'angle' | 'flip' | 'perpendicular'} [orientation=0]
 * {orientation: angle} - rotate to a specified angle (e.g. {orientation: 15})
 * {orientation: flip} - filps the text 180deg correction for upside down text placement on west -> east lines
 * {orientation: perpendicular} - places text at right angles to the line.
 * @property {string} [fontColor='black'] Font color
 * @property {number} [fontSize=18] Font size
 *
 * @typedef RouteButtonSettings
 * @type {object}
 * @property {boolean} [showButton=false]
 * @property {string} [label='']
 *
 *
 * @typedef RouteSelectionSettings
 * @type {object}
 * @property {boolean} [selectable=false]
 * @property {string} [strokeColor='#FFA524']
 * @property {number} [strokeOpacity=1]
 * @property {number} [strokeWidthPx=4]
 * @property {string} [dashPattern='']   Defines the pattern of dashes and gaps used to paint. It's a list of comma or whitespace separated lengths and percentages. https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray
 *                                       '5,1' will result in   ----- ----- ----- -----
 *                                       '4' will result in     ----    ----    ----
 *                                       '3,2' will result in   ---  ---  ---  ---  ---
 *                                       '' will result in      -----------------------
 *
 *
 * @typedef Route
 * @type {object}
 * @property {string} id
 * @property {string} layerId
 * @property {RouteSegment[]} segments
 * @property {RouteButtonSettings} buttonSettings
 * @property {RouteSelectionSettings} selectionSettings
 * @property {DecoratorSettings} decorator
 *
 *
 * @typedef AddLayersControlRequest
 * @type {object}
 * @property {string} id
 * @property {LayerControl[]} [baseLayers=[]] Base layers will be switched with radio buttons
 * @property {LayerControl[]} [overlayLayers=[]] Overlays will be switched with checkboxes
 * @property {boolean} [autoZIntex=true] If true, the control will assign zIndexes in increasing order to all of its layers so that the order is preserved when switching them on/off.
 * @property {boolean} [collapsed=true] If true, the control will be collapsed into an icon and expanded on mouse hover or touch.
 * @property {boolean} [hideSingleBase=false] If true, the base layers in the control will be hidden when there is only one.
 * @property {string} [position='topright'] The position of the control (one of the map corners). Possible values are 'topleft', 'topright', 'bottomleft' or 'bottomright'
 *
 *
 * @typedef LayerControl
 * @type {object}
 * @property {string} id Existing layer id
 * @property {string} label Label that will be used in control
 *
 *
 * @typedef ShowControlRequest
 * @type {object}
 * @property {string} id Control id
 *
 *
 * @typedef HideControlRequest
 * @type {object}
 * @property {string} id Control id
 *
 *
 * @typedef RemoveControlRequest
 * @type {object}
 * @property {string} id Control id
 */

/**
 *
 * @param {IconMarker} marker
 */
function ShowIconMarker(marker) {
  if (marker.settings) {
    if (marker.settings.iconUrl) {
      var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(
        marker.settings.iconUrl
      );
      marker.settings.iconUrl = actualIconUrl;
    }

    if (marker.settings.shadowUrl) {
      var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(
        marker.settings.shadowUrl
      );
      marker.settings.shadowUrl = actualShadowUrl;
    }
  }
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-add-icon-marker", true, true, marker);
  window.dispatchEvent(event);
}

/**
 *
 * @param {IconMarker[]} markers
 */
function ShowIconMarkerArray(markers) {
  for (var i = 0; i < markers.length; i++) {
    var marker = markers[i];
    if (marker.settings.iconUrl) {
      var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(
        marker.settings.iconUrl
      );
      markers[i].settings.iconUrl = actualIconUrl;
    }

    if (marker.settings.shadowUrl) {
      var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(
        marker.settings.iconUrl
      );
      markers[i].settings.shadowUrl = actualShadowUrl;
    }
  }
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-icon-marker-array",
    true,
    true,
    markers
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {CircleMarker} marker
 */
function ShowCircleMarker(marker) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-add-circle-marker", true, true, marker);
  window.dispatchEvent(event);
}

/**
 *
 * @param {CircleMarker[]} markers
 */
function ShowCircleMarkerArray(markers) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-circle-marker-array",
    true,
    true,
    markers
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {Route} route
 */
function ShowRoute(route) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-add-route", true, true, route);
  window.dispatchEvent(event);
}

function ClearMap() {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-clear-map", true, true, null);
  window.dispatchEvent(event);
}

function SetSettings(settings) {
  if (
    settings.defaultMarkerSettings &&
    settings.defaultMarkerSettings.iconMarker
  ) {
    if (settings.defaultMarkerSettings.iconMarker.iconUrl) {
      var actualIconUrl = Microsoft.Dynamics.NAV.GetImageResource(
        settings.defaultMarkerSettings.iconMarker.iconUrl
      );
      settings.defaultMarkerSettings.iconMarker.iconUrl = actualIconUrl;
    }

    if (settings.defaultMarkerSettings.iconMarker.shadowUrl) {
      var actualShadowUrl = Microsoft.Dynamics.NAV.GetImageResource(
        settings.defaultMarkerSettings.iconMarker.shadowUrl
      );
      settings.defaultMarkerSettings.iconMarker.shadowUrl = actualShadowUrl;
    }
  }

  if (settings.providerSettings) {
    if (settings.providerSettings.subdomains) {
      settings.providerSettings.subdomains = settings.providerSettings.subdomains.split(
        ","
      );
    }
  }

  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-set-settings", true, true, settings);
  window.dispatchEvent(event);
}

function EnableLasso() {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-enable-lasso", true, true, null);
  window.dispatchEvent(event);
}

/**
 * @param {ZoomAroundRequest} zoomObject
 */
function SetZoomAround(zoomObject) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-disable-fit-markers-bounds",
    true,
    true,
    zoomObject
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {RemoveMarkerRequest} removeMarkerRequest
 */
function RemoveMarker(removeMarkerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-remove-marker",
    true,
    true,
    removeMarkerRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {AddGeoJSONLayerRequest} addGeoJsonLayerRequest
 */
function AddGeoJSONLayer(addGeoJsonLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-geojson-layer",
    true,
    true,
    addGeoJsonLayerRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {AddMarkerClusterLayerRequest} addMarkerClusterLayerRequest
 */
function AddMarkerClusterLayer(addMarkerClusterLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-marker-cluster-layer",
    true,
    true,
    addMarkerClusterLayerRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {AddHeatLayerRequest} addHeatLayerRequest
 */
function AddHeatLayer(addHeatLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-heat-layer",
    true,
    true,
    addHeatLayerRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {RemoveLayerRequest} removeLayerRequest
 */
function RemoveLayer(removeLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-remove-layer",
    true,
    true,
    removeLayerRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {ShowLayerRequest} showLayerRequest
 */
function ShowLayer(showLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-show-layer", true, true, showLayerRequest);
  window.dispatchEvent(event);
}

/**
 *
 * @param {HideLayerRequest} hideLayerRequest
 */
function HideLayer(hideLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent("meta-ui-map-hide-layer", true, true, hideLayerRequest);
  window.dispatchEvent(event);
}

/**
 *
 * @param {FitLayerBoundsRequest} fitLayerBoundsRequest
 */
function FitLayerBounds(fitLayerBoundsRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-fit-layer-bounds",
    true,
    true,
    fitLayerBoundsRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {AddHeatPointRequest} addHeatPointRequest
 */
function AddHeatPoint(addHeatPointRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-fit-layer-bounds",
    true,
    true,
    addHeatPointRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {AddLayersControlRequest} addLayersControlRequest
 */
function AddLayersControl(addLayersControlRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-add-layers-control",
    true,
    true,
    addLayersControlRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {ShowControlRequest} showControlRequest
 */
function ShowControl(showControlRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-show-control",
    true,
    true,
    showControlRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {HideControlRequest} hideControlRequest
 */
function HideControl(hideControlRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-hide-control",
    true,
    true,
    hideControlRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {RemoveControlRequest} removeControlRequest
 */
function RemoveControl(removeControlRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-remove-control",
    true,
    true,
    removeControlRequest
  );
  window.dispatchEvent(event);
}

/**
 *
 * @param {ClearLayerRequest} clearLayerRequest
 */
function ClearLayer(clearLayerRequest) {
  var event = document.createEvent("CustomEvent");
  event.initCustomEvent(
    "meta-ui-map-clear-layer",
    true,
    true,
    clearLayerRequest
  );
  window.dispatchEvent(event);
}
