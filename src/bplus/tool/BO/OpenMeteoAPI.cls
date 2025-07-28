Class bplus.tool.BO.OpenMeteoAPI Extends Ens.BusinessOperation
{

Method OnMensage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
        Set tSC = $$$OK
        Try {

            Set tSC = ..FetchWeatherData(pRequest.startDate, pRequest.endDate, .response)
            Set pResponse = ##class(bplus.tool.msg.Resp).%New()
            Set pResponse.content = response
            
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        
        Return $$$OK
}

ClassMethod FetchWeatherData(startDate As %String, endDate As %String) As %String(MAXLEN=100000) [ Language = python ]
{
        import openmeteo_requests

        import pandas as pd
        import requests_cache
        from retry_requests import retry

        cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
        retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
        openmeteo = openmeteo_requests.Client(session = retry_session)

        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            "latitude": -22.822099,
            "longitude": -51.583474,
            "hourly": ["global_tilted_irradiance_instant", "global_tilted_irradiance"],
            "minutely_15": ["global_tilted_irradiance", "global_tilted_irradiance_instant"],
            "timezone": "America/Sao_Paulo",
            "azimuth": 1.6,
            "start_date": startDate,
            "end_date": endDate,
        }
        responses = openmeteo.weather_api(url, params=params)

        response = responses[0]
        print(f"Coordinates: {response.Latitude()}°N {response.Longitude()}°E")
        print(f"Elevation: {response.Elevation()} m asl")
        print(f"Timezone: {response.Timezone()}{response.TimezoneAbbreviation()}")
        print(f"Timezone difference to GMT+0: {response.UtcOffsetSeconds()}s")

        minutely_15 = response.Minutely15()
        minutely_15_global_tilted_irradiance = minutely_15.Variables(0).ValuesAsNumpy()
        minutely_15_global_tilted_irradiance_instant = minutely_15.Variables(1).ValuesAsNumpy()

        minutely_15_data = {"date": pd.date_range(
            start = pd.to_datetime(minutely_15.Time(), unit = "s", utc = True),
            end = pd.to_datetime(minutely_15.TimeEnd(), unit = "s", utc = True),
            freq = pd.Timedelta(seconds = minutely_15.Interval()),
            inclusive = "left"
        )}

        minutely_15_data["global_tilted_irradiance"] = minutely_15_global_tilted_irradiance
        minutely_15_data["global_tilted_irradiance_instant"] = minutely_15_global_tilted_irradiance_instant

        minutely_15_dataframe = pd.DataFrame(data = minutely_15_data)
        print("\nMinutely15 data\n", minutely_15_dataframe)

        hourly = response.Hourly()
        hourly_global_tilted_irradiance_instant = hourly.Variables(0).ValuesAsNumpy()
        hourly_global_tilted_irradiance = hourly.Variables(1).ValuesAsNumpy()

        hourly_data = {"date": pd.date_range(
            start = pd.to_datetime(hourly.Time(), unit = "s", utc = True),
            end = pd.to_datetime(hourly.TimeEnd(), unit = "s", utc = True),
            freq = pd.Timedelta(seconds = hourly.Interval()),
            inclusive = "left"
        )}

        hourly_data["global_tilted_irradiance_instant"] = hourly_global_tilted_irradiance_instant
        hourly_data["global_tilted_irradiance"] = hourly_global_tilted_irradiance

        hourly_dataframe = pd.DataFrame(data = hourly_data)
        return hourly_dataframe
}

}
