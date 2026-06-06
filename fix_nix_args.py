import sys
import re


def fix_file(file_path):
    with open(file_path, "r") as f:
        content = f.read()

    # We only want to modify the first argument set.
    # It might be preceded by comments.

    # Try to find the argument set pattern
    # Looking for the first { ... }: that is not inside another block (usually at top level)
    # We'll look for the first occurrence of { followed by something and then }:
    match = re.search(r"\{[\s\n]*[^}]*?\.\.\.[\s\n]*\}:", content, re.DOTALL)
    if not match:
        return False

    arg_set = match.group(0)
    if "isTotal" in arg_set:
        return False

    # Check if it's multiline or single line
    if "\n" in arg_set:
        # Multiline. Try to find the '...' line
        if re.search(r"^\s*\.\.\.\s*$", arg_set, re.MULTILINE):
            # Replace '...' with 'isTotal,\n  ...'
            # We try to preserve indentation
            new_arg_set = re.sub(
                r"^(\s*)(\.\.\.)", r"\1isTotal,\n\1\2", arg_set, flags=re.MULTILINE
            )
        else:
            # Maybe it's like '  pkgs, ...'
            new_arg_set = re.sub(r",\s*\.\.\.", r",\n  isTotal,\n  ...", arg_set)
    else:
        # Single line
        new_arg_set = re.sub(r",\s*\.\.\.", r", isTotal, ...", arg_set)

    if new_arg_set != arg_set:
        new_content = content.replace(arg_set, new_arg_set, 1)
        with open(file_path, "w") as f:
            f.write(new_content)
        return True
    return False


if __name__ == "__main__":
    for file_path in sys.argv[1:]:
        if fix_file(file_path):
            print(f"Fixed: {file_path}")
        else:
            print(f"Skipped: {file_path}")
