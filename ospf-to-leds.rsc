#!rsc by RouterOS
# RouterOS script: ospf-to-leds
# Copyright (c) 2020-2025 Christian Hesse <mail@eworm.de>
# https://rsc.eworm.de/COPYING.md
#
# requires RouterOS, version=7.15
#
# visualize ospf instance state via leds
# https://rsc.eworm.de/doc/ospf-to-leds.md

:local ExitOK false;
:onerror Err {
  :global GlobalConfigReady; :global GlobalFunctionsReady;
  :retry { :if ($GlobalConfigReady != true || $GlobalFunctionsReady != true) \
      do={ :error ("Global config and/or functions not ready."); }; } delay=500ms max=50;
  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ParseKeyValueStore;
  :global ScriptLock;

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :set ExitOK true;
    :error false;
  }

  :foreach Instance in=[ /routing/ospf/instance/find where comment~"^ospf-to-leds," ] do={
    :local InstanceVal [ /routing/ospf/instance/get $Instance ];
    :local LED ([ $ParseKeyValueStore ($InstanceVal->"comment") ]->"leds");
    :local LEDType [ /system/leds/get [ find where leds=$LED ] type ];

    :local NeighborCount 0;
    :foreach Area in=[ /routing/ospf/area/find where instance=($InstanceVal->"name") ] do={
      :local AreaName [ /routing/ospf/area/get $Area name ];
      :set NeighborCount ($NeighborCount + [ :len [ /routing/ospf/neighbor/find where area=$AreaName ] ]);
    }

    :if ($NeighborCount > 0 && $LEDType = "off") do={
      $LogPrint info $ScriptName ("OSPF instance " . $InstanceVal->"name" . " has " . $NeighborCount . " neighbors, led on!");
      /system/leds/set type=on [ find where leds=$LED ];
    }
    :if ($NeighborCount = 0 && $LEDType = "on") do={
      $LogPrint info $ScriptName ("OSPF instance " . $InstanceVal->"name" . " has no neighbors, led off!");
      /system/leds/set type=off [ find where leds=$LED ];
    }
  }
} do={
  :global ExitError; $ExitError $ExitOK [ :jobname ] $Err;
}
