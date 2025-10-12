# TMUX Configuration

## 🔧 Key Features
- **Prefix Key**: `` ` `` (backtick) instead of `Ctrl-b`
- **Mouse Support**: Full mouse integration enabled
- **256 Color Support**: Enhanced terminal colors
- **Vi Mode**: Vim-style copy mode keybindings
- **Session Management**: Advanced session switching with fzf
- **AI Integration**: Built-in AI assistant popup

## ⌨️ Essential Keybinds

### Prefix Key
| Key | Action |
|-----|--------|
| `` ` `` | Prefix key (hold before other commands) |
| `` ` ` `` | Send literal backtick |

### Configuration
| Key | Action |
|-----|--------|
| `` `r `` | Reload tmux config |

### Sessions & Windows
| Key | Action |
|-----|--------|
| `` `o `` | Session switcher (fzf-based) |
| `` `T `` | Advanced session manager (sesh) |
| `` `L `` | Switch to last session (sesh) |
| `` `S `` | Create new session (prompts for name) |
| `` `c `` | New window (in current directory) |
| `Ctrl-H` | Previous window |
| `Ctrl-L` | Next window |
| `Alt-Shift-Left` | Previous window |
| `Alt-Shift-Right` | Next window |
| `Alt-i` | Move window left |
| `Alt-o` | Move window right |

### Pane Management
| Key | Action |
|-----|--------|
| `` `" `` | Split horizontally (current dir) |
| `` `- `` | Split horizontally (current dir) |
| `` `% `` | Split vertically (current dir) |
| `` `\| `` | Split vertically (current dir) |
| `` `m `` | Maximize/restore pane |

### Pane Navigation
| Key | Action |
|-----|--------|
| `Alt-Left` | Smart left (pane → window) |
| `Alt-Right` | Smart right (pane → window) |
| `Alt-Up` | Pane up |
| `Alt-Down` | Pane down |

### Pane Resizing
| Key | Action |
|-----|--------|
| `` `H `` | Resize left |
| `` `J `` | Resize down |
| `` `K `` | Resize up |
| `` `L `` | Resize right |
| `` `←/→/↑/↓ `` | Resize with arrows |

### Copy Mode (Vi-style)
**Visual Indicator**: Pane background changes to dark gray (`#181818`) when entering copy mode

| Key | Action |
|-----|--------|
| `v` | Begin selection |
| `Ctrl-v` | Rectangle selection |
| `y` | Copy selection |
| `a` | Copy selection + open AI chat |

### Search (tmux-copycat)
| Key | Action |
|-----|--------|
| `` `/ `` | Regex search (case insensitive) |
| `` `Ctrl-f `` | File search |
| `` `Ctrl-g `` | Git status files |
| `` `Alt-h `` | SHA-1/SHA-256 hashes |
| `` `Ctrl-u `` | URL search |
| `` `Ctrl-d `` | Number search |
| `` `Alt-i `` | IP address search |
| `n` | Next match (in copycat mode) |
| `N` | Previous match (in copycat mode) |
| `Enter` | Copy match (vi mode) |

### Smart Open (tmux-open)
| Key | Action |
|-----|--------|
| `o` | Open selection with system default |
| `Ctrl-o` | Open selection with $EDITOR |
| `Shift-s` | Search selection in Google |

### Utility Popups
| Key | Action |
|-----|--------|
| `` `k `` | Show all keybinds (fzf searchable) |
| `` `a `` | AI assistant popup |
| `Alt-f` | Floating window toggle |

## 🔌 Installed Plugins

### Core Plugins
- **tpm** - Plugin manager
- **tmux-sensible** - Sensible defaults

### Theme
- **catppuccin/tmux** - Beautiful theme with custom modifications

### Navigation & Integration
- **vim-tmux-navigator** - Seamless vim/tmux navigation
- **tmux-yank** - Enhanced copy/paste
- **tmux-floax** - Floating windows (`Alt-f`)

### Session Management
- **tmux-resurrect** - Save/restore sessions
- **tmux-continuum** - Auto-save sessions

### Search & Utilities
- **tmux-copycat** - Advanced search with predefined patterns
- **tmux-open** - Smart opening of highlighted content

## 🔍 Enhanced Search & Open Features

### tmux-copycat - Powerful Search
Advanced search functionality with predefined patterns and regex support:
- **Regex Search**: Use `` `/ `` for custom patterns (e.g., `[0-9]+` for numbers)
- **Predefined Searches**: Quick searches for common patterns:
  - Files, git status, URLs, IPs, SHA hashes, numbers
