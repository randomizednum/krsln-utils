#!/bin/bash
#Downloads a file (using curl) and feeds that to oparse.lua.

curl -s "${1:-"https://bilimolimpiyatlari.tubitak.gov.tr/tr/duyurular"}" | oparsecli - "${2:--}"
