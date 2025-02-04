import shutil
import os
import sys

def main():
    if len(sys.argv) < 4:
        print("Usage: python copy_files.py <src_base> <destination_base> <file1> <file2> ...")
        sys.exit(1)

    src = sys.argv[1]
    destination = sys.argv[2]
    files = sys.argv[3:]

    os.makedirs(destination, exist_ok=True)

    for file in files:
        src_path = os.path.join(src, os.path.basename(file))
        dest_path = os.path.join(destination, os.path.basename(file))

        shutil.copy2(src_path, dest_path)

if __name__ == "__main__":
    main()