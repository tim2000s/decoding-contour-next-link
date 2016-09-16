#! /bin/bash
# Initialising Carelink Automation
# Proof of concept ONLY - 640g csv to NightScout
# ****************************************************************************************
# USER SPECIFIC Variables - Please enter your values here
# ****************************************************************************************
api_secret_hash='adaaf9099c71096fb2175cc9a4d180eea8c79964' # This is the SHA-1 Hash of your API-SECRET string - eg "ASANEXAMPLE1" is transformed into...
your_nightscout='https://tjs-2.azurewebsites.net' #'https://something.azurewebsites.net'
gap_seconds=300 # between polling pump
cron_ok=1 # change to 0 if you don't want to run as cron (set to run at boot time is recommended)
cron_delay=20 # seconds to test if cron started
