import {socket,channel} from "./socket"
import $ from "jquery"

$(".led-button").click( function(ev) {
  ev.preventDefault()
  let led = ev.target.dataset["led"]
  switchLed(led)
})

function switchLed(led) {
  console.log("Switch LED", led, "ON CHANNEL", channel)
  channel.push( "led-switched", { led: led }, {} )
    .receive("ok", resp => { console.log("Sent successfully", resp) })
    .receive("error", resp => { console.log("Unable to send", resp) })
}

channel.on("led-switched", payload => {
  console.log("UPDATING LED", payload.led)
  if(payload.led == "off") {
    $("#red-led").html( "" )
    $("#blue-led").html( "" )
    $("#green-led").html( "" )
  } else {
    $(`#${payload.led}-led`).html( "🔆" )
  }
})

channel.on("button-pressed", payload => {
  console.log("BUTTON PRESSED", payload)
  $("#push-button-1").css('background-color', 'darkred')
  $("#push-button-1").css('color', 'white')
  $("#push-button-1").html("Button 1 pressed")
})

channel.on("button-released", payload => {
  console.log("BUTTON RELEASED", payload)
  $("#push-button-1").css('background-color', 'transparent')
  $("#push-button-1").css('color', 'lightgray')
  $("#push-button-1").html("Button 1 released")
})

channel.on("temperature", payload => {
  console.log("Temperature Measurement received", payload)
  $("#temperature").html(`${payload.celsius}<small>˚C</small> &nbsp; ${payload.farenheit}<small>˚F</small>`)
})


