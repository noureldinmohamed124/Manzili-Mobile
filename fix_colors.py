import os
import glob
import re

def fix_colors_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False
    
    # We shouldn't change app_colors.dart
    if "app_colors.dart" in filepath.replace('\\', '/'):
        return

    # Replace AppColors.surface
    if 'AppColors.surface' in content and 'AppColors.surfaceMuted' not in content:
        # Care: AppColors.surfaceMuted might be matched if we just do string replace. 
        # So we use regex for word boundary or exact match
        content = re.sub(r'AppColors\.surface(?!\w)', 'Theme.of(context).colorScheme.surface', content)
        changed = True
        
    # Replace Colors.white with context-aware color in the UI 
    # (only in places we're sure context is available, but mostly it is)
    if 'Colors.white' in content:
        # Exclude places where white is explicitly needed (like text on colored buttons)
        # We will only replace Colors.white if it's used as a background color
        # e.g. color: Colors.white, backgroundColor: Colors.white
        content = re.sub(r'(color|backgroundColor|fillColor):\s*Colors\.white', r'\1: Theme.of(context).colorScheme.surface', content)
        changed = True

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            fix_colors_in_file(os.path.join(root, file))
