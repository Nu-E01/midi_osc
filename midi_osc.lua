--[[
midi_osc v1.0
=========================
Converts MIDI notes to oscillator-like pulse sequences in either MIDI or empty item format.

FUNCTIONALITY:
- Two output modes: MIDI or empty items
- Supports octave transposition (-6 -> +4)
- Adjustable pitch bend range (±1 -> ±48)
- Preserves original CC messages (MIDI mode only)
- interactive GUI

USAGE:
1. Select MIDI items in REAPER
2. Set desired octave offset and bend range
3. Select output mode (MIDI or Empty Item)
4. Click "Generate"

AUTHOR: @dumb_cmd
REQUIRES: REAPER v6.0+ with ImGui support
]]--

------------------------------------------
-- GUI Settings
------------------------------------------
local script_title = "midi_osc"
local window_width = 300
local window_height = 185
local octave_offset = 0  -- Default pitch offset in octaves
local bend_range = 2     -- Default pitch bend range in semitones
local pulse_mode = false -- false: MIDI mode (default), true: Empty Item mode

------------------------------------------
-- Shared Utility Functions
------------------------------------------
local function isTrackEmptyInTimeRange(track, start_time, end_time)
    local item_count = reaper.GetTrackNumMediaItems(track)
    for i = 0, item_count - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        
        -- Check if item overlaps with ideal time range
        if not (item_end <= start_time or item_start >= end_time) then
            return false
        end
    end
    return true
end

------------------------------------------
-- Shared Processing Functions
------------------------------------------
local function GetBendPoints(take, noteStartPPQ, noteEndPPQ)
    local bendPoints = {}
    local lastValue = 8192 -- Default if no bend found
    
    -- Find the most recent bend before the note starts
    local ccCount = reaper.MIDI_CountEvts(take)
    for i = 0, ccCount-1 do
        local ret, _, _, ppqpos, msg = reaper.MIDI_GetCC(take, i)
        if ret and msg>>4 == 0xE and ppqpos <= noteStartPPQ then
            local _, _, _, _, _, _, val1, val2 = reaper.MIDI_GetCC(take, i)
            lastValue = val1 + (val2<<7)
        end
    end
    
    -- Add initial point (either from pre-note bend or default)
    table.insert(bendPoints, {ppq = noteStartPPQ, value = lastValue})
    
    -- Capture all bends during the note
    for i = 0, ccCount-1 do
        local ret, _, _, ppqpos, msg, _, val1, val2 = reaper.MIDI_GetCC(take, i)
        if ret and msg>>4 == 0xE and ppqpos >= noteStartPPQ and ppqpos <= noteEndPPQ then
            local bendValue = val1 + (val2<<7)
            if bendValue ~= lastValue then
                table.insert(bendPoints, {ppq = ppqpos, value = bendValue})
                lastValue = bendValue
            end
        end
    end
    
    -- Add final point
    table.insert(bendPoints, {ppq = noteEndPPQ, value = lastValue})
    
    return bendPoints
end

local function CalculateFrequency(pitch, bendValue, octave_offset)
    local bendSemitones = (bendValue - 8192)/8192 * bend_range
    return 440 * 2^((pitch + bendSemitones - 69 + (octave_offset * 12))/12)
end

