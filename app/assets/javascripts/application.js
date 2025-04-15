// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require rails_sortable
//= require leaflet
//= require leaflet.markercluster
//= require tinymce
//= require js.cookies
//= require popper
//= require bootstrap
//= require photoswipe
//= require_tree .

// Hide Turbolinks progress bar
document.addEventListener("turbolinks:load", function () {
  var progress = document.querySelector(".turbolinks-progress-bar");
  if (progress) {
    progress.remove();
  }

  // Initialize Bootstrap
  $(function () {
    $('[data-bs-toggle="collapse"]').collapse();
  });
});

var ready;
var app = {};

function pageLoad() {
  setTimeout(function () {
    $("#notice_wrapper").fadeOut("slow", function () {
      $(this).remove();
    });
    $("#alert_wrapper").fadeOut("slow", function () {
      $(this).remove();
    });
  }, 4500);

  // re-initialize sortable on Turbolinks page load
  $(".sortable").railsSortable();

  // Only load the map if necessary
  if ($("#bigmap").length > 0 || $(".minimap").length > 0) {
    var zoomControl = true;
    var attributionControl = true;
    var tileOptions = {
      subdomains: "abcd",
      minZoom: 0,
      maxZoom: 20,
      ext: "png",
      opacity: 0.5,
    };
    if ($(".minimap").length === 1) {
      // zoomControl = false;
      attributionControl = false;
    } else {
      tileOptions.attribution =
        'Map tiles by <a href="https://carto.com/">CartoDB</a>, under CC BY 3.0. Data by <a href="http://www.openstreetmap.org/">OpenStreetMap</a>, under ODbL.';
    }
    if (
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      )
    ) {
      zoomControl = false;
    }

    app.basemap = L.tileLayer(
      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
      tileOptions
    );

    // Return to the last-used map extent, or use a default extent
    var lat = Cookies.get("lat") || 0;
    var lng = Cookies.get("lng") || 27;
    var zoom = Cookies.get("zoom") || 3;
    app.leafletMap = new L.Map("map", {
      center: [lat, lng],
      zoom: zoom,
      maxZoom: 8,
      minZoom: 2,
      layers: [app.basemap],
      maxBounds: L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180)),
      zoomControl: zoomControl,
      attributionControl: attributionControl,
    });

    // Fetch geocoded posts
    var postId = $(".post_id").data("id") || null;
    var postLat = $(".post_id").data("latitude") || null;
    var postLong = $(".post_id").data("longitude") || null;
    getPosts(postId, postLat, postLong);

    // Store the last map extent in cookies
    app.leafletMap.on("zoomend", function () {
      updateCookies();
    });
    app.leafletMap.on("moveend", function () {
      updateCookies();
    });
  }

  function updateCookies() {
    Cookies.set("lat", app.leafletMap.getCenter().lat);
    Cookies.set("lng", app.leafletMap.getCenter().lng);
    Cookies.set("zoom", app.leafletMap.getZoom());
  }

  function getPosts(postID, postLat, postLong) {
    // Request posts with a lat/long
    var url = window.location.origin + "/getpins/index.json";
    $.ajax({
      dataType: "text",
      url: url,
      beforeSend: function (jqXHR, settings) {
        // send the post ID
        jqXHR.postID = postID;
        jqXHR.postLat = postLat;
        jqXHR.postLong = postLong;
      },
      success: function (data, textStatus, jqXHR) {
        var postID = jqXHR.postID || null;
        var postLat = jqXHR.postLat || null;
        var postLong = jqXHR.postLong || null;
        drawEvents(data, postID, postLat, postLong);
      },
      error: function () {
        console.log("Error with Index map");
      },
    });
  }

  function drawEvents(data, postID, postLat, postLong) {
    var geojson = $.parseJSON(data);
    var geojsonMarkerOptions = {
      radius: 8,
      fillColor: "#FF0000",
      color: "#000",
      weight: 1,
      opacity: 1,
      fillOpacity: 0.8,
    };

    // Add the posts to the map
    var jsonLayer = L.geoJson(geojson, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, geojsonMarkerOptions);
      },
      onEachFeature: function (feature, layer) {
        var popupContent;
        if (feature.properties.title != undefined) {
          popupContent = feature.properties.title;
          if (feature.properties.url != undefined) {
            popupContent =
              "<p><strong><a class='mapTitle' href='" +
              feature.properties.url +
              "''>" +
              feature.properties.title +
              "</a></strong></p>";
          }
          if (feature.properties.photo !== undefined) {
            popupContent +=
              "<a href='" +
              feature.properties.url +
              "''><img width='240px' height='159px' class='mapPhoto' src='" +
              feature.properties.photo +
              "'></a>";
          }
        }
        layer.bindPopup(popupContent);
      },
    });
    // var featureGroup = L.featureGroup();
    // featureGroup.addLayer(jsonLayer);
    var markers = L.markerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: false,
      zoomToBoundsOnClick: true,
      spiderfyDistanceMultiplier: 1.5,
    });
    markers.addLayer(jsonLayer);
    app.leafletMap.addLayer(markers);
    // featureGroup.addTo(app.leafletMap);

    // If we are on a Post page, zoom to the post
    if (postLat !== null && postLong !== null) {
      app.leafletMap.flyTo([postLat, postLong], 5);
    }
  }
}

