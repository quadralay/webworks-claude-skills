---
title: Creating Marketing Images with Gemini API and Pillow Compression
category: workflow-improvements
component:
  - gemini-imagegen
  - pillow
symptoms:
  - Need high-quality marketing/hero images for documentation
  - AI-generated images are too large for web use (4+ MB)
  - Text in generated images is blurry or unreadable
root_cause: Marketing assets require both AI-generated imagery for visual appeal and post-processing optimization for web performance
date_solved: 2025-12-28
related_files:
  - plans/readme-image-prompt.md
  - images/readme-main.png
---

# Creating Marketing Images with Gemini API and Pillow Compression

## Problem

When creating hero images for README files and marketing materials:
1. Need professional UI mockups showing terminal/code interfaces
2. Text must be readable (monospace fonts for authenticity)
3. Generated images are too large for web (4+ MB)
4. Some Gemini models produce blurry/illegible text

## Solution

### 1. Model Selection

**Use `gemini-3-pro-image-preview`** - NOT `gemini-2.0-flash-exp`

| Model | Text Quality | Use Case |
|-------|--------------|----------|
| `gemini-3-pro-image-preview` | Excellent - clear, readable | Marketing images, UI mockups |
| `gemini-2.0-flash-exp` | Poor - blurry, distorted | Abstract art, non-text images |

### 2. Prompt Engineering for Readable Text

**Critical elements for terminal/code mockups:**

```
CRITICAL: All text must use MONOSPACE FONT and be CLEARLY READABLE.

Terminal window:
- User input: "exact command here"
- AI response showing:
  "Line 1 of output"
  "Line 2 of output"
  Green checkmark: "Success message"
```

**Key phrases to include:**
- "MONOSPACE FONT" (or specify: Consolas, Cascadia Code)
- "CLEARLY READABLE"
- "high contrast"
- Exact text content to display

### 3. Resolution & Aspect Ratio

| Use Case | Resolution | Aspect Ratio |
|----------|------------|--------------|
| README hero | 2K | 16:9 |
| Social cards | 1K | 16:9 |
| Documentation | 1K | 16:9 |

### 4. Python Implementation

```python
import os
from google import genai
from google.genai import types
from PIL import Image

client = genai.Client(api_key=os.environ['GEMINI_API_KEY'])

# Generate with Pro model at 2K
response = client.models.generate_content(
    model='gemini-3-pro-image-preview',
    contents=[prompt],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
        image_config=types.ImageConfig(
            aspect_ratio='16:9',
            image_size='2K'
        ),
    ),
)

# Save image
for part in response.parts:
    if part.inline_data:
        img = part.as_image()
        img.save('output.jpg')  # Gemini returns JPEG

        # Convert to PNG
        pil_img = Image.open('output.jpg')
        pil_img.save('output.png', 'PNG')
```

### 5. Pillow Compression Pipeline

Achieve ~79% file size reduction:

```python
from PIL import Image
import os

def compress_for_web(input_path, output_path, max_width=1920):
    """Compress image similar to TinyPNG."""

    original_size = os.path.getsize(input_path)

    img = Image.open(input_path)

    # Resize if needed
    if img.width > max_width:
        ratio = max_width / img.width
        new_size = (max_width, int(img.height * ratio))
        img = img.resize(new_size, Image.LANCZOS)

    # Convert to palette mode (like TinyPNG)
    img_optimized = img.convert('P', palette=Image.ADAPTIVE, colors=256)

    # Save with optimization
    img_optimized.save(output_path, 'PNG', optimize=True)

    compressed_size = os.path.getsize(output_path)
    reduction = (1 - compressed_size/original_size) * 100

    print(f"Reduction: {reduction:.1f}%")
    return reduction
```

## Results Achieved

| Metric | Before | After |
|--------|--------|-------|
| File size | 4.4 MB | 954 KB |
| Resolution | 2752×1536 | 1920×1071 |
| **Reduction** | - | **78.9%** |

## File Size Targets

| Image Type | Target | Maximum |
|------------|--------|---------|
| README hero | < 500 KB | 1 MB |
| Documentation | < 200 KB | 500 KB |
| Social cards | < 300 KB | 500 KB |

## Prevention Checklist

- [ ] Use `gemini-3-pro-image-preview` for text-heavy images
- [ ] Include "MONOSPACE FONT" and "CLEARLY READABLE" in prompt
- [ ] Specify exact text content to display
- [ ] Generate at 2K resolution for text clarity
- [ ] Compress with Pillow before committing
- [ ] Verify file size < 1 MB
- [ ] Test readability at display size

## Dependencies

```bash
pip install google-genai Pillow
```

Environment variable required:
```bash
export GEMINI_API_KEY="your-api-key"
```

## Related

- [plans/readme-image-prompt.md](../../plans/readme-image-prompt.md) - Prompt template for this repo's hero image
- [images/readme-main.png](../../images/readme-main.png) - Generated hero image
