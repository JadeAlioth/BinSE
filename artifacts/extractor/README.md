# IDA feature extractor — usage

Generates the three sidecar files each binary needs before comparison:
`<binary>.pkl`, `<binary>.cmp.dat`, `<binary>.fcg.dat`.

Requirement: a licensed **IDA Pro 9.3** installation (not included here).

## Windows

```bat
ida.exe -A -S"<abs-path>\extractor\windows\run_extract.py" <binary>
```

## Linux

```bash
./ida -A -S"<abs-path>/extractor/linux/run_extract.py" <binary>
```



Notes:
- the modules match the Python 3.11 embedded in IDA 9.3; an `ImportError`
  from `run_extract.py` means your IDA uses a different Python — pick the
  other folder or rebuild the module for that version;

