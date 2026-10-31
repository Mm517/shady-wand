#!/usr/bin/env bash
# شغّله من جهازك: MCP_TOKEN=التوكن bash test.sh
set -u
BASE="https://cijujqhxdjpvuyzbxedf.supabase.co/functions/v1"
ANON="$(grep -o 'const SUPABASE_ANON_KEY = "[^"]*"' index.html | sed 's/.*= "//;s/"$//')"
: "${MCP_TOKEN:?حط MCP_TOKEN قبل الأمر}"

echo "== 1) generate-prompt"
curl -sS -m 60 -w "\nHTTP %{http_code}\n" -X POST "$BASE/generate-prompt" \
  -H "Content-Type: application/json" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" \
  -d '{"idea":"لوجو لمطعم برجر بطابع كرتوني بحري","platform":"Midjourney / صور","tone":"إبداعي","language":"English"}'

H=(-H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "Authorization: Bearer $MCP_TOKEN")
echo; echo "== 2) mcp initialize"
curl -sS -m 30 -w "\nHTTP %{http_code}\n" -X POST "$BASE/mcp" "${H[@]}" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}'
echo; echo "== 3) mcp tools/list"
curl -sS -m 30 -w "\nHTTP %{http_code}\n" -X POST "$BASE/mcp" "${H[@]}" -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
echo; echo "== 4) mcp tools/call"
curl -sS -m 60 -w "\nHTTP %{http_code}\n" -X POST "$BASE/mcp" "${H[@]}" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"generate_prompt","arguments":{"idea":"صورة لقطة نايمة على سحابة","platform":"Midjourney / صور"}}}'
echo; echo "== 5) mcp بدون توكن (لازم 401)"
curl -sS -m 30 -w "\nHTTP %{http_code}\n" -X POST "$BASE/mcp" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":4,"method":"tools/list"}'
