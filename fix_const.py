import os

def fix_const_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    changed = False
    for i in range(len(lines)):
        # If a line contains Theme.of(context) and has 'const ', it's invalid.
        if 'Theme.of(context)' in lines[i] and 'const ' in lines[i]:
            # Replace all occurrences of 'const ' with '' ONLY IF it's before a widget or we can just remove all 'const ' on that line.
            # E.g. "const SizedBox( ... Theme.of(context) ... )"
            lines[i] = lines[i].replace('const ', '')
            changed = True
            
        # Also catch multi-line const cases: if previous line ends with `const ` or `const` and this line has Theme
        # but that's rarer. We'll handle inline first.

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"Fixed const in {filepath}")

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            fix_const_in_file(os.path.join(root, file))