$(document).on("turbolinks:load", pageLoad);

// Initialize PhotoSwipe
document.addEventListener("turbolinks:load", function () {
  // Wait for DOM to be fully loaded
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initPhotoSwipe);
  } else {
    initPhotoSwipe();
  }
});

function initPhotoSwipe() {
  // Check if PhotoSwipe is loaded
  if (typeof PhotoSwipe === "undefined") {
    console.error("PhotoSwipe not loaded");
    return;
  }

  var initPhotoSwipeFromDOM = function (gallerySelector) {
    var parseThumbnailElements = function (el) {
      var thumbElements = el.getElementsByClassName("col-md-4"),
        items = [],
        figureEl,
        linkEl,
        size,
        item;

      for (var i = 0; i < thumbElements.length; i++) {
        figureEl = thumbElements[i].getElementsByTagName("figure")[0];
        if (!figureEl) {
          continue;
        }

        linkEl = figureEl.getElementsByTagName("a")[0];
        if (!linkEl) {
          continue;
        }

        size = linkEl.getAttribute("data-size");
        if (!size) {
          size = "1200x800";
        }
        size = size.split("x");

        item = {
          src: linkEl.getAttribute("href"),
          w: parseInt(size[0], 10),
          h: parseInt(size[1], 10),
        };

        var imgEl = linkEl.getElementsByTagName("img")[0];
        if (imgEl) {
          item.msrc = imgEl.getAttribute("src");
        }

        var captionEl = figureEl.getElementsByTagName("figcaption")[0];
        if (captionEl) {
          item.title = captionEl.textContent;
        }

        item.el = figureEl;
        items.push(item);
      }

      return items;
    };

    var closest = function closest(el, fn) {
      return el && (fn(el) ? el : closest(el.parentNode, fn));
    };

    var onThumbnailsClick = function (e) {
      e = e || window.event;
      e.preventDefault ? e.preventDefault() : (e.returnValue = false);

      var eTarget = e.target || e.srcElement;
      var clickedListItem = closest(eTarget, function (el) {
        return el.tagName && el.tagName.toUpperCase() === "FIGURE";
      });

      if (!clickedListItem) {
        return;
      }

      var clickedGallery = clickedListItem.closest(".pswp-gallery");
      if (!clickedGallery) {
        return;
      }

      var thumbElements = clickedGallery.getElementsByClassName("col-md-4");
      var index = 0;
      for (var i = 0; i < thumbElements.length; i++) {
        if (thumbElements[i].contains(clickedListItem)) {
          index = i;
          break;
        }
      }

      if (index >= 0) {
        openPhotoSwipe(index, clickedGallery);
      }
      return false;
    };

    var openPhotoSwipe = function (
      index,
      galleryElement,
      disableAnimation,
      fromURL
    ) {
      var pswpElement = document.querySelectorAll(".pswp")[0];
      if (!pswpElement) {
        console.error("PhotoSwipe element not found");
        return;
      }

      var items = parseThumbnailElements(galleryElement);
      if (!items || items.length === 0) {
        console.error("No gallery items found");
        return;
      }

      var options = {
        galleryUID: galleryElement.getAttribute("data-pswp-uid"),
        getThumbBoundsFn: function (index) {
          var thumbnail = items[index].el.getElementsByTagName("img")[0];
          if (!thumbnail) {
            return { x: 0, y: 0, w: 0 };
          }
          var pageYScroll =
            window.pageYOffset || document.documentElement.scrollTop;
          var rect = thumbnail.getBoundingClientRect();
          return { x: rect.left, y: rect.top + pageYScroll, w: rect.width };
        },
        addCaptionHTMLFn: function (item, captionEl, isFake) {
          if (!item.title) {
            captionEl.children[0].textContent = "";
            return false;
          }
          captionEl.children[0].textContent = item.title;
          captionEl.children[0].style.textAlign = "center";
          return true;
        },
        maxSpreadZoom: 2,
        getDoubleTapZoom: function (isMouseClick, item) {
          if (isMouseClick) {
            return 1.5;
          } else {
            return item.initialZoomLevel < 0.7 ? 1 : 1.5;
          }
        },
      };

      if (fromURL) {
        if (options.galleryPIDs) {
          for (var j = 0; j < items.length; j++) {
            if (items[j].pid == index) {
              options.index = j;
              break;
            }
          }
        } else {
          options.index = parseInt(index, 10) - 1;
        }
      } else {
        options.index = parseInt(index, 10);
      }

      if (isNaN(options.index)) {
        return;
      }

      if (disableAnimation) {
        options.showAnimationDuration = 0;
      }

      try {
        var gallery = new PhotoSwipe(
          pswpElement,
          PhotoSwipeUI_Default,
          items,
          options
        );
        gallery.init();
      } catch (error) {
        console.error("Error initializing PhotoSwipe:", error);
      }
    };

    var galleryElements = document.querySelectorAll(gallerySelector);
    for (var i = 0, l = galleryElements.length; i < l; i++) {
      galleryElements[i].setAttribute("data-pswp-uid", i + 1);
      galleryElements[i].onclick = onThumbnailsClick;
    }
  };

  initPhotoSwipeFromDOM(".pswp-gallery");
}
