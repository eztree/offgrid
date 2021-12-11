import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input"];
  connect() {
    console.log("stimulus connected");
  }

  inputCheckbox(e) {
    e.preventDefault();
    console.log(e.currentTarget.checked);
    const token = document.getElementsByName("csrf-token")[0].content;
    fetch(
      `/checklists/${e.currentTarget.attributes["data-checklist-id"].value}?`,
      {
        method: "PATCH",
        headers: {
          Accept: "text/plain",
          "X-CSRF-Token": token,
        },
      }
    )
      .then((response) => response.text())
      .then((data) => {
        console.log(data);
      });
  }
}
