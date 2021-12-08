import AerisWeather from '@aerisweather/javascript-sdk';
import '@aerisweather/javascript-sdk/dist/styles/sass/styles.scss';

const AERIS_CLIENT_ID = 'ytDT8G1WiJCpzUmYEPqFW';
const AERIS_CLIENT_SECRET = 'cMYABZI74d4JPVrvBBBBauoSpqILF3YRVambv2kM';

const aeris = new AerisWeather(AERIS_CLIENT_ID, AERIS_CLIENT_SECRET);

const initAerisWeather = () => {
  const weatherElement = document.getElementById('aeris-weather-cards');
  const target = document.getElementById('forecast');

  if (target) { // Puts in the weather data only if there's a div#aeris-weather-cards
      window.onload = () => {
        const request = aeris.api().endpoint('forecasts').place('-43.72091834,170.065166961').limit(3);
        request.get().then((result) => {
            const data = result.data;
            const { periods } = data[0];
            if (periods) {
                periods.reverse().forEach(period => {
                    const date = new Date(period.dateTimeISO);
                    const icon = `https://cdn.aerisapi.com/wxblox/icons/${period.icon || 'na.png'}`;
                    const maxTempC = period.maxTempC || 'N/A';
                    const minTempC = period.minTempC || 'N/A';
                    const weather = period.weatherPrimary || 'N/A';
      
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
                });
            }
        }); 
      }
    };
  }



export { initAerisWeather };
