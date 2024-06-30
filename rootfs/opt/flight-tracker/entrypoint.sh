#!/bin/bash
set -e

IPATH=/usr/local/share/adsbexchange
LOGFILE="$IPATH/lastlog"

function enable_and_start_dump1090_fa_service() {
  if ! ls -l /etc/systemd/system/dump1090-fa.service 2>&1 | grep '/dev/null' &>/dev/null; then
    # Enable dump1090-fa service
    systemctl enable dump1090-fa || true
    # Start or restart dump1090-fa service
    systemctl restart dump1090-fa || true
  else
    echo "--------------------"
    echo "CAUTION, dump1090-fa.service is masked and won't run!"
    echo "If this is unexpected for you, please report this issue"
    echo "--------------------"
    sleep 3
  fi

  systemctl is-active dump1090-fa &>/dev/null || {
    echo "---------------------------------"
    journalctl -u dump1090-fa | tail -n10
    echo "---------------------------------"
    echo "dump1090-fa service couldn't be started."
    echo "Try an copy as much of the output above and include it in your report, thank you!"
    echo "---------------------------------"
    exit 1
  }
}

function enable_and_start_mlat_client_service() {
  if ! ls -l /etc/systemd/system/mlat-client.service 2>&1 | grep '/dev/null' &>/dev/null; then
    # Enable mlat-client service
    systemctl enable mlat-client || true
    # Start or restart mlat-client service
    systemctl restart mlat-client || true
  else
    echo "--------------------"
    echo "CAUTION, mlat-client.service is masked and won't run!"
    echo "If this is unexpected for you, please report this issue"
    echo "--------------------"
    sleep 3
  fi

  systemctl is-active mlat-client &>/dev/null || {
    echo "---------------------------------"
    journalctl -u mlat-client | tail -n10
    echo "---------------------------------"
    echo "mlat-client service couldn't be started."
    echo "Try an copy as much of the output above and include it in your report, thank you!"
    echo "---------------------------------"
    exit 1
  }
}

function enable_and_start_fr24feed_service() {
  if [[ -f /etc/fr24feed.ini ]]; then
    if ! ls -l /etc/systemd/system/fr24feed.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable fr24feed service
      systemctl enable fr24feed || true
      # Start or restart fr24feed service
      systemctl restart fr24feed || true
    else
      echo "--------------------"
      echo "CAUTION, fr24feed.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active fr24feed &>/dev/null || {
      echo "---------------------------------"
      journalctl -u fr24feed | tail -n10
      echo "---------------------------------"
      echo "fr24feed service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  fi
  echo -e "Missing /etc/fr24feed.ini, please check the Flightradar24 configuration."
}

function enable_and_start_rbfeeder_service() {
  if [[ -f /etc/rbfeeder.ini ]]; then
    if ! ls -l /etc/systemd/system/rbfeeder.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable rbfeeder service
      systemctl enable rbfeeder || true
      # Start or restart rbfeeder service
      systemctl restart rbfeeder || true
    else
      echo "--------------------"
      echo "CAUTION, rbfeeder.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active rbfeeder &>/dev/null || {
      echo "---------------------------------"
      journalctl -u rbfeeder | tail -n10
      echo "---------------------------------"
      echo "rbfeeder service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  fi
  echo -e "Missing /etc/rbfeeder.ini, please check the AirNav RadarBox configuration."
}

function enable_and_start_piaware_service() {
  if [[ -f /etc/piaware.conf ]]; then
    if ! ls -l /etc/systemd/system/piaware.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable piaware service
      systemctl enable piaware || true
      # Start or restart piaware service
      systemctl restart piaware || true
    else
      echo "--------------------"
      echo "CAUTION, piaware.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active piaware &>/dev/null || {
      echo "---------------------------------"
      journalctl -u piaware | tail -n10
      echo "---------------------------------"
      echo "piaware service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  fi
  echo -e "Missing /etc/rbfeeder.ini, please check the AirNav RadarBox configuration."
}

function enable_and_start_pfclient_service() {
  if [[ -f /etc/pfclient-config.json ]]; then
    if ! ls -l /etc/systemd/system/pfclient.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable pfclient service
      systemctl enable pfclient || true
      # Start or restart pfclient service
      systemctl restart pfclient || true
    else
      echo "--------------------"
      echo "CAUTION, pfclient.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active pfclient &>/dev/null || {
      echo "---------------------------------"
      journalctl -u pfclient | tail -n10
      echo "---------------------------------"
      echo "pfclient service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  fi
  echo -e "Missing /etc/pfclient-config.json, please check the AirNav RadarBox configuration."
}

