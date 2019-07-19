/* 
    Here we listen to "nav-nxt-map-on-init" event that should be raised by map after initialization
    When map is initialized, we call "ControlReady" method
 */
window.addEventListener("meta-ui-map-on-init", function (event) {
    console.log("MAP INITIALIZED AND IS LISTENING TO EVENTS");
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnMapInit", []);
});

window.addEventListener("meta-ui-map-on-settings-set", function (event) {
    console.log("MAP SETTINGS ARE INITIALIZED AND READY TO SERVE...");
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady", []);
});

/*  So all the events below are sent from the map and handled by NAV.
 *  There are a lot of internal leaflet information in the event.detail. If you want to see it, uncomment console.log piece of code and see the output log in web client.
 *  The most important piece of info you could get is event.detail.latlng, which represent coordinates.
 *  If you need some specific information to be sent, let us know.
 */
window.addEventListener("meta-ui-map-marker-cliked", function (event) {
    console.log(event);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnMarkerClicked", [event.detail]);
});

window.addEventListener("meta-ui-map-route-selected", function (event) {
    console.log(event);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnRouteSelected", [event.detail]);
});

window.addEventListener("meta-ui-map-selected-markers", function (event) {
    console.log(event);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnMarkersSelected", [event.detail]);
});

window.addEventListener("meta-ui-map-route-visibility-toggled", function (event) {
    console.log(event);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnRouteVisibilityToggled", [event.detail]);
});

var body = document.getElementById("controlAddIn");

body.innerHTML = "<meta-ui-map></meta-ui-map>";