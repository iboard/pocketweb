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


