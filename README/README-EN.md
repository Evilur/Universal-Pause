<div align=center>
    <img src='/img/logo.svg' width='50%'/>
    <br>
    <a href=#><img src='https://img.shields.io/github/languages/code-size/Evilur/Universal-Pause?style=for-the-badge&color=%230084ff'/></a>
    <a href='https://github.com/Evilur/Universal-Pause/commits/master/'><img src='https://img.shields.io/github/last-commit/Evilur/Universal-Pause?style=for-the-badge&color=%230084ff'/></a>
    <a href='https://aur.archlinux.org/packages/universal-pause'><img src='https://img.shields.io/aur/maintainer/universal-pause?style=for-the-badge&color=%230084ff'/></a>
    <br>
    <a href='https://github.com/Evilur/Universal-Pause/blob/master/LICENSE'><img src='https://img.shields.io/github/license/Evilur/Universal-Pause?style=for-the-badge&color=%238400ff'/></a>
    <a href='https://github.com/Evilur/Universal-Pause/releases/latest'><img src='https://img.shields.io/github/v/release/Evilur/Universal-Pause?style=for-the-badge&color=%238400ff'/></a>
    <br>
    [English]
    [<a href='/readme/README-RU.MD'>Русский</a>]
</div>

# Universal-Pause
Sometimes game developers don't think about the user experience. Implementing a game pause can make you suffer. This program is designed to fix that

## What it can do
- Pause cutscenes, even if the game doesn't allow it. So you can safely step away from the PC or read the long subtitles
- Pause games that have decided that pausing is only for casual players, so they don't pause at all (hi, soulslikes)
- Suspend any other programs, not even games

During a pause, programs stop using CPU and GPU resources. So you can use them for tasks that are more important at that moment, without losing progress

## Usage
To freeze, universal-pause looks for an active X-server window (the one that was last clicked on by the user). This means that the following command will pause your terminal emulator:
```BASH
universal-pause --run
```
So, it is assumed that this command will be used via the hotkey. Gnome and KDE allow you to do this through the GUI. Personally, I use sxhkd for this, and bind the command to the 'Pause-Break' key:
```
Pause:
    universal-pause --run
```

## Gamepads
Also universal-pause allows you to use key combinations on gamepads and other controllers using the evdev component in the linux kernel

### Find the gamepad device
To find your gamepad, you need to use the command:
```BASH
universal-pause --find
```
###

### Find out the key codes
To find out the gamepad key codes, you can use the command:
```BASH
universal-pause --test
```

### Setting the gamepad hotkey
Now we have the path to the device and the key codes we want to use to stop processes. Then now we can run a program that will wait for the desired combination to be pressed and run universal-pause
```BASH
universal-pause --evdev <path> <key code 1> <key code 2> <key code ...>
```
You can use different conditions for the keys:
```BASH
# Pressing 'Left Ctrl' and 'Pause-Break' keys simultaneously
universal-pause --evdev <path> 'KEY_PAUSE' 'KEY_LEFTCTRL'
# Pressing a non-standard key for which there is no event code definition. EV_KEY - event type
universal-pause --evdev <path> 'EV_KEY:800'
```


## Installation
### Building from source
```BASH
git clone https://github.com/Evilur/Universal-Pause /tmp/Universal-Pause
cd /tmp/Universal-Pause
sudo make clean install
```
### AUR
Universal-Pause is also available for installation via AUR. Package: [universal-pause](https://aur.archlinux.org/packages/universal-pause)

## Dependencies
- ps
- xdotool
- sox (optional) - for playing sounds
