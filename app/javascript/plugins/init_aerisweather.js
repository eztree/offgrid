import AerisWeather from '@aerisweather/javascript-sdk';
import '@aerisweather/javascript-sdk/dist/styles/sass/styles.scss';

const AERIS_CLIENT_ID = 'ytDT8G1WiJCpzUmYEPqFW';
const AERIS_CLIENT_SECRET = 'cMYABZI74d4JPVrvBBBBauoSpqILF3YRVambv2kM';

const aeris = new AerisWeather(AERIS_CLIENT_ID, AERIS_CLIENT_SECRET);

const initAerisWeather = async () => {
  const target = document.getElementById('forecast');

  if (target) { // Puts in the weather data only if there's a div#forecast
    const checkpoints = JSON.parse(target.dataset.checkpoints);
    const tripDates = JSON.parse(target.dataset.tripDates);

    const requests = checkpoints.map((point, index) => {
      const tripDate = `${tripDates[index]}`;
      return aeris.api().endpoint('forecasts').place(`${point.latitude},${point.longitude}`).from(tripDate).to(tripDate);
    })
    
    const responses = await Promise.all(
      requests.map(req => req.get())
    )

      responses.forEach((response) => {
        let period = response.data[0].periods[0];
        let date = new Date(period.dateTimeISO);
        let icon = `https://cdn.aerisapi.com/wxblox/icons/${period.icon || 'na.png'}`;
        let maxTempC = period.maxTempC || 'N/A';
        let minTempC = period.minTempC || 'N/A';
        let weather = period.weatherPrimary || 'N/A';

        const html = (`
          <div class="card">
            <div class="card-body">
              <p class="title">${aeris.utils.dates.format(date, 'eeee')}</p>
              <p><img class="icon" src="${icon}"></p>
              <p class="wx">${weather}</p>
              <p class="temps"><span>High:</span>${maxTempC}°C <span>Low:</span>${minTempC}°C</p>
            </div>
          </div>
        `);
        target.insertAdjacentHTML('afterbegin', html);
      })
  }
}

export { initAerisWeather };