function enable_and_start_adsbexchange_feed_service() {
  if ! ls -l /etc/systemd/system/adsbexchange-feed.service 2>&1 | grep '/dev/null' &>/dev/null; then
    # Enable adsbexchange-feed service
    systemctl enable adsbexchange-feed >> $LOGFILE || true
    # Start or restart adsbexchange-feed service
    systemctl restart adsbexchange-feed || true
  else
    echo "--------------------"
    echo "CAUTION, adsbexchange-feed.service is masked and won't run!"
    echo "If this is unexpected for you, please report this issue"
    echo "--------------------"
    sleep 3
  fi

  systemctl is-active adsbexchange-feed &>/dev/null || {
    rm -f $IPATH/readsb_version
    echo "---------------------------------"
    journalctl -u adsbexchange-feed | tail -n10
    echo "---------------------------------"
    echo "adsbexchange-feed service couldn't be started, please report this error to the adsbexchange forum or discord."
    echo "Try an copy as much of the output above and include it in your report, thank you!"
    echo "---------------------------------"
    exit 1
  }
}

function enable_and_start_adsbexchange_mlat_service() {
  if [[ "$LATITUDE" == 0 ]] || [[ "$LONGITUDE" == 0 ]] || [[ "$USER" == 0 ]]; then
    MLAT_DISABLED=1
  else
    MLAT_DISABLED=0
  fi

  if ls -l /etc/systemd/system/adsbexchange-mlat.service 2>&1 | grep '/dev/null' &>/dev/null; then
    echo "--------------------"
    echo "CAUTION, adsbexchange-mlat is masked and won't run!"
    echo "If this is unexpected for you, please report this issue"
    echo "--------------------"
    sleep 3
  else
    if [[ "${MLAT_DISABLED}" == "1" ]]; then
      systemctl disable adsbexchange-mlat || true
      systemctl stop adsbexchange-mlat || true
    else
      # Enable adsbexchange-mlat service
      systemctl enable adsbexchange-mlat >> $LOGFILE || true
      # Start or restart adsbexchange-mlat service
      systemctl restart adsbexchange-mlat || true
    fi
  fi

  [[ "${MLAT_DISABLED}" == "1" ]] || systemctl is-active adsbexchange-mlat &>/dev/null || {
    rm -f $IPATH/mlat_version
    echo "---------------------------------"
    journalctl -u adsbexchange-mlat | tail -n10
    echo "---------------------------------"
    echo "adsbexchange-mlat service couldn't be started, please report this error to the adsbexchange forum or discord."
    echo "Try an copy as much of the output above and include it in your report, thank you!"
    echo "---------------------------------"
    exit 1
  }
}

function enable_and_start_adsbexchange_stats_service() {
  if ! ls -l /etc/systemd/system/adsbexchange-stats.service 2>&1 | grep '/dev/null' &>/dev/null; then
    # Enable adsbexchange-feed service
    systemctl enable adsbexchange-stats >> $LOGFILE || true
    # Start or restart adsbexchange-feed service
    systemctl restart adsbexchange-stats || true
  else
    echo "--------------------"
    echo "CAUTION, adsbexchange-stats.service is masked and won't run!"
    echo "If this is unexpected for you, please report this issue"
    echo "--------------------"
    sleep 3
  fi

  systemctl is-active adsbexchange-stats &>/dev/null || {
    echo "---------------------------------"
    journalctl -u adsbexchange-stats | tail -n10
    echo "---------------------------------"
    echo "adsbexchange-stats service couldn't be started, please report this error to the adsbexchange forum or discord."
    echo "Try an copy as much of the output above and include it in your report, thank you!"
    echo "---------------------------------"
    exit 1
  }
}

enable_and_start_planespotters_service() {
  if [[ -f /etc/planespotters/feedclient ]] && [[ -f /etc/planespotters/uuid ]]; then
    if ! ls -l /etc/systemd/system/planespotters-feed.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable adsbexchange-feed service
      systemctl enable planespotters-feed >> $LOGFILE || true
      # Start or restart adsbexchange-feed service
      systemctl restart planespotters-feed || true
    else
      echo "--------------------"
      echo "CAUTION, planespotters-feed.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active planespotters-feed &>/dev/null || {
      echo "---------------------------------"
      journalctl -u planespotters-feed | tail -n10
      echo "---------------------------------"
      echo "planespotters-feed service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  else
    echo -e "Missing /etc/planespotters/feedclient or /etc/planespotters/uuid, please check the Planespotters.net configuration."
  }
  fi
}

