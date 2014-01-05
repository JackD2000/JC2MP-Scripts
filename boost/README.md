
JC2-MP Boost plugin 
===================

This plugin was created by [Catlinman](https://twitter.com/Catlinman_) for the [Just Cause 2: Multiplayer mod](http://jc-mp.com).

On pressing the shift key, the registered player's vehicle will start charging into the direction of its last movement. 

Commands
--------

The &lt;name&gt; space indicates that a players username can be entered here. You can also leave it empty or write '.' to reference your own username.

<table>
  <tr>
    <td>/boost
    <td>Enables or disables boost if the player is in the list of registered players</td>
  </tr>
  <tr>
    <td>/boost add &lt;name&gt;</td>
    <td>Adds a player to the list of registered players (Requires admin status)</td>
  </tr>
  <tr>
    <td>/boost remove &lt;name&gt;</td>
    <td>Removes a player from the list of registered players (Requires admin status)</td>
  </tr>
<tr>
	<td>/boost players
	<td>Lists all registered players (Requires admin status - Offline players are ignored)
</tr>
</table>

Controls
--------

<table>
  <tr>
    <td>LSHIFT
    <td>Accelerate</td>
  </tr>
  <tr>
    <td>LCTRL
    <td>Decelerate</td>
  </tr>
</table>

Admins
--------

In the plugin's server folder, make sure to insert the admin's SteamId into the file admins.txt

You can also temporarily disable an admin by adding '--' infront of the admin's SteamId.
