
JC2-MP Garbage Cleanup plugin 
===================

This plugin was created by [Catlinman](https://twitter.com/Catlinman_) for the [Just Cause 2: Multiplayer mod](http://jc-mp.com).

The Garbage Cleanup plugin is used to remove all unmanaged and unused vehicles from the server to reduce the amount of physics calculations the server has to perform. An example of an unmanaged vehicle would be for instance, when a plugin like the [example metatank script](http://wiki.jc-mp.com/Lua/Tutorials/Intermediate/A_tank_that_shoots_tanks) spawns a new vehicle. This vehicle is unmanaged and remains on the server until a player enters it and destroys it. This plugin ensures that such vehicles are removed.

The plugin runs on a timer which will trigger a cleanup cycle after 30 minutes. The time between cycles can be set by editing 'garbage_cleanup.lua' and changing the value of interval variable. The interval is measured in minutes.

This plugin requires a modified freeroam plugin, the reason for this being that the vehicles spawned by freeroam are managed by freeroam alone. We don't want to remove these as they won't be respawned otherwise. Freeroam sends the vehicle it spawns to a list of vehicles inside of the Garbage Cleanup plugin. If a vehicle is in this list it won't be removed in a cleanup cycle.

Commands
--------
All commands require admin status

<table>
  <tr>
    <td>/cleanup
    <td>Forces a cleanup cycle</td>
  </tr>
  <tr>
    <td>/cleanup time</td>
    <td>Prints the time until the next cleanup cycle</td>
  </tr>
  <tr>
    <td>/cleanup reset</td>
    <td>Resets the cleanup cycle</td>
  </tr>
  <tr>
    <td>/cleanup enable</td>
    <td>Enables the cleanup cycle</td>
  </tr>
  <tr>
    <td>/cleanup disable</td>
    <td>Disables the cleanup cycle</td>
  </tr>
</table>

Admins
--------

In the plugin's server folder, make sure to insert the admin's SteamId into the file admins.txt

You can also temporarily disable an admin by adding '--' infront of the admin's SteamId.