- **Case Insensitive**: All searches ignore case by default
- **Grep-powered**: Uses system grep for robust searching
- **Copycat Mode**: After search, use `n/N` to navigate matches

### tmux-open - Smart Opening
Opens highlighted content intelligently:
- **Files**: PDFs, docs, images open in default viewers
- **URLs**: Links open in default browser  
- **Code**: Use `Ctrl-o` to open files in $EDITOR
- **Search**: `Shift-s` googles highlighted text
- **Cross-platform**: Works on Linux, macOS, Windows (Cygwin)

## 🚀 Advanced Features

### Session Management
Session management is powered by **fzf** and **sesh** ([joshmedeski/sesh](https://github.com/joshmedeski/sesh))

#### Custom Session Switcher (`` `o ``) - Your fzf Implementation
- Custom-built fzf session picker (`session-fzf.sh`)
- Lists all tmux sessions with live preview
- Preview shows detailed session info: windows, panes, content
- `Ctrl-K` to kill sessions and reload list
- Create new sessions by typing name + Enter
- Additional fzf navigation:
  - `Ctrl-U/D`: Scroll preview up/down
  - `Ctrl-B/F`: Page preview up/down
  - `Shift-Up/Down`: Navigate preview
- Uses custom `session-preview.sh` for rich session visualization

#### Advanced Session Manager (`` `T ``) - Sesh Integration
- Powered by `sesh` - smart session manager
- Multiple view modes with keybind filters:
  - `Ctrl-a`: All sessions (default)
  - `Ctrl-t`: Tmux sessions only
  - `Ctrl-g`: Config directories
  - `Ctrl-x`: Zoxide directories (recent dirs)
  - `Ctrl-f`: Find directories (fd search)
  - `Ctrl-d`: Kill selected session
- Icons and enhanced preview
- Integrates with zoxide for smart directory jumping

### AI Integration
- `` `a ``: General AI assistant popup
- `a` in copy mode: Send selection to AI

### Smart Navigation
- `Alt-Left/Right`: Navigate panes, switch windows at edges
- Automatically handles screen boundaries
- Works seamlessly with vim splits via vim-tmux-navigator

### Window Behavior
- Windows start at index 1
- Auto-renumber when closed
- Prevent automatic renaming
- New windows/panes open in current directory

## 📁 Custom Scripts (Your Implementation)
- `session-fzf.sh` - Custom fzf session switcher with live preview
- `session-preview.sh` - Rich session preview showing windows/panes/content
- `ai-ask-selection.sh` - AI integration for text selections

## 🎨 Theme Configuration - Catppuccin Customized

### Base Theme
- **Catppuccin Frappe** flavor - elegant dark theme
- Status bar positioned at top
- Basic window status style for clean look

### Custom Window Number Colors
Smart color-coding that responds to window state:

```bash
# Current window number colors
@catppuccin_window_current_number_color "#{?window_zoomed_flag,#{@them_yellow},#{@them_mauve}}"

# Inactive window number colors  
@catppuccin_window_number_color "#{?window_zoomed_flag,#{@them_yellow},#{@them_overlay_2}}"
```

**What this does:**
- **Zoomed panes** (`` `m ``): Window numbers turn **yellow** to indicate maximized state
- **Normal state**: Current window is **mauve**, inactive windows are **gray**
- **Visual feedback**: Instantly see which windows have maximized panes
- **Persistent**: Yellow color stays even when switching between windows with zoomed panes

### Status Line Customization
- **Minimal design**: Only shows essential info (application + session)
- **Clean window titles**: Just window names, no extra clutter  
- **Top positioning**: Status bar at top for better visibility
- **Extended lengths**: More space for longer session/window names

### Visual Feedback Features
- 🟡 **Yellow window numbers**: Window has a maximized/zoomed pane
- 🟣 **Mauve window numbers**: Current active window (normal state)  
- ⚪ **Gray window numbers**: Inactive windows (normal state)
- 🔘 **Dark gray pane background**: Indicates copy mode is active

### Color Meanings
- **Window Numbers**: Yellow (zoomed), Mauve (active), Gray (inactive)
- **Pane Background**: Changes to `#181818` when in copy mode for clear visual feedback

## 🔧 Configuration Files
- Main config: `~/.config/tmux/tmux.conf`
- Scripts: `~/.config/tmux/scripts/`
- Plugins: `~/.config/tmux/plugins/`