import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["ticked"];

  connect() {
    console.log(this.contentTarget);
  }

  tickCheckbox() {
    this.tickedTarget.classList.add("border");
  }
}
