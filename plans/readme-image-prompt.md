# README Image Generation Prompt

Use this prompt with Gemini (Nano Banana Pro) to generate the hero image for the README.

---

## Prompt

```
<work_surface>
A polished UI mockup showing an AI coding assistant terminal interacting with documentation software. Style: modern tech product screenshot suitable for a GitHub README hero image.
</work_surface>

<layout>
Wide aspect ratio (16:9). Dark themed interface.
Left side (60%): Windows Terminal window with conversation.
Right side (40%): Preview panel showing documentation output.
Subtle gradient background behind the windows.
</layout>

<components>
Terminal window:
- Windows 11 style window chrome with rounded corners
- Minimize/maximize/close buttons on the right (─ □ ✕)
- Tab bar showing "Claude Code" with PowerShell-style icon
- Dark charcoal background (#0c0c0c)
- User input line: "Build the project with all targets"
- AI response block showing:
  - "Detecting AutoMap installation..."
  - "Found: ePublisher 2024.1"
  - "Building 3 targets..."
  - Green checkmark with "Build complete"

Preview panel:
- Clean documentation page with header, navigation sidebar, content area
- Professional help system appearance
- Subtle "Reverb 2.0" styling

Visual accents:
- Purple glow or highlight on AI response area
- Green accent on success states
- Soft drop shadows on windows
</components>

<constraints>
- No real logos or trademarked brand imagery
- Text must be legible but can be slightly stylized
- Professional, minimal aesthetic—no clutter
- Colors: dark grays (#1a1a2e), purples (#7c3aed), greens (#22c55e)
- Windows Terminal uses #0c0c0c background with #cccccc text
- Suitable for light and dark GitHub themes
</constraints>
```

---

## Output

- **File:** `images/readme-main.png`
- **Recommended:** Compress with TinyPNG or Squoosh before committing

## Reference

Prompt structure based on: https://www.radicalcuriosity.xyz/p/how-to-create-an-effective-prompt
