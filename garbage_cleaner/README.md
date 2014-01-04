
JC2-MP Garbage Cleanup plugin 
===================

This plugin was created by [Catlinman](https://twitter.com/Catlinman_) for for the [Just Cause 2: Multiplayer mod](http://jc-mp.com).

The Garbage Cleanup plugin is used to remove all unmanaged and unused vehicles from the server reducing the amount of physics calculations the server has to perform. An example of an unmanaged vehicle would be for instance when a plugin like the metatank plugin spawns in a new vehicle. This vehicle is unmanaged and remains on the server until a player enters it and destroys it. This plugin insures that such vehicles are removed.

The plugin runs over a timer which will trigger a cleanup cycle after the timer reaches the default time of 30 minutes. The time between cycles can be set by going into the garbage_cleanup.lua and changing the value of interval to something other than 30. The interval is measured in minutes.

This plugin requires a modified freeroam plugin. The reason for this being that the vehicles spawned by freeroam are managed by freeroam. We don't want to remove these as they won't be respawned otherwise. Freeroam sends the vehicle it spawns to a list of vehicles inside of the Garbage cleanup plugin. If a vehicle is in this list it won't be remove on a cleanup cycle.

Commands
--------
The * indicates that 'cleanup' has to be the first argument - All commands require admin status
<table>
  <tr>
    <td>/cleanup
    <td>Forces a garbage cleanup cycle</td>
  </tr>
  <tr>
    <td>/* time</td>
    <td>Prints the time until the next cleanup cycle</td>
  </tr>
  <tr>
    <td>/* reset</td>
    <td>Resets the garbage cleanup cycle</td>
  </tr>
  <tr>
    <td>/* enable</td>
    <td>Enables the garbage cleanup cycle</td>
  </tr>
  <tr>
    <td>/* disable</td>
    <td>Disables the garbage cleanup cycle</td>
  </tr>
</table>

Admins
--------

In the plugins server folder, make sure to insert the admins SteamId into the file admins.txt

You can also temporally disable an admin by adding a '--' infront of the admins SteamId.