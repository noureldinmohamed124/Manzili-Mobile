import os
import glob

def fix_rtl_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace hardcoded TextDirection.rtl with Directionality.of(context)
    if 'TextDirection.rtl' in content:
        content = content.replace('TextDirection.rtl', 'Directionality.of(context)')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

# Walk through lib/presentation
for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            fix_rtl_in_file(os.path.join(root, file))