------------------------------------------
-- MIDI Mode Processing
------------------------------------------
local function midi_ProcessItem(item, octave_offset, suffix)
    local take = reaper.GetActiveTake(item)
    if not take or not reaper.TakeIsMIDI(take) then return false end
    
    -- Check if there are any notes in the item
    local _, notecnt = reaper.MIDI_CountEvts(take)
    if notecnt == 0 then return false end
    
    -- Prepare new MIDI item
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_name = reaper.GetTakeName(take)
    local item_end = item_pos + item_len
    
    -- Find or create target track
    local source_track = reaper.GetMediaItemTrack(item)
    local track_idx = reaper.GetMediaTrackInfo_Value(source_track, "IP_TRACKNUMBER")
    local target_track = reaper.GetTrack(0, track_idx)
    if not (target_track and isTrackEmptyInTimeRange(target_track, item_pos, item_end)) then
        reaper.InsertTrackAtIndex(track_idx, true)
        target_track = reaper.GetTrack(0, track_idx)
    end
    
    local new_item = reaper.CreateNewMIDIItemInProj(target_track, item_pos, item_end)
    local new_take = reaper.GetActiveTake(new_item)
    
    -- Set item name(Example: "-o3b9" means "-3 octaves and set pitch bend range to 9 semitones")
    local base_name = item_name:match("(.+)%..+$") or item_name
    local ext = item_name:match("%.(.+)$") or ""
    local new_name = base_name .. "_osc" .. suffix
    if ext ~= "" then new_name = new_name .. "." .. ext end
    reaper.GetSetMediaItemTakeInfo_String(new_take, "P_NAME", new_name, true)
    
    -- Process all notes
    for i = 0, notecnt - 1 do
        local _, _, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        
        if not muted then
            local bendPoints = GetBendPoints(take, startppqpos, endppqpos)
            local currentBendIndex = 1
            
            local function getCurrentBend(ppq)
                while currentBendIndex < #bendPoints and 
                      bendPoints[currentBendIndex+1].ppq <= ppq do
                    currentBendIndex = currentBendIndex + 1
                end
                return bendPoints[currentBendIndex].value
            end
            
            local currentPPQ = startppqpos
            while currentPPQ < endppqpos do
                local bendValue = getCurrentBend(currentPPQ)
                local freq = CalculateFrequency(pitch, bendValue, octave_offset)
                
                local noteStartTime = reaper.MIDI_GetProjTimeFromPPQPos(take, currentPPQ)
                local noteEndTime = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqpos)
                local periodSec = 1 / freq
                local pulseEndTime = noteStartTime + periodSec
                
                if pulseEndTime > noteEndTime then break end
                
        -- PPQ setting
                local pulseStartPPQ = reaper.MIDI_GetPPQPosFromProjTime(new_take, noteStartTime)
                local pulseEndPPQ = reaper.MIDI_GetPPQPosFromProjTime(new_take, pulseEndTime)
                local periodPPQ = pulseEndPPQ - pulseStartPPQ
                periodPPQ = math.max(1, periodPPQ) 
        
        -- Insert Notes
                if periodPPQ >= 1 then
                    reaper.MIDI_InsertNote(new_take, false, false, 
                                        pulseStartPPQ, pulseEndPPQ, 
                                        chan, pitch, vel, true)
                end
                
                currentPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, pulseEndTime)
                if currentPPQ >= endppqpos then break end
            end
        end
    end
    
    -- Copy only specific control messages (excluding pitch bend)
    local _, cc_cnt = reaper.MIDI_CountEvts(take)
    for i = 0, cc_cnt - 1 do
        local _, _, muted, ppqpos, chanmsg, chan, msg2, msg3 = reaper.MIDI_GetCC(take, i)
        if not muted and (chanmsg & 0xF0) == 0xB0 then  -- Only standard CC messages
            local new_ppq = reaper.MIDI_GetPPQPosFromProjTime(new_take, 
                            reaper.MIDI_GetProjTimeFromPPQPos(take, ppqpos))
            reaper.MIDI_InsertCC(new_take, false, false, new_ppq, chanmsg, chan, msg2, msg3)
        end
    end
    
    reaper.MIDI_Sort(new_take)
    reaper.UpdateItemInProject(new_item)
    return true
end

