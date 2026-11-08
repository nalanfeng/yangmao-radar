import json, re, os, urllib.request, xml.etree.ElementTree as ET, hashlib, datetime
FEEDS = {
 "NodeSeek": "https://rss.nodeseek.com/",
 "LowEndTalk": "https://lowendtalk.com/categories/offers/feed.rss",
 "V2EX交易": "https://www.v2ex.com/feed/tab/deals.xml",
}
KW = re.compile(r"(免费\s*(的)?\s*(vps|服务器|云服务器|云机|主机|小鸡|机器|容器|vds)|白嫖|永久免费|免绑卡|不绑卡|无需(信用)?卡|不用绑卡|free\s+(vps|vds|server|cloud server|hosting|instance|container)|no credit card|without (a )?credit card|no card required|always[- ]free|\$0(\.00)?\s*/\s*(mo|month|yr|year))", re.I)
HOST = re.compile(r"(vps|服务器|云机|主机|server|hosting|instance|容器|vds|compute|cloud|独服|机器)", re.I)
SEEN = "seen.json"
BOOT = not os.path.exists(SEEN)
seen = set(json.load(open(SEEN))) if not BOOT else set()
hits = []
for src, url in FEEDS.items():
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 yangmao-radar"})
        root = ET.fromstring(urllib.request.urlopen(req, timeout=20).read())
    except Exception as e:
        print("feed fail", src, e); continue
    items = root.findall(".//item") or root.findall(".//{http://www.w3.org/2005/Atom}entry")
    for it in items:
        g = lambda t: (it.findtext(t) or it.findtext("{http://www.w3.org/2005/Atom}" + t) or "")
        title = g("title").strip()
        link = g("link").strip()
        if not link:
            l = it.find("{http://www.w3.org/2005/Atom}link"); link = l.get("href") if l is not None else ""
        desc = re.sub("<[^>]+>", " ", g("description") or g("summary") or g("content"))[:600]
        key = hashlib.md5(link.encode()).hexdigest()
        if key in seen: continue
        seen.add(key)
        text = title + " " + desc
        if not BOOT and KW.search(text) and HOST.search(text):
            hits.append({"src": src, "title": title, "link": link, "snippet": desc.strip()[:300]})
json.dump(sorted(seen)[-5000:], open(SEEN, "w"))
with open("hits.jsonl", "a") as f:
    for h in hits:
        h["found_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        f.write(json.dumps(h, ensure_ascii=False) + "\n")
open(os.environ.get("GITHUB_OUTPUT", "/dev/null"), "a").write(f"hits={len(hits)}\n")
json.dump(hits, open("new_hits.json", "w"), ensure_ascii=False)
print(len(hits), "hits")
