Just Cause 2 - Multiplayer Environment script
===
## Commands ##
<table>
  <tr>
    <td>/time &lt;hour of day&gt;</td>
    <td>Set the current time. Accepts any number >= 0</td>
  </tr>
  <tr>
    <td>/timestep &lt;speed&gt;</td>
    <td>Set the speed of time. Accepts any number</td>
  </tr>
  <tr>
    <td>/weather &lt;0 - 2&gt;</td>
    <td>Set the weather. Accepts number range of 0 through 2. 0 = clear, 2 = storm</td>
  </tr>
</table>

## Admins ##
Edit client/environment.lua

In the top, change line `self:AddAdmin("STEAM_0:0:16870054")` to have your own Steam ID.
Duplicate this line, and change the IDs to add more admins that are allowed to use these commands.
