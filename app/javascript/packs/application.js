// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import Elm from "../Main";

var isLocalhost = false;
if (document.location.hostname === "localhost") {
  isLocalhost = true;
}

document.addEventListener("DOMContentLoaded", () => {
  const target = document.createElement("div");

  document.body.appendChild(target);
  Elm.Main.embed(target, {
    environment: isLocalhost ? "development" : "production" //process.env.RAILS_ENV
  });
});
