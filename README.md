# ma-scan
ssdeep helper to identify similar files

A simple bash script making use of ssdeep to help identify similar files. Uses ssdeep, in Ubuntu `sudo apt-install ssdeep`.

`* Operations:`</p>
`   --check FILE    : Checks file for known signatures`</p>
`   --generate FILE : Generates a hash signature for each file`</p>
`   --list          : Lists known signatures`

- Usage generate hashes: `find /lab/malware/samples -type f ! -name "*.md" -not -path "*.git*" -exec ./scan-id.sh --generate {} +`
- Usage search files for hashes: `find /lab/malware/samples -type f ! -name "*.md" -not -path "*.git*" -exec ./scan-id.sh --check {} +`