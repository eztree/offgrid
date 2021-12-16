import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input", "done", "undone", "completed"];
  connect() {
    console.log("stimulus connected");
  }

  async inputCheckbox(e) {
    e.preventDefault();
    const token = document.getElementsByName("csrf-token")[0].content;
    await fetch(
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
        const isChecked = data.checklist.checked ? "checked" : "";

        const badgeListsChecked = data.tag_lists.includes("optional")
          ? `<span class="badge badge-pill badge-secondary">optional</span>`
          : "";

        const isFood = data.item.tag_list.includes("food")
          ? `${data.trip.no_of_people}x ${data.item.name}`
          : `${data.item.name}`;

        // INSERT HTML TAG
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
            ${badgeListsChecked}
          </div>
        `;

        const isCategoryChecked = data.check ? "checked" : "";
        const isCategoryCheckedText = data.check
          ? "Uncheck all!"
          : "Check all!";

        const input_icon = `<i class="fas fa-check-circle" style="color:darkcyan;"></i>`;
        const input_icon_false = `${data.done_checklist_count} / ${data.checklist_count}
                          <i class="fas fa-exclamation-circle" style="color:#cc3300;"></i>`;

        const input_category = `
          <input data-action="change->checklist#inputCheckboxAll"
            data-checklist-target="all" type="checkbox" id="category-${data.category}"
            data-trip-id="${data.trip.id}"
            data-category-name="${data.category}"
            data-category-check="${data.check}"
            name="category-${data.category}"
            value="category-${data.category}"
            ${isCategoryChecked}
          >
          <label for="category-${data.category}">
            ${isCategoryCheckedText}
          </label>
          `;

        // INSERT HTML TAG END
        // Queryselectors
        const checklistElement = document
          .getElementById(`${data.checklist.id}`)
          .closest(".checklist-box-padding");

        const checklistCategoryElement = document
          .getElementById(`category-${data.category}`)
          .closest(".category-div");

        const checklistCompleteSection =
          document.getElementById("checklist-complete");
        const checklistCard = document.getElementById(`${data.category}`);
        const checklistCardChild = document.getElementById(
          `${data.category}-icon`
        );

        const checklistCardCheckIcon = document.getElementById(
          `${data.category}-check-icon`
        );
        // const checklistCategory = document.getElementById(
        //   `category-${data.category}`
        // );
        // Queryselectors END
        // Add green tick icon at header
        const isCheckListCompleted = data.check_all
          ? (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-check-circle" style="color:darkcyan;"></i> Checklist completed!</div>`)
          : (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-exclamation-circle" style="color:firebrick;"></i> Checklist is not complete!</div>`);
        // if single checkbox ticked
        if (data.checklist.checked) {
          checklistElement.remove();
          this.doneTarget.insertAdjacentHTML("beforeend", input);

          isCheckListCompleted;

          // if all checkbox are ticked
          if (data.check) {
            checklistCardCheckIcon.innerHTML = "";
            checklistCardCheckIcon.insertAdjacentHTML("beforeend", input_icon);
            checklistCategoryElement.innerHTML = "";
            checklistCategoryElement.insertAdjacentHTML(
              "beforeend",
              input_category
            );
          } else {
            checklistCardCheckIcon.innerHTML = "";
            checklistCardCheckIcon.insertAdjacentHTML(
              "beforeend",
              input_icon_false
            );
          }
        } else {
          checklistElement.remove();
          this.undoneTarget.insertAdjacentHTML("beforeend", input);
          isCheckListCompleted;
          checklistCategoryElement.innerHTML = "";
          checklistCategoryElement.insertAdjacentHTML(
            "beforeend",
            input_category
          );
          checklistCardCheckIcon.innerHTML = "";
          checklistCardCheckIcon.insertAdjacentHTML(
            "beforeend",
            input_icon_false
          );

          // if (data.checked == false) {
          //   checklistCategoryElement.remove();
          //   checklistCardCheckIcon.innerHTML = "";
          //   checklistCardCheckIcon.insertAdjacentHTML(
          //     "beforeend",
          //     input_icon_false
          //   );
          // }
        }
        // Add green tick icon at header END
        // Change category checkbox

        // Change category checkbox END
      });
  }

  async inputCheckboxAll(e) {
    const tripId = e.currentTarget.attributes["data-trip-id"].value;
    const categoryName = e.currentTarget.attributes["data-category-name"].value;
    const categoryCheck =
      e.currentTarget.attributes["data-category-check"].value;
    const token = document.getElementsByName("csrf-token")[0].content;
    await fetch(`/trips/${tripId}/${categoryName}/${categoryCheck}?`, {
      method: "PATCH",
      headers: {
        Accept: "text/plain",
        "X-CSRF-Token": token,
      },
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        // INITIALIZE VARIABLE
        const isCategoryChecked = data.check ? "checked" : "";
        const isCategoryCheckedText = data.check
          ? "Uncheck all!"
          : "Check all!";

        // QUERY SELECTOR
        const checklistCategoryElement = document
          .getElementById(`category-${data.category}`)
          .closest(".category-div");
        const checklistCard = document.getElementById(`${data.category}`);
        const checklistCardChild = document.getElementById(
          `${data.category}-icon`
        );
        const checklistCardCheckIcon = document.getElementById(
          `${data.category}-check-icon`
        );
        const checklistCompleteSection =
          document.getElementById("checklist-complete");

        const doneElement = document.getElementById("done");
        const undoneElement = document.getElementById("undone");
        // INPUT

        const input_category = `
          <input data-action="change->checklist#inputCheckboxAll"
            data-checklist-target="all" type="checkbox" id="category-${data.category}"
            data-trip-id="${data.trip.id}"
            data-category-name="${data.category}"
            data-category-check="${data.check}"
            name="category-${data.category}"
            value="category-${data.category}"
            ${isCategoryChecked}
          >
          <label for="category-${data.category}">
            ${isCategoryCheckedText}
          </label>
          `;

        const isCheckListCompleted = data.check_all
          ? (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-check-circle" style="color:darkcyan;"></i> Checklist completed!</div>`)
          : (checklistCompleteSection.innerHTML = `<div class="mr-2"><i class="fas fa-exclamation-circle" style="color:firebrick;"></i> Checklist is not complete!</div>`);

        const input_icon = `<i class="fas fa-check-circle" style="color:darkcyan;"></i>`;
        const input_icon_false = `${data.done_checklist_count} / ${data.checklist_count}
                          <i class="fas fa-exclamation-circle" style="color:#cc3300;"></i>`;
        // LOGIC
        // change category checkbox
        checklistCategoryElement.innerHTML = "";
        checklistCategoryElement.insertAdjacentHTML(
          "beforeend",
          input_category
        );
        // checklists completed status at top of page
        isCheckListCompleted;
        // checklist completed status at category header
        if (data.check) {
          checklistCardCheckIcon.innerHTML = "";
          checklistCardCheckIcon.insertAdjacentHTML("beforeend", input_icon);
        } else {
          checklistCardCheckIcon.innerHTML = "";
          checklistCardCheckIcon.insertAdjacentHTML(
            "beforeend",
            input_icon_false
          );
        }

        data.checklists.forEach((checklist) => {
          // debugger;
          const checklistElement = document
            .getElementById(`${checklist.checklist_id}`)
            .closest(".checklist-box-padding");
          const isChecked = checklist.checklist_status ? "checked" : "";
          const badgeListsChecked = checklist.tag_list.includes("optional")
            ? `<span class="badge badge-pill badge-secondary">optional</span>`
            : "";
          const isFood = checklist.tag_list.includes("food")
            ? `${data.trip.no_of_people}x ${checklist.name}`
            : `${checklist.name}`;

          const input = `
              <div class="checklist-box-padding">
                <input data-action="change->checklist#inputCheckbox"
                  data-checklist-target="input" type="checkbox" id="${checklist.checklist_id}"
                  data-checklist-id="${checklist.checklist_id}"
                  name="${checklist.checklist_id}"
                  value="${checklist.checklist_id}"
                  ${isChecked}
                >
                <label for="${checklist.checklist_id}">
                  ${isFood}
                </label>
                ${badgeListsChecked}
              </div>
            `;
          checklistElement.remove();
          const isDone = data.check
            ? this.doneTarget.insertAdjacentHTML("beforeend", input)
            : this.undoneTarget.insertAdjacentHTML("beforeend", input);
          isDone;
        });
      });
  }
}
