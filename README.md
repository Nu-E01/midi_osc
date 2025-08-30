# midi_osc

midi_osc is a script that generates high-frequency MIDI notes to simulate oscillator behavior in REAPER/FL Studio.

(In REAPER, midi_osc can create empty items instead of MIDI notes, like how [midi2item](https://ytpmv.info/ReaScript-midi2item/) works)

It is designed to create sequences similar to [*death by amen*](https://youtu.be/XpnNVWOC98A) by Virtual Riot.

## Interface & Sample Projects

midi_osc.lua in REAPER：[.rpp demo](https://youtu.be/eY1qcbOlORQ)

![midi_osc for FL Stuio](Image/midi_osc(REAPER).png)

midi_osc.pyscript in FL Studio：[.flp demo](https://www.youtube.com/watch?v=Fps_TGekRuc)

![midi_osc for REAPER](Image/midi_osc(FL).png)

Sample projects [here](https://github.com/Nu-E01/midi_osc/tree/main/Sample%20Projects)

## Usage

**HINT:  Higher pitches and accuracy require higher PPQ & BPM values.**

### For REAPER
1. Copy `midi_osc.lua` to your REAPER scripts folder
2. In REAPER, open Action List (Shift+?)
3. Click "New action" → "Load ReaScript" → select `midi_osc.lua`
4. Run from Action List or assign to a shortcut

### For FL Studio
1. Copy `midi_osc.pyscript` to your FL Studio piano roll scripts folder
2. Access via piano roll: Tools > Scripts > midi_osc


You can refer to the article below for more information.

[REAPER 版本](https://www.bilibili.com/read/cv42356141/)

[FL 版本](https://www.bilibili.com/opus/1094703862863888439)
