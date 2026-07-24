#!/bin/bash
set -euo pipefail

PI_KEYS="$(node -e 'const fs=require("fs"),path=require("path"); console.log(path.join(path.dirname(fs.realpathSync(process.argv[1])), "../node_modules/@earendil-works/pi-tui/dist/keys.js"))' "$(command -v pi)")"
node -e 'const fs=require("fs"),file=process.argv[1],base="const KITTY_FUNCTIONAL_KEY_BASE = 0xe000;",needle="    effectiveCodepoint = normalizeKittyFunctionalCodepoint(effectiveCodepoint);"; let source=fs.readFileSync(file,"utf8"); if (!source.includes(base)) { if (!source.includes(needle)) throw new Error(`Unsupported pi-tui keys.js: ${file}`); source=source.replace("const KITTY_PRINTABLE_ALLOWED_MODIFIERS = MODIFIERS.shift | LOCK_MASK;", `const KITTY_PRINTABLE_ALLOWED_MODIFIERS = MODIFIERS.shift | LOCK_MASK;\n${base}`).replace(needle, `${needle}\n    if (effectiveCodepoint >= KITTY_FUNCTIONAL_KEY_BASE)\n        return undefined;`); fs.writeFileSync(file,source); }' "$PI_KEYS"
