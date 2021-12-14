import AerisWeather from "@aerisweather/javascript-sdk";
import "@aerisweather/javascript-sdk/dist/styles/sass/styles.scss";

const AERIS_CLIENT_ID = "CJMrC5sBomVTjYPxx8dxG";
const AERIS_CLIENT_SECRET = "yWuh731VBcBGj5qorpnlaZaHZysa5XyC5nWhy5Zv";

const aeris = new AerisWeather(AERIS_CLIENT_ID, AERIS_CLIENT_SECRET);

const initAerisWeather = async () => {
  let target = "";
  if (window.location.pathname.includes("dashboard")) {
    target = document.getElementById("forecast");
  } else {
    target = document.getElementById("forecast_trip");
  }

  if (target) {
    // Puts in the weather data only if there's a div#forecast
    const checkpoints = JSON.parse(target.dataset.checkpoints);
    const tripDates = JSON.parse(target.dataset.tripDates);

    const requests = checkpoints.map((point, index) => {
      const tripDate = `${tripDates[index]}`;
      return aeris
        .api()
        .endpoint("forecasts")
        .place(`${point.latitude},${point.longitude}`)
        .from(tripDate)
        .to(tripDate);
    });

    const responses = await Promise.all(requests.map((req) => req.get()));
    let count = 0;
    responses.forEach((response, index) => {
      count += 1;
      let period = response.data[0].periods[0];
      let date = new Date(period.dateTimeISO);
      let icon = `https://raw.githubusercontent.com/eztree/Sandbox/master/app/assets/images/weather/${
        period.icon || "na.png"
      }`;
      let maxTempC = period.maxTempC || "N/A";
      let minTempC = period.minTempC || "N/A";
      let weather = period.weatherPrimary || "N/A";

      let html = "";
      if (window.location.pathname.includes("dashboard/mobile")) {
        html = `
          <div class="w-card">
            <div class="dashboard-card-body">
              <p class="mobile-title">${aeris.utils.dates.format(
                date,
                "eee"
              )}</p>
              <p><img class="mobile-icon" src="${icon}"></p>
              <p class="mobile-wx">${weather}</p>
              <p class="mobile-temps"><span>${maxTempC}°C / ${minTempC}°C</span></p>
            </div>
          </div>
        `;
      } else if (window.location.pathname.includes("dashboard")) {
        html = `
          <div class="w-card">
            <div class="card-body">
              <p class="title">${aeris.utils.dates.format(date, "eee")}</p>
              <p><img class="icon" src="${icon}"></p>
              <p class="wx">${weather}</p>
              <p class="temps"><span>${maxTempC}°C / ${minTempC}°C</span></p>
            </div>
          </div>
        `;
      } else {
        const breakfast_arr = JSON.parse(target.dataset.breakfast);
        const meal_arr = JSON.parse(target.dataset.meal);
        const checkpoint_arr = JSON.parse(target.dataset.checkpointsName);
        console.log(checkpoint_arr);
        html = `
            <div class="card">
              <div class="card-header" id="heading${count}">
                <h2 class="mb-0">
                  <button class="btn btn-link btn-block text-left text-black" type="button" data-toggle="collapse" data-target="#collapse${count}" aria-expanded="true" aria-controls="collapse${count}">
                    Day ${count} – ${date.toDateString()}
                  </button>
                </h2>
              </div>
              <div id="collapse${count}" class="collapse" aria-labelledby="heading${count}" data-parent="#accordionDay">
                <div class="p-2">
                  <div>You'll be hiking from <strong>${checkpoint_arr[index]}</strong> to <strong>${checkpoint_arr[index + 1]}</strong> today.</div>
                </div>
                <div class="d-flex">
                  <div class="w-card p-3 text-center" style="border-right: 1px solid rgba(0,0,0,0.125); border-top: 1px solid rgba(0,0,0,0.125);">
                    <div class="card-body mx-4">
                      <p><img class="icon" src="${icon}"></p>
                      <p class="wx">${weather}</p>
                      <p class="temps"><span>${maxTempC}°C / ${minTempC}°C</span></p>
                    </div>
                  </div>
                  <table class="table">
                    <thead>
                      <tr>
                        <th scope="col">Meal</th>
                        <th scope="col">Food</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <th scope="row">Breakfast</th>
                        <td>${
                          breakfast_arr[
                            Math.floor(Math.random() * breakfast_arr.length)
                          ]
                        }</td>
                      </tr>
                      <tr>
                        <th scope="row">Lunch</th>
                        <td>${
                          meal_arr[
                            Math.floor(Math.random() * meal_arr.length)
                          ]
                        }</td>
                      </tr>
                      <tr>
                        <th scope="row">Dinner</th>
                        <td>${
                          meal_arr[
                            Math.floor(Math.random() * meal_arr.length)
                          ]
                        }</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>`;
      }
      target.insertAdjacentHTML("beforeend", html);
    });
  }
};

export { initAerisWeather };
