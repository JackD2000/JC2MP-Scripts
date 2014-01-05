JC2-MP MOTD plugin 
===================

This plugin was created by [Catlinman](https://twitter.com/Catlinman_) for the [Just Cause 2: Multiplayer mod](http://jc-mp.com).

The purpose of the plugin is to give players a quick outline of the server once they join.

Commands
--------

<table>
  <tr>
    <td>/motd
    <td>Prints the MOTD messages into the chat</td>
  </tr>
  <tr>
    <td>/help</td>
    <td>Prints additional help into the chat</td>
  </tr>
</table>

Usage
-------

To be able to have the messages show up on your server, you will have to change the content of the two files 'message.txt' and 'help.txt' inside the plugins server folder. The message file contains the information displayed when a player joins the server or the motd command is called by the client. The help file contains the information displayed by the help command. 

If a file remains empty, the commands associated with that file are automatically disabled. You can also add '--' infront of a line to comment it out.