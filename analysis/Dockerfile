# syntax=docker/dockerfile:1
# The analysis environment: pinned Python packages, no network needed at run time.
FROM python:3.12.8-slim-bookworm
RUN pip install --no-cache-dir numpy==2.2.1 pandas==2.2.3 scipy==1.14.1 statsmodels==0.14.4 matplotlib==3.10.0 tabulate==0.9.0
COPY extract.py report.py /analysis/
WORKDIR /study-root
ENTRYPOINT ["/bin/sh", "-c", "python /analysis/extract.py \"$0\" && python /analysis/report.py \"$0\""]
