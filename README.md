# midi_osc

midi_osc is a script that generates high-frequency MIDI notes to simulate oscillator behavior in REAPER/FL Studio.

(In REAPER, midi_osc can create empty items instead of MIDI notes, like how [midi2item](https://ytpmv.info/ReaScript-midi2item/) works)

It is designed to create sequences similar to [*death by amen*](https://youtu.be/XpnNVWOC98A) by Virtual Riot.

## Minimum Requirements

REAPER v5.979 with ReaImGui

FL Studio 21.1

## Interface & Sample Projects

`midi_osc.lua` in REAPER：[.rpp demo](https://youtu.be/eY1qcbOlORQ)

![midi_osc for FL Stuio](Image/midi_osc(REAPER).png)

`midi_osc.pyscript` in FL Studio：[.flp demo](https://www.youtube.com/watch?v=Fps_TGekRuc)

![midi_osc for REAPER](Image/midi_osc(FL).png)

Sample projects [here](https://github.com/Nu-E01/midi_osc/tree/main/Sample%20Projects)

## Usage

**HINT:  Higher pitches and accuracy require higher PPQ & BPM values.**

### For REAPER
1. Copy `midi_osc.lua` to your REAPER scripts folder
   
   (Options → Show REAPER resource path in explorer/finder → /Scripts)
3. In REAPER, open Action List (Shift+?)
4. Click "New action" → "Load ReaScript" → select `midi_osc.lua`
5. Run from Action List or assign to a shortcut
6. Select MIDI item(s), adjust settings and then click the "Generate" button

### For FL Studio
1. Copy `midi_osc.pyscript` to your FL Studio Piano roll scripts folder

   Win: `\[FL Studio folder]\System\Config\Piano roll scripts`

   mac: `/Applications/[FL Studio folder]/Contents/Resources/FL/System/Config/Piano roll scripts`
3. Access via piano roll: Tools > Scripts > midi_osc


You can refer to the article below for more information.

[REAPER 版本](https://www.bilibili.com/read/cv42356141/)

[FL 版本](https://www.bilibili.com/opus/1094703862863888439)
