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

        const isFood = data.item.tag_list.includes("food")
          ? `${data.trip.no_of_people}x ${data.item.name}`
          : `${data.item.name}`;

        const input = `
          <div class="checklist-box-padding">
            <input data-action="change->checklist#inputCheckbox"
              data-checklist-target="input" type="checkbox" id="${data.checklist.id}"
              data-checklist-id="${data.checklist.id}"
              name="${data.checklist.id}"
              value="${data.checklist.id}"
              ${isChecked}
            >
            <label for="${data.checklist.id}">
              ${isFood}
            </label>
            ${isCheckedBadgeLists}
          </div>
        `;

        const input_icon = `<span id="${data.category}-icon" style="font-size:1.5rem;"> <i class="far fa-check-circle"></i></span>`;

        const checklistElement = document
          .getElementById(`${data.checklist.id}`)
          .closest(".checklist-box-padding");

        const checklistCompleteSection =
          document.getElementById("checklist-complete");
        const checklistCard = document.getElementById(`${data.category}`);
        const checklistCardChild = document.getElementById(
          `${data.category}-icon`
        );

        const isCheckListCompleted = data.check_all
          ? (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-check-circle" style="color:darkcyan;"></i> Checklist completed!</div>`)
          : (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-exclamation-circle" style="color:firebrick;"></i> Checklist is not complete!</div>`);
        if (data.checklist.checked) {
          checklistElement.remove();
          this.doneTarget.insertAdjacentHTML("beforeend", input);

          isCheckListCompleted;

          if (data.check == true) {
            checklistCard.insertAdjacentHTML("beforeend", input_icon);
            checklistCard.style.color = "green";
          } else {
            if (checklistCardChild != undefined) {
              checklistCard.style.color = "black";
              checklistCard.removeChild(checklistCardChild);
            }
          }
        } else {
          checklistElement.remove();
          this.undoneTarget.insertAdjacentHTML("beforeend", input);
          isCheckListCompleted;
          if (checklistCardChild != undefined) {
            checklistCard.style.color = "black";
            checklistCard.removeChild(checklistCardChild);
          }
        }
      });
  }
}
