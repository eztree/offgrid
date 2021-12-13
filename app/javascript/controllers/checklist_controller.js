import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input", "done", "undone"];
  connect() {
    console.log("stimulus connected");
  }

  inputCheckbox(e) {
    e.preventDefault();
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
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        // debugger;
        const isChecked = data.checklist.checked ? "checked" : "";
        const badgeListsUnchecked = data.tag_lists
          .map((tag) => {
            const label =
              tag === "optional" ? "badge-secondary" : "badge-primary";
            return `<span class="badge badge-pill ${label}">${tag}</span>`;
          })
          .join("\n");

        const badgeListsChecked = data.tag_lists
          .map((tag) => {
            const label = "badge-secondary";
            return `<span class="badge badge-pill ${label}">${tag}</span>`;
          })
          .join("\n");

        const isCheckedBadgeLists = data.checklist.checked
          ? badgeListsChecked
          : badgeListsUnchecked;

        const input = `
          <div class="pl-5">
            <input data-action="change->checklist#inputCheckbox"
              data-checklist-target="input" type="checkbox" id="${data.checklist.id}"
              data-checklist-id="${data.checklist.id}"
              name="${data.checklist.id}"
              value="${data.checklist.id}"
              ${isChecked}
            >
            <label for="${data.checklist.id}">
              ${data.item.name}
            </label>
            ${isCheckedBadgeLists}
          </div>
        `;

        const input_icon = `<span id="${data.category}-icon" style="font-size:1.5rem;"> <i class="far fa-check-circle"></i></span>`;

        const checklistElement = document
          .getElementById(`${data.checklist.id}`)
          .closest(".pl-5");

        const checklistCard = document.getElementById(`${data.category}`);
        const checklistCardChild = document.getElementById(
          `${data.category}-icon`
        );

        if (data.checklist.checked) {
          console.log("remove from this list");
          console.log("insert adjacent to the done list");
          checklistElement.remove();
          this.doneTarget.insertAdjacentHTML("beforeend", input);

          if (data.check == true) {
            checklistCard.insertAdjacentHTML("beforeend", input_icon);
            checklistCard.style.color = "green";
            console.log("add icon");
          } else {
            if (checklistCardChild != undefined) {
              checklistCard.style.color = "black";
              checklistCard.removeChild(checklistCardChild);
              console.log("remove icon");
            }
          }
        } else {
          console.log("the opposite");
          checklistElement.remove();
          this.undoneTarget.insertAdjacentHTML("beforeend", input);
          if (checklistCardChild != undefined) {
            console.log("remove icon");
            checklistCard.style.color = "black";
            checklistCard.removeChild(checklistCardChild);
          }
        }
      });
  }
}
