# [12.0 RC4] If multiple versions of episodes of a TV show are defined, Special Features are detected inconsistently

### Description of the bug

When a series has multiple versions of an episode as well as some special features, sometimes either the episode variants or the special features aren't correctly detected. This seems to only be an issue on a per-season basis.

### Reproduction steps

Awesome TV Show (2024)
├── Season 1
│   ├── S01E01 - 720p.mp4
│   ├── S01E01 - 1080p.mp4
│   ├── S01E02 - 720p.mp4
│   ├── S01E02 - 1080p.mp4
│   ├── behind the scenes
│   │   └── S01E01 Cast having a laugh.mp4
│   │   └── S01E02 Cast looking bored.mp4

I have a folder structure similar to this, with multiple episodes and behind the scenes clips. I copied everything into the library, and then did a rescan.
I also tried moving either the bts folder or a specific one of the variants in and out of the library, rescanning after every step.

### What is the current _bug_ behavior?

Seemingly at random, either the Special Features or the variants of the episode will not be correctly detected. The special features seem to either be detected or not as a whole, so they're either all there or none of them are. The same is true for the episode variants.

### What is the expected _correct_ behavior?

Everything should be detected with each episode having two variants, and the special features being visible at the bottom of the season.

### Jellyfin Server version

Master

### Specify commit id

b3a06113029585594fe7a44becbfae7d2bdd9974

### Specify unstable release number

_No response_

### Specify version number

_No response_

### Specify the build version

12.0-rc4

### Environment

```markdown
- OS: Debian 12.7
- Linux Kernel: 7.0.14-6-pve
- Virtualization: Proxmox LXC
- Clients: Browser
- Browser: Firefox 153
- FFmpeg Version: 
- Playback Method:
- Hardware Acceleration:
- CPU Model:
- GPU Model:
- Plugins:
- Reverse Proxy: Nginx Proxy Manager
- Base URL:
- Networking:
- Jellyfin Data Storage & Filesystem: Sata SSD
- Media Storage & Filesystem: NFS share
- External Integrations:
```

### Jellyfin logs

```shell
Emby.Server.Implementations.Library.Validators.ArtistsValidator: Refreshed metadata for 0 new artists out of 0 total
[2026-08-03 03:57:01.754 +00:00] [INF] [73] Emby.Server.Implementations.Library.Validators.GenresValidator: Refreshed metadata for 0 new genres out of 7 total
[2026-08-03 03:57:01.782 +00:00] [INF] [73] Emby.Server.Implementations.Library.Validators.MusicGenresValidator: Refreshed metadata for 0 new music genres out of 0 total
[2026-08-03 03:57:01.817 +00:00] [INF] [73] Emby.Server.Implementations.Library.Validators.StudiosValidator: Refreshed metadata for 0 new studios out of 7 total
[2026-08-03 03:57:01.877 +00:00] [INF] [73] Emby.Server.Implementations.ScheduledTasks.TaskManager: "Scan Media Library" Completed after 0 minute(s) and 14 seconds
```

### FFmpeg logs

```shell

```

### Client / Browser logs

_No response_

### Relevant screenshots or videos

_No response_

### Additional information

_No response_
