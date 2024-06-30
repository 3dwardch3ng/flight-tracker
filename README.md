# flight-tracker

## WIP: Please do not use this yet.

### Note: 
1. Below services have been installed but have been disabled. You will need to specify which service/s you want to enable via the environment variables.

| UNIT                              | DESCRIPTION                                         | PORTS                                               |
|-----------------------------------|-----------------------------------------------------|-----------------------------------------------------|
| adsbexchange-feed.service         | adsbexchange-feed                                   | 30154 (feed-adsbx)                                  |
| adsbexchange-mlat.service         | adsbexchange-mlat                                   |                                                     |
| adsbexchange-stats.service        | adsbexchange-stats                                  |                                                     |
| dump1090-fa.service               | dump1090 ADS-B receiver (FlightAware customization) | 30001 30002 30003 30004 30005 30104 4999…9999 (UDP) |
| fr24feed.service                  | Flightradar24 Decoder & Feeder                      | 8754 30334                                          |
| mlat-client.service               | LSB: Multilateration client                         | 30106                                               |
| pfclient.service                  | LSB: planefinder.net ads-b decoder                   | 30053 30054                                         |
| piaware.service                   | FlightAware ADS-B uploader                          | 30105 (fa-mlat-clie) 30106 (fa-mlat-clie)           |
| planespotters-feed.service        | Planespotters.net Radar Feed                        |                                                     |
| planespotters-mlat-client.service | Planespotters.net MLAT Client                       |                                                     |
| rbfeeder.service                  | RBFeeder Service                                    | 32004 32008 32088 32457 32458 32459                 |
| -                                 |  -                                                  | (lighttpd) 80 8080 8504                             |
2. If you enabled multiple services including the FlightRadar24, you then should not enable the MLAT for FlightRadar24 as instructed by FR24.
3. You will need to attach your USB rtl-sdr dongle to the same instance which your docker container is running on, and mapping the device/s under the /dev for this USB device to the container.

### Environment Variables:
| ENVIRONMENT VARIABLE | DEFAULT VALUE | DESCRIPTION                                                                                   |
|----------------------|---------------|-----------------------------------------------------------------------------------------------|
| ENABLE_ADSBEXCHANGE  | false         | Enable adsbexchange services                                                                 |