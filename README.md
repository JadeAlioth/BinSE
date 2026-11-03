# BinSE

BinSE matches functions between two binaries. Output is one matched pair per line — `<func-in-binary1>\t<func-in-binary2>`


## Repository layout

```
Dockerfile                       builds a runnable image
.dockerignore
requirements.txt                 pinned runtime stack (python 3.8, torch 2.0.1+cu118, ...)
artifacts/
  BinSE.zip                      main zip
  extractor/                     IDA feature extractor (windows/ + linux/, see its README)
testdata/                        sample binaries + sidecars
```

## Quick start (Docker)

```bash
docker build -t binse:latest .
docker run --rm --gpus all \
  -v /path/to/data:/data binse \
  --file1 /data/A --file2 /data/B --out-pairs /data/pairs.txt
```

* `--gpus all` needs nvidia-container-toolkit; without a GPU the image falls
  back to CPU automatically (`--device auto`).
* Each input binary `<X>` must sit in the same directory as its three sidecars
  `<X>.pkl`, `<X>.cmp.dat`, `<X>.fcg.dat`.
* Flags: `--device {auto|cuda:N|cpu}`, `--min-blk N` (default 3),
  `--out-pairs FILE` (mirror of stdout to a file).

## Trying it on the shipped samples

```bash
# cross-compiler: clang-10 vs gcc-10
docker run --rm --gpus all \
  -v "$PWD/testdata/clang-10/coreutils-8.30/O0":/d1 \
  -v "$PWD/testdata/gcc-10/coreutils-8.30/O0":/d2 \
  binse --file1 /d1/numfmt --file2 /d2/numfmt

# different optimization levels: puttygen O0 vs O3
# control-flow flattening: ollvm/coreutils-8.30/{bcf,fla,split} vs clang-10 counterparts
```

## Preparing inputs (feature extraction)

Sidecars are produced with a licensed **IDA Pro 9.3** (not distributed here).
Use `artifacts/extractor/` — point IDA's `-S` at `run_extract.py`:

```
Windows:  ida.exe -A -S"<abs>\extractor\windows\run_extract.py" <binary>
Linux:    ./ida   -A -S"<abs>/extractor/linux/run_extract.py"   <binary>
```

Outputs (`<binary>.pkl/.cmp.dat/.fcg.dat`) land next to the target. 


## Running without Docker

Linux x86-64 with Python 3.8:

```bash
unzip artifacts/BinSE.zip -d binse && cd binse/BinSE
python3.8 -m venv venv && venv/bin/pip install -r ../../requirements.txt
venv/bin/python main.py --file1 /data/A --file2 /data/B
```