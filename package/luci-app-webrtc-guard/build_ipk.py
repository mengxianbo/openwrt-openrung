#!/usr/bin/env python3
import pathlib
import sys
import tarfile
import tempfile

def add_tree(source, archive, skip_control=False):
    source = pathlib.Path(source)
    for path in sorted(source.rglob("*")):
        rel = path.relative_to(source)
        if skip_control and rel.parts and rel.parts[0] == "CONTROL":
            continue
        archive.add(path, arcname="./" + str(rel), recursive=False)

def build(source, output):
    source = pathlib.Path(source)
    output = pathlib.Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        with tarfile.open(tmp / "control.tar.gz", "w:gz", format=tarfile.GNU_FORMAT) as tar:
            add_tree(source / "CONTROL", tar)
        with tarfile.open(tmp / "data.tar.gz", "w:gz", format=tarfile.GNU_FORMAT) as tar:
            add_tree(source, tar, skip_control=True)
        (tmp / "debian-binary").write_text("2.0\n", encoding="ascii")
        with tarfile.open(output, "w:gz", format=tarfile.GNU_FORMAT) as tar:
            tar.add(tmp / "debian-binary", arcname="./debian-binary")
            tar.add(tmp / "control.tar.gz", arcname="./control.tar.gz")
            tar.add(tmp / "data.tar.gz", arcname="./data.tar.gz")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: build_ipk.py <staging-dir> <output.ipk>")
    build(sys.argv[1], sys.argv[2])
