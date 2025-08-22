# midi_osc / MIDI振荡器模拟器

> 将 MIDI 音符转换为高频脉冲序列，模拟振荡器行为 | Convert MIDI notes to oscillator-like pulse sequences

**Language**: [English](#english) | [中文](#中文)

---

## English <a id="english"></a>

### 🎹 Introduction
`midi_osc` is a script that converts MIDI notes into high-frequency pulse sequences to simulate oscillator behavior in digital audio workstations. It supports both FL Studio and REAPER with different implementations for each platform.

### ✨ Features
- **Multi-DAW Support**: FL Studio (Python) and REAPER (Lua)
- **Oscillator Simulation**: Generates pulse sequences based on note frequency
- **Pitch Control**: Adjustable transposition (± octaves) and pitch bend range
- **Slide Support**: Smooth pitch transitions between notes
- **Dual Output Modes**: MIDI notes or empty items (REAPER only)
- **Preserves Properties**: Maintains original velocity, pan, filter settings, etc.

### 📦 Installation

#### For FL Studio
1. Copy `midi_osc.py` to your FL Studio scripts folder:
   - Windows: `C:\Program Files\Image-Line\FL Studio\System\Scripts\`
   - macOS: `/Applications/FL Studio.app/Contents/Resources/FL/System/Scripts/`
2. Restart FL Studio
3. Access via: Tools > Macros > midi_osc

#### For REAPER
1. Copy `midi_osc.lua` to your REAPER scripts folder:
   - Windows: `C:\Users\[Username]\AppData\Roaming\REAPER\Scripts\`
   - macOS: `~/Library/Application Support/REAPER/Scripts/`
2. In REAPER, open Action List (Shift+?)
3. Click "New action" → "Load ReaScript" → select `midi_osc.lua`
4. Run from Action List or assign to a shortcut

### 🚀 Usage
1. **FL Studio**: 
   - Create MIDI notes in piano roll
   - Run the script from Macros menu
   - Adjust BPM, base frequency, and transposition in dialog

2. **REAPER**:
   - Select MIDI items in timeline
   - Run the script from Action List
   - Choose mode (MIDI or Empty Item)
   - Set transposition and bend range in GUI
   - Click "Generate"

### ⚙️ Parameters
- **BPM**: Controls pulse frequency timing
- **Base Frequency**: Reference frequency for A4 (default: 440Hz)
- **Transpose**: Octave offset (-6 to +6)
- **Pitch Bend Range**: Semitone range for bend messages (1-24)
- **1-Tick Mode**: Minimal note length (FL Studio only)

### 🐛 Known Issues
- Very high frequencies may cause performance issues
- Extreme transposition values might exceed MIDI range
- Slide behavior may vary between DAWs

### 🤝 Contributing
Contributions are welcome! Please feel free to:
- Report bugs via Issues
- Suggest new features
- Submit pull requests for improvements
- Add support for other DAWs

### 📄 License
MIT License - see [LICENSE](LICENSE) file for details.

### 👤 Author
**@dumb_cmd**  
- Bilibili: [@dumb_cmd](https://space.bilibili.com/your_id)
- GitHub: [@your_username](https://github.com/your_username)

---

## 中文版本 <a id="中文"></a>

### 🎹 介绍
`midi_osc` 是一个将 MIDI 音符转换为高频脉冲序列的脚本，用于在数字音频工作站中模拟振荡器行为。支持 FL Studio 和 REAPER 两个平台，分别提供不同的实现版本。

### ✨ 功能特点
- **多宿主支持**: FL Studio (Python) 和 REAPER (Lua)
- **振荡器模拟**: 根据音符频率生成脉冲序列
- **音高控制**: 可调节移调（±八度）和弯音范围
- **滑音支持**: 音符之间的平滑音高过渡
- **双输出模式**: MIDI 音符或空项目（仅 REAPER）
- **保留属性**: 保持原始力度、声像、滤波器设置等

### 📦 安装方法

#### FL Studio 版本
1. 将 `midi_osc.py` 复制到 FL Studio 脚本文件夹：
   - Windows: `C:\Program Files\Image-Line\FL Studio\System\Scripts\`
   - macOS: `/Applications/FL Studio.app/Contents/Resources/FL/System/Scripts/`
2. 重启 FL Studio
3. 通过菜单访问：工具 → 宏 → midi_osc

#### REAPER 版本
1. 将 `midi_osc.lua` 复制到 REAPER 脚本文件夹：
   - Windows: `C:\Users\[用户名]\AppData\Roaming\REAPER\Scripts\`
   - macOS: `~/Library/Application Support/REAPER/Scripts/`
2. 在 REAPER 中打开动作列表 (Shift+?)
3. 点击"新建动作" → "加载 ReaScript" → 选择 `midi_osc.lua`
4. 从动作列表运行或分配快捷键

### 🚀 使用方法
1. **FL Studio**:
   - 在钢琴卷帘中创建 MIDI 音符
   - 从宏菜单运行脚本
   - 在对话框中调整 BPM、基准频率和移调

2. **REAPER**:
   - 在时间线中选择 MIDI 项目
   - 从动作列表运行脚本
   - 选择模式（MIDI 或空项目）
   - 在 GUI 中设置移调和弯音范围
   - 点击"生成"

### ⚙️ 参数说明
- **BPM**: 控制脉冲频率时序
- **基准频率**: A4 的参考频率（默认：440Hz）
- **移调**: 八度偏移（-6 到 +6）
- **弯音范围**: 弯音信息的半音范围（1-24）
- **1-Tick 模式**: 最小音符长度（仅 FL Studio）

### 🐛 已知问题
- 极高频率可能导致性能问题
- 极端移调值可能超出 MIDI 范围
- 滑音行为在不同宿主中可能有所差异

### 🤝 贡献指南
欢迎贡献代码！您可以：
- 通过 Issues 报告错误
- 建议新功能
- 提交改进的 Pull Request
- 添加对其他宿主的支持

### 📄 许可证
MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

### 👤 作者
**@dumb_cmd**  
- 哔哩哔哩: [@dumb_cmd](https://space.bilibili.com/你的ID)
- GitHub: [@你的用户名](https://github.com/你的用户名)

---

**Note**: Replace `your_id` and `your_username` with your actual Bilibili ID and GitHub username.

[回到顶部](#midi_osc--midi振荡器模拟器)
