import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    // console.log(this.formTarget);
    // console.log(this.inputTarget);
    // console.log(this.listTarget);
    console.log("stimulus connected");
  }

  inputCheckbox(e) {
    // console.log(typeof this.inputTargets.checked);
    // console.log(this.inputTargets);
    // this.inputTargets.checked = true;
    e.preventDefault();
    console.log(
      e.currentTarget.querySelector("input[type=checkbox]").attributes[
        "data-checklist-id"
      ].value
    );
    const token = document.getElementsByName("csrf-token")[0].content;
    // console.log(e.currentTarget.children);
    if (e.currentTarget.querySelector("input[type=checkbox]").checked == true) {
      e.currentTarget.querySelector("input[type=checkbox]").checked = false;
      fetch(
        `/checklists/${
          e.currentTarget.querySelector("input[type=checkbox]").attributes[
            "data-checklist-id"
          ].value
        }?`,
        {
          method: "PATCH",
          headers: {
            Accept: "text/plain",
            "X-CSRF-Token": token,
          },
          // body: { checked: e.currentTarget.children[0].checked },
        }
      )
        .then((response) => response.text())
        .then((data) => {
          console.log(data);
        });
    } else {
      e.currentTarget.querySelector("input[type=checkbox]").checked = true;
      fetch(
        `/checklists/${
          e.currentTarget.querySelector("input[type=checkbox]").attributes[
            "data-checklist-id"
          ].value
        }?`,
        {
          method: "PATCH",
          headers: {
            Accept: "text/plain",
            "X-CSRF-Token": token,
          },
          // body: { checked: e.currentTarget.children[0].checked },
        }
      )
        .then((response) => response.text())
        .then((data) => {
          console.log(data);
        });
    }
  }

  // click(event) {
  //   event.preventDefault();
  // const url = this.formTarget.action
  // fetch(url, {
  //   method: 'PATCH',
  //   headers: { 'Accept': 'text/plain' },
  //   body: new FormData(this.formTarget)
  // })
  //   .then(response => response.text())
  //   .then((data) => {
  //     console.log(data);
  //   })
  // console.log(event);
  // }
}