------------------------------------------
-- Empty Item Mode Processing
------------------------------------------
local function empty_ProcessItem(item, octave_offset)
    local take = reaper.GetActiveTake(item)
    if not take or not reaper.TakeIsMIDI(take) then return false end

    local sourceTrack = reaper.GetMediaItemTake_Track(take)
    local sourceTrackIndex = reaper.GetMediaTrackInfo_Value(sourceTrack, "IP_TRACKNUMBER")

    local notes = {}
    local _, noteCount = reaper.MIDI_CountEvts(take)
    for n = 0, noteCount-1 do
        local ret, _, _, startPPQ, endPPQ, _, pitch = reaper.MIDI_GetNote(take, n)
        if ret then
            table.insert(notes, {
                startPPQ = startPPQ,
                endPPQ = endPPQ,
                pitch = pitch,
                startTime = reaper.MIDI_GetProjTimeFromPPQPos(take, startPPQ),
                endTime = reaper.MIDI_GetProjTimeFromPPQPos(take, endPPQ)
            })
        end
    end

    if #notes == 0 then return false end

    local noteTracks = {{}}
    for _, note in ipairs(notes) do
        local placed = false
        for i, track in ipairs(noteTracks) do
            local canPlace = true
            for _, existingNote in ipairs(track) do
                if note.startTime < existingNote.endTime and existingNote.startTime < note.endTime then
                    canPlace = false
                    break
                end
            end
            if canPlace then
                table.insert(track, note)
                placed = true
                break
            end
        end
        if not placed then
            table.insert(noteTracks, {note})
        end
    end
    
    local parentTrack = reaper.GetTrack(0, sourceTrackIndex-1)
    local originalDepth = reaper.GetMediaTrackInfo_Value(parentTrack, "I_FOLDERDEPTH")
    
    for i, trackNotes in ipairs(noteTracks) do
        local insertIdx = sourceTrackIndex + i - 1
        reaper.InsertTrackAtIndex(insertIdx, false)
        local oscTrack = reaper.GetTrack(0, insertIdx)
        
        for _, note in ipairs(trackNotes) do
            local bendPoints = GetBendPoints(take, note.startPPQ, note.endPPQ)
            local currentBendIndex = 1
            
            local function getCurrentBend(ppq)
                while currentBendIndex < #bendPoints and 
                      bendPoints[currentBendIndex+1].ppq <= ppq do
                    currentBendIndex = currentBendIndex + 1
                end
                return bendPoints[currentBendIndex].value
            end
            
            local currentTime = note.startTime
            while currentTime < note.endTime do
                local currentPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, currentTime)
                local bendValue = getCurrentBend(currentPPQ)
                local freq = CalculateFrequency(note.pitch, bendValue, octave_offset)
                local period = 1/freq
                local pulseEnd = currentTime + period
                
                if pulseEnd > note.endTime then break end
                
                local item = reaper.AddMediaItemToTrack(oscTrack)
                reaper.SetMediaItemPosition(item, currentTime, false)
                reaper.SetMediaItemLength(item, pulseEnd - currentTime, false)
                reaper.AddTakeToMediaItem(item)
                
                currentTime = pulseEnd
            end
        end
    end
    
    if #noteTracks > 0 then
        reaper.SetMediaTrackInfo_Value(parentTrack, "I_FOLDERDEPTH", 1)
        local lastTrack = reaper.GetTrack(0, sourceTrackIndex + #noteTracks - 1)
        reaper.SetMediaTrackInfo_Value(lastTrack, "I_FOLDERDEPTH", originalDepth - 1)
    end
    
    return true
end

------------------------------------------
-- GUI Functions
------------------------------------------
local function createGUI()
    local ctx = reaper.ImGui_CreateContext(script_title)
    local size = reaper.ImGui_GetFontSize(ctx)
    
    -- GUI main loop
    local function loop()
        -- Get REAPER main window dimensions
        local main_viewport = reaper.ImGui_GetMainViewport(ctx)
        local screen_w, screen_h = reaper.ImGui_Viewport_GetWorkSize(main_viewport)
        
        -- Centered window position
        local center_x = (screen_w - window_width) * 0.5
        local center_y = (screen_h - window_height) * 0.5
        
        -- Set window position (called before Begin())
        reaper.ImGui_SetNextWindowPos(ctx, center_x, center_y, reaper.ImGui_Cond_Appearing())
        local visible, open = reaper.ImGui_Begin(ctx, script_title, true, 
            reaper.ImGui_WindowFlags_NoResize())
        
        if not visible then
            if open then
                reaper.defer(loop)
            end
            return
        end
        
        -- Set window size
        reaper.ImGui_SetWindowSize(ctx, window_width, window_height)
        
        -- Mode selector
        reaper.ImGui_Text(ctx, "Mode:")
        reaper.ImGui_SameLine(ctx)
        if reaper.ImGui_RadioButton(ctx, "MIDI", not pulse_mode) then
            pulse_mode = false
        end
        reaper.ImGui_SameLine(ctx)
        if reaper.ImGui_RadioButton(ctx, "Empty Item", pulse_mode) then
            pulse_mode = true
        end
        
        -- Transpose slider
        reaper.ImGui_Text(ctx, "Transpose:")
        local format_str = octave_offset > 0 and " +%d octave(s)" or " %d octave(s)"
        local changed, new_offset = reaper.ImGui_SliderInt(ctx, "##octave", octave_offset, -6, 4, format_str)
        if changed then octave_offset = new_offset end
        
        -- Pitch Bend Range slider
        reaper.ImGui_Spacing(ctx)
        reaper.ImGui_Text(ctx, "Pitch Bend Range:")
        local bend_changed, new_bend = reaper.ImGui_SliderInt(ctx, "##bend", bend_range, 1, 24, "%d semitone(s)")
        if bend_changed then bend_range = new_bend end
        
        -- Generate button
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Spacing(ctx)
        local generate_clicked = reaper.ImGui_Button(ctx, "Generate", -1, 0)
        
        -- Warning message
        if octave_offset > 2 or math.abs(bend_range) > 36 then
            reaper.ImGui_Spacing(ctx)
            reaper.ImGui_Text(ctx, "Please avoid frequencies above C8")
            reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFFFFFFFF)
            reaper.ImGui_PopStyleColor(ctx)
        end
        
        reaper.ImGui_End(ctx)
        
        -- Handle generate button click outside of ImGui frame
        if generate_clicked then
            -- Check for selected items
            if reaper.CountSelectedMediaItems(0) == 0 then
                reaper.ShowMessageBox("Please select MIDI items to process first", "Notice", 0)
            else
                reaper.PreventUIRefresh(1)
                reaper.Undo_BeginBlock()
                
                -- Process all selected MIDI items
                local suffix = ''
                if octave_offset ~= 0 or bend_range ~= 2 then
                    suffix = ' '
                    if octave_offset ~= 0 then
                        local offset_sign = octave_offset > 0 and "+" or "-"
                        suffix = suffix .. offset_sign .. "o" .. math.abs(octave_offset)
                    end
                    if bend_range ~= 2 then
                        suffix = suffix .. 'b' .. bend_range
                    end
                end
                
                local processed = 0
                for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
                    local item = reaper.GetSelectedMediaItem(0, i)
                    if reaper.TakeIsMIDI(reaper.GetActiveTake(item)) then
                        local success
                        if pulse_mode then
                            success = empty_ProcessItem(item, octave_offset)
                        else
                            success = midi_ProcessItem(item, octave_offset, suffix)
                        end
                        
                        if success then
                            processed = processed + 1
                        end
                    end
                end
                
                if processed == 0 then
                    reaper.ShowMessageBox("No MIDI items found for processing", "Notice", 0)
                end
                
                reaper.Undo_EndBlock("midi_osc("..(pulse_mode and "Empty" or "MIDI")..')'..suffix, -1)
                reaper.PreventUIRefresh(-1)
                reaper.UpdateArrange()
            end
        end
        
        if open then
            reaper.defer(loop)
        end
    end
    
    -- Start GUI loop
    reaper.defer(loop)
end

------------------------------------------
-- Main Program
------------------------------------------
local function checkImguiAvailable()
    local ok, _ = pcall(reaper.ImGui_CreateContext, 'TestContext')
    return ok
end

local function showMissingImguiDialog()
    local title = "Missing Dependency"
    local msg = "This script requires ReaImGui to run.\n\n" ..
                "Would you like to install it in the next window?"
    
    local result = reaper.ShowMessageBox(msg, title, 4) -- 4 = Yes/No buttons
    if result == 6 then -- 6 = Yes
        reaper.ReaPack_BrowsePackages("ReaImGui: ReaScript binding for Dear ImGui")
    end
end

local function main()
    if not checkImguiAvailable() then
        showMissingImguiDialog()
        return
    end
    
    -- Proceed if ImGui is available
    createGUI()
end

main()