enable_and_start_planespotters_feed_service() {
  if [[ -f /etc/planespotters/feedclient ]] && [[ -f /etc/planespotters/uuid ]]; then
    if ! ls -l /etc/systemd/system/planespotters-feed.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable adsbexchange-feed service
      systemctl enable planespotters-feed >> $LOGFILE || true
      # Start or restart adsbexchange-feed service
      systemctl restart planespotters-feed || true
    else
      echo "--------------------"
      echo "CAUTION, planespotters-feed.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active planespotters-feed &>/dev/null || {
      echo "---------------------------------"
      journalctl -u planespotters-feed | tail -n10
      echo "---------------------------------"
      echo "planespotters-feed service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }

    if ! ls -l /etc/systemd/system/planespotters-mlat-client.service 2>&1 | grep '/dev/null' &>/dev/null; then
      # Enable adsbexchange-mlat-client service
      systemctl enable planespotters-mlat-client >> $LOGFILE || true
      # Start or restart adsbexchange-mlat-client service
      systemctl restart planespotters-mlat-client || true
    else
      echo "--------------------"
      echo "CAUTION, planespotters-mlat-client.service is masked and won't run!"
      echo "If this is unexpected for you, please report this issue"
      echo "--------------------"
      sleep 3
    fi

    systemctl is-active planespotters-mlat-client &>/dev/null || {
      echo "---------------------------------"
      journalctl -u planespotters-mlat-client | tail -n10
      echo "---------------------------------"
      echo "planespotters-mlat-client service couldn't be started."
      echo "Try an copy as much of the output above and include it in your report, thank you!"
      echo "---------------------------------"
      exit 1
    }
  else
    echo -e "Missing /etc/planespotters/feedclient or /etc/planespotters/uuid, please check the Planespotters.net configuration."
  }
  fi
}

# Make sure all services have been installed
RUN systemctl list-units 'adsbexchange-*' 'dump1090-*' 'fr24feed*' 'pfclient*' 'piaware*' \
    'planespotters*' 'rbfeeder*' 'dump978-*' 'mlat*'

enable_and_start_dump1090_fa_service

if [[ SRV_MLAT_CLIENT]] then
  enable_and_start_mlat_client_service
fi

# fr24feed for Flightradar24
if [[ SRV_FR24FEED ]] then
  if [[ SRV_INIT_FR24FEED ]] then
    source /opt/flight-tracker/initialise-fr24feed
  fi

  enable_and_start_fr24feed_service
fi

# rbfeeder for RadarBox
if [[ SRV_RBFEEDER ]] then
  enable_and_start_rbfeeder_service
fi

# piaware for FlightAware
if [[ SRV_PIAWARE ]] then
  if [[ SRV_INIT_FR24FEED ]] then
    source /opt/flight-tracker/initialise-piaware $SRV_PARAM_PIAWARE_FEEDER_ID $SRV_PARAM_PIAWARE_RECEIVER_HOST \
    $SRV_PARAM_PIAWARE_RECEIVER_PORT $SRV_PARAM_PIAWARE_ALLOW_MLAT $SRV_PARAM_PIAWARE_MLAT_RESULTS
  fi
  enable_and_start_piaware_service
fi

# pfclient for planefinder.net
if [[ SRV_PFCLIENT ]] then
  enable_and_start_pfclient_service
fi

# feedclient for ADS-B Exchange
if [[ SRV_ADSBEXCHANGE ]] then
  if [[ SRV_INIT_ADSBEXCHANGE ]] then
    source /opt/flight-tracker/initialise-feedclient $SRV_PARAM_ADSBEXCHANGE_ADSBEXCHANGEUSERNAME $SRV_PARAM_ADSBEXCHANGE_RECEIVERLATITUDE $SRV_PARAM_ADSBEXCHANGE_RECEIVERLONGITUDE
    if [[ -z $INPUT ]] || [[ -z $INPUT_TYPE ]] || [[ -z $USER ]] \
    || [[ -z $LATITUDE ]] || [[ -z $LONGITUDE ]] || [[ -z $ALTITUDE ]] \
    || [[ -z $MLATSERVER ]] || [[ -z $TARGET ]] || [[ -z $NET_OPTIONS ]]; then
      echo -e "Error initialising feedclient for ADS-B Exchange, please check the provided environment variables."
      exit 1
    fi
  fi

  enable_and_start_adsbexchange_feed_service
  enable_and_start_adsbexchange_mlat_service

  # in case the mlat-client service using /etc/default/mlat-client as config is using adsbexchange as a host, disable the service
  if grep -qs 'SERVER_HOSTPORT.*feed.adsbexchange.com' /etc/default/mlat-client &>/dev/null; then
    systemctl disable --now mlat-client >> $LOGFILE 2>&1 || true
  fi

  if [[ -f /etc/default/adsbexchange ]]; then
    sed -i -e 's/feed.adsbexchange.com,30004,beast_reduce_out,feed.exchangeable.com,64004/feed1.adsbexchange.com,30004,beast_reduce_out,feed2.adsbexchange.com,64004/' /etc/default/adsbexchange || true
  fi
fi

# adsbexchange-stats for ADS-B Exchange
if [[ $SRV_ADSBEXCHANGE_STATS ]] then
  if [[ $SRV_ADSBEXCHANGE ]] then
    enable_and_start_adsbexchange_stats_service
  fi
  echo -e "ADS-B Exchange service must be enabled and running to start the stats service."
fi

# planespotter-feed and planespotter-mlat-client for Planespotters.net
if [[ $SRV_PLANESPOTTERS ]] then
  if [[ $SRV_INIT_PLANESPOTTERS ]] then
    source /opt/flight-tracker/initialise-planespotters
  fi

  enable_and_start_planespotters_service
fi