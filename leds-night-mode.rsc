#!rsc by RouterOS
# RouterOS script: leds-night-mode
# Copyright (c) 2013-2025 Christian Hesse <mail@eworm.de>
# https://rsc.eworm.de/COPYING.md
#
# disable LEDs
# https://rsc.eworm.de/doc/leds-mode.md

/system/leds/settings/set all-leds-off=immediate;
